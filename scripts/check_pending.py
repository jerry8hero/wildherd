#!/usr/bin/env python3
"""
待发布内容检查脚本
用于检查视频发布排期，发送提醒

使用方法:
    python3 check_pending.py              # 检查今日/明日待发布
    python3 check_pending.py --all        # 显示所有待发布内容
    python3 check_pending.py --config    # 显示发布配置
"""

import os
import yaml
import argparse
from datetime import datetime, timedelta
from pathlib import Path

# 配置路径
SCRIPT_DIR = Path(__file__).parent.parent
CONFIG_FILE = SCRIPT_DIR / "configs" / "publishing_schedule.yml"
SCHEDULE_FILE = SCRIPT_DIR / "docs" / "video-scripts" / "发布排期表.md"
RECORD_FILE = SCRIPT_DIR / "docs" / "video-scripts" / "发布记录.yml"


def load_config():
    """加载发布配置"""
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)
    return {}


def load_schedule():
    """加载发布排期表"""
    schedule = []
    if SCHEDULE_FILE.exists():
        with open(SCHEDULE_FILE, "r", encoding="utf-8") as f:
            content = f.read()
            # 简单解析Markdown表格
            lines = content.strip().split("\n")
            for line in lines:
                if "|" in line and not line.strip().startswith("|"):
                    parts = [p.strip() for p in line.split("|")]
                    if len(parts) >= 3 and parts[1] and parts[2]:
                        schedule.append({
                            "title": parts[1],
                            "date": parts[2] if len(parts) > 2 else "",
                            "status": parts[3] if len(parts) > 3 else "待发布"
                        })
    return schedule


def load_records():
    """加载发布记录"""
    if RECORD_FILE.exists():
        with open(RECORD_FILE, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)
    return {}


def check_today_pending(schedule):
    """检查今日待发布内容"""
    today = datetime.now().strftime("%Y-%m-%d")
    tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")

    today_pending = []
    tomorrow_pending = []

    for item in schedule:
        date_str = item.get("date", "")
        status = item.get("status", "待发布")

        if status.lower() in ["待发布", "pending", "planned"]:
            if today in date_str:
                today_pending.append(item)
            elif tomorrow in date_str:
                tomorrow_pending.append(item)

    return today_pending, tomorrow_pending


def show_all_pending(schedule):
    """显示所有待发布内容"""
    pending = [item for item in schedule
               if item.get("status", "").lower() in ["待发布", "pending", "planned"]]

    print("\n" + "=" * 60)
    print("📋 所有待发布内容")
    print("=" * 60)

    if not pending:
        print("暂无待发布内容")
        return

    for i, item in enumerate(pending, 1):
        print(f"\n{i}. {item.get('title', '未命名')}")
        print(f"   计划日期: {item.get('date', '待定')}")


def show_config(config):
    """显示发布配置"""
    print("\n" + "=" * 60)
    print("⚙️  发布配置")
    print("=" * 60)

    platforms = config.get("platforms", {})
    for platform, settings in platforms.items():
        if settings.get("enabled"):
            print(f"\n📺 {platform.upper()}")
            if "schedule" in settings:
                for day_info in settings["schedule"].get("primary", []):
                    print(f"   主要: {day_info.get('day')} {day_info.get('time')}")
                for day_info in settings["schedule"].get("secondary", []):
                    print(f"   次要: {day_info.get('day')} {day_info.get('time')}")

    reminders = config.get("reminders", {})
    print(f"\n⏰ 提醒规则")
    for reminder in reminders.get("before_publish", []):
        if "days" in reminder:
            print(f"   提前{reminder.get('days')}天: {reminder.get('message')}")
        elif "hours" in reminder:
            print(f"   提前{reminder.get('hours')}小时: {reminder.get('message')}")

    goals = config.get("goals", {})
    print(f"\n🎯 月度目标")
    monthly = goals.get("monthly", {})
    print(f"   新视频: {monthly.get('new_videos', 'N/A')}期")
    print(f"   平均播放: {monthly.get('avg_views', 'N/A')}")
    print(f"   新增粉丝: {monthly.get('new_followers', 'N/A')}")


def main():
    parser = argparse.ArgumentParser(description="待发布内容检查工具")
    parser.add_argument("--all", action="store_true", help="显示所有待发布内容")
    parser.add_argument("--config", action="store_true", help="显示发布配置")
    args = parser.parse_args()

    config = load_config()
    schedule = load_schedule()

    if args.config:
        show_config(config)
        return

    if args.all:
        show_all_pending(schedule)
        return

    # 默认检查今日/明日待发布
    today_pending, tomorrow_pending = check_today_pending(schedule)

    print(f"\n[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] 待发布内容检查")
    print("=" * 60)

    if today_pending:
        print(f"\n📌 今日待发布 ({len(today_pending)}期):")
        for item in today_pending:
            print(f"   - {item.get('title', '未命名')}")
    else:
        print("\n📌 今日无待发布")

    if tomorrow_pending:
        print(f"\n📅 明日待发布 ({len(tomorrow_pending)}期):")
        for item in tomorrow_pending:
            print(f"   - {item.get('title', '未命名')}")
    else:
        print("\n📅 明日无待发布")

    # 检查内容缓冲
    buffer_config = config.get("reminders", {}).get("content_buffer", {})
    min_weeks = buffer_config.get("min_weeks", 2)
    pending_count = len([s for s in schedule if s.get("status", "").lower() in ["待发布", "pending", "planned"]])

    print("\n" + "-" * 60)
    if pending_count >= min_weeks * 2:  # 假设每周2期
        print(f"✅ 内容储备充足 ({pending_count}期)")
    else:
        print(f"⚠️ 内容储备不足 (建议至少{min_weeks * 2}期，当前{pending_count}期)")

    print("\n💡 提示: 使用 --all 查看所有待发布，--config 查看发布配置")


if __name__ == "__main__":
    main()
