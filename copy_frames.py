#!/usr/bin/env python3
import shutil
from pathlib import Path

comfy_output = Path.home() / "ComfyUI" / "output"
frames_dir = Path("output/ai_video/frames")

# 获取所有 lineart 图片
lineart_files = sorted(comfy_output.glob("lineart_*.png"))
print(f"找到 {len(lineart_files)} 张 AI 生成的图片")

# 为每个场景复制一张图片
for i in range(1, 9):
    scene_dir = frames_dir / f"scene_{i:03d}"
    scene_dir.mkdir(parents=True, exist_ok=True)

    # 计算对应的图片索引
    idx = min(i - 1, len(lineart_files) - 1)
    if idx >= 0 and lineart_files:
        src = lineart_files[idx]
        dst = scene_dir / f"frame_{i:03d}.png"
        shutil.copy(src, dst)
        print(f"场景 {i}: {src.name} -> {dst}")
    else:
        print(f"场景 {i}: 没有对应图片")

print("\n复制完成!")
