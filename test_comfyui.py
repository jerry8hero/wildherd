#!/usr/bin/env python3
import sys
sys.path.insert(0, 'scripts')

from comfyui_api import ComfyUIAPI, LineArtWorkflow

api = ComfyUIAPI(host="127.0.0.1", port=8188)
print(f"ComfyUI 就绪: {api.is_ready()}")

workflow = LineArtWorkflow(api)
print("测试生成...")

images = workflow.generate_lineart(
    prompt="a cute turtle, line art, sketch",
    negative_prompt="blurry, low quality",
    width=512,
    height=512,
    steps=20,
    output_dir="output/test_frames"
)

print(f"生成结果: {images}")
