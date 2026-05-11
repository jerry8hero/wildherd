"""API 客户端基类"""

import os
import logging
import requests
from abc import ABC, abstractmethod
from errors import APIError

logger = logging.getLogger(__name__)


class BaseAPIClient(ABC):
    def __init__(self, api_key_env: str, base_url: str):
        self.base_url = base_url
        self.api_key = os.environ.get(api_key_env)
        if not self.api_key:
            raise EnvironmentError(f"请设置环境变量 {api_key_env}")
        self._headers = self._build_headers()

    @abstractmethod
    def _build_headers(self) -> dict: ...

    def post(self, path: str, payload: dict, timeout: int = 60) -> dict:
        url = f"{self.base_url}{path}"
        try:
            resp = requests.post(url, json=payload, headers=self._headers, timeout=timeout)
            resp.raise_for_status()
            return resp.json()
        except requests.exceptions.Timeout:
            raise APIError(self.__class__.__name__, message="请求超时")
        except requests.exceptions.HTTPError as e:
            raise APIError(self.__class__.__name__, status_code=e.response.status_code, message=str(e))
        except requests.exceptions.RequestException as e:
            raise APIError(self.__class__.__name__, message=str(e))