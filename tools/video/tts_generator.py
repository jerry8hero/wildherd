#!/usr/bin/env python3
"""
TTS 文字转语音生成器

使用 Edge TTS 实现文字转语音，完全免费无需API Key

使用方法:
    python3 tts_generator.py --text "测试文字" --output test.mp3
    python3 tts_generator.py --file script.md --output audio/
    python3 tts_generator.py --list-voices

安装依赖:
    pip install edge-tts
"""

import os
import sys
import asyncio
import argparse
from pathlib import Path
from typing import Optional, List, Dict


# 检查依赖
try:
    import edge_tts
except ImportError:
    print("请先安装 edge-tts:")
    print("  pip install edge-tts")
    sys.exit(1)


# 可用的中文声音
CHINESE_VOICES = {
    # 女声
    "xiaoxiao": {
        "name": "晓晓",
        "voice": "zh-CN-XiaoxiaoNeural",
        "description": "年轻女声，清晰自然"
    },
    "xiaoyi": {
        "name": "小艺",
        "voice": "zh-CN-XiaoyiNeural",
        "description": "年轻女声，活泼"
    },
    "yuni": {
        "name": "云希",
        "voice": "zh-CN-YunxiNeural",
        "description": "年轻女声，阳光"
    },
    # 男声
    "yunyang": {
        "name": "云扬",
        "voice": "zh-CN-YunyangNeural",
        "description": "男声，专业播报"
    },
    "xiaoxuan": {
        "name": "小璇",
        "voice": "zh-CN-XiaoxuanNeural",
        "description": "年轻女声，亲切"
    },
    # 其他
    "xiaobai": {
        "name": "小白",
        "voice": "zh-CN-XiaobaiNeural",
        "description": "年轻女声，简单"
    }
}

# 默认设置
DEFAULT_VOICE = "xiaoxiao"
DEFAULT_RATE = "+10%"  # 语速加快10%，更适合视频
DEFAULT_PITCH = "+0Hz"
DEFAULT_VOLUME = "+0%"


class TTSGenerator:
    """TTS文字转语音生成器"""

    def __init__(
        self,
        voice: str = DEFAULT_VOICE,
        rate: str = DEFAULT_RATE,
        pitch: str = DEFAULT_PITCH,
        volume: str = DEFAULT_VOLUME
    ):
        """
        初始化TTS生成器

        Args:
            voice: 声音名称 (xiaoxiao/xiaoyi/yuni/yunyang/xiaoxuan/xiaobai)
            rate: 语速 (+/-百分比，如 +10% 或 -5%)
            pitch: 音调 (+/-Hz)
            volume: 音量 (+/-百分比)
        """
        if voice not in CHINESE_VOICES:
            raise ValueError(f"未知声音: {voice}，可用: {list(CHINESE_VOICES.keys())}")

        self.voice_key = voice
        self.voice = CHINESE_VOICES[voice]["voice"]
        self.rate = rate
        self.pitch = pitch
        self.volume = volume

    def __str__(self):
        info = CHINESE_VOICES[self.voice_key]
        return f"TTSGenerator({info['name']}, 语速={self.rate}, 音调={self.pitch})"

    async def generate(
        self,
        text: str,
        output_path: str,
        format: str = "audio-24khz-48kbitrate-mono-mp3"
    ) -> str:
        """
        生成TTS音频

        Args:
            text: 要转换的文字
            output_path: 输出文件路径
            format: 音频格式

        Returns:
            输出文件路径
        """
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        # 移除格式后缀，使用edge-tts的format参数
        format_map = {
            "mp3": "audio-24khz-48kbitrate-mono-mp3",
            "webm": "webm-24khz-16bit-mono-opus",
            "ogg": "ogg-24khz-16bit-mono-opus"
        }

        audio_format = format_map.get(output_path.suffix.lstrip("."), format_map["mp3"])

        communicate = edge_tts.Communicate(
            text,
            self.voice,
            rate=self.rate,
            pitch=self.pitch,
            volume=self.volume
        )

        await communicate.save(str(output_path))

        print(f"✓ TTS音频已生成: {output_path}")
        print(f"  声音: {CHINESE_VOICES[self.voice_key]['name']}")
        print(f"  语速: {self.rate}")
        print(f"  文字长度: {len(text)} 字符")

        return str(output_path)

    def generate_sync(
        self,
        text: str,
        output_path: str,
        format: str = "mp3"
    ) -> str:
        """同步版本的generate"""
        return asyncio.run(self.generate(text, output_path, format))


def extract_text_from_markdown(md_path: str) -> str:
    """从Markdown文件提取纯文本"""
    with open(md_path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.split("\n")
    text_parts = []

    for line in lines:
        # 跳过标题行（但保留一级标题的内容）
        if line.startswith("# "):
            text_parts.append(line[2:].strip())
        # 跳过水平线和分隔符
        elif line.strip() in ["---", "***", "___"]:
            continue
        # 跳过链接和图片
        elif line.startswith("!["):
            continue
        # 处理列表项
        elif line.startswith(("- ", "* ")):
            text_parts.append(line[2:].strip())
        # 处理加粗和斜体
        else:
            # 移除markdown格式符
            line = line.replace("**", "").replace("*", "").replace("`", "")
            if line.strip():
                text_parts.append(line.strip())

    # 添加适当停顿
    full_text = "。".join(text_parts)
    # 清理多余标点
    full_text = full_text.replace("。。", "。").replace("，，", "，")

    return full_text


async def list_voices():
    """列出所有可用的中文声音"""
    voices = await edge_tts.list_voices()
    chinese_voices = [v for v in voices if v["Locale"].startswith("zh-")]

    print("\n可用中文声音:")
    print("-" * 60)

    categories = {
        "zh-CN": "中国大陆",
        "zh-TW": "台湾",
        "zh-HK": "香港"
    }

    for locale, locale_name in categories.items():
        locale_voices = [v for v in chinese_voices if v["Locale"] == locale]
        if locale_voices:
            print(f"\n{locale_name} ({locale}):")
            for v in locale_voices[:5]:  # 只显示前5个
                gender = "♀" if v["Gender"] == "Female" else "♂"
                print(f"  {gender} {v['Name']} - {v.get('ShortName', '')}")


def main():
    parser = argparse.ArgumentParser(
        description="TTS 文字转语音生成器 - 使用 Edge TTS",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 生成简单文本的TTS
  python3 tts_generator.py --text "测试文字" --output test.mp3

  # 从Markdown文件生成TTS
  python3 tts_generator.py --file docs/video-scripts/鳄龟/01-养鳄龟选大还是小.md --output audio/

  # 使用不同声音
  python3 tts_generator.py --text "测试" --voice yunyang --output test.mp3

  # 列出所有可用声音
  python3 tts_generator.py --list-voices

声音选择:
  xiaoxiao - 晓晓（年轻女声，推荐）
  xiaoyi   - 小艺（年轻女声）
  yuni     - 云希（年轻女声）
  yunyang  - 云扬（男声）
  xiaoxuan - 小璇（年轻女声）
  xiaobai  - 小白（年轻女声）
        """
    )

    parser.add_argument("--text", "-t", help="要转换的文字")
    parser.add_argument("--file", "-f", help="Markdown文件路径，自动提取文本")
    parser.add_argument("--output", "-o", help="输出文件/目录路径 (list-voices模式不需要)")
    parser.add_argument("--voice", "-v", default=DEFAULT_VOICE,
                       choices=list(CHINESE_VOICES.keys()),
                       help=f"选择声音 (默认: {DEFAULT_VOICE})")
    parser.add_argument("--rate", "-r", default=DEFAULT_RATE,
                       help=f"语速 (默认: {DEFAULT_RATE})")
    parser.add_argument("--pitch", "-p", default=DEFAULT_PITCH,
                       help=f"音调 (默认: {DEFAULT_PITCH})")
    parser.add_argument("--list-voices", "-l", action="store_true",
                       help="列出所有可用的中文声音")
    parser.add_argument("--format", default="mp3",
                       choices=["mp3", "webm", "ogg"],
                       help="输出格式 (默认: mp3)")

    args = parser.parse_args()

    # 列出声音
    if args.list_voices:
        asyncio.run(list_voices())
        return

    # 检查参数
    if not args.text and not args.file:
        parser.print_help()
        print("\n错误: 请提供 --text 或 --file 参数")
        return

    # 确定输入文本
    if args.file:
        if not os.path.exists(args.file):
            print(f"错误: 文件不存在 {args.file}")
            sys.exit(1)
        print(f"从文件提取文本: {args.file}")
        text = extract_text_from_markdown(args.file)

        # 如果output是目录，自动生成文件名
        output_path = args.output
        if os.path.isdir(output_path):
            md_name = Path(args.file).stem
            output_path = os.path.join(output_path, f"{md_name}.{args.format}")
    else:
        text = args.text
        output_path = args.output

    # 创建生成器
    generator = TTSGenerator(
        voice=args.voice,
        rate=args.rate,
        pitch=args.pitch
    )

    print(f"\nTTS生成器: {generator}")
    print(f"输入文字长度: {len(text)} 字符")
    print(f"输出文件: {output_path}")
    print("-" * 40)

    # 生成音频
    try:
        result = asyncio.run(generator.generate(text, output_path, args.format))
        print("-" * 40)
        print("✓ 生成完成!")

        # 获取文件大小
        file_size = os.path.getsize(result)
        print(f"  文件大小: {file_size / 1024:.1f} KB")

    except Exception as e:
        print(f"✗ 生成失败: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
