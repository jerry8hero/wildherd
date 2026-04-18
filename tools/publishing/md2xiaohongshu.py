#!/usr/bin/env python3
"""
Markdown 转多平台配图工具

支持平台:
    - 小红书 (3:4 竖屏): 1080x1440
    - B站 (16:9 横屏): 1920x1080
    - 抖音 (9:16 竖屏): 1080x1920
    - 视频号 (9:16 竖屏): 1080x1920

用法:
    # 生成多平台封面
    python md2xiaohongshu.py --title "标题" --subtitle "副标题" --output ./output

    # 列出支持的平台
    python md2xiaohongshu.py --list-platforms

    # Markdown转小红书配图
    python md2xiaohongshu.py <输入.md> [输出目录]

示例:
    python md2xiaohongshu.py --title "大鳄龟vs小鳄龟" --subtitle "新手入门"
    python md2xiaohongshu.py 01-养草龟需要准备什么.md ./output

依赖安装:
    pip install markdown Pillow

字体说明:
    脚本会自动使用系统字体, 如需显示emoji需配合emoji字体使用
"""

import os
import sys
import re
import argparse
from pathlib import Path
from typing import List, Tuple, Optional

try:
    from markdown import markdown
except ImportError:
    print("请先安装 markdown: pip install markdown")
    sys.exit(1)

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("请先安装 Pillow: pip install Pillow")
    sys.exit(1)


# 小红书配图尺寸 (3:4 竖屏)
XHS_WIDTH = 1080
XHS_HEIGHT = 1440

# 多平台尺寸配置
PLATFORM_SIZES = {
    "xiaohongshu": {"width": 1080, "height": 1440, "name": "小红书", "ratio": "3:4"},
    "bilibili": {"width": 1920, "height": 1080, "name": "B站", "ratio": "16:9"},
    "douyin": {"width": 1080, "height": 1920, "name": "抖音", "ratio": "9:16"},
    "video_account": {"width": 1080, "height": 1920, "name": "视频号", "ratio": "9:16"},
}

# 颜色配置
COLORS = {
    "primary": "#2D5A4A",      # 深墨绿 - 主色
    "secondary": "#4A7C6F",    # 浅墨绿
    "accent": "#D4A853",       # 金色 - 强调
    "background": "#F5F5F0",   # 米白背景
    "dark_bg": "#1A3A2F",     # 深色背景
    "text": "#333333",        # 正文
    "light_text": "#666666",  # 浅色文字
    "white": "#FFFFFF",
    "header_bg": "#2D5A4A",   # 标题栏背景
}


def clean_text(text: str) -> str:
    """清理文本，移除emoji等特殊字符"""
    import re

    # 1. 移除数字序号 emoji (如 1️⃣ 2️⃣ 3️⃣)
    # 匹配: 数字 + 可选variation selector + combining enclosing keycap + 可选空格
    text = re.sub(r'[\u0030-\u0039]\ufe0f?\u20e3\s*', '', text)

    # 2. 移除常见的独立emoji字符
    # 只移除明确是emoji的字符，不使用宽范围
    common_emoji = [
        '\U0001F600', '\U0001F601', '\U0001F602', '\U0001F603', '\U0001F604', '\U0001F605',
        '\U0001F606', '\U0001F607', '\U0001F608', '\U0001F609', '\U0001F60A', '\U0001F60B',
        '\U0001F60C', '\U0001F60D', '\U0001F60E', '\U0001F60F',
        '\U0001F610', '\U0001F611', '\U0001F612', '\U0001F613', '\U0001F614', '\U0001F615',
        '\U0001F616', '\U0001F617', '\U0001F618', '\U0001F619', '\U0001F61A', '\U0001F61B',
        '\U0001F61C', '\U0001F61D', '\U0001F61E', '\U0001F61F', '\U0001F620', '\U0001F621',
        '\U0001F622', '\U0001F623', '\U0001F624', '\U0001F625', '\U0001F626', '\U0001F627',
        '\U0001F628', '\U0001F629', '\U0001F62A', '\U0001F62B', '\U0001F62C', '\U0001F62D',
        '\U0001F62E', '\U0001F62F', '\U0001F630', '\U0001F631', '\U0001F632', '\U0001F633',
        '\U0001F634', '\U0001F635', '\U0001F636', '\U0001F637',
        # 更多常见emoji...
        '\U0001F300', '\U0001F301', '\U0001F302', '\U0001F303', '\U0001F304', '\U0001F305',
        '\U0001F306', '\U0001F307', '\U0001F308', '\U0001F309', '\U0001F30A', '\U0001F30B',
        '\U0001F30C',
        '\U0001F680', '\U0001F681', '\U0001F682', '\U0001F683', '\U0001F684', '\U0001F685',
        '\U0001F686', '\U0001F687', '\U0001F688', '\U0001F689',
        '\U0001F38A', '\U0001F38B',  # 红包 emoji
        '\U0001F40D', '\U0001F40E',  # 爬宠相关
        '\U0001F419', '\U0001F41A',  # 章鱼等
        '\U0001F41B', '\U0001F41C', '\U0001F41D', '\U0001F41E', '\U0001F41F',  # 虫、螃蟹等
        '\U0001F980', '\U0001F981', '\U0001F982', '\U0001F983', '\U0001F984',  # 螃蟹、蜥蜴等
        '\U0001F985', '\U0001F986', '\U0001F987', '\U0001F988', '\U0001F989',  # 鹰、蛇等
        '\U0001F98A', '\U0001F98B', '\U0001F98C', '\U0001F98D', '\U0001F98E', '\U0001F98F', '\U0001F990',
        '\U0001F991', '\U0001F992', '\U0001F993', '\U0001F994', '\U0001F995', '\U0001F996', '\U0001F997',
        '\U0001F998', '\U0001F999', '\U0001F99A', '\U0001F99B', '\U0001F99C', '\U0001F99D', '\U0001F99E',
        '\U0001F99F', '\U0001F9A0',
        '\U0001F340', '\U0001F40A', '\U0001F40B', '\U0001F40C',  # 动物
        '\U0001F40F', '\U0001F410', '\U0001F411', '\U0001F412', '\U0001F413', '\U0001F414', '\U0001F415',
        '\U0001F416', '\U0001F417', '\U0001F418', '\U0001F422', '\U0001F423', '\U0001F424', '\U0001F425',
        '\U0001F426', '\U0001F427', '\U0001F428', '\U0001F429', '\U0001F42A', '\U0001F42B', '\U0001F42C',
        '\U0001F42D', '\U0001F42E', '\U0001F42F', '\U0001F430', '\U0001F431', '\U0001F432', '\U0001F433',
        '\U0001F434', '\U0001F435', '\U0001F436', '\U0001F437', '\U0001F438', '\U0001F439', '\U0001F43A',
        '\U0001F43B', '\U0001F43C', '\U0001F43D', '\U0001F43E', '\U0001F43F', '\U0001F440',
        '\U0001F441', '\U0001F442', '\U0001F443', '\U0001F444', '\U0001F445', '\U0001F446', '\U0001F447',
        '\U0001F448', '\U0001F449', '\U0001F44A', '\U0001F44B', '\U0001F44C', '\U0001F44D', '\U0001F44E',
        '\U0001F44F', '\U0001F450',
    ]
    for emoji in common_emoji:
        text = text.replace(emoji, '')

    # 3. 移除 variation selector (如果单独出现，可能是残留)
    text = text.replace('\ufe0f', '')

    # 4. 移除 zero width joiner
    text = text.replace('\u200d', '')

    # 5. 移除带圈数字 ①②③等
    text = re.sub(r'[\u2460-\u2473]', '', text)

    # 6. 移除方块 ■ □ 等
    text = re.sub(r'[\u25a0-\u25ff]', '', text)

    return text.strip()


def get_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    """获取字体"""
    # 字体路径列表 - 按优先级排列
    font_paths = [
        # Linux WSL - Noto Sans CJK
        "/usr/share/fonts/google-noto-sans-cjk-fonts/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/google-noto-sans-cjk-fonts/NotoSansCJK-Bold.ttc",
        "/usr/share/fonts/google-noto-sans-cjk-fonts/NotoSansCJK-Medium.ttc",
        # Linux 本地 - Noto Sans CJK
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc",
        # Linux 其他路径
        "/usr/share/fonts/truetype/wqy/wqy-microhei.ttc",
        "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
        # macOS
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/STHeiti Light.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/System/Library/Fonts/Supplemental/msyh.ttc",
        # Windows 通过 WSL 挂载
        "/mnt/c/Windows/Fonts/msyh.ttc",
        "/mnt/c/Windows/Fonts/msyhbd.ttc",
        "/mnt/c/Windows/Fonts/simsun.ttc",
        "/mnt/c/Windows/Fonts/simhei.ttf",
        # Windows 本地
        "C:/Windows/Fonts/msyh.ttc",
        "C:/Windows/Fonts/msyhbd.ttc",
        "C:/Windows/Fonts/simsun.ttc",
        "C:/Windows/Fonts/simhei.ttf",
        # 用户目录
        os.path.expanduser("~/Library/Fonts/msyh.ttc"),
    ]

    font_size = size
    for font_path in font_paths:
        if os.path.exists(font_path):
            try:
                if bold:
                    # 尝试粗体版本
                    bold_paths = [
                        font_path.replace("Regular", "Bold").replace("Regular", "Medium"),
                        font_path.replace(".ttc", " Bold.ttc").replace(".ttf", "-Bold.ttf"),
                        font_path.replace("NotoSansCJK-", "NotoSansCJK-Bold"),
                        # Windows 字体名规律
                        font_path.replace("msyh", "msyhbd").replace("yahei", "yaheibd"),
                    ]
                    for bold_path in bold_paths:
                        if bold_path != font_path and os.path.exists(bold_path):
                            return ImageFont.truetype(bold_path, font_size)
                return ImageFont.truetype(font_path, font_size)
            except Exception:
                continue

    # 默认字体（不支持中文）
    print("警告: 未找到中文字体，文字可能无法正常显示")
    return ImageFont.load_default()


def parse_markdown_to_blocks(md_content: str) -> List[dict]:
    """解析 Markdown 为结构化块"""
    blocks = []
    lines = md_content.strip().split("\n")

    current_block = None
    in_code_block = False

    for line in lines:
        # 跳过水平线分隔
        if line.strip() in ["---", "***", "___"]:
            if current_block:
                blocks.append(current_block)
            current_block = {"type": "divider", "content": ""}
            blocks.append(current_block)
            current_block = None
            continue

        # 标题
        if line.startswith("# "):
            if current_block:
                blocks.append(current_block)
            blocks.append({"type": "h1", "content": line[2:].strip()})
            current_block = None
        elif line.startswith("## "):
            if current_block:
                blocks.append(current_block)
            blocks.append({"type": "h2", "content": line[3:].strip()})
            current_block = None
        elif line.startswith("### "):
            if current_block:
                blocks.append(current_block)
            blocks.append({"type": "h3", "content": line[4:].strip()})
            current_block = None
        # 引用/说明
        elif line.startswith(">"):
            if current_block and current_block["type"] == "text":
                current_block["content"] += "\n" + line[1:].strip()
            else:
                if current_block:
                    blocks.append(current_block)
                current_block = {"type": "quote", "content": line[1:].strip()}
        # 列表
        elif re.match(r"^[-*]\s", line) or re.match(r"^\d+\.\s", line):
            if current_block and current_block["type"] == "list":
                current_block["items"].append(line.lstrip("-*0123456789. ").strip())
            else:
                if current_block:
                    blocks.append(current_block)
                current_block = {
                    "type": "list",
                    "items": [line.lstrip("-*0123456789. ").strip()]
                }
        # 普通文本
        elif line.strip():
            if current_block and current_block["type"] == "text":
                current_block["content"] += "\n" + line.strip()
            else:
                if current_block:
                    blocks.append(current_block)
                current_block = {"type": "text", "content": line.strip()}
        else:
            if current_block:
                blocks.append(current_block)
                current_block = None

    if current_block:
        blocks.append(current_block)

    return blocks


def create_cover_image(title: str, subtitle: str = "", output_path: str = "cover.png") -> str:
    """创建封面图（默认小红书3:4竖屏）"""
    img = Image.new("RGB", (XHS_WIDTH, XHS_HEIGHT), COLORS["dark_bg"])
    draw = ImageDraw.Draw(img)

    # 顶部小装饰条（降低高度，避免遮挡标题）
    draw.rectangle([(0, 0), (XHS_WIDTH, 60)], fill=COLORS["accent"])

    # 主标题 - 居中显示
    font_title = get_font(96, bold=True)
    title_text = title
    # 文字换行处理（如果太长）
    if len(title_text) > 12:
        # 分两行
        mid = len(title_text) // 2
        for i in range(mid, 0, -1):
            if title_text[i] in ' \n-':
                break
        line1 = title_text[:i].strip()
        line2 = title_text[i:].strip()

        # 计算两行总高度
        bbox1 = draw.textbbox((0, 0), line1, font=font_title)
        line1_width = bbox1[2] - bbox1[0]
        bbox2 = draw.textbbox((0, 0), line2, font=font_title)
        line2_width = bbox2[2] - bbox2[0]

        # 绘制两行
        draw.text(((XHS_WIDTH - line1_width) // 2, 180), line1, fill=COLORS["white"], font=font_title)
        draw.text(((XHS_WIDTH - line2_width) // 2, 180 + 110), line2, fill=COLORS["white"], font=font_title)

        subtitle_y = 180 + 220
    else:
        bbox = draw.textbbox((0, 0), title_text, font=font_title)
        title_width = bbox[2] - bbox[0]
        draw.text(((XHS_WIDTH - title_width) // 2, 200), title_text, fill=COLORS["white"], font=font_title)
        subtitle_y = 340

    # 副标题
    if subtitle:
        font_subtitle = get_font(48)
        bbox = draw.textbbox((0, 0), subtitle, font=font_subtitle)
        subtitle_width = bbox[2] - bbox[0]
        draw.text(((XHS_WIDTH - subtitle_width) // 2, subtitle_y), subtitle, fill=COLORS["accent"], font=font_subtitle)

    # 底部装饰区域
    draw.rectangle([(0, XHS_HEIGHT - 180), (XHS_WIDTH, XHS_HEIGHT)], fill=COLORS["secondary"])

    # 底部信息
    font_info = get_font(36)
    info_text = "中国原生龟 | 皮实耐养"
    bbox = draw.textbbox((0, 0), info_text, font=font_info)
    info_width = bbox[2] - bbox[0]
    draw.text(((XHS_WIDTH - info_width) // 2, XHS_HEIGHT - 130), info_text, fill=COLORS["white"], font=font_info)

    img.save(output_path)
    print(f"封面图已保存: {output_path}")
    return output_path


def create_multipplatform_cover(
    title: str,
    subtitle: str = "",
    platform: str = "xiaohongshu",
    output_dir: str = "output"
) -> dict:
    """
    为多个平台生成不同尺寸的封面

    Args:
        title: 封面标题
        subtitle: 副标题
        platform: 默认平台 (xiaohongshu/bilibili/douyin/video_account)
        output_dir: 输出目录

    Returns:
        各平台封面路径字典
    """
    os.makedirs(output_dir, exist_ok=True)
    base_name = title.replace("-", " ").replace(" ", "").replace("/", "_")

    output_files = {}

    for p, config in PLATFORM_SIZES.items():
        width = config["width"]
        height = config["height"]
        platform_name = config["name"]

        img = Image.new("RGB", (width, height), COLORS["dark_bg"])
        draw = ImageDraw.Draw(img)

        # 根据平台调整布局
        if p == "bilibili":
            # B站横屏16:9布局
            # 顶部装饰条
            draw.rectangle([(0, 0), (width, 80)], fill=COLORS["accent"])

            # 标题
            font_title = get_font(100, bold=True)
            if len(title) > 15:
                mid = len(title) // 2
                for i in range(mid, 0, -1):
                    if title[i] in ' \n-':
                        break
                line1 = title[:i].strip()
                line2 = title[i:].strip()
                bbox1 = draw.textbbox((0, 0), line1, font=font_title)
                line1_width = bbox1[2] - bbox1[0]
                bbox2 = draw.textbbox((0, 0), line2, font=font_title)
                line2_width = bbox2[2] - bbox2[0]
                draw.text(((width - line1_width) // 2, 200), line1, fill=COLORS["white"], font=font_title)
                draw.text(((width - line2_width) // 2, 200 + 120), line2, fill=COLORS["white"], font=font_title)
                subtitle_y = 200 + 240
            else:
                bbox = draw.textbbox((0, 0), title, font=font_title)
                title_width = bbox[2] - bbox[0]
                draw.text(((width - title_width) // 2, 250), title, fill=COLORS["white"], font=font_title)
                subtitle_y = 400

            if subtitle:
                font_subtitle = get_font(56)
                bbox = draw.textbbox((0, 0), subtitle, font=font_subtitle)
                subtitle_width = bbox[2] - bbox[0]
                draw.text(((width - subtitle_width) // 2, subtitle_y), subtitle, fill=COLORS["accent"], font=font_subtitle)

            # 底部装饰
            draw.rectangle([(0, height - 120), (width, height)], fill=COLORS["secondary"])
            font_info = get_font(40)
            info_text = "B站：爬宠博主"
            bbox = draw.textbbox((0, 0), info_text, font=font_info)
            info_width = bbox[2] - bbox[0]
            draw.text(((width - info_width) // 2, height - 90), info_text, fill=COLORS["white"], font=font_info)

        else:
            # 竖屏布局（抖音/小红书/视频号）
            # 顶部装饰条
            draw.rectangle([(0, 0), (width, 60)], fill=COLORS["accent"])

            # 标题
            font_title = get_font(80, bold=True)
            if len(title) > 10:
                mid = len(title) // 2
                for i in range(mid, 0, -1):
                    if title[i] in ' \n-':
                        break
                line1 = title[:i].strip()
                line2 = title[i:].strip()
                bbox1 = draw.textbbox((0, 0), line1, font=font_title)
                line1_width = bbox1[2] - bbox1[0]
                bbox2 = draw.textbbox((0, 0), line2, font=font_title)
                line2_width = bbox2[2] - bbox2[0]
                draw.text(((width - line1_width) // 2, 140), line1, fill=COLORS["white"], font=font_title)
                draw.text(((width - line2_width) // 2, 140 + 95), line2, fill=COLORS["white"], font=font_title)
                subtitle_y = 140 + 190
            else:
                bbox = draw.textbbox((0, 0), title, font=font_title)
                title_width = bbox[2] - bbox[0]
                draw.text(((width - title_width) // 2, 180), title, fill=COLORS["white"], font=font_title)
                subtitle_y = 300

            if subtitle:
                font_subtitle = get_font(42)
                bbox = draw.textbbox((0, 0), subtitle, font=font_subtitle)
                subtitle_width = bbox[2] - bbox[0]
                draw.text(((width - subtitle_width) // 2, subtitle_y), subtitle, fill=COLORS["accent"], font=font_subtitle)

            # 底部装饰
            bottom_height = 160 if p == "xiaohongshu" else 140
            draw.rectangle([(0, height - bottom_height), (width, height)], fill=COLORS["secondary"])

            font_info = get_font(32)
            if p == "xiaohongshu":
                info_text = "小红书：爬宠博主"
            elif p == "douyin":
                info_text = "抖音：爬宠博主"
            else:
                info_text = "视频号：爬宠博主"
            bbox = draw.textbbox((0, 0), info_text, font=font_info)
            info_width = bbox[2] - bbox[0]
            draw.text(((width - info_width) // 2, height - bottom_height + 50), info_text, fill=COLORS["white"], font=font_info)

        output_path = os.path.join(output_dir, f"{base_name}_{p}_cover.png")
        img.save(output_path)
        output_files[p] = output_path
        print(f"{platform_name}封面已保存: {output_path}")

    return output_files


def create_page_image(
    page_data: dict,
    page_num: int = 1,
    total_pages: int = 1,
    output_path: str = "page.png"
) -> str:
    """创建完整页面（卡片式布局）"""
    import re

    img = Image.new("RGB", (XHS_WIDTH, XHS_HEIGHT), COLORS["background"])
    draw = ImageDraw.Draw(img)

    # 顶部细装饰条
    draw.rectangle([(0, 0), (XHS_WIDTH, 50)], fill=COLORS["header_bg"])

    # 页码
    font_page = get_font(28)
    page_text = f"{page_num} / {total_pages}"
    bbox = draw.textbbox((0, 0), page_text, font=font_page)
    page_width = bbox[2] - bbox[0]
    draw.text(((XHS_WIDTH - page_width) // 2, 15), page_text, fill=COLORS["white"], font=font_page)

    # 底部装饰
    draw.rectangle([(0, XHS_HEIGHT - 50), (XHS_WIDTH, XHS_HEIGHT)], fill=COLORS["secondary"])

    y_position = 80

    # 页面标题（如果有）
    if page_data.get("title"):
        title = clean_text(page_data["title"])
        font_title = get_font(44, bold=True)
        draw.text((60, y_position), title, fill=COLORS["primary"], font=font_title)
        y_position += 55

    # 副标题（h3）
    if page_data.get("subtitle"):
        subtitle = clean_text(page_data["subtitle"])
        font_subtitle = get_font(32)
        draw.text((60, y_position), subtitle, fill=COLORS["secondary"], font=font_subtitle)
        y_position += 50

    # 判断内容类型
    content = page_data.get("content", [])

    # 如果只有文本内容（没有列表），显示为单卡片
    if len(content) == 1 and content[0]["type"] == "text":
        block = content[0]
        text = clean_text(re.sub(r"\*\*(.+?)\*\*", r"\1", block["content"]))
        # 绘制大卡片
        card_padding = 30
        card_height = 180
        draw.rectangle([(40, y_position), (XHS_WIDTH - 40, y_position + card_height)], fill=COLORS["white"], outline=COLORS["secondary"], width=2)
        font_text = get_font(32)
        draw.text((60 + card_padding, y_position + card_padding), text, fill=COLORS["text"], font=font_text)

    elif content and any(c["type"] == "list" for c in content):
        # 卡片式布局 - 每个要点一张卡片，两列排列
        card_margin = 15
        card_width = (XHS_WIDTH - 120 - card_margin) // 2  # 两列
        card_height = 250
        col = 0
        x_pos = 60

        for block in content:
            if block["type"] == "list":
                items = block.get("items", [])
                for i, item in enumerate(items):
                    item_text = clean_text(re.sub(r"\*\*(.+?)\*\*", r"\1", item))

                    # 计算卡片位置
                    x = x_pos + col * (card_width + card_margin)
                    y = y_position

                    # 卡片背景
                    draw.rectangle([(x, y), (x + card_width, y + card_height)], fill=COLORS["white"], outline=COLORS["accent"], width=2)

                    # 卡片顶部色条
                    draw.rectangle([(x, y), (x + card_width, y + 8)], fill=COLORS["accent"])

                    # 序号圆点
                    font_num = get_font(24, bold=True)
                    draw.ellipse([(x + 15, y + 25), (x + 45, y + 55)], fill=COLORS["accent"])
                    num_text = str(i + 1)
                    bbox = draw.textbbox((0, 0), num_text, font=font_num)
                    num_w = bbox[2] - bbox[0]
                    draw.text((x + 15 + (30 - num_w) // 2, y + 28), num_text, fill=COLORS["white"], font=font_num)

                    # 卡片内容
                    font_card_content = get_font(26)
                    # 文本换行
                    words = item_text.split()
                    lines = []
                    current_line = ""
                    for word in words:
                        if len(current_line) + len(word) <= 14:
                            current_line += (" " if current_line else "") + word
                        else:
                            lines.append(current_line)
                            current_line = word
                    if current_line:
                        lines.append(current_line)

                    text_y = y + 70
                    for line in lines[:5]:  # 最多显示5行
                        draw.text((x + 15, text_y), line, fill=COLORS["text"], font=font_card_content)
                        text_y += 38

                    col += 1
                    if col >= 2:
                        col = 0
                        y_position += card_height + card_margin

        # 如果最后只有一列，补上另一列的位置
        if col != 0:
            y_position += card_height + card_margin

    img.save(output_path)
    print(f"内容页已保存: {output_path}")
    return output_path



def create_content_image(
    block: dict,
    page_num: int = 1,
    total_pages: int = 1,
    output_path: str = "content.png"
) -> str:
    """创建内容页"""
    img = Image.new("RGB", (XHS_WIDTH, XHS_HEIGHT), COLORS["background"])
    draw = ImageDraw.Draw(img)

    # 顶部细装饰条（降低高度）
    draw.rectangle([(0, 0), (XHS_WIDTH, 50)], fill=COLORS["header_bg"])

    # 页码 - 居中显示在顶部
    font_page = get_font(28)
    page_text = f"{page_num} / {total_pages}"
    bbox = draw.textbbox((0, 0), page_text, font=font_page)
    page_width = bbox[2] - bbox[0]
    draw.text(((XHS_WIDTH - page_width) // 2, 15), page_text, fill=COLORS["white"], font=font_page)

    # 左侧装饰线
    draw.rectangle([(0, 50), (8, XHS_HEIGHT - 50)], fill=COLORS["accent"])

    # 页面底部装饰
    draw.rectangle([(0, XHS_HEIGHT - 50), (XHS_WIDTH, XHS_HEIGHT)], fill=COLORS["secondary"])

    # 内容区域边距
    left_margin = 80
    right_margin = 60
    content_width = XHS_WIDTH - left_margin - right_margin
    y_position = 120

    if block["type"] == "h1":
        # 大标题
        font_title = get_font(72, bold=True)
        draw.text((left_margin, y_position), clean_text(block["content"]), fill=COLORS["primary"], font=font_title)
        y_position += 100
        # 标题下划线
        draw.rectangle([(left_margin, y_position), (left_margin + 200, y_position + 6)], fill=COLORS["accent"])

    elif block["type"] == "h2":
        # 章节标题
        font_title = get_font(52, bold=True)
        draw.text((left_margin, y_position), clean_text(block["content"]), fill=COLORS["primary"], font=font_title)
        y_position += 90
        # 标题下划线
        draw.rectangle([(left_margin, y_position), (left_margin + 150, y_position + 6)], fill=COLORS["accent"])

    elif block["type"] == "h3":
        # 小标题 - 带序号
        font_title = get_font(44, bold=True)
        draw.text((left_margin, y_position), clean_text(block["content"]), fill=COLORS["primary"], font=font_title)

    elif block["type"] == "text":
        font_text = get_font(34)
        lines = block["content"].split("\n")
        for line in lines:
            # 处理粗体 (**text**) 并清理emoji
            line = clean_text(re.sub(r"\*\*(.+?)\*\*", r"\1", line))
            # 自动换行处理
            max_chars = 22
            if len(line) > max_chars:
                # 按标点或空格分割
                words = line.split()
                current_line = ""
                for word in words:
                    if len(current_line) + len(word) + 1 <= max_chars:
                        current_line += (" " if current_line else "") + word
                    else:
                        if current_line:
                            draw.text((left_margin, y_position), current_line, fill=COLORS["text"], font=font_text)
                            y_position += 55
                        current_line = word
                if current_line:
                    draw.text((left_margin, y_position), current_line, fill=COLORS["text"], font=font_text)
                    y_position += 55
            else:
                draw.text((left_margin, y_position), line, fill=COLORS["text"], font=font_text)
                y_position += 55

    elif block["type"] == "list":
        font_item = get_font(36)
        for i, item in enumerate(block["items"]):
            # 处理粗体并清理emoji
            item = clean_text(re.sub(r"\*\*(.+?)\*\*", r"\1", item))
            # 列表序号圆点
            draw.ellipse([(left_margin - 25, y_position + 10), (left_margin - 5, y_position + 30)], fill=COLORS["accent"])
            # 自动换行
            max_chars = 20
            if len(item) > max_chars:
                words = item.split()
                current_line = ""
                for word in words:
                    if len(current_line) + len(word) + 1 <= max_chars:
                        current_line += (" " if current_line else "") + word
                    else:
                        draw.text((left_margin + 10, y_position), current_line, fill=COLORS["text"], font=font_item)
                        y_position += 50
                        current_line = word
                if current_line:
                    draw.text((left_margin + 10, y_position), current_line, fill=COLORS["text"], font=font_item)
                    y_position += 50
            else:
                draw.text((left_margin + 10, y_position), item, fill=COLORS["text"], font=font_item)
                y_position += 55

    elif block["type"] == "quote":
        # 引用框
        draw.rectangle([(40, y_position - 20), (XHS_WIDTH - 40, y_position + 100)], fill=COLORS["secondary"], outline=COLORS["primary"], width=3)
        font_quote = get_font(32)
        draw.text((60, y_position), block["content"], fill=COLORS["white"], font=font_quote)

    elif block["type"] == "divider":
        # 分隔线
        draw.rectangle([(100, XHS_HEIGHT // 2 - 2), (XHS_WIDTH - 100, XHS_HEIGHT // 2 + 2)], fill=COLORS["accent"])

    img.save(output_path)
    print(f"内容页已保存: {output_path}")
    return output_path


def create_summary_image(items: List[Tuple[str, str]], output_path: str = "summary.png") -> str:
    """创建汇总页"""
    img = Image.new("RGB", (XHS_WIDTH, XHS_HEIGHT), COLORS["background"])
    draw = ImageDraw.Draw(img)

    # 顶部标题栏
    draw.rectangle([(0, 0), (XHS_WIDTH, 100)], fill=COLORS["header_bg"])

    # 标题
    font_title = get_font(48, bold=True)
    draw.text((60, 30), "装备清单汇总", fill=COLORS["white"], font=font_title)

    y_position = 160
    for item, note in items:
        # 物品名称
        font_item = get_font(36, bold=True)
        draw.text((80, y_position), item, fill=COLORS["primary"], font=font_item)

        # 备注
        font_note = get_font(28)
        draw.text((80, y_position + 45), note, fill=COLORS["light_text"], font=font_note)

        y_position += 110

    # 底部装饰
    draw.rectangle([(0, XHS_HEIGHT - 60), (XHS_WIDTH, XHS_HEIGHT)], fill=COLORS["dark_bg"])

    img.save(output_path)
    print(f"汇总页已保存: {output_path}")
    return output_path


def create_ending_image(next_episode: str = "", output_path: str = "ending.png") -> str:
    """创建结尾引导页"""
    img = Image.new("RGB", (XHS_WIDTH, XHS_HEIGHT), COLORS["dark_bg"])
    draw = ImageDraw.Draw(img)

    # 装饰圆形
    center_x = XHS_WIDTH // 2
    draw.ellipse([(center_x - 200, 200), (center_x + 200, 600)], fill=COLORS["secondary"])

    # 主标题
    font_title = get_font(56, bold=True)
    title_text = "互动时间"
    title_bbox = draw.textbbox((0, 0), title_text, font=font_title)
    title_x = (XHS_WIDTH - (title_bbox[2] - title_bbox[0])) // 2
    draw.text((title_x, 280), title_text, fill=COLORS["white"], font=font_title)

    # 内容
    font_content = get_font(36)
    content_lines = [
        "看完还有疑问吗？",
        "",
        "评论区告诉我",
        "",
        "如果对你有帮助",
        "点个赞 + 收藏"
    ]
    y_position = 700
    for line in content_lines:
        line_bbox = draw.textbbox((0, 0), line, font=font_content)
        line_x = (XHS_WIDTH - (line_bbox[2] - line_bbox[0])) // 2
        draw.text((line_x, y_position), line, fill=COLORS["white"], font=font_content)
        y_position += 55

    # 下期预告
    if next_episode:
        font_next = get_font(32)
        next_text = f"关注我，下期讲"
        next_episode_text = f"「{next_episode}」"
        next_bbox = draw.textbbox((0, 0), next_text, font=font_next)
        next_x = (XHS_WIDTH - (next_bbox[2] - next_bbox[0])) // 2
        draw.text((next_x, 1150), next_text, fill=COLORS["accent"], font=font_next)
        ep_bbox = draw.textbbox((0, 0), next_episode_text, font=font_next)
        ep_x = (XHS_WIDTH - (ep_bbox[2] - ep_bbox[0])) // 2
        draw.text((ep_x, 1200), next_episode_text, fill=COLORS["white"], font=font_next)

    # 话题标签
    font_tag = get_font(24)
    tags = "#草龟 #养龟 #爬宠 #宠物龟 #新手养龟"
    tags_bbox = draw.textbbox((0, 0), tags, font=font_tag)
    tags_x = (XHS_WIDTH - (tags_bbox[2] - tags_bbox[0])) // 2
    draw.text((tags_x, 1350), tags, fill=COLORS["secondary"], font=font_tag)

    img.save(output_path)
    print(f"结尾页已保存: {output_path}")
    return output_path


def md_to_xiaohongshu(
    md_path: str,
    output_dir: str = "output",
    theme: str = "nature"
) -> List[str]:
    """
    将 Markdown 文件转换为小红书配图

    Args:
        md_path: Markdown 文件路径
        output_dir: 输出目录
        theme: 主题风格 (nature/dark/light)

    Returns:
        生成的图片路径列表
    """
    # 读取 Markdown 文件
    with open(md_path, "r", encoding="utf-8") as f:
        md_content = f.read()

    # 创建输出目录
    os.makedirs(output_dir, exist_ok=True)

    # 解析 Markdown
    blocks = parse_markdown_to_blocks(md_content)

    # 过滤掉话题标签行和图片版说明
    blocks = [b for b in blocks if not (
        b["type"] == "text" and b["content"].startswith("#")
    ) and not (
        b["type"] == "text" and "使用说明" in b["content"]
        and "共10张" in b["content"]
    ) and not (
        b["type"] == "text" and "尺寸建议" in b["content"]
    )]

    output_files = []

    # 生成封面
    base_name = Path(md_path).stem.replace("_小红书配图版", "").replace("_小红书版", "")
    cover_path = os.path.join(output_dir, f"{base_name}_00_封面.png")
    create_cover_image(
        title=base_name.replace("-", " ").replace(" ", ""),
        subtitle="新手必看",
        output_path=cover_path
    )
    output_files.append(cover_path)

    # ========== 内容分组逻辑 ==========
    # 将相关块组合成页面，每个页面包含一个完整主题

    # 先过滤分隔符和不需要的块
    filtered_blocks = []
    for b in blocks:
        if b["type"] == "divider":
            continue
        # 跳过话题标签
        if b["type"] == "text" and b["content"].startswith("#"):
            continue
        filtered_blocks.append(b)

    # 将块组合成页面
    # 每个 h3 + 它的内容 = 一张独立的图
    pages = []
    current_title = None  # h2 主标题
    current_subtitle = None  # h3 副标题
    current_content = []  # 当前h3下的列表项

    for block in filtered_blocks:
        if block["type"] in ("h1", "h2"):
            # 保存当前的h3页面（如果有）
            if current_subtitle and current_content:
                pages.append({
                    "title": current_title,
                    "subtitle": current_subtitle,
                    "content": current_content
                })
            # 新的主标题
            current_title = block["content"]
            current_subtitle = None
            current_content = []

        elif block["type"] == "h3":
            # 保存当前的h3页面（如果有）
            if current_subtitle and current_content:
                pages.append({
                    "title": current_title,
                    "subtitle": current_subtitle,
                    "content": current_content
                })
            # 新的副标题
            current_subtitle = block["content"]
            current_content = []

        elif block["type"] == "list":
            # 将列表项添加到当前内容
            current_content.append(block)

        elif block["type"] == "text":
            # 文本内容 - 如果有当前h3内容，先保存h3页面
            if current_subtitle and current_content:
                pages.append({
                    "title": current_title,
                    "subtitle": current_subtitle,
                    "content": current_content
                })
                current_content = []
            # 然后文本作为独立页面（如果没有h3标题）
            if not current_subtitle:
                pages.append({
                    "title": current_title,
                    "subtitle": None,
                    "content": [block]
                })
                current_title = None

    # 最后一页
    if current_subtitle and current_content:
        pages.append({
            "title": current_title,
            "subtitle": current_subtitle,
            "content": current_content
        })
    elif current_title and not current_subtitle and current_content:
        # 只有文本没有h3的情况
        pages.append({
            "title": current_title,
            "subtitle": None,
            "content": current_content
        })

    # ========== 生成内容页 ==========
    total_pages = len(pages)
    page_num = 1
    for page in pages:
        if not page["content"] and not page["title"]:
            continue
        # 跳过只有短文本的页面
        if page["title"] is None and len(page["content"]) == 1 and page["content"][0]["type"] == "text":
            continue

        content_path = os.path.join(output_dir, f"{base_name}_{page_num:02d}.png")
        create_page_image(
            page_data=page,
            page_num=page_num,
            total_pages=total_pages,
            output_path=content_path
        )
        output_files.append(content_path)
        page_num += 1

    # 生成结尾页
    ending_path = os.path.join(output_dir, f"{base_name}_99_结尾.png")
    create_ending_image(
        next_episode="草龟到家后怎么养",
        output_path=ending_path
    )
    output_files.append(ending_path)

    return output_files


def main():
    parser = argparse.ArgumentParser(description="Markdown 转多平台配图工具")
    parser.add_argument("input", nargs="?", help="输入的 Markdown 文件路径")
    parser.add_argument("--output", "-o", default="output", help="输出目录 (默认: output)")
    parser.add_argument("--theme", "-t", default="nature", choices=["nature", "dark", "light"], help="主题风格")
    parser.add_argument("--platform", "-p", default="xiaohongshu",
                        choices=["xiaohongshu", "bilibili", "douyin", "video_account", "all"],
                        help="目标平台 (默认: xiaohongshu)")
    parser.add_argument("--title", help="直接指定封面标题 (跳过Markdown解析)")
    parser.add_argument("--subtitle", default="新手必看", help="封面副标题")
    parser.add_argument("--list-platforms", action="store_true", help="列出支持的平台")

    args = parser.parse_args()

    # 列出支持的平台
    if args.list_platforms:
        print("支持的平台:")
        for p, config in PLATFORM_SIZES.items():
            print(f"  {p}: {config['name']} ({config['ratio']}) - {config['width']}x{config['height']}")
        return

    # 多平台封面生成模式
    if args.title:
        if not args.input:
            args.input = "."
        print(f"生成多平台封面: {args.title}")
        print(f"副标题: {args.subtitle}")
        print("-" * 50)
        output_files = create_multipplatform_cover(
            title=args.title,
            subtitle=args.subtitle,
            platform=args.platform if args.platform != "all" else "xiaohongshu",
            output_dir=args.output
        )
        print("-" * 50)
        print(f"完成! 共生成 {len(output_files)} 个平台封面")
        return

    # Markdown 转配图模式
    if not args.input:
        print("错误: 请提供 Markdown 文件路径 或使用 --title 直接指定标题")
        print("用法:")
        print("  # 生成多平台封面")
        print("  python md2xiaohongshu.py --title '标题' --subtitle '副标题'")
        print("")
        print("  # Markdown转配图")
        print("  python md2xiaohongshu.py <输入.md>")
        print("")
        print("  # 列出支持的平台")
        print("  python md2xiaohongshu.py --list-platforms")
        sys.exit(1)

    if not os.path.exists(args.input):
        print(f"错误: 文件不存在 {args.input}")
        sys.exit(1)

    print(f"正在转换: {args.input}")
    print(f"输出目录: {args.output}")
    print("-" * 50)

    try:
        output_files = md_to_xiaohongshu(
            md_path=args.input,
            output_dir=args.output,
            theme=args.theme
        )
        print("-" * 50)
        print(f"转换完成! 共生成 {len(output_files)} 张图片")
        print(f"输出目录: {os.path.abspath(args.output)}")
    except Exception as e:
        print(f"转换失败: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
