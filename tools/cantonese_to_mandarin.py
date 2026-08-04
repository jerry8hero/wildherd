#!/usr/bin/env python3
"""
粤语转国语转换工具（优化版）
将粤语视频文案转换成国语版本

使用方法：
    # 转换单个文件
    python3 tools/cantonese_to_mandarin.py input.md -o output.md

    # 批量转换目录
    python3 tools/cantonese_to_mandarin.py --dir docs/video/scripts/冷到你唔信/第六册-爬行动物

    # 预览转换（不写入文件）
    python3 tools/cantonese_to_mandarin.py input.md --preview
"""

import re
import sys
import argparse
from pathlib import Path
from typing import List, Tuple

# 粤语 → 国语 转换规则（按优先级排列）
# 规则格式：(粤语模式, 替换函数/字符串, 说明)
# 使用正则表达式进行更智能的替换

def create_converter(context: str = "animal"):
    """
    创建转换器

    Args:
        context: 上下文类型（animal=动物, person=人物, general=通用）
    """
    # 根据上下文确定代词
    if context == "animal":
        ta = "它"
        ta_plural = "它们"
        ta_possessive = "它的"
    elif context == "person":
        ta = "他/她"
        ta_plural = "他们/她们"
        ta_possessive = "他/她的"
    else:
        ta = "他/她/它"
        ta_plural = "他们/她们/它们"
        ta_possessive = "他/她/它的"

    # 转换规则（按优先级排列，先匹配先替换）
    rules = [
        # === 第一优先级：核心语法词 ===

        # 代词
        (r'佢哋', ta_plural),
        (r'佢嘅', ta_possessive),
        (r'佢', ta),
        (r'我哋', '我们'),
        (r'你哋', '你们'),

        # 否定词
        (r'唔係', '不是'),
        (r'唔单止', '不仅'),
        (r'唔好', '不要'),
        (r'唔使', '不用'),
        (r'唔知', '不知道'),
        (r'唔够', '不够'),
        (r'唔信', '不信'),
        (r'唔理', '不管'),
        (r'唔怕', '不怕'),
        (r'唔讲', '不说'),
        (r'唔係咁', '不是这样'),
        (r'唔係话', '不是说'),
        (r'唔係净系', '不是只'),
        (r'唔', '不'),
        (r'冇', '没有'),

        # 指示代词
        (r'呢个', '这个'),
        (r'呢只', '这只'),
        (r'呢种', '这种'),
        (r'呢度', '这里'),
        (r'呢边', '这边'),
        (r'呢', '这'),
        (r'嗰个', '那个'),
        (r'嗰只', '那只'),
        (r'嗰种', '那种'),
        (r'嗰度', '那里'),
        (r'嗰边', '那边'),
        (r'嗰', '那'),

        # 系动词
        (r'係', '是'),

        # 助词
        (r'嘅', '的'),
        (r'喺', '在'),
        (r'畀', '被'),
        (r'俾', '被'),
        (r'咗', '了'),
        (r'嘅话', '的话'),
        (r'嘅时候', '的时候'),

        # === 第二优先级：高频词汇 ===

        # 时间词
        (r'依家', '现在'),
        (r'而家', '现在'),
        (r'啱啱', '刚刚'),
        (r'先至', '才'),
        (r'仲', '还'),

        # 程度副词
        (r'真係', '真是'),
        (r'好', '很'),
        (r'几', '很'),
        (r'劲', '厉害'),
        (r'犀利', '厉害'),
        (r'巴闭', '厉害'),
        (r'得人惊', '吓人'),

        # 疑问词
        (r'点解', '为什么'),
        (r'点样', '怎么样'),
        (r'几时', '什么时候'),
        (r'几多', '多少'),
        (r'边个', '哪个'),
        (r'边度', '哪里'),
        (r'做乜', '干什么'),
        (r'做咩', '干什么'),
        (r'咩', '什么'),

        # 动词
        (r'睇', '看'),
        (r'讲', '说'),
        (r'谂', '想'),
        (r'諗', '想'),
        (r'食', '吃'),
        (r'饮', '喝'),
        (r'行', '走'),
        (r'企', '站'),
        (r'瞓', '睡'),
        (r'攞', '拿'),
        (r'揾', '找'),
        (r'识', '会'),
        (r'得', '能'),
        (r'钟意', '喜欢'),
        (r'中意', '喜欢'),
        (r'憎', '讨厌'),

        # 形容词
        (r'得意', '有趣'),
        (r'正', '好'),
        (r'靓', '漂亮'),
        (r'细', '小'),
        (r'大只', '强壮'),

        # 名词
        (r'屋企', '家'),
        (r'细蚊仔', '小孩'),
        (r'BB', '宝宝'),
        (r'后生', '年轻'),
        (r'老人家', '老人'),

        # 连词
        (r'但係', '但是'),
        (r'不过', '不过'),
        (r'因为', '因为'),
        (r'所以', '所以'),
        (r'如果', '如果'),
        (r'虽然', '虽然'),
        (r'而且', '而且'),
        (r'或者', '或者'),

        # 其他
        (r'其实', '其实'),
        (r'可能', '可能'),
        (r'应该', '应该'),
        (r'一定', '一定'),
        (r'肯定', '肯定'),
        (r'完全', '完全'),
        (r'绝对', '绝对'),
        (r'非常', '非常'),
        (r'超级', '超级'),
        (r'特别', '特别'),

        # 粤语特色表达
        (r'嘥气', '白费力气'),
        (r'搏命', '拼命'),
        (r'搞事', '搞事情'),
        (r'搞鬼', '捣鬼'),
        (r'出事', '出事'),
        (r'冇事', '没事'),
        (r'好彩', '幸运'),
        (r'唔讲唔知', '不说不知道'),
        (r'有冇搞错', '有没有搞错'),
        (r'离谱到你唔信', '离谱到你不信'),
        (r'犀利到你唔信', '厉害到你不信'),
        (r'劲到你唔信', '厉害到你不信'),
        (r'得意到你唔信', '有趣到你不信'),
        (r'好喇', '好了'),
        (r'好啦', '好了'),
        (r'喂', '喂'),
        (r'哎呀', '哎呀'),
        (r'哇', '哇'),
        (r'哗', '哇'),
        (r'嘩', '哇'),
        (r'嗯', '嗯'),
        (r'哦', '哦'),
        (r'喔', '喔'),
        (r'噢', '噢'),
        (r'吓', '啊'),
        (r'咧', '啊'),
        (r'咋', '而已'),
        (r'之嘛', '而已'),
        (r'嚟讲', '来说'),
        (r'嚟睇', '来看'),
        (r'咁上下', '差不多'),
        (r'咁多', '这么多'),
        (r'咁少', '这么少'),
        (r'咁大', '这么大'),
        (r'咁细', '这么小'),
        (r'咁长', '这么长'),
        (r'咁短', '这么短'),
        (r'咁快', '这么快'),
        (r'咁慢', '这么慢'),
        (r'咁样', '这样'),
        (r'咁', '这样'),
    ]

    return rules


def convert_cantonese_to_mandarin(text: str, context: str = "animal") -> str:
    """
    将粤语文本转换成国语

    Args:
        text: 粤语文本
        context: 上下文类型（animal=动物, person=人物, general=通用）

    Returns:
        转换后的国语文本
    """
    result = text
    rules = create_converter(context)

    # 按规则顺序进行替换
    for pattern, replacement in rules:
        result = re.sub(pattern, replacement, result)

    # 清理重复的标点和空格
    result = re.sub(r'。+', '。', result)
    result = re.sub(r'！+', '！', result)
    result = re.sub(r'？+', '？', result)
    result = re.sub(r'\n{3,}', '\n\n', result)

    # 清理残留的粤语语气词
    result = re.sub(r'[囉嗰啫嘅嗻噃㗎嗱]', '', result)

    return result


def convert_file(input_path: Path, output_path: Path = None, context: str = "animal", preview: bool = False) -> dict:
    """
    转换单个文件

    Args:
        input_path: 输入文件路径
        output_path: 输出文件路径
        context: 上下文类型
        preview: 是否仅预览

    Returns:
        转换结果信息
    """
    if not input_path.exists():
        return {"success": False, "error": f"文件不存在: {input_path}"}

    # 读取原文件
    with open(input_path, 'r', encoding='utf-8') as f:
        original = f.read()

    # 转换
    converted = convert_cantonese_to_mandarin(original, context)

    # 确定输出路径
    if output_path is None:
        stem = input_path.stem
        if '_粤语' in stem:
            output_path = input_path.parent / stem.replace('_粤语', '_国语')
        elif '_视频文案' in stem:
            output_path = input_path.parent / f"{stem}_国语.md"
        else:
            output_path = input_path.parent / f"{stem}_国语.md"

    # 预览模式
    if preview:
        return {
            "success": True,
            "input": str(input_path),
            "output": str(output_path),
            "original_length": len(original),
            "converted_length": len(converted),
            "preview": converted[:800] + "..." if len(converted) > 800 else converted,
        }

    # 写入文件
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(converted)

    return {
        "success": True,
        "input": str(input_path),
        "output": str(output_path),
        "original_length": len(original),
        "converted_length": len(converted),
    }


def batch_convert_directory(dir_path: Path, context: str = "animal", preview: bool = False) -> List[dict]:
    """
    批量转换目录下的所有粤语文案

    Args:
        dir_path: 目录路径
        context: 上下文类型
        preview: 是否仅预览

    Returns:
        转换结果列表
    """
    results = []

    # 查找所有粤语文案文件
    patterns = [
        "*_视频文案_粤语.md",
        "*_视频文案.md",
    ]

    files = []
    for pattern in patterns:
        files.extend(dir_path.rglob(pattern))

    # 去重
    files = list(set(files))

    print(f"📁 扫描目录: {dir_path}")
    print(f"📄 找到 {len(files)} 个文案文件")
    print()

    for file_path in sorted(files):
        print(f"🔄 转换: {file_path.parent.name}/{file_path.name}")
        result = convert_file(file_path, context=context, preview=preview)
        results.append(result)

        if result["success"]:
            print(f"   ✅ 完成")
        else:
            print(f"   ❌ 失败: {result['error']}")
        print()

    return results


def main():
    parser = argparse.ArgumentParser(
        description="粤语转国语转换工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s input.md                           # 转换单个文件
  %(prog)s input.md -o output.md              # 指定输出文件
  %(prog)s input.md --preview                 # 预览转换结果
  %(prog)s --dir ./冷到你唔信/第六册-爬行动物  # 批量转换目录
  %(prog)s --dir ./冷到你唔信/第六册 --preview # 预览批量转换
        """,
    )

    parser.add_argument("input", nargs="?", help="输入文件路径")
    parser.add_argument("-o", "--output", help="输出文件路径")
    parser.add_argument("--dir", help="批量转换目录")
    parser.add_argument("--preview", action="store_true", help="预览模式（不写入文件）")
    parser.add_argument("--context", choices=["animal", "person", "general"], default="animal",
                        help="上下文类型（默认: animal）")

    args = parser.parse_args()

    if args.dir:
        # 批量转换模式
        dir_path = Path(args.dir)
        if not dir_path.exists():
            print(f"❌ 目录不存在: {dir_path}")
            sys.exit(1)

        results = batch_convert_directory(dir_path, context=args.context, preview=args.preview)

        # 统计
        success = sum(1 for r in results if r["success"])
        failed = sum(1 for r in results if not r["success"])
        print("=" * 60)
        print(f"📊 转换完成: 成功 {success}, 失败 {failed}")
        print("=" * 60)

    elif args.input:
        # 单文件转换模式
        input_path = Path(args.input)
        output_path = Path(args.output) if args.output else None

        result = convert_file(input_path, output_path, context=args.context, preview=args.preview)

        if result["success"]:
            print(f"✅ 转换成功!")
            print(f"   输入: {result['input']}")
            print(f"   输出: {result['output']}")
            print(f"   原文长度: {result['original_length']} 字符")
            print(f"   译文长度: {result['converted_length']} 字符")

            if args.preview:
                print()
                print("=" * 60)
                print("📝 转换预览:")
                print("=" * 60)
                print(result["preview"])
        else:
            print(f"❌ 转换失败: {result['error']}")
            sys.exit(1)

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
