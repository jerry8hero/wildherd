#!/usr/bin/env python3
"""
对B站发布内容进行3轮迭代优化（普通话风格）
"""

import json
import sys
import urllib.request
import urllib.error
import re
from datetime import datetime
from pathlib import Path

API_ENDPOINT = "https://api.minimaxi.com/anthropic/v1/messages"
API_KEY = "sk-cp-UZAUY_uogMBUAHvjpnPayc1ClIOnCiWPE8vokHl2tGm_Rv55sp-SpHfZGgHgk62jG93k_dYSztm0BL6XvH87DS5Ju-wnNOtjAqVcdueLdQK0w60aQrcK0VE"
API_MODEL = "MiniMax-M2.7"
MAX_TOKENS = 8000

REVIEW_PROMPTS = {
    1: """# 第1轮 Review：开场吸引力评审

你是一位专业的B站视频文案编辑。以下是一篇视频口播文案。请评审开场部分并优化。

## 评审维度

1. **5秒法则**：开头第一句话能否在5秒内抓住观众注意力？
2. **开场类型**：是否使用了痛点共鸣型/场景沉浸型/数据震惊型/情绪调动型中的一种？
3. **钩子效果**：是否有让人想继续看下去的钩子？
4. **代入感**：是否能快速让观众产生共鸣或好奇心？

## 优化要求

- 保持B站风格：年轻、活泼、有梗、接地气
- 开头要有冲击力，用反问/数据/悬念/反转等方式迅速抓住注意力
- 避免千篇一律的"今天来聊xx"模式，要有变化和惊喜
- 保持普通话口语风格
- 不要在文案中添加任何加粗标记、舞台指示或emoji
- 保持文案段落之间用 `---` 分隔的格式

## 输出格式

先给出本轮评分（1-10分）和简短问题列表，然后输出优化后的完整文案。""",

    2: """# 第2轮 Review：叙事结构评审

你是一位专业的B站视频文案编辑。以下是一篇视频口播文案。请评审叙事部分并优化。

## 评审维度

1. **结构清晰度**：是否使用了清单型/故事型/对比型等清晰的叙事结构？
2. **信息密度**：内容是否充实，有无重复啰嗦的地方？
3. **逻辑流畅性**：段落之间过渡是否自然，逻辑是否通顺？
4. **节奏感**：每个段落长短是否适中，观看时是否容易疲劳？
5. **表达技巧**：是否有效使用了比喻、动作描写、网络梗、金句等技巧？

## 优化要求

- 保持B站风格
- 检查是否有冗余表达或重复内容
- 优化叙事节奏，保持观看粘性
- 确保语言生动有趣，避免流水账式叙述
- 多用比喻将抽象概念与现代事物对比
- 不要在文案中添加任何加粗标记、舞台指示或emoji
- 保持文案段落之间用 `---` 分隔的格式

## 输出格式

先给出本轮评分（1-10分）和简短问题列表，然后输出优化后的完整文案。""",

    3: """# 第3轮 Review：结尾互动性评审

你是一位专业的B站视频文案编辑。以下是一篇视频口播文案。请评审结尾部分并优化。

## 评审维度

1. **收尾类型**：是否使用了对比收尾型/顺口溜型/悬念预告型？
2. **三件套完整**：是否包含点赞、投币、收藏的互动引导？
3. **记忆点**：结尾是否有让人记住的核心金句或顺口溜？
4. **互动引导**：是否有效引导观众评论、点赞、投币？
5. **悬念感**：是否留有悬念引导关注下期？

## 优化要求

- 保持B站风格
- 确保结尾有力度，不能虎头蛇尾
- 添加两句式顺口溜（押韵好记，便于记忆传播）
- 三件套（点赞、投币、收藏）表达要自然融入，不生硬
- 下期预告要有悬念感，让观众期待
- 引导评论区互动
- 不要在文案中添加任何加粗标记、舞台指示或emoji
- 保持文案段落之间用 `---` 分隔的格式

## 输出格式

先给出本轮评分（1-10分）和简短问题列表，然后输出优化后的完整文案。"""
}


def call_minimax(content: str, prompt_template: str, round_num: int) -> str:
    """调用 MiniMax API"""
    prompt = f"""{prompt_template}

---

以下是需要评审和优化的视频口播文案：

{content}"""

    data = {
        "model": API_MODEL,
        "max_tokens": MAX_TOKENS,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ]
    }

    req = urllib.request.Request(
        API_ENDPOINT,
        data=json.dumps(data).encode('utf-8'),
        headers={
            'Content-Type': 'application/json',
            'x-api-key': API_KEY,
            'anthropic-version': '2023-06-01'
        },
        method='POST'
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            result = json.loads(response.read().decode('utf-8'))

        if result.get('type') == 'error':
            raise Exception(f"API Error: {result.get('error', {}).get('message', 'Unknown error')}")

        content_list = result.get('content', [])
        for item in content_list:
            if item.get('type') == 'text':
                return item.get('text', '')

        raise Exception("No text response from API")
    except urllib.error.HTTPError as e:
        raise Exception(f"HTTP Error: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        raise Exception(f"URL Error: {e.reason}")


def extract_score(output: str) -> float:
    """提取评分"""
    patterns = [
        r'评分[：:]\s*(\d+(?:\.\d+)?)',
        r'分数[：:]\s*(\d+(?:\.\d+)?)',
        r'Score[：:]\s*(\d+(?:\.\d+)?)',
        r'(\d+(?:\.\d+)?)\s*/\s*10',
        r'(\d+(?:\.\d+)?)\s*分',
    ]

    for pattern in patterns:
        match = re.search(pattern, output, re.IGNORECASE)
        if match:
            try:
                score = float(match.group(1))
                if 0 <= score <= 10:
                    return score
            except ValueError:
                continue
    return 0


def extract_main_content(output: str) -> str:
    """提取优化后的文案"""
    markers = [
        r'##\s*优化后的完整文案',
        r'##\s*完整优化文案',
        r'##\s*优化后完整文案',
        r'##\s*最终优化版',
        r'##\s*最终文案',
        r'以下是优化后的文案',
    ]

    for marker in markers:
        match = re.search(marker, output, re.IGNORECASE)
        if match:
            after = output[match.end():]
            after = re.sub(r'^[\s\n]*[-]{3,}', '', after)
            after = re.sub(r'^[\s\n]*```\w*', '', after)
            lines = after.strip().split('\n')
            cleaned = [l for l in lines if not l.startswith('> ') and l != '>']
            result = '\n'.join(cleaned).strip()
            if len(result) > 100:
                return result

    # 回退：返回去掉引用和加粗的输出
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', output)
    text = re.sub(r'^>\s?', '', text, flags=re.MULTILINE)
    return text.strip()


def postprocess(text: str) -> str:
    """后处理"""
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)
    text = re.sub(r'^>\s?', '', text, flags=re.MULTILINE)
    text = re.sub(r'```\w*\n?', '', text)
    text = re.sub(r'```', '', text)
    text = re.sub(r'[🔥⭐🎯📌💡🎬🚀✅❌🔴🟡🟢🦕🪙👍👆👇❤️‍🔥👀🤔😏😤🫡🧡]', '', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip() + '\n'


def three_round_review(file_path: str) -> dict:
    """执行3轮review"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_len = len(content)
    current_text = content

    print(f"  原文案长度: {len(current_text)} 字符")

    results = []

    for round_num in [1, 2, 3]:
        print(f"    第{round_num}轮 Review...")
        try:
            reviewed = call_minimax(current_text, REVIEW_PROMPTS[round_num], round_num)
            score = extract_score(reviewed)
            print(f"      评分: {score}")

            optimized = extract_main_content(reviewed)
            if len(optimized) > len(current_text) * 0.5 and len(optimized) > 200:
                current_text = optimized
                print(f"      提取到优化文案 ({len(current_text)} 字符)")
            else:
                print(f"      提取失败，保留原文案")

            results.append({"round": round_num, "score": score})

        except Exception as e:
            print(f"      错误: {e}")
            results.append({"round": round_num, "score": 0, "error": str(e)})

    final_text = postprocess(current_text)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(final_text)

    print(f"    最终文案长度: {len(final_text)} 字符")

    return {
        "status": "completed",
        "original_length": original_len,
        "final_length": len(final_text),
        "rounds": results
    }


if __name__ == "__main__":
    file_path = sys.argv[1] if len(sys.argv) > 1 else "/home/bigrice/workspace/github/private/wildherd/docs/video/scripts/火焰龟/01-火焰龟发色指南：养出爆红体色的秘密.md"

    print(f"开始3轮Review: {file_path}")
    print("=" * 50)

    result = three_round_review(file_path)

    print("=" * 50)
    print(f"完成!")
    print(f"  原文长度: {result['original_length']}")
    print(f"  最终长度: {result['final_length']}")
    for r in result['rounds']:
        print(f"  第{r['round']}轮评分: {r['score']}")