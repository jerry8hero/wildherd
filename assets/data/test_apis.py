#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""测试多个天气API"""

import requests

# 测试Open-Meteo（免费，无需API Key）
def test_open_meteo():
    print("=== 测试 Open-Meteo (免费) ===")
    url = "https://api.open-meteo.com/v1/forecast?latitude=39.9&longitude=116.4&current=temperature_2m,relative_humidity_2m,weather_code"

    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()
            current = data.get('current', {})
            print(f"温度: {current.get('temperature_2m')}°C")
            print(f"湿度: {current.get('relative_humidity_2m')}%")
            print("✅ Open-Meteo 可用!")
            return True
    except Exception as e:
        print(f"❌ Open-Meteo 失败: {e}")
    return False

# 测试和风天气（国内）
def test_qweather():
    print("\n=== 测试 和风天气 (国内) ===")
    # 使用免费版可能需要key，先测试
    print("和风天气需要注册获取key")
    return False

if __name__ == "__main__":
    test_open_meteo()
