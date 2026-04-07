#!/usr/bin/env python3
import shutil
from pathlib import Path

# 从 ComfyUI output 复制最新图片
comfy_output = Path.home() / "ComfyUI" / "output"
output_dir = Path("output/test_frames")
output_dir.mkdir(parents=True, exist_ok=True)

# 找最新的 lineart 图片
images = sorted(comfy_output.glob("lineart_*.png"))
if images:
    latest = images[-1]
    dest = output_dir / latest.name
    shutil.copy(latest, dest)
    print(f"复制图片: {latest} -> {dest}")
    print(f"大小: {dest.stat().st_size} bytes")
else:
    print("没有找到 lineart 图片")
