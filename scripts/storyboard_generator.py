#!/usr/bin/env python3
"""
分镜生成器

根据视频脚本，自动生成AI绘图提示词

使用方法:
    python3 storyboard_generator.py --script docs/video-scripts/鳄龟/02-养鳄龟需要准备什么硬核装备.md

输出:
    分镜列表，每个分镜包含:
    - scene_id: 场景编号
    - duration: 预计时长(秒)
    - description: 场景描述
    - prompt: AI绘图正向提示词
    - negative_prompt: AI绘图负向提示词
"""

import os
import re
import json
import argparse
from pathlib import Path
from typing import List, Dict, Optional


# 默认线条画风提示词模板
LINEART_PROMPT_TEMPLATE = """
风格: 线条画风格 (Lineart Style)
- 纯线条勾勒，无填充或极少填充
- 清晰的轮廓线
- 简洁的阴影线表示层次
- 类似铅笔画或钢笔画

主题: {subject}
场景: {scene_description}

细节要求:
- 保持画面简洁
- 重点突出主体
- 适合动画制作
"""

NEGATIVE_PROMPT = """
photo realistic, photorealistic, 3d render, real photograph, blurry, noise, low quality,
distorted, bad anatomy, extra fingers, deformed limbs, bad hands, face errors,
watermark, text, gray background, grey background, shading, gradient, realistic texture,
complex lighting, soft shading, detailed shadows, oil painting, watercolor, messy, cluttered,
dark, moody, dramatic lighting, cinematic
"""


class StoryboardGenerator:
    """分镜生成器"""

    def __init__(self):
        self.segments = []

    def parse_script(self, script_path: str) -> str:
        """解析Markdown脚本"""
        with open(script_path, "r", encoding="utf-8") as f:
            content = f.read()
        return content

    def split_scenes(self, script_content: str) -> List[str]:
        """
        将脚本分割成场景

        分割规则:
        - 按 --- 分隔符分割
        - 每个段落为一个场景
        """
        # 按分隔符分割
        parts = script_content.split("---")

        scenes = []
        for part in parts:
            part = part.strip()
            if part and len(part) > 20:  # 过滤太短的内容
                scenes.append(part)

        return scenes

    def extract_key_info(self, scene_text: str) -> Dict:
        """
        从场景文本中提取关键信息

        Returns:
            {
                "keywords": ["鳄龟", "缸", "过滤"],
                "main_subject": "鳄龟",
                "action": "描述动作或状态"
            }
        """
        # 移除 Markdown 格式
        text = re.sub(r'#+\s', '', scene_text)
        text = re.sub(r'\[.*?\]\(.*?\)', '', text)
        text = re.sub(r'[!*_`]', '', text)

        # 提取关键词（中文词汇）
        # 简单实现：提取连续的中文词汇
        chinese_words = re.findall(r'[\u4e00-\u9fa5]+', text)

        # 去重但保持顺序
        seen = set()
        unique_words = []
        for word in chinese_words:
            if word not in seen and len(word) >= 2:
                seen.add(word)
                unique_words.append(word)

        # 确定主体（通常是第一个重要名词）
        subjects = ["鳄龟", "大鳄龟", "小鳄龟", "草龟", "巴西龟", "龟",
                   "过滤", "加热棒", "水缸", "晒台", "温度", "水质"]

        main_subject = None
        for subject in subjects:
            if subject in text:
                main_subject = subject
                break

        if not main_subject and unique_words:
            main_subject = unique_words[0]

        return {
            "keywords": unique_words[:10],  # 取前10个关键词
            "main_subject": main_subject or "爬宠",
            "raw_text": text[:200]  # 取前200字符
        }

    def generate_prompt(self, scene_text: str, scene_num: int) -> Dict:
        """
        为场景生成AI绘图提示词

        Returns:
            {
                "scene_id": 1,
                "duration": 5,
                "description": "场景描述",
                "prompt": "正向提示词",
                "negative_prompt": "负向提示词"
            }
        """
        info = self.extract_key_info(scene_text)

        # 生成场景描述
        description = info["raw_text"].replace("\n", " ")[:100]

        # 分析场景内容类型，生成对应的视觉描述
        scene_type = self._analyze_scene_type(scene_text)

        # 生成专业的线条画提示词
        prompt = self._build_lineart_prompt(info, scene_type)

        return {
            "scene_id": scene_num,
            "duration": self._estimate_duration(scene_text),
            "description": description,
            "prompt": prompt,
            "negative_prompt": NEGATIVE_PROMPT.strip()
        }

    def _analyze_scene_type(self, scene_text: str) -> str:
        """分析场景内容类型"""
        text_lower = scene_text.lower()

        if any(kw in text_lower for kw in ["缸", "水缸", "容器", "饲养"]):
            return "tank_aquarium"
        elif any(kw in text_lower for kw in ["过滤", "过滤器", "滤材"]):
            return "filtration"
        elif any(kw in text_lower for kw in ["加热", "温度", "加热棒", "恒温"]):
            return "heating"
        elif any(kw in text_lower for kw in ["喂食", "吃东西", "开食", "饲料"]):
            return "feeding"
        elif any(kw in text_lower for kw in ["安全", "夹子", "手套", "工具"]):
            return "safety_tools"
        elif any(kw in text_lower for kw in ["龟", "鳄龟", "爬宠"]):
            return "turtle"
        else:
            return "general"

    def _build_lineart_prompt(self, info: Dict, scene_type: str) -> str:
        """
        构建插画提示词

        注意：SDXL不擅长纯线条画，所以这里生成风格化插画，
        然后通过后处理（Canny边缘检测）提取线条
        """

        # 场景类型对应的视觉元素 - 使用清晰结构化的描述
        visual_elements = {
            "tank_aquarium": "a large glass aquarium tank, clear water, gravel bottom, simple minimal style, clean edges and outlines",
            "filtration": "an aquarium filtration system, multiple filter boxes, water pump, clean mechanical design, clear structure",
            "heating": "a water heater rod thermostat, temperature gauge, warm water bubbles, aquarium equipment",
            "feeding": "a turtle eating food pellets, hand holding tweezers, simple aquarium scene",
            "safety_tools": "turtle handling tools, long tongs, protective gloves, a turtle, simple composition",
            "turtle": "an alligator snapping turtle, close up view, visible shell pattern, strong legs, underwater",
            "general": "a simple clean illustration, clear subject, minimal background"
        }

        elements = visual_elements.get(scene_type, visual_elements["general"])

        # 主体
        subject = info.get("main_subject", "turtle")
        subject_mapping = {
            "鳄龟": "an alligator snapping turtle",
            "大鳄龟": "a large alligator snapping turtle",
            "小鳄龟": "a small turtle",
            "草龟": "a Chinese pond turtle",
            "巴西龟": "a red-eared slider turtle",
            "龟": "a turtle",
            "爬宠": "a reptile pet"
        }
        subject_desc = subject_mapping.get(subject, subject)

        # 构建提示词 - 生成风格化插画
        # SDXL擅长生成这类内容，然后通过后处理提取线条
        prompt = f"a clean digital illustration, {subject_desc}, {elements}, minimalist style, clear edges, simple shapes, solid colors, vector art style, flat design, no complex shading"

        return prompt

    def _estimate_duration(self, scene_text: str) -> int:
        """
        根据文本长度估算场景时长

        规则:
        - 每50个字约1秒配音
        - 最少3秒，最多15秒
        """
        chinese_chars = len(re.findall(r'[\u4e00-\u9fa5]', scene_text))
        duration = max(3, min(15, chinese_chars // 50 + 3))
        return duration

    def generate(self, script_path: str) -> List[Dict]:
        """
        生成完整分镜

        Args:
            script_path: 脚本文件路径

        Returns:
            分镜列表
        """
        script_content = self.parse_script(script_path)
        scenes = self.split_scenes(script_content)

        storyboard = []
        total_duration = 0

        for i, scene in enumerate(scenes, 1):
            prompt_data = self.generate_prompt(scene, i)
            storyboard.append(prompt_data)
            total_duration += prompt_data["duration"]

        # 添加元数据
        result = {
            "script": script_path,
            "total_scenes": len(storyboard),
            "estimated_duration": total_duration,
            "scenes": storyboard
        }

        self.segments = result
        return result

    def save_to_json(self, output_path: str):
        """保存分镜到JSON文件"""
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(self.segments, f, ensure_ascii=False, indent=2)

    def save_to_markdown(self, output_path: str):
        """保存分镜到Markdown文件"""
        lines = [
            "# 分镜脚本",
            "",
            f"**总场景数**: {self.segments['total_scenes']}",
            f"**预计时长**: {self.segments['estimated_duration']}秒",
            "",
            "---",
            ""
        ]

        for scene in self.segments["scenes"]:
            lines.extend([
                f"## 场景 {scene['scene_id']}",
                "",
                f"**时长**: {scene['duration']}秒",
                "",
                f"**描述**: {scene['description']}",
                "",
                f"**正向提示词**:",
                f"```",
                scene["prompt"],
                f"```",
                "",
                f"**负向提示词**:",
                f"```",
                scene["negative_prompt"],
                f"```",
                "",
                "---",
                ""
            ])

        with open(output_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))

    def print_summary(self):
        """打印分镜摘要"""
        if not self.segments:
            print("无分镜数据")
            return

        print("\n" + "="*60)
        print("分镜生成完成")
        print("="*60)
        print(f"总场景数: {self.segments['total_scenes']}")
        print(f"预计时长: {self.segments['estimated_duration']}秒")
        print("-"*60)

        for scene in self.segments["scenes"]:
            print(f"\n场景 {scene['scene_id']} ({scene['duration']}秒)")
            print(f"  描述: {scene['description'][:50]}...")
            print(f"  提示词: {scene['prompt'][:60]}...")


def main():
    parser = argparse.ArgumentParser(
        description="分镜生成器 - 根据脚本生成AI绘图提示词"
    )
    parser.add_argument("script", help="视频脚本文件路径")
    parser.add_argument("--output", "-o", help="输出文件路径")
    parser.add_argument("--format", "-f", choices=["json", "markdown", "both"],
                       default="both", help="输出格式")

    args = parser.parse_args()

    if not os.path.exists(args.script):
        print(f"错误: 文件不存在 {args.script}")
        return

    # 生成
    generator = StoryboardGenerator()
    result = generator.generate(args.script)

    # 输出
    generator.print_summary()

    # 保存
    script_name = Path(args.script).stem
    output_dir = Path(args.script).parent.parent / "storyboards"
    output_dir.mkdir(parents=True, exist_ok=True)

    if args.format in ["json", "both"]:
        json_path = output_dir / f"{script_name}_storyboard.json"
        generator.save_to_json(str(json_path))
        print(f"\n✓ JSON已保存: {json_path}")

    if args.format in ["markdown", "both"]:
        md_path = output_dir / f"{script_name}_storyboard.md"
        generator.save_to_markdown(str(md_path))
        print(f"✓ Markdown已保存: {md_path}")


if __name__ == "__main__":
    main()
