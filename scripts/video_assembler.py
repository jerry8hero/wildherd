#!/usr/bin/env python3
"""
视频组装器

使用 FFmpeg 和 MoviePy 实现视频剪辑

使用方法:
    python3 video_assembler.py --audio audio.mp3 --images images/ --output video.mp4
    python3 video_assembler.py --audio audio.mp3 --subtitle subs.srt --output video.mp4

安装依赖:
    pip install moviepy

    # FFmpeg (系统需要安装):
    # Ubuntu/Debian: sudo apt install ffmpeg
    # macOS: brew install ffmpeg
    # Windows: 下载 ffmpeg.exe 并添加到PATH
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
from typing import Optional, List, Dict
import json


# 检查依赖
def check_ffmpeg():
    """检查FFmpeg是否安装"""
    try:
        result = subprocess.run(
            ["ffmpeg", "-version"],
            capture_output=True,
            text=True
        )
        return True
    except FileNotFoundError:
        return False


def check_dependencies():
    """检查所有依赖"""
    missing = []

    # 检查FFmpeg
    if not check_ffmpeg():
        missing.append("ffmpeg (请运行: sudo apt install ffmpeg)")

    # 检查MoviePy
    try:
        import moviepy
    except ImportError:
        missing.append("moviepy (请运行: pip install moviepy)")

    if missing:
        print("缺少依赖:")
        for m in missing:
            print(f"  - {m}")
        return False
    return True


# 颜色配置（用于打印输出）
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'


def print_step(step: str, message: str):
    """打印步骤信息"""
    print(f"{Colors.OKBLUE}[{step}]{Colors.ENDC} {message}")


def print_success(message: str):
    """打印成功信息"""
    print(f"{Colors.OKGREEN}✓{Colors.ENDC} {message}")


def print_warning(message: str):
    """打印警告信息"""
    print(f"{Colors.WARNING}⚠{Colors.ENDC} {message}")


class VideoAssembler:
    """视频组装器"""

    def __init__(self, output_dir: str = "output"):
        """
        初始化视频组装器

        Args:
            output_dir: 输出目录
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def generate_slideshow(
        self,
        images: List[str],
        duration_per_image: float = 3.0,
        output_path: Optional[str] = None,
        transition: str = "fade",
        transition_duration: float = 0.5
    ) -> str:
        """
        从图片列表生成幻灯片视频

        Args:
            images: 图片路径列表
            duration_per_image: 每张图片显示时长（秒）
            output_path: 输出视频路径
            transition: 转场效果 (fade/slice/none)
            transition_duration: 转场时长

        Returns:
            生成的视频路径
        """
        try:
            from moviepy.editor import (
                ImageClip, concatenate_videoclips, CompositeVideoClip
            )
        except ImportError:
            print("请先安装 moviepy: pip install moviepy")
            sys.exit(1)

        if not images:
            raise ValueError("图片列表为空")

        if output_path is None:
            output_path = self.output_dir / "slideshow.mp4"

        print_step("1/3", f"加载 {len(images)} 张图片...")

        clips = []
        for img_path in images:
            img_path = Path(img_path)
            if not img_path.exists():
                print_warning(f"图片不存在，跳过: {img_path}")
                continue

            # 创建图片clip
            clip = ImageClip(str(img_path), duration=duration_per_image)

            # 添加转场效果
            if transition == "fade":
                clip = clip.crossfadein(transition_duration)
                clip = clip.crossfadeout(transition_duration)

            clips.append(clip)

        if not clips:
            raise ValueError("没有有效的图片")

        print_step("2/3", "拼接图片...")

        # 拼接所有clips
        video = concatenate_videoclips(clips, method="compose")

        print_step("3/3", f"导出视频: {output_path}")

        # 导出
        video.write_videofile(
            str(output_path),
            fps=30,
            codec='libx264',
            audio=False,
            verbose=False,
            logger=None
        )

        print_success(f"幻灯片已生成: {output_path}")

        return str(output_path)

    def add_audio(
        self,
        video_path: str,
        audio_path: str,
        output_path: Optional[str] = None
    ) -> str:
        """
        为视频添加音频

        Args:
            video_path: 视频文件路径
            audio_path: 音频文件路径
            output_path: 输出文件路径

        Returns:
            输出文件路径
        """
        video_path = Path(video_path)
        audio_path = Path(audio_path)

        if not video_path.exists():
            raise FileNotFoundError(f"视频文件不存在: {video_path}")
        if not audio_path.exists():
            raise FileNotFoundError(f"音频文件不存在: {audio_path}")

        if output_path is None:
            output_path = self.output_dir / f"{video_path.stem}_with_audio.mp4"

        print_step("1/2", f"加载视频: {video_path.name}")

        # 使用FFmpeg合并音视频
        cmd = [
            "ffmpeg", "-y",
            "-i", str(video_path),
            "-i", str(audio_path),
            "-c:v", "copy",
            "-c:a", "aac",
            "-shortest",
            str(output_path)
        ]

        print_step("2/2", "合成音视频...")

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            raise RuntimeError(f"FFmpeg错误: {result.stderr}")

        print_success(f"音频已添加: {output_path}")

        return str(output_path)

    def add_subtitle(
        self,
        video_path: str,
        subtitle_path: str,
        output_path: Optional[str] = None,
        style: Optional[str] = None
    ) -> str:
        """
        为视频添加字幕

        Args:
            video_path: 视频文件路径
            subtitle_path: SRT字幕文件路径
            output_path: 输出文件路径
            style: 字幕样式 (可选)

        Returns:
            输出文件路径
        """
        video_path = Path(video_path)
        subtitle_path = Path(subtitle_path)

        if not video_path.exists():
            raise FileNotFoundError(f"视频文件不存在: {video_path}")
        if not subtitle_path.exists():
            raise FileNotFoundError(f"字幕文件不存在: {subtitle_path}")

        if output_path is None:
            output_path = self.output_dir / f"{video_path.stem}_subtitled.mp4"

        # 默认字幕样式
        if style is None:
            style = (
                "FontName=黑纸,"
                "FontSize=24,"
                "PrimaryColour=&HFFFFFF,"
                "OutlineColour=&H000000,"
                "Outline=2,"
                "Alignment=2"
            )

        print_step("1/2", f"加载字幕: {subtitle_path.name}")

        # 使用FFmpeg添加字幕
        cmd = [
            "ffmpeg", "-y",
            "-i", str(video_path),
            "-vf", f"subtitles={str(subtitle_path)}:force_style='{style}'",
            "-c:a", "copy",
            str(output_path)
        ]

        print_step("2/2", "添加字幕...")

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            # 尝试使用ass格式
            cmd = [
                "ffmpeg", "-y",
                "-i", str(video_path),
                "-i", str(subtitle_path),
                "-c", "copy",
                "-c:s", "mov_text",
                "-metadata", f"s.title={subtitle_path.stem}",
                str(output_path)
            ]
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True
            )

        if result.returncode != 0:
            raise RuntimeError(f"FFmpeg错误: {result.stderr}")

        print_success(f"字幕已添加: {output_path}")

        return str(output_path)

    def add_watermark(
        self,
        video_path: str,
        watermark_path: str,
        position: str = "bottom-right",
        output_path: Optional[str] = None
    ) -> str:
        """
        为视频添加水印

        Args:
            video_path: 视频文件路径
            watermark_path: 水印图片路径
            position: 水印位置 (top-left/top-right/bottom-left/bottom-right/center)
            output_path: 输出文件路径

        Returns:
            输出文件路径
        """
        video_path = Path(video_path)
        watermark_path = Path(watermark_path)

        if not video_path.exists():
            raise FileNotFoundError(f"视频文件不存在: {video_path}")
        if not watermark_path.exists():
            raise FileNotFoundError(f"水印文件不存在: {watermark_path}")

        if output_path is None:
            output_path = self.output_dir / f"{video_path.stem}_watermarked.mp4"

        # 位置坐标
        positions = {
            "top-left": "10:10",
            "top-right": "W-w-10:10",
            "bottom-left": "10:H-h-10",
            "bottom-right": "W-w-10:H-h-10",
            "center": "(W-w)/2:(H-h)/2"
        }

        pos = positions.get(position, positions["bottom-right"])

        print_step("1/2", "添加水印...")

        cmd = [
            "ffmpeg", "-y",
            "-i", str(video_path),
            "-i", str(watermark_path),
            "-filter_complex",
            f"[0:v][1:v]overlay={pos}",
            "-c:a", "copy",
            str(output_path)
        ]

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            raise RuntimeError(f"FFmpeg错误: {result.stderr}")

        print_success(f"水印已添加: {output_path}")

        return str(output_path)

    def assemble_full(
        self,
        audio_path: str,
        images: List[str],
        subtitle_path: Optional[str] = None,
        watermark_path: Optional[str] = None,
        duration_per_image: float = 3.0,
        output_path: str = "final_video.mp4"
    ) -> str:
        """
        完整组装流程：图片+配音+字幕+水印

        Args:
            audio_path: 配音文件路径
            images: 图片列表
            subtitle_path: 字幕文件路径（可选）
            watermark_path: 水印文件路径（可选）
            duration_per_image: 每张图片显示时长
            output_path: 输出文件路径

        Returns:
            最终视频文件路径
        """
        output_path = Path(output_path)

        print("\n" + "="*50)
        print("开始视频组装")
        print("="*50)

        temp_dir = self.output_dir / "temp"
        temp_dir.mkdir(parents=True, exist_ok=True)

        try:
            # Step 1: 生成幻灯片
            print_step("Step 1/4", "生成幻灯片...")
            slideshow_path = temp_dir / "slideshow.mp4"
            self.generate_slideshow(
                images=images,
                duration_per_image=duration_per_image,
                output_path=str(slideshow_path),
                transition="fade"
            )

            # Step 2: 添加配音
            print_step("Step 2/4", "添加配音...")
            with_audio_path = temp_dir / "with_audio.mp4"
            self.add_audio(
                video_path=str(slideshow_path),
                audio_path=audio_path,
                output_path=str(with_audio_path)
            )

            # Step 3: 添加字幕
            if subtitle_path:
                print_step("Step 3/4", "添加字幕...")
                with_subtitle_path = temp_dir / "with_subtitle.mp4"
                self.add_subtitle(
                    video_path=str(with_audio_path),
                    subtitle_path=subtitle_path,
                    output_path=str(with_subtitle_path)
                )
                current_path = with_subtitle_path
            else:
                current_path = with_audio_path

            # Step 4: 添加水印
            if watermark_path:
                print_step("Step 4/4", "添加水印...")
                self.add_watermark(
                    video_path=str(current_path),
                    watermark_path=watermark_path,
                    output_path=str(output_path)
                )
            else:
                # 直接复制
                import shutil
                shutil.copy(str(current_path), str(output_path))

            print("\n" + "="*50)
            print_success("视频组装完成!")
            print(f"输出文件: {output_path}")
            print("="*50)

            return str(output_path)

        finally:
            # 清理临时文件
            import shutil
            if temp_dir.exists():
                shutil.rmtree(temp_dir)


def main():
    parser = argparse.ArgumentParser(
        description="视频组装器 - FFmpeg/MoviePy",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 从图片生成幻灯片
  python3 video_assembler.py --images img1.jpg img2.jpg img3.jpg --output slideshow.mp4

  # 为视频添加配音
  python3 video_assembler.py --video video.mp4 --audio voice.mp3 --output with_audio.mp4

  # 完整组装流程
  python3 video_assembler.py --audio voice.mp3 --images img1.jpg img2.jpg --subtitle subs.srt --output final.mp4

注意:
  - 需要安装 FFmpeg: sudo apt install ffmpeg
  - 需要安装 MoviePy: pip install moviepy
        """
    )

    parser.add_argument("--images", "-i", nargs="+", help="图片文件列表")
    parser.add_argument("--audio", "-a", help="配音音频文件")
    parser.add_argument("--video", "-v", help="视频文件（用于添加音视频）")
    parser.add_argument("--subtitle", "-s", help="字幕文件 (SRT格式)")
    parser.add_argument("--watermark", "-w", help="水印图片")
    parser.add_argument("--output", "-o", required=True, help="输出文件路径")
    parser.add_argument("--duration", "-d", type=float, default=3.0,
                       help="每张图片显示时长（秒，默认3秒）")
    parser.add_argument("--transition", "-t", default="fade",
                       choices=["fade", "slice", "none"],
                       help="转场效果")
    parser.add_argument("--position", "-p", default="bottom-right",
                       choices=["top-left", "top-right", "bottom-left", "bottom-right", "center"],
                       help="水印位置")

    args = parser.parse_args()

    # 检查依赖
    if not check_dependencies():
        sys.exit(1)

    # 创建组装器
    assembler = VideoAssembler()

    try:
        if args.video and args.audio:
            # 添加音频模式
            result = assembler.add_audio(
                video_path=args.video,
                audio_path=args.audio,
                output_path=args.output
            )

        elif args.images:
            # 幻灯片模式
            result = assembler.assemble_full(
                audio_path=args.audio if args.audio else "",
                images=args.images,
                subtitle_path=args.subtitle,
                watermark_path=args.watermark,
                duration_per_image=args.duration,
                output_path=args.output
            )

        else:
            parser.print_help()
            print("\n错误: 请提供 --images 或 --video 参数")
            sys.exit(1)

        print(f"\n完成: {result}")

    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
