#!/usr/bin/env python3
"""
文案 Review 核心模块
"""

import json
import subprocess
import time
from pathlib import Path
from typing import Optional, Dict, Any
import urllib.request
import urllib.error
import yaml


class ReviewConfig:
    """Review 配置管理"""

    def __init__(self, config_path: str = None):
        if config_path is None:
            config_path = Path(__file__).parent / "config.json"

        self._load_config(config_path)

    def _load_config(self, config_path: str):
        """加载 JSON 配置"""
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)

        # 从 minimax CLI 获取 API 配置
        import subprocess
        try:
            result = subprocess.run(
                ['x', 'minimax', '--cfg', 'cat'],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0:
                cfg = yaml.safe_load(result.stdout)
                profile = cfg.get("profile", [{}])[0]
                self.api_key = profile.get("codingplan", {}).get("apikey", "")
                self.api_model = profile.get("model", config["api"]["model"])
                self.api_endpoint = profile.get("endpoint", config["api"]["endpoint"]) + "/v1/messages"
            else:
                raise ValueError("Failed to get minimax config")
        except Exception as e:
            raise ValueError(f"无法获取 minimax 配置: {e}")

        self.api_max_tokens = config["api"]["max_tokens"]
        self.api_timeout = config["api"].get("timeout", 120)

        self.retry_times = config["review"]["retry_times"]
        self.retry_delay = config["review"]["retry_delay"]

        self.scripts_base = config["paths"]["scripts_base"]
        self.prompts_dir = Path(__file__).parent / config["paths"]["prompts_dir"]
        self.state_dir = Path(__file__).parent / config["paths"]["state_dir"]

        self.default_start = config["default_range"]["start"]
        self.default_end = config["default_range"]["end"]


class MiniMaxClient:
    """MiniMax API 客户端"""

    def __init__(self, config: ReviewConfig):
        self.config = config

    def call(self, content: str, prompt_template: str, round_num: int) -> str:
        """调用 MiniMax API，带重试机制"""
        prompt = f"""{prompt_template}

review 并修改以下文案，直接输出完整修改版：

{content}"""

        data = {
            "model": self.config.api_model,
            "max_tokens": self.config.api_max_tokens,
            "messages": [
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        }

        last_error = None

        for attempt in range(self.config.retry_times):
            try:
                return self._make_request(data)
            except urllib.error.HTTPError as e:
                last_error = f"HTTP Error: {e.code} - {e.reason}"
                if attempt < self.config.retry_times - 1:
                    time.sleep(self.config.retry_delay)
            except urllib.error.URLError as e:
                last_error = f"URL Error: {e.reason}"
                if attempt < self.config.retry_times - 1:
                    time.sleep(self.config.retry_delay)
            except Exception as e:
                last_error = str(e)
                if attempt < self.config.retry_times - 1:
                    time.sleep(self.config.retry_delay)

        raise Exception(f"Failed after {self.config.retry_times} attempts. Last error: {last_error}")

    def _make_request(self, data: Dict[str, Any]) -> str:
        """发送 API 请求"""
        req = urllib.request.Request(
            self.config.api_endpoint,
            data=json.dumps(data).encode('utf-8'),
            headers={
                'Content-Type': 'application/json',
                'x-api-key': self.config.api_key,
                'anthropic-version': '2023-06-01'
            },
            method='POST'
        )

        with urllib.request.urlopen(req, timeout=self.config.api_timeout) as response:
            result = json.loads(response.read().decode('utf-8'))

        if result.get('type') == 'error':
            raise Exception(f"API Error: {result.get('error', {}).get('message', 'Unknown error')}")

        content_list = result.get('content', [])
        for item in content_list:
            if item.get('type') == 'text':
                return item.get('text', '')

        raise Exception("No text response from API")