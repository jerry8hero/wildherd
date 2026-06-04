#!/usr/bin/env python3
"""
自动化文案Review脚本
对视频文案进行3轮迭代优化（分维度针对性评审）

功能：
1. 评审维度精细化 - 三套 prompt 分别针对开场、叙事、结尾
2. 配置外置化 - config.json + 环境变量管理 API_KEY
3. 评分与报告机制 - 每轮输出评分和问题列表，生成 JSON 报告
4. 健壮性提升 - 失败重试（最多3次）、断点续传
"""

import json
import sys
import argparse
from datetime import datetime
from pathlib import Path

from review_core import ReviewConfig, MiniMaxClient
from state_manager import StateManager

# 兼容平铺文件目录结构的粤语特征字（用于校验提取的优化文案）
CANTONESE_MARKERS = ['嘅', '嘢', '咁', '喔', '喇', '喺', '咗', '佢', '系', '係',
                     '冇', '呢期', '恐龙', '唔', '咗', '哋', '啲', '嘞']


class ReviewReport:
    """Review 报告生成器"""

    def __init__(self):
        self.results = []
        self.start_time = datetime.now()

    def add_result(self, file_path: str, status: str, rounds_data: list = None,
                   error: str = None, original_len: int = 0, final_len: int = 0):
        self.results.append({
            "file_path": file_path,
            "status": status,
            "rounds": rounds_data or [],
            "error": error,
            "original_length": original_len,
            "final_length": final_len,
            "timestamp": datetime.now().isoformat()
        })

    def generate_report(self, output_path: str = None) -> dict:
        """生成汇总报告"""
        if output_path is None:
            output_path = Path(__file__).parent / "state" / f"review_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

        # 计算统计
        total = len(self.results)
        completed = sum(1 for r in self.results if r["status"] == "completed")
        failed = sum(1 for r in self.results if r["status"] == "failed")

        # 计算平均评分
        all_scores = []
        for r in self.results:
            for round_data in r.get("rounds", []):
                if round_data.get("score"):
                    all_scores.append(round_data["score"])

        summary = {
            "total": total,
            "completed": completed,
            "failed": failed,
            "average_score": round(sum(all_scores) / len(all_scores), 1) if all_scores else 0,
            "total_review_rounds": len(all_scores),
            "duration_seconds": (datetime.now() - self.start_time).seconds
        }

        report = {
            "generated_at": datetime.now().isoformat(),
            "summary": summary,
            "files": self.results
        }

        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)

        return report


def load_prompt_template(prompts_dir: Path, filename: str) -> str:
    """加载 Prompt 模板"""
    prompt_path = prompts_dir / filename
    with open(prompt_path, 'r', encoding='utf-8') as f:
        content = f.read()
    # 返回除了最后一行之外的内容（最后一行是提示语）
    lines = content.strip().split('\n')
    return '\n'.join(lines[:-1])


def parse_review_output(output: str, round_num: int) -> dict:
    """解析 Review 输出，提取评分和问题"""
    result = {
        "round": round_num,
        "score": None,
        "issues": [],
        "content": output
    }

    # 尝试提取评分
    import re
    score_patterns = [
        r'评分[：:]\s*[★⭐]?\s*(\d+(?:\.\d+)?)',
        r'分数[：:]\s*(\d+(?:\.\d+)?)',
        r'Score[：:]\s*(\d+(?:\.\d+)?)',
        r'(\d+(?:\.\d+)?)\s*/\s*10',
        r'(\d+(?:\.\d+)?)\s*分',
        r'本轮评分[：:\s]*[★⭐]*\s*(\d+(?:\.\d+)?)',
        r'评分[：:\s]*[★⭐]*\s*(\d+(?:\.\d+)?)',
        r'\*\*(\d+(?:\.\d+)?)\s*/\s*10\*\*',
        r'\*\*(\d+(?:\.\d+)?)\s*分\*\*',
    ]

    for pattern in score_patterns:
        match = re.search(pattern, output, re.IGNORECASE)
        if match:
            try:
                score = float(match.group(1))
                if 0 <= score <= 10:
                    result["score"] = score
                    break
            except ValueError:
                continue

    return result


def extract_main_content(content: str) -> str:
    """提取完整文案内容（整个文件）"""
    return content.strip()


def extract_optimized_text(review_output: str) -> str:
    """从 review 输出中提取优化后的完整文案"""
    import re

    # 策略1: 寻找 "优化后的完整文案" 标记后的内容
    markers = [
        r'##\s*优化后的完整文案',
        r'##\s*完整优化文案',
        r'##\s*优化后完整文案',
        r'##\s*最终优化版',
        r'##\s*最终文案',
        r'优化后的完整文案[：:]',
        r'以下是优化后的完整文案',
    ]

    for marker in markers:
        match = re.search(marker, review_output, re.IGNORECASE)
        if match:
            after = review_output[match.end():]
            after = re.sub(r'^[\s\n]*[-]{3,}', '', after)
            after = re.sub(r'^[\s\n]*```markdown', '', after)
            after = re.sub(r'^[\s\n]*```', '', after)
            after = re.sub(r'```[\s\n]*$', '', after.strip())
            lines = after.strip().split('\n')
            cleaned = []
            for line in lines:
                if line.startswith('> '):
                    line = line[2:]
                elif line == '>':
                    line = ''
                cleaned.append(line)
            result = '\n'.join(cleaned).strip()
            if len(result) > 100:
                return result

    # 策略2: 寻找包含粤语内容的大段文本
    cantonese_markers = [
        '嘅', '嘢', '咁', '喔', '喇', '喺', '咗', '佢', '系', '係',
        '冇', '呢期', '恐龙', '唔', '咗', '哋', '啲', '嘞', '咁',
        '几巴閉', '走宝', '吹吹水', '记得三连', '评论区'
    ]
    blocks = review_output.split('---')

    for i, block in enumerate(blocks):
        block = block.strip()
        if not block:
            continue
        cantonese_count = sum(1 for m in cantonese_markers if m in block)
        if cantonese_count >= 1 and len(block) > 20:
            remaining = '---'.join(blocks[i:])
            lines = remaining.split('\n')
            cleaned = []
            for line in lines:
                if line.startswith('> '):
                    line = line[2:]
                elif line == '>':
                    line = ''
                cleaned.append(line)
            result = '\n'.join(cleaned).strip()
            if len(result) > 100:
                return result

    # 策略3: 回退 - 返回整个输出（让后续处理判断）
    return review_output.strip()


def postprocess_content(text: str, original_content: str) -> str:
    """后处理：清理格式，确保标题存在"""
    import re

    # 去掉所有加粗标记
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)

    # 去掉引用标记
    text = re.sub(r'^>\s?', '', text, flags=re.MULTILINE)

    # 去掉代码块标记
    text = re.sub(r'```\w*\n?', '', text)
    text = re.sub(r'```', '', text)

    # 去掉 emoji（保留几巴閉中的文字）
    text = re.sub(r'[🔥⭐🎯📌💡🎬🚀✅❌🔴🟡🟢🦕🪙👍👆👇❤️‍🔥👀🤔😏😤🫡]', '', text)

    # 确保有标题行
    if not text.startswith('# '):
        # 从原文提取标题
        orig_title_match = re.match(r'# (.+)', original_content)
        if orig_title_match:
            title = orig_title_match.group(1)
            # 去掉可能重复的标题
            text = f'# {title}\n\n---\n\n{text}'

    # 清理多余空行（最多保留一个空行）
    text = re.sub(r'\n{3,}', '\n\n', text)

    # 确保以换行结尾
    text = text.strip() + '\n'

    return text


def reassemble_content(original_content: str, optimized_content: str) -> str:
    """直接返回优化后的完整文案"""
    return optimized_content


def three_round_review(file_path: str, config: ReviewConfig, client: MiniMaxClient,
                       prompt_prefix: str = "", min_cantonese: int = 3,
                       min_length_ratio: float = 0.6, start_round: int = 1) -> dict:
    """对单个文件进行3轮Review，返回结果详情

    start_round: 从第几轮开始（1/2/3），用于断点续传单轮
    """
    result = {
        "file_path": file_path,
        "status": "in_progress",
        "rounds": [],
        "error": None
    }

    print(f"  处理文件: {file_path}")

    # 加载 prompt 模板（支持前缀，例如 round1_opening_turtle.md）
    r1_name = f"round1_opening{prompt_prefix}.md"
    r2_name = f"round2_narrative{prompt_prefix}.md"
    r3_name = f"round3_ending{prompt_prefix}.md"
    prompt_r1 = load_prompt_template(config.prompts_dir, r1_name)
    prompt_r2 = load_prompt_template(config.prompts_dir, r2_name)
    prompt_r3 = load_prompt_template(config.prompts_dir, r3_name)

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        original_len = len(content)
        original_content = extract_main_content(content)

        print(f"    原文案长度: {len(original_content)} 字符")
        if start_round > 1:
            print(f"    ⏩ 跳过前 {start_round - 1} 轮，直接以当前文件作为输入")

        # 当前最优文案（每轮在此基础上优化）
        current_text = original_content

        # 第1轮Review - 开场
        if start_round <= 1:
            print(f"    第1轮Review（开场）...")
            reviewed_1 = client.call(current_text, prompt_r1, 1)
            parsed_1 = parse_review_output(reviewed_1, 1)
            result["rounds"].append(parsed_1)
            print(f"      评分: {parsed_1.get('score', 'N/A')}")

            # 从第1轮输出中提取优化后的文案
            optimized_1 = extract_optimized_text(reviewed_1)
            # 验证提取的文案质量（可配置粤语阈值和长度比例）
            cantonese_count = sum(1 for m in CANTONESE_MARKERS if m in optimized_1)
            if (min_cantonese == 0 or cantonese_count >= min_cantonese) and \
                    len(optimized_1) > len(original_content) * min_length_ratio:
                current_text = optimized_1
                print(f"      提取到优化文案 ({len(current_text)} 字符)")
            else:
                print(f"      提取失败，保留原文案")

        # 第2轮Review - 叙事
        if start_round <= 2:
            print(f"    第2轮Review（叙事）...")
            reviewed_2 = client.call(current_text, prompt_r2, 2)
            parsed_2 = parse_review_output(reviewed_2, 2)
            result["rounds"].append(parsed_2)
            print(f"      评分: {parsed_2.get('score', 'N/A')}")

            # 从第2轮输出中提取优化后的文案
            optimized_2 = extract_optimized_text(reviewed_2)
            cantonese_count = sum(1 for m in CANTONESE_MARKERS if m in optimized_2)
            if (min_cantonese == 0 or cantonese_count >= min_cantonese) and \
                    len(optimized_2) > len(original_content) * min_length_ratio:
                current_text = optimized_2
                print(f"      提取到优化文案 ({len(current_text)} 字符)")
            else:
                print(f"      提取失败，保留上一轮文案")

        # 第3轮Review - 结尾
        print(f"    第3轮Review（结尾）...")
        reviewed_3 = client.call(current_text, prompt_r3, 3)
        parsed_3 = parse_review_output(reviewed_3, 3)
        result["rounds"].append(parsed_3)
        print(f"      评分: {parsed_3.get('score', 'N/A')}")

        # 从第3轮输出中提取优化后的文案
        optimized_3 = extract_optimized_text(reviewed_3)
        cantonese_count = sum(1 for m in CANTONESE_MARKERS if m in optimized_3)
        if (min_cantonese == 0 or cantonese_count >= min_cantonese) and \
                len(optimized_3) > len(current_text) * min_length_ratio:
            final_text = optimized_3
            print(f"      提取到优化文案 ({len(final_text)} 字符)")
        else:
            final_text = current_text
            print(f"      提取失败，保留上一轮文案")

        print(f"    最终文案长度: {len(final_text)} 字符")

        # 保存优化后的文案
        final_text = postprocess_content(final_text, original_content)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(final_text)

        result["status"] = "completed"
        result["original_length"] = original_len
        result["final_length"] = len(final_text)
        print(f"    ✓ 完成")

    except Exception as e:
        result["status"] = "failed"
        result["error"] = str(e)
        print(f"    ✗ 错误: {e}")

    return result


def process_directory(base_dir: str, start_num: int = 2, end_num: int = 101,
                      config: ReviewConfig = None, client: MiniMaxClient = None,
                      state_mgr: StateManager = None, report: ReviewReport = None,
                      flat: bool = False, prompt_prefix: str = "",
                      min_cantonese: int = 3, min_length_ratio: float = 0.6,
                      start_round: int = 1):
    """处理目录下的所有视频文案文件

    flat=False（默认）：base_dir 下是子目录结构，{num}-标题/子目录/*.md
    flat=True：base_dir 下平铺 .md 文件，{num}-标题.md
    """
    base_path = Path(base_dir)

    for num in range(start_num, end_num + 1):
        num_str = f"{num:03d}"

        file_path = None

        if flat:
            # 平铺模式：依次尝试 005-*.md / 05-*.md / 5-*.md
            matching_files = []
            for pat in (f"{num_str}-*.md", f"{num:02d}-*.md", f"{num}-*.md"):
                matching_files = sorted(base_path.glob(pat))
                if matching_files:
                    break
            if not matching_files:
                print(f"跳过 {num_str}: 未找到匹配文件")
                continue
            file_path = str(matching_files[0])
        else:
            # 原始模式：依次尝试 005-*/ 05-*/ 5-*/
            matching_dirs = []
            for pat in (f"{num_str}-*", f"{num:02d}-*", f"{num}-*"):
                matching_dirs = list(base_path.glob(pat))
                if matching_dirs:
                    break
            if not matching_dirs:
                print(f"跳过 {num_str}: 未找到对应目录")
                continue

            dir_path = matching_dirs[0]
            if not dir_path.is_dir():
                # 可能是文件，不是目录，平铺模式
                if dir_path.is_file() and dir_path.suffix == ".md":
                    file_path = str(dir_path)
                else:
                    continue
            else:
                # 查找markdown文件
                md_files = list(dir_path.glob("*.md"))
                if not md_files:
                    print(f"跳过 {num_str}: 目录中无md文件")
                    continue
                file_path = str(md_files[0])

        if not file_path:
            continue

        # 检查是否已完成（断点续传）
        if state_mgr.is_completed(file_path):
            print(f"跳过 {num_str}: 已完成处理")
            continue

        # 标记为进行中
        state_mgr.save_state(file_path, "in_progress")

        # 执行3轮review
        result = three_round_review(
            file_path, config, client,
            prompt_prefix=prompt_prefix,
            min_cantonese=min_cantonese,
            min_length_ratio=min_length_ratio,
            start_round=start_round,
        )

        # 更新状态
        state_mgr.save_state(
            file_path,
            result["status"],
            rounds_data=result.get("rounds"),
            error=result.get("error")
        )

        # 添加到报告
        report.add_result(
            file_path,
            result["status"],
            rounds_data=result.get("rounds"),
            error=result.get("error"),
            original_len=result.get("original_length", 0),
            final_len=result.get("final_length", 0)
        )


def main():
    # 加载配置
    try:
        config = ReviewConfig()
    except FileNotFoundError as e:
        print(f"配置文件未找到: {e}")
        print("请确保 config.json 存在，或复制 .env.example 为 .env 并填入 API_KEY")
        sys.exit(1)
    except ValueError as e:
        print(f"配置错误: {e}")
        print("请确保设置了 MINIMAX_API_KEY 环境变量")
        sys.exit(1)

    # 初始化组件
    client = MiniMaxClient(config)
    state_mgr = StateManager(str(config.state_dir))
    report = ReviewReport()

    # 解析命令行参数：兼容位置参数 + 新可选标志
    parser = argparse.ArgumentParser(
        description="视频文案 3 轮自动 Review（开场/叙事/结尾）"
    )
    parser.add_argument("start", nargs="?", type=int, default=None,
                        help="起始编号（兼容旧用法）")
    parser.add_argument("end", nargs="?", type=int, default=None,
                        help="结束编号（兼容旧用法）")
    parser.add_argument("sub_dir", nargs="?", default=None,
                        help="子目录名（兼容旧用法）")
    parser.add_argument("--prompt-prefix", default="",
                        help='prompt 文件名前缀（如 _turtle → round1_opening_turtle.md）')
    parser.add_argument("--flat", action="store_true",
                        help="平铺文件目录结构（无子目录，.md 直接在子目录下）")
    parser.add_argument("--min-cantonese", type=int, default=3,
                        help="粤语特征字阈值，0 = 跳过粤语校验（普通话脚本用）")
    parser.add_argument("--min-length-ratio", type=float, default=0.6,
                        help="优化文案最小长度比例（相对原文）")
    parser.add_argument("--start-round", type=int, default=1, choices=[1, 2, 3],
                        help="从第几轮开始（1=完整跑；2=跳过开场；3=只跑结尾）")
    parser.add_argument("--force", action="store_true",
                        help="忽略已完成状态，强制重跑")
    args = parser.parse_args()

    # 起始/结束编号
    if args.start is not None:
        start = args.start
        end = args.end if args.end is not None else start
    else:
        start = config.default_start
        end = config.default_end

    base_dir = config.scripts_base
    if args.sub_dir:
        base_dir = Path(base_dir) / args.sub_dir
    else:
        base_dir = Path(base_dir)

    print(f"开始处理: {start:03d} - {end:03d}")
    print(f"目录: {base_dir}")
    if args.prompt_prefix:
        print(f"Prompt 前缀: {args.prompt_prefix}")
    if args.flat:
        print(f"目录模式: 平铺（flat）")
    if args.start_round > 1:
        print(f"⏩ 起始轮次: {args.start_round}（跳过前 {args.start_round - 1} 轮）")
    print("=" * 50)

    process_directory(
        str(base_dir), start, end,
        config=config,
        client=client,
        state_mgr=state_mgr,
        report=report,
        flat=args.flat,
        prompt_prefix=args.prompt_prefix,
        min_cantonese=args.min_cantonese,
        min_length_ratio=args.min_length_ratio,
        start_round=args.start_round,
    )

    print("=" * 50)

    # 生成报告
    report_path = Path(config.state_dir) / f"review_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    summary = report.generate_report(str(report_path))
    print(f"处理完成!")
    print(f"  总文件数: {summary['summary']['total']}")
    print(f"  完成: {summary['summary']['completed']}")
    print(f"  失败: {summary['summary']['failed']}")
    print(f"  平均评分: {summary['summary']['average_score']}")
    print(f"报告已保存: {report_path}")


if __name__ == "__main__":
    main()