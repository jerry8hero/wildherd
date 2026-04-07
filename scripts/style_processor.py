#!/usr/bin/env python3
"""
图像风格化处理器

对AI生成的插画进行风格统一处理：
- 去饱和度
- 增强对比度
- 统一色调

用于创建一致的视频视觉风格
"""

import cv2
import numpy as np
from pathlib import Path
from PIL import Image
import argparse


def stylize_image(
    input_path: str,
    output_path: str = None,
    saturation: float = 0.7,  # 0.0 = 灰度, 1.0 = 原始
    contrast: float = 1.2,    # 1.0 = 原始
    brightness: float = 1.0,  # 1.0 = 原始
    warmth: float = 0.0,       # -1.0 = 冷, 0.0 = 中性, 1.0 = 暖
    vignette: float = 0.0      # 0.0 = 无, 1.0 = 强
) -> str:
    """
    对图像进行风格化处理

    Args:
        input_path: 输入图像路径
        output_path: 输出路径
        saturation: 饱和度 (0.0-1.0)
        contrast: 对比度 (1.0 = 原始)
        brightness: 亮度 (1.0 = 原始)
        warmth: 暖色调调整 (-1.0 到 1.0)
        vignette: 暗角效果 (0.0-1.0)

    Returns:
        输出图像路径
    """
    # 读取图像
    img = cv2.imread(input_path)
    if img is None:
        raise ValueError(f"无法读取图像: {input_path}")

    # 转换为浮点数
    img_f = img.astype(np.float32) / 255.0

    # 调整亮度
    if brightness != 1.0:
        img_f = img_f * brightness
        img_f = np.clip(img_f, 0, 1)

    # 调整对比度
    if contrast != 1.0:
        mean = np.mean(img_f)
        img_f = (img_f - mean) * contrast + mean
        img_f = np.clip(img_f, 0, 1)

    # 调整饱和度
    if saturation != 1.0:
        # 转换到HSV
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV).astype(np.float32)
        hsv[:, :, 1] = hsv[:, :, 1] * saturation
        hsv[:, :, 1] = np.clip(hsv[:, :, 1], 0, 255)
        img = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR)
        img_f = img.astype(np.float32) / 255.0

    # 调整暖色调
    if warmth != 0.0:
        # 减少蓝色，增加红色（暖色调）
        if warmth > 0:
            img_f[:, :, 0] = img_f[:, :, 0] * (1 - warmth * 0.3)  # B通道
            img_f[:, :, 2] = img_f[:, :, 2] * (1 + warmth * 0.2)  # R通道
        else:
            img_f[:, :, 0] = img_f[:, :, 0] * (1 - warmth * 0.2)  # B通道
            img_f[:, :, 2] = img_f[:, :, 2] * (1 + warmth * 0.3)  # R通道
        img_f = np.clip(img_f, 0, 1)

    # 暗角效果
    if vignette > 0:
        rows, cols = img_f.shape[:2]
        kernel_x = cv2.getGaussianKernel(cols, cols / 2)
        kernel_y = cv2.getGaussianKernel(rows, rows / 2)
        kernel = kernel_y * kernel_x.T
        mask = kernel / kernel.max()
        mask = 1 - (1 - mask) * vignette

        # 应用暗角
        for c in range(3):
            img_f[:, :, c] = img_f[:, :, c] * mask

    # 转换回 uint8
    result = (img_f * 255).astype(np.uint8)

    # 保存
    if output_path is None:
        input_file = Path(input_path)
        output_path = str(input_file.parent / f"{input_file.stem}_styled{input_file.suffix}")

    cv2.imwrite(output_path, result)
    print(f"风格化完成: {output_path}")

    return output_path


def batch_stylize(
    input_dir: str,
    output_dir: str = None,
    pattern: str = "*.png",
    **kwargs
):
    """
    批量处理图像
    """
    input_path = Path(input_dir)
    if output_dir:
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
    else:
        output_path = input_path

    files = list(input_path.glob(pattern))
    print(f"找到 {len(files)} 个图像文件")

    for f in files:
        try:
            out_file = output_path / f"{f.stem}_styled{f.suffix}"
            stylize_image(str(f), str(out_file), **kwargs)
        except Exception as e:
            print(f"处理失败 {f.name}: {e}")

    print(f"批量处理完成: {len(files)} 个文件")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="图像风格化处理器")
    parser.add_argument("input", help="输入图像或目录")
    parser.add_argument("-o", "--output", help="输出路径")
    parser.add_argument("--sat", type=float, default=0.7, help="饱和度 (0.0-1.0)")
    parser.add_argument("--contrast", type=float, default=1.2, help="对比度")
    parser.add_argument("--brightness", type=float, default=1.0, help="亮度")
    parser.add_argument("--warmth", type=float, default=0.0, help="暖色调 (-1到1)")
    parser.add_argument("--vignette", type=float, default=0.0, help="暗角 (0-1)")
    parser.add_argument("--batch", action="store_true", help="批量处理目录")

    args = parser.parse_args()

    kwargs = {
        "saturation": args.sat,
        "contrast": args.contrast,
        "brightness": args.brightness,
        "warmth": args.warmth,
        "vignette": args.vignette
    }

    if args.batch:
        batch_stylize(args.input, args.output, **kwargs)
    else:
        stylize_image(args.input, args.output, **kwargs)