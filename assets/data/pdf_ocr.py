#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PDF OCR 提取工具
将扫描版PDF转换为文本
"""

import os
import sys
import json
from pathlib import Path

# 尝试导入所需库
try:
    import pytesseract
    from pdf2image import convert_from_path
    from PIL import Image
except ImportError as e:
    print(f"缺少依赖库: {e}")
    print("请运行: pip3 install pytesseract pdf2image pillow")
    sys.exit(1)

def ocr_image(image):
    """对单个图像进行OCR识别"""
    text = pytesseract.image_to_string(image, lang='chi_sim+eng')
    return text

def extract_pdf_text(pdf_path, max_pages=None):
    """从PDF提取文字"""
    print(f"正在处理: {pdf_path}")

    if not os.path.exists(pdf_path):
        print(f"文件不存在: {pdf_path}")
        return None

    try:
        # 将PDF转换为图像
        print("正在将PDF页面转换为图像...")
        images = convert_from_path(pdf_path, dpi=300)

        if max_pages:
            images = images[:max_pages]

        print(f"共 {len(images)} 页，开始OCR识别...")

        all_text = []
        for i, image in enumerate(images):
            print(f"  正在识别第 {i+1}/{len(images)} 页...")
            text = ocr_image(image)
            all_text.append(f"=== 第 {i+1} 页 ===\n{text}")

        return "\n\n".join(all_text)

    except Exception as e:
        print(f"处理出错: {e}")
        return None

def main():
    if len(sys.argv) < 2:
        print("用法: python3 pdf_ocr.py <PDF文件路径> [输出页数]")
        sys.exit(1)

    pdf_path = sys.argv[1]
    max_pages = int(sys.argv[2]) if len(sys.argv) > 2 else None

    # 提取文字
    text = extract_pdf_text(pdf_path, max_pages)

    if text:
        # 保存到txt文件
        output_path = pdf_path.replace('.pdf', '_ocr.txt')
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(text)
        print(f"\n文字已保存到: {output_path}")

        # 显示前3000字符
        print("\n=== 内容预览 (前3000字符) ===")
        print(text[:3000])
    else:
        print("提取失败")

if __name__ == "__main__":
    main()
