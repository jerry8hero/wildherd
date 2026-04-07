#!/usr/bin/env python3
"""
B站视频发布器

使用 B站开放平台 API 上传和发布视频

使用方法:
    python3 bilibili_publisher.py --video video.mp4 --title "视频标题"
    python3 bilibili_publisher.py --help

注意:
    需要 B站开放平台账号和 cookies
    获取 cookies: 登录 B站后，F12 开发者工具 -> Application -> Cookies
"""

import os
import sys
import json
import argparse
import hashlib
import time
from pathlib import Path
from typing import Optional, Dict, List
from urllib.parse import urlencode


# 检查依赖
try:
    import requests
except ImportError:
    print("请先安装 requests: pip install requests")
    sys.exit(1)


# B站API配置
BILIBILI_API = "https://api.bilibili.com"
UPLOAD_API = "https://upos-szu.com"


class BilibiliPublisher:
    """B站视频发布器"""

    def __init__(self, cookies: Optional[Dict[str, str]] = None):
        """
        初始化B站发布器

        Args:
            cookies: B站 cookies dict，包含 sessdata, bili_jct, buvid3 等
        """
        if cookies is None:
            cookies = self._load_cookies_from_env()

        self.cookies = cookies
        self.headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Referer": "https://www.bilibili.com"
        }

    def _load_cookies_from_env(self) -> Dict[str, str]:
        """从环境变量加载cookies"""
        cookies = {}
        sessdata = os.environ.get("BILIBILI_SESSDATA")
        bili_jct = os.environ.get("BILIBILI_BILI_JCT")
        buvid3 = os.environ.get("BILIBILI_BUVID3")

        if sessdata:
            cookies["SESSDATA"] = sessdata
        if bili_jct:
            cookies["bili_jct"] = bili_jct
        if buvid3:
            cookies["buvid3"] = buvid3

        return cookies

    def _check_login(self) -> bool:
        """检查登录状态"""
        url = f"{BILIBILI_API}/web-interface/nav"
        try:
            response = requests.get(
                url,
                cookies=self.cookies,
                headers=self.headers,
                timeout=10
            )
            result = response.json()
            return result.get("code") == 0
        except Exception as e:
            print(f"登录检查失败: {e}")
            return False

    def get_upload_token(self) -> Optional[Dict]:
        """获取上传令牌"""
        url = f"{BILIBILI_API}/x/gallery/v2/all-channel综上andlist"
        try:
            response = requests.get(
                url,
                cookies=self.cookies,
                headers=self.headers,
                timeout=10
            )
            if response.status_code == 200:
                return response.json()
        except Exception as e:
            print(f"获取上传令牌失败: {e}")
        return None

    def upload_video(
        self,
        video_path: str,
        title: str,
        desc: str = "",
        tags: Optional[List[str]] = None,
        tid: int = 124,  # 生活-日常
        cover_path: Optional[str] = None,
        source: str = ""
    ) -> Optional[Dict]:
        """
        上传并发布视频

        Args:
            video_path: 视频文件路径
            title: 视频标题
            desc: 视频描述
            tags: 标签列表
            tid: 分区ID
            cover_path: 封面图片路径
            source: 来源

        Returns:
            发布结果
        """
        video_path = Path(video_path)
        if not video_path.exists():
            raise FileNotFoundError(f"视频文件不存在: {video_path}")

        file_size = video_path.stat().st_size
        file_name = video_path.name

        print(f"准备上传视频: {title}")
        print(f"文件: {file_name} ({file_size / 1024 / 1024:.1f} MB)")

        # 检查登录状态
        if not self._check_login():
            print("错误: B站登录状态失效，请更新 cookies")
            return None

        # 注意：B站实际上传API需要更多步骤
        # 这里提供一个简化版本，实际使用需要完整对接

        # 1. 获取上传参数
        print("获取上传参数...")
        upload_params = self._get_upload_params()
        if not upload_params:
            print("获取上传参数失败")
            return None

        # 2. 分片上传
        print("开始上传...")
        upload_url = self._upload_file(
            video_path,
            upload_params
        )

        if not upload_url:
            print("上传失败")
            return None

        # 3. 提交发布
        print("提交发布...")
        result = self._submit_video(
            video_path=video_path,
            title=title,
            desc=desc,
            tags=tags,
            tid=tid,
            cover_path=cover_path,
            source=source,
            upload_url=upload_url
        )

        return result

    def _get_upload_params(self) -> Optional[Dict]:
        """获取上传参数（需要完整实现）"""
        # B站实际上传API需要申请开发者权限
        # 这里返回示例参数
        return {
            "upaudio": "https://upos-szu.com/mixin",
            "chunk_size": 4194304,  # 4MB
            "version": "2.0.0"
        }

    def _upload_file(self, video_path: Path, params: Dict) -> Optional[str]:
        """上传文件（需要完整实现）"""
        # B站使用分片上传，这里是简化版本
        # 实际需要对接B站开放平台API
        print("注意: B站API对接需要完整实现，当前为演示模式")
        return str(video_path)

    def _submit_video(
        self,
        video_path: Path,
        title: str,
        desc: str,
        tags: Optional[List[str]],
        tid: int,
        cover_path: Optional[str],
        source: str,
        upload_url: str
    ) -> Dict:
        """提交视频发布（需要完整实现）"""
        # 这里返回示例结果
        return {
            "code": 0,
            "message": "演示模式：实际发布需要完整API对接",
            "data": {
                "bvid": "BV1xxx",
                "aid": 12345678,
                "title": title,
                "status": "待审核"
            }
        }

    def get_video_list(self, page: int = 1, page_size: int = 10) -> List[Dict]:
        """获取已发布的视频列表"""
        url = f"{BILIBILI_API}/x/space/arc/search"
        params = {
            "pn": page,
            "ps": page_size,
            "order": "pubdate"
        }

        try:
            response = requests.get(
                url,
                params=params,
                cookies=self.cookies,
                headers=self.headers,
                timeout=10
            )
            result = response.json()

            if result.get("code") == 0:
                return result.get("data", {}).get("vlist", [])
            return []

        except Exception as e:
            print(f"获取视频列表失败: {e}")
            return []

    def delete_video(self, aid: int) -> bool:
        """删除视频"""
        url = f"{BILIBILI_API}/x/video/delete"
        data = {"aid": aid}

        try:
            response =requests.post(
                url,
                data=data,
                cookies=self.cookies,
                headers=self.headers,
                timeout=10
            )
            result = response.json()
            return result.get("code") == 0
        except Exception as e:
            print(f"删除视频失败: {e}")
            return False


def save_cookies(cookies: Dict[str, str], filepath: str = "bilibili_cookies.json"):
    """保存cookies到文件"""
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(cookies, f, ensure_ascii=False, indent=2)
    print(f"Cookies已保存到: {filepath}")


def load_cookies_from_file(filepath: str = "bilibili_cookies.json") -> Dict[str, str]:
    """从文件加载cookies"""
    if not os.path.exists(filepath):
        return {}

    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)


def interactive_setup():
    """交互式设置"""
    print("\n" + "="*50)
    print("B站发布器设置")
    print("="*50)

    print("\n请按以下步骤获取Cookies:")
    print("1. 登录 B站 (https://www.bilibili.com)")
    print("2. 按 F12 打开开发者工具")
    print("3. 切换到 'Application' 标签")
    print("4. 左侧选择 'Cookies' -> 'https://www.bilibili.com'")
    print("5. 找到并复制以下值:")
    print("   - SESSDATA")
    print("   - bili_jct")
    print("   - buvid3")
    print()

    cookies = {}
    cookies["SESSDATA"] = input("请输入 SESSDATA: ").strip()
    cookies["bili_jct"] = input("请输入 bili_jct: ").strip()
    cookies["buvid3"] = input("请输入 buvid3 (可选): ").strip() or ""

    if cookies["SESSDATA"]:
        # 保存到文件
        save_path = "bilibili_cookies.json"
        save_cookies(cookies, save_path)

        # 同时保存到环境变量文件
        env_path = ".env"
        with open(env_path, "a", encoding="utf-8") as f:
            f.write(f"\n# B站 Cookies\n")
            f.write(f'BILIBILI_SESSDATA="{cookies["SESSDATA"]}"\n')
            f.write(f'BILIBILI_BILI_JCT="{cookies["bili_jct"]}"\n')
            if cookies["buvid3"]:
                f.write(f'BILIBILI_BUVID3="{cookies["buvid3"]}"\n')

        print(f"\n已保存到: {save_path}")
        print("\n下一步: 运行 python3 bilibili_publisher.py 测试发布")


def main():
    parser = argparse.ArgumentParser(
        description="B站视频发布器",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 交互式设置（首次使用）
  python3 bilibili_publisher.py --setup

  # 上传视频
  python3 bilibili_publisher.py --video video.mp4 --title "视频标题" --desc "视频描述"

  # 指定标签
  python3 bilibili_publisher.py --video video.mp4 --title "标题" --tags "爬宠,养龟,新手"

  # 获取视频列表
  python3 bilibili_publisher.py --list

  # 删除视频
  python3 bilibili_publisher.py --delete 12345678

注意事项:
  - 需要 B站开放平台权限才能上传
  - 获取 Cookies 方法见上方说明
  - 视频需要审核后才能公开可见
        """
    )

    parser.add_argument("--setup", action="store_true", help="交互式设置cookies")
    parser.add_argument("--video", "-v", help="视频文件路径")
    parser.add_argument("--title", "-t", help="视频标题")
    parser.add_argument("--desc", "-d", default="", help="视频描述")
    parser.add_argument("--tags", nargs="+", help="视频标签")
    parser.add_argument("--cover", "-c", help="封面图片路径")
    parser.add_argument("--list", action="store_true", help="获取视频列表")
    parser.add_argument("--delete", type=int, help="删除视频(AID)")
    parser.add_argument("--cookies-file", default="bilibili_cookies.json", help="cookies文件路径")

    args = parser.parse_args()

    # 交互式设置
    if args.setup:
        interactive_setup()
        return

    # 加载cookies
    cookies = load_cookies_from_file(args.cookies_file)
    if not cookies:
        print("错误: 未找到cookies，请先运行 --setup")
        print("或设置环境变量: BILIBILI_SESSDATA, BILIBILI_BILI_JCT")
        sys.exit(1)

    publisher = BilibiliPublisher(cookies)

    # 获取视频列表
    if args.list:
        print("\n获取视频列表...")
        videos = publisher.get_video_list()
        if videos:
            print(f"\n共 {len(videos)} 个视频:\n")
            print(f"{'标题':<40} {'BVID':<15} {'播放':<10}")
            print("-" * 70)
            for v in videos:
                title = v.get("title", "")[:38]
                bvid = v.get("bvid", "")
                play = v.get("play", 0)
                print(f"{title:<40} {bvid:<15} {play}")
        else:
            print("未获取到视频列表")
        return

    # 删除视频
    if args.delete:
        print(f"\n删除视频 AID={args.delete}...")
        if publisher.delete_video(args.delete):
            print("删除成功")
        else:
            print("删除失败")
        return

    # 上传视频
    if args.video:
        if not args.title:
            print("错误: 上传视频需要 --title 参数")
            sys.exit(1)

        result = publisher.upload_video(
            video_path=args.video,
            title=args.title,
            desc=args.desc,
            tags=args.tags,
            cover_path=args.cover
        )

        if result:
            print("\n发布结果:")
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            print("\n发布失败")
        return

    # 无参数
    parser.print_help()
    print("\n提示: 使用 --setup 进行初始设置")


if __name__ == "__main__":
    main()
