#!/usr/bin/env python3
"""对普通话版做第 2、3 轮 review"""

import json
import re
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "review"))

from review_core import ReviewConfig, MiniMaxClient

TARGET = Path("/home/bigrice/workspace/github/private/wildherd/docs/video/scripts/龟类对比/04-不同品种龟的价格大对比.md")
LOG = Path("/home/bigrice/workspace/github/private/wildherd/tools/review/state/putonghua_review_04.json")

PROMPT_R2 = """# 第 2 轮 Review：普通话版叙事结构评审

你是 B 站爬宠科普视频的普通话文案编辑。**以下文案刚由粤语版转换而来**，请评审并修正。

## 评审维度

1. **专有名词保真度**：龟圈品种名（草龟、火焰龟、剃刀龟、钻纹龟、白巴、金士百、金钻、银金、台缘、安缘、黄缘）**不许意译或改名**。例如"金士百"是"Gold Standard"的音译，**绝对不能改成"焦糖"**——这是品种名不是颜色描述。
2. **结构清晰度**：6 站结构是否清晰，对比型叙事是否有效？
3. **信息密度**：每站信息是否充实，有无重复啰嗦？
4. **节奏感**：段段长短是否适中，避免观众疲劳？
5. **比喻与梗**：B 站风格保留（"还要什么自行车""花小钱办大事"等）

## 优化要求

- 保持普通话口语风格（北方官话，避免"甭""咋"等过方言语）
- 检查并修正任何"粤语残留"（嘅/咁/唔/啲/嚟/冇 等字）
- 修正品种名误译
- 多用比喻将抽象概念与现代事物对比
- 不要加粗、不要 emoji、不要舞台指示
- 保持文案段落之间用 `---` 分隔的格式
- 段头金句"平民战神/丑小鸭逆袭/冷淡美人/品相税活教材/色彩经济学活教材/价格天花板"是上一轮粤语版就设计好的，可以保留

## 输出格式

先给出本轮评分（1-10分）和简短问题列表（特别指出是否有品种名误译、粤语残留），然后输出优化后的完整文案（从 # 标题行开始，不要代码块包裹）。
"""

PROMPT_R3 = """# 第 3 轮 Review：普通话版结尾互动性评审

你是 B 站爬宠科普视频的普通话文案编辑。**以下文案是普通话版的第 2 轮优化结果**，请评审结尾部分。

## 评审维度

1. **收尾类型**：对比收尾型 / 顺口溜型 / 悬念预告型？是否组合使用？
2. **三件套完整**：点赞、投币、收藏的引导是否自然融入？
3. **记忆点**：六行口诀是否押韵好记？"黄缘万金坐头把交椅"这种收尾是否有力？
4. **互动引导**：最后的"性价比之王是哪只"互动话题是否能激发评论？
5. **悬念感**：是否需要补一个"下期预告"（如"新手养龟最容易踩的5个坑"）？原粤语版有但本轮转换时被简化掉了。
6. **粤语残留检查**：结尾段是否还有"嘅/咁/唔/啲"等粤语字？

## 优化要求

- 保持 B 站风格
- 顺口溜保持押韵好记
- 三件套表达自然不生硬
- 引导评论 + 引导关注
- **强烈建议补回"下期预告"小段**，让结尾有"未完待续"的悬念
- 不要加粗、不要 emoji、不要舞台指示
- 保持文案段落之间用 `---` 分隔的格式

## 输出格式

先给出本轮评分（1-10分）和简短问题列表，然后输出**完整优化后的文案**（从 # 标题行开始，覆盖全篇，不只是结尾段）。
"""


def call_with_retry(client, content, prompt, round_num, max_retry=5):
    last_error = None
    for attempt in range(max_retry):
        try:
            return client.call(content, prompt, round_num)
        except Exception as e:
            last_error = str(e)
            print(f"  尝试 {attempt+1}/{max_retry} 失败: {e}")
            time.sleep(3)
    raise Exception(f"Failed after {max_retry} attempts: {last_error}")


def extract_manuscript(output: str) -> str:
    m = re.search(r'#\s*不同品种龟[^\n]*\n[\s\S]*$', output)
    if m:
        text = m.group(0)
    else:
        text = output
    text = re.sub(r'```[a-zA-Z]*\n?', '', text)
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


def extract_score(output):
    patterns = [
        r'评分[：:]\s*[★⭐]?\s*(\d+(?:\.\d+)?)',
        r'分数[：:]\s*(\d+(?:\.\d+)?)',
        r'\*\*(\d+(?:\.\d+)?)\s*/\s*10\*\*',
        r'(\d+(?:\.\d+)?)\s*/\s*10',
    ]
    for p in patterns:
        m = re.search(p, output, re.IGNORECASE)
        if m:
            try:
                return float(m.group(1))
            except ValueError:
                pass
    return None


def main():
    config = ReviewConfig()
    client = MiniMaxClient(config)

    with open(TARGET, 'r', encoding='utf-8') as f:
        current = f.read()

    rounds_log = []
    prompt_files = [PROMPT_R2, PROMPT_R3]
    titles = ["普通话叙事", "普通话结尾"]
    start_round = 1

    for i, (prompt, title) in enumerate(zip(prompt_files, titles), 2):
        print(f"\n========== 第 {i} 轮 Review ({title}) ==========")
        try:
            output = call_with_retry(client, current, prompt, i)
        except Exception as e:
            print(f"第 {i} 轮失败: {e}")
            break

        score = extract_score(output)
        print(f"评分: {score}")
        print(f"前 500 字:\n{output[:500]}\n...")

        optimized = postprocess(extract_manuscript(output))
        if len(optimized) > 200:
            current = optimized
            print(f"提取到优化文案 ({len(current)} 字符)")

        rounds_log.append({
            "round": i, "title": title, "score": score,
            "output": output, "optimized_text": current,
        })

        with open(LOG, 'w', encoding='utf-8') as f:
            json.dump({"file": str(TARGET), "rounds": rounds_log, "current_text": current},
                      f, ensure_ascii=False, indent=2)

    print(f"\n========== 最终文案 ({len(current)} 字符) ==========")
    print(current)


if __name__ == "__main__":
    main()
