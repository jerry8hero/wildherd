#!/usr/bin/env python3
"""
第四册-无脊椎动物 文案 3轮自动化 Review

与 auto_review.py 的区别：
- 不按 --- 分割，发送完整文案给 API
- 路径适配当前环境
- endpoint 拼接修正
"""

import json
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

import yaml

# 禁用输出缓冲
sys.stdout.reconfigure(line_buffering=True)
sys.stderr.reconfigure(line_buffering=True)

SCRIPTS_DIR = Path("/home/pi/workspace/github/private/wildherd/docs/video/scripts/冷到你唔信/第四册-无脊椎动物")
PROMPTS_DIR = Path(__file__).parent / "prompts"
STATE_DIR = Path(__file__).parent / "state" / "volume4"
REPORT_PATH = Path(__file__).parent / "state" / f"volume4_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

RETRY_TIMES = 3
RETRY_DELAY = 5
API_TIMEOUT = 120
MAX_TOKENS = 8000


def get_api_config():
    result = subprocess.run(
        ["x", "minimax", "--cfg", "cat"],
        capture_output=True, text=True, timeout=10,
    )
    if result.returncode != 0:
        raise RuntimeError(f"获取 minimax 配置失败: {result.stderr}")
    cfg = yaml.safe_load(result.stdout)
    profile = cfg.get("profile", [{}])[0]
    api_key = profile.get("codingplan", {}).get("apikey", "")
    model = profile.get("model", "MiniMax-M2.2")
    endpoint = "https://api.minimaxi.com/anthropic/v1/messages"
    if not api_key:
        raise ValueError("API key 为空")
    return api_key, model, endpoint


def load_prompt(filename: str) -> str:
    content = (PROMPTS_DIR / filename).read_text(encoding="utf-8").strip()
    lines = content.split("\n")
    return "\n".join(lines[:-1])


def call_api(api_key, model, endpoint, content, prompt_template):
    prompt = f"{prompt_template}\n\nreview 并修改以下文案，直接输出完整修改版：\n\n{content}"
    data = {
        "model": model,
        "max_tokens": MAX_TOKENS,
        "messages": [{"role": "user", "content": prompt}],
    }
    body = json.dumps(data).encode("utf-8")
    headers = {
        "Content-Type": "application/json",
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01",
    }

    for attempt in range(RETRY_TIMES):
        try:
            req = urllib.request.Request(endpoint, data=body, headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=API_TIMEOUT) as resp:
                result = json.loads(resp.read().decode("utf-8"))
            for item in result.get("content", []):
                if item.get("type") == "text":
                    return item.get("text", "")
            raise RuntimeError("API 未返回文本")
        except (urllib.error.HTTPError, urllib.error.URLError) as e:
            print(f"      重试 {attempt + 1}/{RETRY_TIMES}: {e}")
            if attempt < RETRY_TIMES - 1:
                time.sleep(RETRY_DELAY)
            else:
                raise


def parse_score(text):
    for p in [r"评分[：:]\s*(\d+)", r"(\d+)\s*/\s*10", r"(\d+)\s*分"]:
        m = re.search(p, text)
        if m:
            return int(m.group(1))
    return None


def review_file(file_path, api_key, model, endpoint):
    content = file_path.read_text(encoding="utf-8")
    original_len = len(content)

    prompts = [
        ("开场", load_prompt("round1_opening.md")),
        ("叙事", load_prompt("round2_narrative.md")),
        ("结尾", load_prompt("round3_ending.md")),
    ]

    current = content
    rounds_data = []
    for label, prompt in prompts:
        print(f"    第{rounds_data.__len__() + 1}轮 ({label})...")
        current = call_api(api_key, model, endpoint, current, prompt)
        score = parse_score(current)
        print(f"      评分: {score or 'N/A'}")
        rounds_data.append({"label": label, "score": score})

    file_path.write_text(current, encoding="utf-8")
    print(f"    {original_len} → {len(current)} 字符 ✓")
    return {"rounds": rounds_data, "original_len": original_len, "final_len": len(current)}


def main():
    api_key, model, endpoint = get_api_config()
    print(f"模型: {model}")
    STATE_DIR.mkdir(parents=True, exist_ok=True)

    dirs = sorted(SCRIPTS_DIR.glob("[0-9][0-9][0-9]-*"))
    print(f"找到 {len(dirs)} 个文案目录")
    print("=" * 60)

    results = []
    for i, dir_path in enumerate(dirs, 1):
        md_files = list(dir_path.glob("*.md"))
        if not md_files:
            continue

        file_path = md_files[0]
        state_file = STATE_DIR / f"{dir_path.name}.done"

        if state_file.exists():
            print(f"  [{i}/{len(dirs)}] 跳过 {dir_path.name}")
            continue

        print(f"  [{i}/{len(dirs)}] {dir_path.name}")
        state_file.write_text("in_progress", encoding="utf-8")

        try:
            info = review_file(file_path, api_key, model, endpoint)
            state_file.write_text("completed", encoding="utf-8")
            results.append({"file": dir_path.name, "status": "completed", **info})
        except Exception as e:
            state_file.write_text(f"failed: {e}", encoding="utf-8")
            print(f"    ✗ 失败: {e}")
            results.append({"file": dir_path.name, "status": "failed", "error": str(e)})

    print("=" * 60)

    completed = sum(1 for r in results if r["status"] == "completed")
    failed = sum(1 for r in results if r["status"] == "failed")
    scores = [rd["score"] for r in results if r["status"] == "completed" for rd in r.get("rounds", []) if rd.get("score")]
    avg_score = round(sum(scores) / len(scores), 1) if scores else 0

    report = {
        "generated_at": datetime.now().isoformat(),
        "summary": {"total": len(results), "completed": completed, "failed": failed, "avg_score": avg_score},
        "files": results,
    }

    STATE_DIR.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"完成: {completed} | 失败: {failed} | 平均分: {avg_score}")
    print(f"报告: {REPORT_PATH}")


if __name__ == "__main__":
    main()
