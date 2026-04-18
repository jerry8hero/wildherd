#!/usr/bin/env python3
"""
线条画后处理器

将AI生成的彩色图像转换为纯线条画风格

使用Canny边缘检测和阈值处理提取线条
"""

import cv2
import numpy as np
from pathlib import Path
from PIL import Image
import argparse


def extract_lineart(
    input_path: str,
    output_path: str = None,
    bg_color: str = "black",
    line_color: str = "white",
    blur_size: int = 5,
    canny_low: int = 50,
    canny_high: int = 150,
    dilate_iterations: int = 1,
    erode_iterations: int = 1
) -> str:
    """
    从图像中提取线条画

    Args:
        input_path: 输入图像路径
        output_path: 输出图像路径，默认在原文件名前加lineart_
        bg_color: 背景色 "black" 或 "white"
        line_color: 线条色 "black" 或 "white"
        blur_size: 高斯模糊核大小
        canny_low: Canny边缘检测低阈值
        canny_high: Canny边缘检测高阈值
        dilate_iterations: 膨胀迭代次数
        erode_iterations: 腐蚀迭代次数

    Returns:
        输出图像路径
    """
    # 读取图像
    img = cv2.imread(input_path)
    if img is None:
        raise ValueError(f"无法读取图像: {input_path}")

    # 转换为灰度
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 双边滤波：保持边缘的同时平滑噪声
    # d: 像素邻域直径, sigmaColor: 颜色空间标准差, sigmaSpace: 坐标空间标准差
    bilateral = cv2.bilateralFilter(gray, 9, 75, 75)

    # 边缘检测
    edges = cv2.Canny(bilateral, canny_low, canny_high)

    # 形态学操作清理边缘
    kernel = np.ones((2, 2), np.uint8)

    # 闭操作连接断开的线条
    edges = cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel)

    # 膨胀使线条更粗更明显
    if dilate_iterations > 0:
        edges = cv2.dilate(edges, kernel, iterations=dilate_iterations)

    # 腐蚀细化线条
    if erode_iterations > 0:
        edges = cv2.erode(edges, kernel, iterations=erode_iterations)

    # 确定颜色映射
    if bg_color == "black" and line_color == "white":
        # 黑背景白线条
        line_art = 255 - edges  # 反转：边缘(白)变黑，背景变白
    elif bg_color == "white" and line_color == "black":
        # 白背景黑线条
        line_art = edges
    elif bg_color == "black":
        # 黑背景，保持线条原色
        line_art = edges
    else:
        line_art = 255 - edges

    # 保存结果
    if output_path is None:
        input_file = Path(input_path)
        output_path = str(input_file.parent / f"{input_file.stem}_lineart{input_file.suffix}")

    cv2.imwrite(output_path, line_art)
    print(f"线条画已保存: {output_path}")

    return output_path


def batch_process(
    input_dir: str,
    output_dir: str = None,
    pattern: str = "*.png",
    bg_color: str = "black",
    line_color: str = "white"
):
    """
    批量处理图像

    Args:
        input_dir: 输入目录
        output_dir: 输出目录，默认与输入相同
        pattern: 文件匹配模式
        bg_color: 背景色
        line_color: 线条色
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
            out_file = output_path / f"{f.stem}_lineart{f.suffix}"
            extract_lineart(str(f), str(out_file), bg_color, line_color)
        except Exception as e:
            print(f"处理失败 {f.name}: {e}")

    print(f"批量处理完成: {len(files)} 个文件")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="线条画后处理器")
    parser.add_argument("input", help="输入图像或目录")
    parser.add_argument("-o", "--output", help="输出路径")
    parser.add_argument("--bg", choices=["black", "white"], default="black", help="背景色")
    parser.add_argument("--line", choices=["black", "white"], default="white", help="线条色")
    parser.add_argument("--canny-low", type=int, default=50, help="Canny低阈值")
    parser.add_argument("--canny-high", type=int, default=150, help="Canny高阈值")
    parser.add_argument("--batch", action="store_true", help="批量处理目录")

    args = parser.parse_args()

    if args.batch:
        batch_process(args.input, args.output, bg_color=args.bg, line_color=args.line)
    else:
        extract_lineart(
            args.input,
            args.output,
            bg_color=args.bg,
            line_color=args.line,
            canny_low=args.canny_low,
            canny_high=args.canny_high
        )