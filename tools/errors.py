"""WildHerd 项目异常层级"""


class WildherdError(Exception):
    """项目基础异常"""


class APIError(WildherdError):
    """API 调用失败"""

    def __init__(self, service: str, status_code: int | None = None, message: str = ""):
        self.service = service
        self.status_code = status_code
        super().__init__(f"[{service}] HTTP {status_code}: {message}" if status_code else f"[{service}] {message}")


class ReviewError(WildherdError):
    """文案审核失败"""


class PublishingError(WildherdError):
    """发布流程失败"""