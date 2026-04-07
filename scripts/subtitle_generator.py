#!/usr/bin/env python3
"""
字幕生成器

使用 Whisper 实现语音转字幕，完全免费本地运行

使用方法:
    python3 subtitle_generator.py --audio test.mp3
    python3 subtitle_generator.py --audio test.mp3 --output subtitles/
    python3 subtitle_generator.py --audio test.mp3 --model base

安装依赖:
    pip install openai-whisper
"""

import os
import sys
import argparse
from pathlib import Path
from typing import Optional, List, Dict


# 检查依赖
try:
    import whisper
except ImportError:
    print("请先安装 openai-whisper:")
    print("  pip install openai-whisper")
    # 提供备用方案说明
    print("\n或者使用在线API方案（需要API Key）")
    sys.exit(1)


# 可用模型
MODELS = {
    "tiny": {"params": 39, "description": "最快，最不准确"},
    "base": {"params": 74, "description": "平衡速度和准确性"},
    "small": {"params": 244, "description": "较准确，较慢"},
    "medium": {"params": 769, "description": "准确，较慢"},
    "large": {"params": 1550, "description": "最准确，最慢"}
}

DEFAULT_MODEL = "base"


class SubtitleGenerator:
    """字幕生成器"""

    def __init__(self, model_name: str = DEFAULT_MODEL, device: str = "auto"):
        """
        初始化字幕生成器

        Args:
            model_name: Whisper模型 (tiny/base/small/medium/large)
            device: 运行设备 (auto/cuda/cpu)
        """
        self.model_name = model_name

        # 自动选择设备
        if device == "auto":
            import torch
            device = "cuda" if torch.cuda.is_available() else "cpu"

        self.device = device
        self.model = None

        print(f"字幕生成器初始化: {model_name} 模型, 使用 {device} 设备")

    def _load_model(self):
        """加载Whisper模型"""
        if self.model is None:
            print(f"正在加载模型 {self.model_name}...")
            self.model = whisper.load_model(self.model_name, device=self.device)
            print("模型加载完成")

    def generate_from_audio(
        self,
        audio_path: str,
        output_path: Optional[str] = None,
        language: str = "zh"
    ) -> str:
        """
        从音频生成字幕

        Args:
            audio_path: 音频文件路径
            output_path: 输出字幕路径 (默认与音频同目录同名)
            language: 语言 (zh/en等)

        Returns:
            生成的字幕文件路径
        """
        audio_path = Path(audio_path)

        if not audio_path.exists():
            raise FileNotFoundError(f"音频文件不存在: {audio_path}")

        # 确定输出路径
        if output_path is None:
            output_path = audio_path.with_suffix(".srt")
        else:
            output_path = Path(output_path)

        output_path.parent.mkdir(parents=True, exist_ok=True)

        # 加载模型
        self._load_model()

        print(f"\n开始转录音频: {audio_path}")
        print(f"语言: {language}")

        # 转录
        result = self.model.transcribe(
            str(audio_path),
            language=language,
            verbose=True
        )

        # 生成SRT字幕
        srt_content = self._generate_srt(result["segments"])

        # 保存
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(srt_content)

        print(f"\n✓ 字幕已生成: {output_path}")
        print(f"  字幕数量: {len(result['segments'])} 段")
        print(f"  总时长: {self._format_time(result.get('duration', 0))}")

        return str(output_path)

    def _generate_srt(self, segments: List[Dict]) -> str:
        """将转录结果转换为SRT格式"""
        srt_lines = []

        for i, segment in enumerate(segments, 1):
            start_time = self._format_srt_time(segment["start"])
            end_time = self._format_srt_time(segment["end"])
            text = segment["text"].strip()

            srt_lines.append(f"{i}")
            srt_lines.append(f"{start_time} --> {end_time}")
            srt_lines.append(text)
            srt_lines.append("")  # 空行分隔

        return "\n".join(srt_lines)

    def _format_srt_time(self, seconds: float) -> str:
        """将秒数转换为SRT时间格式 HH:MM:SS,mmm"""
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        secs = int(seconds % 60)
        millis = int((seconds % 1) * 1000)

        return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"

    def _format_time(self, seconds: float) -> str:
        """格式化时长"""
        minutes = int(seconds // 60)
        secs = int(seconds % 60)
        return f"{minutes}分{secs}秒"

    def generate_with_timestamps(
        self,
        audio_path: str,
        output_path: Optional[str] = None,
        language: str = "zh"
    ) -> Dict:
        """
        生成带时间戳的字幕数据

        Returns:
            包含所有片段和时间的字典
        """
        audio_path = Path(audio_path)
        self._load_model()

        print(f"\n开始转录音频: {audio_path}")

        result = self.model.transcribe(
            str(audio_path),
            language=language,
            verbose=True
        )

        return {
            "segments": result["segments"],
            "language": result.get("language", language),
            "duration": result.get("duration", 0)
        }


def main():
    parser = argparse.ArgumentParser(
        description="字幕生成器 - 使用 Whisper",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 从音频生成字幕
  python3 subtitle_generator.py --audio test.mp3

  # 指定输出路径
  python3 subtitle_generator.py --audio test.mp3 --output subtitles/test.srt

  # 使用更大模型（更准确但更慢）
  python3 subtitle_generator.py --audio test.mp3 --model small

  # 列出可用模型
  python3 subtitle_generator.py --list-models

模型说明:
  tiny   - 39M参数，最快，最不准确
  base   - 74M参数，平衡（推荐）
  small  - 244M参数，较准确
  medium - 769M参数，准确
  large  - 1550M参数，最准确，最慢
        """
    )

    parser.add_argument("--audio", "-a", help="音频文件路径")
    parser.add_argument("--output", "-o", help="输出字幕路径")
    parser.add_argument("--model", "-m", default=DEFAULT_MODEL,
                       choices=list(MODELS.keys()),
                       help=f"Whisper模型 (默认: {DEFAULT_MODEL})")
    parser.add_argument("--language", "-l", default="zh",
                       help="语言 (默认: zh)")
    parser.add_argument("--list-models", action="store_true",
                       help="列出可用模型")
    parser.add_argument("--device", "-d", default="auto",
                       choices=["auto", "cuda", "cpu"],
                       help="运行设备 (默认: auto)")

    args = parser.parse_args()

    # 列出模型
    if args.list_models:
        print("\n可用 Whisper 模型:")
        print("-" * 50)
        for name, info in MODELS.items():
            default = " (默认)" if name == DEFAULT_MODEL else ""
            print(f"  {name:8} - {info['params']:4}M参数 - {info['description']}{default}")
        return

    # 检查参数
    if not args.audio:
        parser.print_help()
        print("\n错误: 请提供 --audio 参数")
        return

    if not os.path.exists(args.audio):
        print(f"错误: 音频文件不存在 {args.audio}")
        sys.exit(1)

    # 创建生成器
    generator = SubtitleGenerator(
        model_name=args.model,
        device=args.device
    )

    # 生成字幕
    try:
        output_path = generator.generate_from_audio(
            audio_path=args.audio,
            output_path=args.output,
            language=args.language
        )

        print("-" * 40)
        print("✓ 生成完成!")

        # 显示预览
        print("\n字幕预览 (前3段):")
        print("-" * 40)
        with open(output_path, "r", encoding="utf-8") as f:
            lines = f.read().split("\n")
            count = 0
            for line in lines:
                if line and not line.startswith("-"):
                    print(line)
                    count += 1
                    if count >= 9:  # 3段字幕
                        break
                elif line == "":
                    count = 0
                    print()

    except Exception as e:
        print(f"✗ 生成失败: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
