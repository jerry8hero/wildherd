#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""测试天气API"""

import requests
import json

API_KEY = '4a79ec0dbe836c6fa5619541c39efa7b'
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
