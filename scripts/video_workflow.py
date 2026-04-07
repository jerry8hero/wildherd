#!/usr/bin/env python3
"""
视频自动化工作流 - 主脚本

整合 TTS配音 + Whisper字幕 + FFmpeg剪辑 + B站发布

完整流程:
    脚本 → TTS配音 → Whisper字幕 → 素材组装 → FFmpeg剪辑 → B站发布

使用方法:
    # 完整工作流
    python3 video_workflow.py --script docs/video-scripts/鳄龟/01-养鳄龟选大还是小.md

    # 仅生成TTS
    python3 video_workflow.py --script xxx.md --step tts

    # 仅生成字幕
    python3 video_workflow.py --audio audio.mp3 --step subtitle

    # 组装视频
    python3 video_workflow.py --audio audio.mp3 --images img1.jpg img2.jpg --step assemble

安装依赖:
    pip install edge-tts openai-whisper moviepy requests
    sudo apt install ffmpeg
"""

import os
import sys
import json
import subprocess
import argparse
from pathlib import Path
from typing import Optional, List, Dict
from datetime import datetime


# 颜色配置
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


def print_step(step: str, message: str):
    """打印步骤信息"""
    print(f"{Colors.OKBLUE}[{step}]{Colors.ENDC} {message}")


def print_success(message: str):
    """打印成功信息"""
    print(f"{Colors.OKGREEN}✓{Colors.ENDC} {message}")


def print_warning(message: str):
    """打印警告信息"""
    print(f"{Colors.WARNING}⚠{Colors.ENDC} {message}")


def print_error(message: str):
    """打印错误信息"""
    print(f"{Colors.FAIL}✗{Colors.ENDC} {message}")


def print_header(message: str):
    """打印标题"""
    print(f"\n{Colors.BOLD}{Colors.HEADER}{'='*60}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.HEADER}{message:^60}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.HEADER}{'='*60}{Colors.ENDC}\n")


class VideoWorkflow:
    """视频自动化工作流"""

    def __init__(
        self,
        script_path: Optional[str] = None,
        output_dir: str = "output/video"
    ):
        """
        初始化工作流

        Args:
            script_path: 视频脚本路径 (Markdown格式)
            output_dir: 输出目录
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

        self.script_path = script_path
        self.script_content = None
        self.title = None
        self.audio_path = None
        self.subtitle_path = None
        self.video_path = None

        # 工作目录
        self.work_dir = self.output_dir / "temp"
        self.work_dir.mkdir(parents=True, exist_ok=True)

    def load_script(self) -> str:
        """加载视频脚本"""
        if not self.script_path:
            raise ValueError("未指定脚本路径")

        script_path = Path(self.script_path)

        if not script_path.exists():
            raise FileNotFoundError(f"脚本文件不存在: {script_path}")

        with open(script_path, "r", encoding="utf-8") as f:
            self.script_content = f.read()

        # 提取标题
        lines = self.script_content.split("\n")
        for line in lines:
            if line.startswith("# "):
                self.title = line[2:].strip()
                break

        if not self.title:
            self.title = script_path.stem

        print_success(f"已加载脚本: {self.title}")
        return self.script_content

    def extract_text_from_markdown(self, content: str) -> str:
        """从Markdown提取纯文本"""
        lines = content.split("\n")
        text_parts = []

        for line in lines:
            if line.startswith("# "):
                text_parts.append(line[2:].strip())
            elif line.strip() in ["---", "***", "___"]:
                continue
            elif line.startswith("!["):
                continue
            elif line.startswith(("- ", "* ")):
                text_parts.append(line[2:].strip())
            else:
                line = line.replace("**", "").replace("*", "").replace("`", "")
                if line.strip():
                    text_parts.append(line.strip())

        full_text = "。".join(text_parts)
        full_text = full_text.replace("。。", "。").replace("，，", "，")
        return full_text

    def generate_tts(
        self,
        text: Optional[str] = None,
        voice: str = "xiaoxiao",
        rate: str = "+10%"
    ) -> str:
        """
        生成TTS配音

        Args:
            text: 要转换的文字 (默认从脚本提取)
            voice: 声音选择
            rate: 语速

        Returns:
            音频文件路径
        """
        print_step("1", "生成TTS配音")

        if text is None:
            if not self.script_content:
                self.load_script()
            text = self.extract_text_from_markdown(self.script_content)

        audio_path = self.work_dir / "audio.mp3"

        # 使用 edge-tts
        try:
            import edge_tts
        except ImportError:
            print_error("请先安装 edge-tts: pip install edge-tts")
            sys.exit(1)

        async def generate():
            communicate = edge_tts.Communicate(
                text,
                f"zh-CN-{voice.title()}Neural",
                rate=rate
            )
            await communicate.save(str(audio_path))

        import asyncio
        asyncio.run(generate())

        self.audio_path = str(audio_path)
        print_success(f"TTS已生成: {self.audio_path}")
        print(f"  文字长度: {len(text)} 字符")
        return self.audio_path

    def generate_subtitle(self, audio_path: Optional[str] = None) -> str:
        """
        生成字幕

        Args:
            audio_path: 音频文件路径

        Returns:
            字幕文件路径
        """
        print_step("2", "生成字幕")

        if audio_path:
            self.audio_path = audio_path

        if not self.audio_path:
            raise ValueError("未指定音频文件")

        audio_path = Path(self.audio_path)
        subtitle_path = audio_path.with_suffix(".srt")

        # 使用 Whisper
        try:
            import whisper
        except ImportError:
            print_error("请先安装 openai-whisper: pip install openai-whisper")
            sys.exit(1)

        print("加载Whisper模型...")
        model = whisper.load_model("base")

        print("转录音频...")
        result = model.transcribe(str(audio_path), language="zh")

        # 生成SRT
        segments = result["segments"]
        srt_lines = []

        for i, segment in enumerate(segments, 1):
            start = self._format_srt_time(segment["start"])
            end = self._format_srt_time(segment["end"])
            text = segment["text"].strip()

            srt_lines.append(f"{i}")
            srt_lines.append(f"{start} --> {end}")
            srt_lines.append(text)
            srt_lines.append("")

        subtitle_content = "\n".join(srt_lines)
        with open(subtitle_path, "w", encoding="utf-8") as f:
            f.write(subtitle_content)

        self.subtitle_path = str(subtitle_path)
        print_success(f"字幕已生成: {self.subtitle_path}")
        print(f"  字幕段数: {len(segments)}")

        return self.subtitle_path

    def _format_srt_time(self, seconds: float) -> str:
        """格式化SRT时间"""
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        secs = int(seconds % 60)
        millis = int((seconds % 1) * 1000)
        return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"

    def assemble_video(
        self,
        images: Optional[List[str]] = None,
        duration_per_image: float = 3.0
    ) -> str:
        """
        组装视频

        Args:
            images: 图片列表 (默认使用默认背景)
            duration_per_image: 每张图片时长

        Returns:
            视频文件路径
        """
        print_step("3", "组装视频")

        if not self.audio_path:
            raise ValueError("未生成配音")

        video_path = self.work_dir / "video.mp4"

        # 使用 FFmpeg 创建幻灯片
        # 如果没有指定图片，创建一个纯色背景视频

        if images:
            # 简化处理：直接使用第一张图片作为背景
            bg_image = images[0]
        else:
            # 创建纯色背景
            bg_path = self.work_dir / "bg.png"
            self._create_solid_background(bg_path, 1280, 720)
            bg_image = str(bg_path)

        # 获取音频时长
        import subprocess
        cmd = [
            "ffmpeg", "-i", self.audio_path,
            "-f", "null", "-"
        ]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True
        )

        # 解析时长
        duration = 60  # 默认60秒
        for line in result.stderr.split("\n"):
            if "Duration:" in line:
                try:
                    time_str = line.split("Duration:")[1].split(",")[0].strip()
                    h, m, s = time_str.split(":")
                    duration = int(h) * 3600 + int(m) * 60 + float(s)
                except:
                    pass

        # 创建图片循环视频
        cmd = [
            "ffmpeg", "-y",
            "-loop", "1",
            "-i", bg_image,
            "-i", self.audio_path,
            "-c:v", "libx264",
            "-preset", "fast",
            "-crf", "23",
            "-c:a", "aac",
            "-shortest",
            "-t", str(duration),
            "-vf", "scale=1280:720",
            str(video_path)
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            print_error(f"FFmpeg错误: {result.stderr.decode() if isinstance(result.stderr, bytes) else result.stderr}")
            raise RuntimeError("视频组装失败")

        self.video_path = str(video_path)
        print_success(f"视频已组装: {self.video_path}")

        return self.video_path

    def _create_solid_background(self, path: Path, width: int, height: int):
        """创建纯色背景图片"""
        try:
            from PIL import Image
            img = Image.new("RGB", (width, height), color=(30, 60, 50))
            img.save(path)
        except ImportError:
            # 如果没有PIL，使用FFmpeg
            cmd = [
                "ffmpeg", "-y",
                "-f", "lavfi",
                "-i", f"color=c=0x1E3C32:s={width}x{height}",
                "-frames:v", "1",
                str(path)
            ]
            subprocess.run(cmd, capture_output=True)

    def add_subtitle_to_video(self) -> str:
        """为视频添加字幕"""
        print_step("4", "添加字幕")

        if not self.video_path:
            raise ValueError("未组装视频")

        if not self.subtitle_path:
            print_warning("未生成字幕，跳过")
            return self.video_path

        video_path = Path(self.video_path)
        output_path = self.output_dir / f"{video_path.stem}_subtitled.mp4"

        # 使用FFmpeg添加字幕
        cmd = [
            "ffmpeg", "-y",
            "-i", str(video_path),
            "-vf", f"subtitles={self.subtitle_path}",
            "-c:a", "copy",
            str(output_path)
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            print_warning("字幕添加失败，继续使用无字幕版本")
            return self.video_path

        self.video_path = str(output_path)
        print_success(f"字幕已添加: {self.video_path}")

        return self.video_path

    def generate_cover(self, title: Optional[str] = None) -> str:
        """生成封面"""
        print_step("5", "生成封面")

        if not title:
            title = self.title or "视频标题"

        cover_path = self.output_dir / "cover.png"

        try:
            from PIL import Image, ImageDraw, ImageFont
        except ImportError:
            print_warning("未安装PIL，跳过封面生成")
            return str(cover_path)

        # 创建封面
        width, height = 1280, 720
        img = Image.new("RGB", (width, height), color=(30, 60, 50))
        draw = ImageDraw.Draw(img)

        # 添加标题
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 60)
        except:
            font = ImageFont.load_default()

        # 文字换行
        max_chars = 15
        if len(title) > max_chars:
            mid = len(title) // 2
            for i in range(mid, len(title)):
                if title[i] in ' \n-':
                    break
            line1 = title[:i].strip()
            line2 = title[i:].strip()

            bbox1 = draw.textbbox((0, 0), line1, font=font)
            w1 = bbox1[2] - bbox1[0]
            draw.text(((width - w1) // 2, height // 2 - 50), line1, fill=(255, 255, 255), font=font)

            bbox2 = draw.textbbox((0, 0), line2, font=font)
            w2 = bbox2[2] - bbox2[0]
            draw.text(((width - w2) // 2, height // 2 + 30), line2, fill=(255, 255, 255), font=font)
        else:
            bbox = draw.textbbox((0, 0), title, font=font)
            w = bbox[2] - bbox[0]
            draw.text(((width - w) // 2, height // 2 - 30), title, fill=(255, 255, 255), font=font)

        img.save(cover_path)
        print_success(f"封面已生成: {cover_path}")

        return str(cover_path)

    def run(
        self,
        images: Optional[List[str]] = None,
        voice: str = "xiaoxiao",
        skip_bilibili: bool = False
    ) -> Dict:
        """
        运行完整工作流

        Args:
            images: 图片列表
            voice: TTS声音
            skip_bilibili: 跳过B站发布

        Returns:
            工作流结果
        """
        print_header("视频自动化工作流")
        print(f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

        result = {
            "title": self.title,
            "success": True,
            "steps": {}
        }

        try:
            # Step 1: 加载脚本
            if self.script_path:
                self.load_script()

            # Step 2: 生成TTS
            self.generate_tts(voice=voice)
            result["steps"]["tts"] = {"success": True, "path": self.audio_path}

            # Step 3: 生成字幕
            try:
                self.generate_subtitle()
                result["steps"]["subtitle"] = {"success": True, "path": self.subtitle_path}
            except Exception as e:
                print_warning(f"字幕生成失败: {e}")
                result["steps"]["subtitle"] = {"success": False, "error": str(e)}

            # Step 4: 组装视频
            self.assemble_video(images=images)
            result["steps"]["assemble"] = {"success": True, "path": self.video_path}

            # Step 5: 添加字幕
            self.add_subtitle_to_video()
            result["steps"]["subtitle_video"] = {"success": True, "path": self.video_path}

            # Step 6: 生成封面
            cover_path = self.generate_cover()
            result["steps"]["cover"] = {"success": True, "path": cover_path}

            # Step 7: B站发布（可选）
            if not skip_bilibili:
                print_step("6", "B站发布 (已跳过)")
                result["steps"]["bilibili"] = {"success": False, "skipped": True}

            # 最终输出
            final_video = self.video_path
            result["final_video"] = final_video
            result["success"] = True

        except Exception as e:
            print_error(f"工作流执行失败: {e}")
            result["success"] = False
            result["error"] = str(e)
            import traceback
            traceback.print_exc()

        print_header("工作流完成")
        print(f"状态: {'成功' if result['success'] else '失败'}")
        if result.get("final_video"):
            print(f"输出视频: {result['final_video']}")
        print(f"封面: {cover_path if result['steps'].get('cover', {}).get('success') else 'N/A'}")

        # 保存结果
        result_path = self.output_dir / "workflow_result.json"
        with open(result_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)

        return result


def main():
    parser = argparse.ArgumentParser(
        description="视频自动化工作流 - 从文案到视频发布",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 完整工作流
  python3 video_workflow.py --script docs/video-scripts/鳄龟/01-养鳄龟选大还是小.md

  # 指定图片
  python3 video_workflow.py --script xxx.md --images img1.jpg img2.jpg

  # 指定声音
  python3 video_workflow.py --script xxx.md --voice yunyang

  # 仅生成配音
  python3 video_workflow.py --script xxx.md --step tts

  # 仅组装视频
  python3 video_workflow.py --audio audio.mp3 --images img1.jpg --step assemble

工作流程:
  1. TTS配音 - 使用Edge TTS生成配音
  2. 字幕生成 - 使用Whisper识别生成字幕
  3. 视频组装 - FFmpeg拼接图片和配音
  4. 字幕压制 - FFmpeg添加字幕
  5. 封面生成 - PIL生成封面
  6. B站发布 - (可选，需配置cookies)
        """
    )

    parser.add_argument("--script", "-s", help="视频脚本 (Markdown)")
    parser.add_argument("--audio", "-a", help="配音音频 (跳过TTS)")
    parser.add_argument("--images", "-i", nargs="+", help="背景图片列表")
    parser.add_argument("--subtitle", help="字幕文件 (跳过生成)")
    parser.add_argument("--output", "-o", default="output/video", help="输出目录")
    parser.add_argument("--voice", "-v", default="xiaoxiao",
                       choices=["xiaoxiao", "xiaoyi", "yuni", "yunyang", "xiaoxuan", "xiaobai"],
                       help="TTS声音")
    parser.add_argument("--step", "-t", choices=["tts", "subtitle", "assemble", "full"],
                       default="full", help="执行步骤")
    parser.add_argument("--skip-bilibili", action="store_true", help="跳过B站发布")
    parser.add_argument("--duration", "-d", type=float, default=3.0,
                       help="每张图片显示时长")

    args = parser.parse_args()

    # 创建工作流
    workflow = VideoWorkflow(
        script_path=args.script,
        output_dir=args.output
    )

    # 设置音频路径
    if args.audio:
        workflow.audio_path = args.audio

    # 设置字幕路径
    if args.subtitle:
        workflow.subtitle_path = args.subtitle

    # 执行
    if args.step == "tts":
        if args.script:
            workflow.load_script()
        workflow.generate_tts(voice=args.voice)

    elif args.step == "subtitle":
        workflow.generate_subtitle(audio_path=args.audio)

    elif args.step == "assemble":
        result = workflow.assemble_video(images=args.images, duration_per_image=args.duration)

    elif args.step == "full":
        result = workflow.run(
            images=args.images,
            voice=args.voice,
            skip_bilibili=args.skip_bilibili
        )

        if result.get("success"):
            print_success("工作流执行成功!")
        else:
            print_error("工作流执行失败")
            sys.exit(1)


if __name__ == "__main__":
    main()
