#!/usr/bin/env python3
"""
草龟混养禁忌 - AI视频生成脚本
使用 HunyuanVideo 模型生成动画风格视频

使用方法:
    python generate_turtle_video.py
"""

import os
import torch
import imageio
import numpy as np

from diffusers import TextToVideoSDPipeline

# 配置
HF_HOME = os.environ.get("HF_HOME", "/mnt/d/framepack_models")
MODEL_ID = "ali-vilab/text-to-video-ms-1.7b"

# 视频生成提示词 - 动画风格
PROMPTS = {
    "opening": "Animated cartoon style, a peaceful pond with green grass, Chinese grass turtles swimming slowly among water plants, serene nature scene, soft colors, 2D animation style",
    "aggressive_fish": "Animated cartoon style, a fierce map fish and flowerhorn fish in a tank, attacking a small Chinese grass turtle, dramatic scene, vibrant colors, cartoon animation",
    "tropical_fish": "Animated cartoon style, colorful tropical fish and Chinese grass turtle in a tank with different water temperatures, steam rising, warning signs, cartoon style",
    "pleco_fish": "Animated cartoon style, a pleco catfish attached to a turtle shell, the turtle shell becoming damaged and rotting, close-up animation, educational style",
    "aggressive_turtle": "Animated cartoon style, an aggressive snapping turtle and a docile Chinese grass turtle in the same tank, the snapping turtle attacking, dramatic scene",
    "loach": "Animated cartoon style, a loach fish burrowing into a turtle body part, causing internal damage, cross-section view, educational animation style",
    "small_fish": "Animated cartoon style, tiny neon tetras and danios being eaten by an adult Chinese grass turtle in one bite, underwater scene, cartoon style",
    "ending": "Animated cartoon style, a wise old Chinese grass turtle looking at the camera, warning message appears, dramatic lighting, cartoon animation style"
}

def load_pipeline():
    """加载 Text-to-Video 管道"""
    model_path = f"{HF_HOME}/text-to-video-ms-1.7b"
    print(f"Loading model from: {model_path}")

    pipe = TextToVideoSDPipeline.from_pretrained(
        model_path,
        torch_dtype=torch.float16,
        local_files_only=True,
    )

    # 使用顺序 CPU offload 来节省显存（更慢但更省内存）
    pipe.enable_sequential_cpu_offload()

    return pipe

def save_video_as_mp4(frames, output_path, fps=15):
    """将视频帧保存为 MP4 格式"""
    writer = imageio.get_writer(output_path, fps=fps, codec='libx264', quality=8)
    for frame in frames:
        # 确保帧数据类型正确
        if frame.dtype != np.uint8:
            frame = (frame * 255).astype(np.uint8)
        writer.append_data(frame)
    writer.close()

def generate_video(pipe, prompt, output_path, num_frames=16, guidance_scale=9.0, num_inference_steps=50):
    """生成单个视频片段"""
    print(f"\n生成视频: {output_path}")
    print(f"提示词: {prompt}")

    with torch.inference_mode():
        output = pipe(
            prompt=prompt,
            num_frames=num_frames,
            guidance_scale=guidance_scale,
            num_inference_steps=num_inference_steps,
            height=256,
            width=384,
        )

        frames = output.frames[0]

    # 保存视频
    save_video_as_mp4(frames, output_path, fps=15)
    print(f"已保存: {output_path}")

def main():
    print("=" * 60)
    print("草龟混养禁忌 - AI视频生成器")
    print("=" * 60)

    # 创建输出目录
    output_dir = "/home/bigrice/video_output"
    os.makedirs(output_dir, exist_ok=True)

    # 加载模型
    print("\n正在加载 Text-to-Video 模型...")
    try:
        pipe = load_pipeline()
    except Exception as e:
        print(f"加载模型失败: {e}")
        print("\n请确保 HF_HOME 环境变量设置正确:")
        print(f"  export HF_HOME=/mnt/d/framepack_models")
        import traceback
        traceback.print_exc()
        return

    # 生成所有视频片段
    print("\n开始生成视频片段...")

    for key, prompt in PROMPTS.items():
        output_path = os.path.join(output_dir, f"{key}.mp4")
        try:
            generate_video(pipe, prompt, output_path)
        except Exception as e:
            print(f"生成 {key} 失败: {e}")

    print("\n" + "=" * 60)
    print("所有视频生成完成!")
    print(f"输出目录: {output_dir}")
    print("=" * 60)

if __name__ == "__main__":
    main()
