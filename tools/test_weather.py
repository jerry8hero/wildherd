#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""测试天气API"""

import os
import requests

API_KEY = os.environ.get('OPENWEATHER_API_KEY')
if not API_KEY:
    raise SystemExit('请设置环境变量 OPENWEATHER_API_KEY')

CITY = 'Beijing'

url = f'https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_KEY}&units=metric'

try:
    response = requests.get(url, timeout=10)
    print(f'Status: {response.status_code}')

    if response.status_code == 200:
        data = response.json()
        print(f'城市: {data["name"]}')
        print(f'温度: {data["main"]["temp"]}°C')
        print(f'湿度: {data["main"]["humidity"]}%')
        print(f'天气: {data["weather"][0]["main"]}')
    else:
        print(f'Error: {response.text}')
except Exception as e:
    print(f'请求失败: {e}')
