#!/usr/bin/env python3
"""粤语文案 → 普通话 B 站风格转换（保留所有合规修订与互动设计）"""

import json
import re
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "review"))

from review_core import ReviewConfig, MiniMaxClient

TARGET = Path("/home/bigrice/workspace/github/private/wildherd/docs/video/scripts/龟类对比/04-不同品种龟的价格大对比.md")
LOG = Path("/home/bigrice/workspace/github/private/wildherd/tools/review/state/putonghua_convert_04.json")

CONVERT_PROMPT = """# 任务：粤语文案 → 普通话 B 站风格转换

你是一位 B 站爬宠科普视频的普通话文案编辑。请把以下**粤语文案**完整转换为**普通话 B 站口播风格**，目标是**扩大受众面**（普通话用户在 B 站占绝大多数）。

## 转换规则

### 1. 必须保留的合规修订（不许改动或弱化）
- **黄缘段**："野生黄缘系国家二级保护动物，千祈唔好掂" → "**野生黄缘是国家二级保护动物，千万别碰**"
  "市面上合法流通嘅都系人工繁育嘅，购买时一定要认准合法来源证明同专用标识" → "**市面上合法流通的都是人工繁育的，购买时一定要认准合法来源证明和专用标识**"
- **变异巴西段**：必须保留"**外来入侵物种，千万别放生**"的提示
- **黄缘金融属性弱化**："升值潜力/传落去" → 必须用"灵性强/当传家宝"等文化属性表达，不许出现"升值""投资""理财"等字眼

### 2. 必须保留的互动与节奏设计
- 开场数据震惊 + 反问钩子（"5块到5万，差距你猜不到多远"）
- 每只龟的"反差金句"（平民战神/丑小鸭逆袭/冷淡美人/品相税活教材/色彩经济学活教材/价格天花板）
- 钻纹段"避开温室速生苗"新手避坑干货
- 剃刀段"智商税 vs 极简美学"正反辩论
- 结尾六行口诀
- 三件套（点赞、投币、收藏）

### 3. 转换细节
- 粤语字 → 普通话：嘅→的、咁→这样/那么、唔→不、啲→点/些、嚟→来、冇→没、咗→了、睇→看、系→是、喺→在、咩→什么、咗→了、嗰→那、嚿→块、仲→还、畀→给、㗎→的、咪→不、唔好→不要、仲要→还要
- 保留 B 站风格：年轻、活泼、有梗、接地气
- 句式可以更书面化一些（普通话观众接受度更高）
- 比喻保留：T台模特/天然大理石/工地佬等
- **不要加粗、不要 emoji、不要舞台指示**
- 段落之间用 `---` 分隔

## 输出格式

**直接输出完整的普通话版文案**（从 # 标题行开始），不要评审意见，不要前后说明文字，不要 markdown 代码块包裹。
"""


def call_with_retry(client, content, prompt, max_retry=5):
    last_error = None
    for attempt in range(max_retry):
        try:
            return client.call(content, prompt, 1)
        except Exception as e:
            last_error = str(e)
            print(f"  尝试 {attempt+1}/{max_retry} 失败: {e}")
            time.sleep(3)
    raise Exception(f"Failed after {max_retry} attempts: {last_error}")


def extract_manuscript(output: str) -> str:
    """提取完整普通话文案"""
    # 策略 1: 找 # 标题行
    m = re.search(r'#\s*不同品种龟[^\n]*\n[\s\S]*$', output)
    if m:
        text = m.group(0)
        text = re.sub(r'```[a-zA-Z]*\n?', '', text)
        text = re.sub(r'```', '', text)
        text = re.sub(r'^>\s?', '', text, flags=re.MULTILINE)
        return text.strip()
    # 策略 2: 兜底
    text = re.sub(r'```[a-zA-Z]*\n?', '', output)
    text = re.sub(r'```', '', text)
    text = re.sub(r'^>\s?', '', text, flags=re.MULTILINE)
    return text.strip()


def postprocess(text: str) -> str:
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)
    text = re.sub(r'^>\s?', '', text, flags=re.MULTILINE)
    text = re.sub(r'```[a-zA-Z]*\n?', '', text)
    text = re.sub(r'```', '', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip() + '\n'


def main():
    config = ReviewConfig()
    client = MiniMaxClient(config)

    with open(TARGET, 'r', encoding='utf-8') as f:
        cantonese = f.read()

    print(f"原文长度: {len(cantonese)} 字符")
    print("调用 API 进行粤语→普通话转换...")

    output = call_with_retry(client, cantonese, CONVERT_PROMPT)
    print(f"API 返回长度: {len(output)} 字符")

    converted = postprocess(extract_manuscript(output))
    print(f"提取后长度: {len(converted)} 字符")

    with open(LOG, 'w', encoding='utf-8') as f:
        json.dump({
            "file": str(TARGET),
            "cantonese_len": len(cantonese),
            "converted_text": converted,
            "raw_output": output,
        }, f, ensure_ascii=False, indent=2)
    print(f"已保存到 {LOG}")

    print(f"\n========== 转换结果 ==========")
    print(converted)


if __name__ == "__main__":
    main()
