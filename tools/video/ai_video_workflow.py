#!/usr/bin/env python3
"""
AI 线条画视频生成工作流 - 主脚本

整合所有组件生成 AI 线条画风格视频:
    脚本 → 分镜生成 → AI绘图 → 图片序列 → 视频合成 → 最终视频

使用方法:
    # 完整工作流
    python3 ai_video_workflow.py --script docs/video-scripts/鳄龟/02-养鳄龟需要准备什么硬核装备.md

    # 仅生成分镜
    python3 ai_video_workflow.py --script xxx.md --step storyboard

    # 仅生成线条画
    python3 ai_video_workflow.py --storyboard output/storyboards/xxx_storyboard.json --step generate

    # 仅合成视频
    python3 ai_video_workflow.py --images "output/frames/*.png" --audio output/audio.mp3 --step render
"""

import os
import sys
import json
import subprocess
import argparse
from pathlib import Path
from typing import Optional, List, Dict
from datetime import datetime
import shutil

# 导入本地模块
from storyboard_generator import StoryboardGenerator
from comfyui_api import ComfyUIAPI, LineArtWorkflow, check_comfyui_status
from bgm_finder import BGMFinder


class Colors:
    """颜色配置"""
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


class AIVideoWorkflow:
    """AI 线条画视频生成工作流"""

    def __init__(
        self,
        script_path: Optional[str] = None,
        output_dir: str = "output/ai_video"
    ):
        """
        初始化工作流

        Args:
            script_path: 视频脚本路径
            output_dir: 输出目录
        """
        self.script_path = script_path
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # 子目录
        self.frames_dir = self.output_dir / "frames"
        self.audio_dir = self.output_dir / "audio"
        self.video_dir = self.output_dir / "video"
        self.bgm_dir = self.output_dir / "bgm"

        for d in [self.frames_dir, self.audio_dir, self.video_dir, self.bgm_dir]:
            d.mkdir(parents=True, exist_ok=True)

        # 组件
        self.storyboard_generator = StoryboardGenerator()
        self.bgm_finder = BGMFinder()

        # 状态
        self.storyboard = None
        self.audio_path = None
        self.bgm_path = None
        self.subtitle_path = None
        self.frame_paths = []
        self.video_path = None

    def run_storyboard(self) -> Dict:
        """
        Step 1: 生成分镜

        Returns:
            分镜数据
        """
        print_step("1", "生成分镜")

        if not self.script_path:
            raise ValueError("未指定脚本路径")

        self.storyboard = self.storyboard_generator.generate(self.script_path)

        # 保存分镜
        script_name = Path(self.script_path).stem
        storyboard_path = self.output_dir / f"{script_name}_storyboard.json"
        self.storyboard_generator.save_to_json(str(storyboard_path))

        print_success(f"分镜已生成: {storyboard_path}")
        print(f"  场景数: {self.storyboard['total_scenes']}")
        print(f"  预计时长: {self.storyboard['estimated_duration']}秒")

        return self.storyboard

    def run_lineart_generation(
        self,
        comfyui_host: str = "127.0.0.1",
        comfyui_port: int = 8188
    ) -> List[str]:
        """
        Step 2: 生成线条画

        Args:
            comfyui_host: ComfyUI 地址
            comfyui_port: ComfyUI 端口

        Returns:
            生成的图片路径列表
        """
        print_step("2", "生成线条画")

        if not self.storyboard:
            raise ValueError("请先运行分镜生成")

        # 检查 ComfyUI 连接
        api = ComfyUIAPI(host=comfyui_host, port=comfyui_port)
        if not api.is_ready():
            print_error("ComfyUI 未连接，请先启动 ComfyUI")
            print(f"  启动命令: cd ~/ComfyUI && python main.py --listen {comfyui_host} --port {comfyui_port}")
            print(f"  访问地址: http://{comfyui_host}:{comfyui_port}")
            return []

        workflow = LineArtWorkflow(api)

        # 获取分镜中的提示词
        prompts = []
        for scene in self.storyboard["scenes"]:
            prompts.append({
                "scene_id": scene["scene_id"],
                "prompt": scene["prompt"],
                "negative_prompt": scene.get("negative_prompt", "")
            })

        # 批量生成
        total = len(prompts)
        all_images = []

        for i, p in enumerate(prompts, 1):
            print(f"\n  [{i}/{total}] 生成场景 {p['scene_id']}...")

            scene_dir = self.frames_dir / f"scene_{p['scene_id']:03d}"
            scene_dir.mkdir(parents=True, exist_ok=True)

            images = workflow.generate_lineart(
                prompt=p["prompt"],
                negative_prompt=p.get("negative_prompt", ""),
                output_dir=str(scene_dir)
            )

            if images:
                all_images.extend(images)
                print(f"    生成 {len(images)} 张图片")
            else:
                print_warning(f"    生成失败，将使用占位图")

                # 创建占位图
                placeholder = self._create_placeholder(
                    str(scene_dir / "placeholder.png"),
                    p["prompt"]
                )
                if placeholder:
                    all_images.append(placeholder)

        self.frame_paths = all_images
        print_success(f"线条画生成完成: {len(all_images)} 张图片")

        return all_images

    def _create_placeholder(self, path: str, text: str) -> Optional[str]:
        """创建占位图"""
        try:
            from PIL import Image, ImageDraw, ImageFont

            # 创建空白图片
            img = Image.new("RGB", (1280, 720), color=(240, 240, 240))
            draw = ImageDraw.Draw(img)

            # 添加文字
            try:
                font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 24)
            except:
                font = ImageFont.load_default()

            # 换行处理
            max_chars = 40
            if len(text) > max_chars:
                lines = [text[i:i+max_chars] for i in range(0, len(text), max_chars)]
            else:
                lines = [text]

            y = 320
            for line in lines[:5]:  # 最多5行
                bbox = draw.textbbox((0, 0), line, font=font)
                w = bbox[2] - bbox[0]
                draw.text(((1280 - w) // 2, y), line, fill=(100, 100, 100), font=font)
                y += 30

            img.save(path)
            return path
        except Exception as e:
            print(f"创建占位图失败: {e}")
        return None

    def run_line_extraction(
        self,
        canny_low: int = 40,
        canny_high: int = 120
    ) -> List[str]:
        """
        Step 2.5: 线条提取后处理

        将AI生成的彩色图像转换为纯线条画风格

        Args:
            canny_low: Canny边缘检测低阈值
            canny_high: Canny边缘检测高阈值

        Returns:
            处理后的图片路径列表
        """
        print_step("2.5", "线条提取后处理")

        if not self.frame_paths:
            print_warning("没有图片需要处理")
            return []

        try:
            import cv2
            import numpy as np
        except ImportError:
            print_error("需要安装 OpenCV: pip install opencv-python")
            return self.frame_paths

        processed_paths = []
        total = len(self.frame_paths)

        for i, img_path in enumerate(self.frame_paths, 1):
            try:
                # 读取图像
                img = cv2.imread(img_path)
                if img is None:
                    print_warning(f"无法读取: {img_path}")
                    processed_paths.append(img_path)
                    continue

                # 转换为灰度
                gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

                # 模糊减少噪声
                blurred = cv2.GaussianBlur(gray, (5, 5), 0)

                # 边缘检测
                edges = cv2.Canny(blurred, canny_low, canny_high)

                # 膨胀连接线条
                kernel = np.ones((2, 2), np.uint8)
                edges = cv2.dilate(edges, kernel, iterations=1)

                # 腐蚀细化
                kernel = np.ones((1, 1), np.uint8)
                edges = cv2.erode(edges, kernel, iterations=1)

                # 反转：白底黑线 -> 黑底白线
                line_art = 255 - edges

                # 保存
                path = Path(img_path)
                output_path = path.parent / f"{path.stem}_lineart{path.suffix}"
                cv2.imwrite(str(output_path), line_art)

                processed_paths.append(str(output_path))
                print(f"  [{i}/{total}] 已处理: {path.name}")

            except Exception as e:
                print_warning(f"处理失败 {img_path}: {e}")
                processed_paths.append(img_path)

        self.frame_paths = processed_paths
        print_success(f"线条提取完成: {len(processed_paths)} 张图片")

        return processed_paths

    def run_tts(self, voice: str = "xiaoxiao") -> str:
        """
        Step 3: 生成 TTS 配音

        Args:
            voice: TTS 声音

        Returns:
            音频文件路径
        """
        print_step("3", "生成 TTS 配音")

        if not self.script_path:
            raise ValueError("未指定脚本路径")

        # 使用现有的 TTS 生成
        try:
            # 提取文本
            with open(self.script_path, "r", encoding="utf-8") as f:
                content = f.read()

            # 简单提取文本
            lines = content.split("\n")
            text_parts = []
            for line in lines:
                if line.startswith("# "):
                    text_parts.append(line[2:].strip())
                elif line.startswith("- "):
                    text_parts.append(line[2:].strip())
                elif line.strip() and not line.startswith("!"):
                    text_parts.append(line.strip())

            full_text = "。".join(text_parts)
            full_text = full_text.replace("。。", "。")

            # 生成音频
            audio_path = self.audio_dir / "tts.mp3"

            import asyncio
            import edge_tts

            async def generate():
                communicate = edge_tts.Communicate(
                    full_text,
                    f"zh-CN-{voice.title()}Neural",
                    rate="+10%"
                )
                await communicate.save(str(audio_path))

            asyncio.run(generate())

            self.audio_path = str(audio_path)
            print_success(f"TTS 已生成: {self.audio_path}")

            return self.audio_path

        except ImportError:
            print_warning("未安装 edge-tts，跳过 TTS 生成")
            return ""
        except Exception as e:
            print_error(f"TTS 生成失败: {e}")
            return ""

    def run_subtitle(self, audio_path: Optional[str] = None) -> str:
        """
        Step 4: 生成字幕

        Args:
            audio_path: 音频文件路径

        Returns:
            字幕文件路径
        """
        print_step("4", "生成字幕")

        if audio_path:
            self.audio_path = audio_path

        if not self.audio_path or not Path(self.audio_path).exists():
            print_warning("未找到音频文件，跳过字幕生成")
            return ""

        subtitle_path = Path(self.audio_path).with_suffix(".srt")
        self.subtitle_path = str(subtitle_path)

        try:
            import whisper

            print("  加载 Whisper 模型...")
            model = whisper.load_model("base")

            print("  转录音频...")
            result = model.transcribe(self.audio_path, language="zh")

            # 生成 SRT
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

            print_success(f"字幕已生成: {self.subtitle_path}")
            print(f"  字幕段数: {len(segments)}")

            return self.subtitle_path

        except ImportError:
            print_warning("未安装 whisper，跳过字幕生成")
            return ""
        except Exception as e:
            print_error(f"字幕生成失败: {e}")
            return ""

    def _format_srt_time(self, seconds: float) -> str:
        """格式化 SRT 时间"""
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        secs = int(seconds % 60)
        millis = int((seconds % 1) * 1000)
        return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"

    def run_bgm_match(self) -> str:
        """
        Step 5: 匹配 BGM

        Returns:
            BGM 文件路径
        """
        print_step("5", "匹配 BGM")

        if not self.storyboard:
            raise ValueError("请先运行分镜生成")

        duration = self.storyboard["estimated_duration"]

        # 尝试根据脚本内容匹配
        keywords = []
        for scene in self.storyboard["scenes"]:
            # 从描述中提取关键词
            desc = scene.get("description", "")
            words = desc.split("，") + desc.split("。")
            keywords.extend([w.strip() for w in words if len(w.strip()) >= 2])

        track = self.bgm_finder.get_bgm_for_script(keywords, duration)

        if track:
            # 如果是本地文件，复制到输出目录
            if track.file_path and Path(track.file_path).exists():
                bgm_output = self.bgm_dir / f"{track.id}.mp3"
                shutil.copy(track.file_path, bgm_output)
                self.bgm_path = str(bgm_output)
            else:
                self.bgm_path = track.file_path

            print_success(f"BGM 已匹配: {track.title}")
            print(f"  时长: {track.duration:.0f}秒")
            print(f"  风格: {track.mood}")
        else:
            print_warning("未找到匹配的 BGM")

        return self.bgm_path or ""

    def run_video_render(
        self,
        fps: int = 24,
        video_width: int = 1280,
        video_height: int = 720
    ) -> str:
        """
        Step 6: 渲染视频

        Args:
            fps: 帧率
            video_width: 视频宽度
            video_height: 视频高度

        Returns:
            视频文件路径
        """
        print_step("6", "渲染视频")

        if not self.frame_paths and not self.audio_path:
            raise ValueError("请先生成图片或音频")

        # 如果没有图片，创建一个简单的视频
        if not self.frame_paths:
            print_warning("没有生成图片，创建图片序列...")
            self._create_placeholder_sequence()

        video_path = self.video_dir / "output.mp4"

        # 使用 FFmpeg 合成视频
        cmd = [
            "ffmpeg", "-y"
        ]

        # 输入图片
        if len(self.frame_paths) == 1:
            # 单张图片循环
            cmd.extend(["-loop", "1", "-i", self.frame_paths[0]])
        else:
            # 图片序列 - 需要先创建输入文件
            # 简化处理：使用 glob 模式
            pass

        # 如果有音频
        if self.audio_path and Path(self.audio_path).exists():
            cmd.extend(["-i", self.audio_path])

        # FFmpeg 命令构建
        cmd = [
            "ffmpeg", "-y",
            "-f", "image2",
            "-framerate", str(fps),
            "-pattern_type", "glob",
            "-i", f"{self.frames_dir}/*.png",
            "-i", self.audio_path if self.audio_path and Path(self.audio_path).exists() else None,
            "-c:v", "libx264",
            "-preset", "fast",
            "-crf", "23",
            "-pix_fmt", "yuv420p",
            "-vf", f"scale={video_width}:{video_height}"
        ]

        # 移除 None 元素
        cmd = [c for c in cmd if c is not None]

        # 如果有 BGM，混合音频
        if self.bgm_path and Path(self.bgm_path).exists() and self.audio_path:
            # 混合配音和 BGM
            cmd.extend(["-filter_complex", "[1:a]volume=0.8[bgm];[bgm][2:a]amix=inputs=2:duration=first[aout]"])
            cmd.extend(["-map", "0:v", "-map", "[aout]"])
        elif self.audio_path and Path(self.audio_path).exists():
            cmd.extend(["-map", "0:v", "-map", "1:a"])

        cmd.append(str(video_path))

        # 移除 None
        cmd = [c for c in cmd if c is not None]

        print(f"  执行: ffmpeg {' '.join(cmd[:5])}...")

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=600
            )

            if result.returncode != 0:
                print_error(f"FFmpeg 错误: {result.stderr[:500]}")
                # 尝试简化命令
                video_path = self._render_simple_video()
            else:
                self.video_path = str(video_path)
                print_success(f"视频已渲染: {self.video_path}")
        except Exception as e:
            print_error(f"渲染失败: {e}")
            video_path = self._render_simple_video()

        return self.video_path

    def _create_placeholder_sequence(self):
        """创建占位图序列"""
        for i in range(1, 11):
            scene_dir = self.frames_dir / f"scene_{i:03d}"
            scene_dir.mkdir(parents=True, exist_ok=True)
            self._create_placeholder(
                str(scene_dir / f"frame_{i:03d}.png"),
                f"场景 {i}"
            )

    def _render_simple_video(self) -> str:
        """简化视频渲染"""
        video_path = self.video_dir / "output_simple.mp4"

        cmd = [
            "ffmpeg", "-y",
            "-f", "image2",
            "-framerate", "1",
            "-pattern_type", "glob",
            "-i", f"{self.frames_dir}/*/*.png",
            "-i", self.audio_path if self.audio_path else "/dev/null",
            "-c:v", "libx264",
            "-preset", "fast",
            "-shortest",
            str(video_path)
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                self.video_path = str(video_path)
                print_success(f"视频已渲染(简化版): {self.video_path}")
            else:
                print_error(f"简化渲染也失败了: {result.stderr[:200]}")
        except Exception as e:
            print_error(f"简化渲染失败: {e}")

        return self.video_path or ""

    def run_subtitle_burn(self) -> str:
        """
        Step 7: 烧录字幕

        Returns:
            最终视频路径
        """
        print_step("7", "烧录字幕")

        if not self.video_path:
            raise ValueError("请先渲染视频")

        if not self.subtitle_path or not Path(self.subtitle_path).exists():
            print_warning("没有字幕文件，跳过")
            return self.video_path

        final_path = self.video_dir / "final_with_subtitle.mp4"

        cmd = [
            "ffmpeg", "-y",
            "-i", self.video_path,
            "-vf", f"subtitles={self.subtitle_path}",
            "-c:a", "copy",
            str(final_path)
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True)

            if result.returncode == 0:
                self.video_path = str(final_path)
                print_success(f"字幕已烧录: {self.video_path}")
            else:
                print_warning(f"字幕烧录失败: {result.stderr[:200]}")
        except Exception as e:
            print_error(f"字幕烧录失败: {e}")

        return self.video_path

    def run(
        self,
        voice: str = "xiaoxiao",
        comfyui_host: str = "127.0.0.1",
        comfyui_port: int = 8188,
        skip_comfyui: bool = False,
        skip_bgm: bool = False
    ) -> Dict:
        """
        运行完整工作流

        Args:
            voice: TTS 声音
            comfyui_host: ComfyUI 地址
            comfyui_port: ComfyUI 端口
            skip_comfyui: 跳过 AI 绘图
            skip_bgm: 跳过 BGM

        Returns:
            工作流结果
        """
        print_header("AI 线条画视频生成工作流")
        print(f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

        result = {
            "success": True,
            "steps": {}
        }

        try:
            # Step 1: 分镜
            if self.script_path:
                self.run_storyboard()
                result["steps"]["storyboard"] = {"success": True}

            # Step 2: AI 绘图
            if not skip_comfyui:
                frames = self.run_lineart_generation(comfyui_host, comfyui_port)
                result["steps"]["lineart"] = {
                    "success": len(frames) > 0,
                    "frames": len(frames)
                }

                # Step 2.5: 线条提取后处理
                self.run_line_extraction()

            # Step 3: TTS
            audio_path = self.run_tts(voice=voice)
            result["steps"]["tts"] = {"success": bool(audio_path), "path": audio_path}

            # Step 4: 字幕
            subtitle_path = self.run_subtitle()
            result["steps"]["subtitle"] = {"success": bool(subtitle_path), "path": subtitle_path}

            # Step 5: BGM
            if not skip_bgm:
                bgm_path = self.run_bgm_match()
                result["steps"]["bgm"] = {"success": bool(bgm_path), "path": bgm_path}

            # Step 6: 渲染
            video_path = self.run_video_render()
            result["steps"]["render"] = {"success": bool(video_path), "path": video_path}

            # Step 7: 字幕烧录
            if subtitle_path:
                final_path = self.run_subtitle_burn()
                result["steps"]["subtitle_burn"] = {"success": bool(final_path), "path": final_path}

            result["final_video"] = self.video_path
            result["success"] = bool(self.video_path)

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

        # 保存结果
        result_path = self.output_dir / "workflow_result.json"
        with open(result_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)

        return result


def main():
    parser = argparse.ArgumentParser(
        description="AI 线条画视频生成工作流",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 完整工作流
  python3 ai_video_workflow.py --script docs/video-scripts/鳄龟/02-养鳄龟需要准备什么硬核装备.md

  # 跳过 AI 绘图（用于测试）
  python3 ai_video_workflow.py --script xxx.md --skip-comfyui

  # 检查 ComfyUI 状态
  python3 ai_video_workflow.py --check-comfyui

  # 仅生成分镜
  python3 ai_video_workflow.py --script xxx.md --step storyboard

工作流程:
  1. 分镜生成 - 根据脚本生成场景描述和 AI 提示词
  2. AI 绘图 - 调用 ComfyUI 生成线条画
  3. TTS 配音 - 使用 Edge TTS 生成配音
  4. 字幕生成 - 使用 Whisper 识别生成字幕
  5. BGM 匹配 - 从本地库匹配背景音乐
  6. 视频渲染 - FFmpeg 合成视频
  7. 字幕烧录 - FFmpeg 烧录字幕
        """
    )

    parser.add_argument("--script", "-s", help="视频脚本文件路径")
    parser.add_argument("--output", "-o", default="output/ai_video", help="输出目录")
    parser.add_argument("--voice", "-v", default="xiaoxiao", help="TTS 声音")
    parser.add_argument("--step", "-t", choices=["storyboard", "lineart", "tts", "subtitle", "render", "full"],
                       default="full", help="执行步骤")

    # ComfyUI 配置
    parser.add_argument("--comfyui-host", default="127.0.0.1", help="ComfyUI 地址")
    parser.add_argument("--comfyui-port", type=int, default=8188, help="ComfyUI 端口")
    parser.add_argument("--skip-comfyui", action="store_true", help="跳过 AI 绘图")
    parser.add_argument("--skip-bgm", action="store_true", help="跳过 BGM")

    # 检查
    parser.add_argument("--check-comfyui", action="store_true", help="检查 ComfyUI 状态")

    args = parser.parse_args()

    # 检查 ComfyUI 状态
    if args.check_comfyui:
        check_comfyui_status(args.comfyui_host, args.comfyui_port)
        return

    # 创建工作流
    workflow = AIVideoWorkflow(
        script_path=args.script,
        output_dir=args.output
    )

    # 执行
    if args.step == "storyboard":
        result = workflow.run_storyboard()

    elif args.step == "lineart":
        frames = workflow.run_lineart_generation(args.comfyui_host, args.comfyui_port)
        print(f"生成 {len(frames)} 张图片")

    elif args.step == "tts":
        path = workflow.run_tts(args.voice)
        print(f"音频: {path}")

    elif args.step == "subtitle":
        path = workflow.run_subtitle()
        print(f"字幕: {path}")

    elif args.step == "render":
        path = workflow.run_video_render()
        print(f"视频: {path}")

    elif args.step == "full":
        result = workflow.run(
            voice=args.voice,
            comfyui_host=args.comfyui_host,
            comfyui_port=args.comfyui_port,
            skip_comfyui=args.skip_comfyui,
            skip_bgm=args.skip_bgm
        )

        if result.get("success"):
            print_success("工作流执行成功!")
        else:
            print_error("工作流执行失败")
            sys.exit(1)


if __name__ == "__main__":
    main()
