#!/usr/bin/env python3
"""
BGM 匹配器

从免费 BGM 库中匹配适合的视频背景音乐

使用方法:
    python3 bgm_finder.py --duration 300 --mood calm
    python3 bgm_finder.py --list  # 列出本地 BGM 库
    python3 bgm_finder.py --download --query "peaceful nature" --duration 60
"""

import os
import sys
import json
import hashlib
import argparse
from pathlib import Path
from typing import Optional, List, Dict
from dataclasses import dataclass


@dataclass
class BGMTrack:
    """BGM 曲目"""
    id: str
    title: str
    artist: str
    duration: float  # 秒
    mood: str
    tags: List[str]
    file_path: Optional[str] = None
    source: str = "local"
    url: Optional[str] = None


class BGMFinder:
    """BGM 匹配器"""

    # 预设 BGM 库目录
    DEFAULT_BGM_DIR = "assets/bgm"

    # 预设背景音乐配置 (可扩展)
    PRESET_BGMS = [
        {
            "id": "peaceful_nature_01",
            "title": "宁静自然",
            "artist": "免费素材",
            "duration": 180,
            "mood": "calm",
            "tags": ["自然", "宁静", "放松", "轻音乐"]
        },
        {
            "id": "peaceful_nature_02",
            "title": "清晨露珠",
            "artist": "免费素材",
            "duration": 240,
            "mood": "calm",
            "tags": ["自然", "清晨", "露珠", "轻音乐"]
        },
        {
            "id": "ambient_01",
            "title": "环境音氛围",
            "artist": "免费素材",
            "duration": 300,
            "mood": "ambient",
            "tags": ["氛围", "环境音", "科技感"]
        },
        {
            "id": "upbeat_01",
            "title": "活力节奏",
            "artist": "免费素材",
            "duration": 150,
            "mood": "energetic",
            "tags": ["活力", "节奏", "轻快"]
        },
        {
            "id": "dramatic_01",
            "title": "戏剧性转折",
            "artist": "免费素材",
            "duration": 60,
            "mood": "dramatic",
            "tags": ["戏剧性", "紧张", "悬疑"]
        },
        {
            "id": "peaceful_water_01",
            "title": "水波荡漾",
            "artist": "免费素材",
            "duration": 200,
            "mood": "calm",
            "tags": ["水", "自然", "放松", "爬宠"]
        },
        {
            "id": "gentle_morning_01",
            "title": "温柔晨光",
            "artist": "免费素材",
            "duration": 180,
            "mood": "calm",
            "tags": ["晨光", "温柔", "自然"]
        },
        {
            "id": "adventure_01",
            "title": "探索发现",
            "artist": "免费素材",
            "duration": 120,
            "mood": "adventure",
            "tags": ["探索", "发现", "好奇"]
        },
        {
            "id": "funny_01",
            "title": "趣味时刻",
            "artist": "免费素材",
            "duration": 90,
            "mood": "funny",
            "tags": ["趣味", "幽默", "轻松"]
        },
        {
            "id": "serious_01",
            "title": "严肃提醒",
            "artist": "免费素材",
            "duration": 60,
            "mood": "serious",
            "tags": ["警告", "严肃", "提醒"]
        }
    ]

    # 视频内容类型到 BGM 类型的映射
    CONTENT_MOOD_MAP = {
        "introduction": "calm",       # 开场介绍 - 平静
        "equipment": "ambient",        # 装备介绍 - 科技感
        "feeding": "peaceful",         # 喂食 - 自然平静
        "habitat": "nature",           # 栖息环境 - 自然
        "growth": "upbeat",            # 成长变化 - 活力
        "warning": "serious",          # 警告提醒 - 严肃
        "funny": "funny",              # 趣味内容 - 轻松
        "summary": "calm",             # 总结 - 平静
        "default": "calm"             # 默认 - 平静
    }

    def __init__(self, bgm_dir: Optional[str] = None):
        """
        初始化 BGM 匹配器

        Args:
            bgm_dir: 本地 BGM 库目录
        """
        self.bgm_dir = Path(bgm_dir) if bgm_dir else Path(self.DEFAULT_BGM_DIR)
        self.local_tracks = self._scan_local_bgm()

    def _scan_local_bgm(self) -> List[BGMTrack]:
        """扫描本地 BGM 库"""
        tracks = []

        if not self.bgm_dir.exists():
            print(f"本地 BGM 库不存在: {self.bgm_dir}")
            print("将使用预设 BGM 配置")
            return tracks

        # 扫描目录中的音频文件
        for ext in ["*.mp3", "*.wav", "*.ogg", "*.m4a"]:
            for file_path in self.bgm_dir.glob(ext):
                track = self._parse_bgm_file(file_path)
                if track:
                    tracks.append(track)

        return tracks

    def _parse_bgm_file(self, file_path: Path) -> Optional[BGMTrack]:
        """解析 BGM 文件"""
        try:
            # 从文件名解析信息
            # 格式: mood_title_artist_duration.mp3
            name = file_path.stem
            parts = name.split("_")

            if len(parts) >= 2:
                mood = parts[0] if parts[0] in ["calm", "energetic", "ambient", "funny", "serious", "adventure"] else "calm"
                title = parts[1] if len(parts) > 1 else file_path.stem
                artist = parts[2] if len(parts) > 2 else "Unknown"

                # 获取文件时长
                duration = self._get_audio_duration(file_path)

                return BGMTrack(
                    id=self._generate_id(file_path),
                    title=title,
                    artist=artist,
                    duration=duration,
                    mood=mood,
                    tags=[title, artist],
                    file_path=str(file_path),
                    source="local"
                )
        except Exception as e:
            print(f"解析 BGM 文件失败 {file_path}: {e}")

        return None

    def _get_audio_duration(self, file_path: Path) -> float:
        """获取音频时长"""
        try:
            # 使用 ffprobe 获取时长
            import subprocess
            cmd = [
                "ffprobe",
                "-v", "error",
                "-show_entries", "format=duration",
                "-of", "json",
                str(file_path)
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)

            if result.returncode == 0:
                data = json.loads(result.stdout)
                return float(data["format"]["duration"])
        except Exception:
            pass

        # 备用方案：从文件名猜测时长
        return 180.0  # 默认 3 分钟

    def _generate_id(self, file_path: Path) -> str:
        """生成唯一 ID"""
        return hashlib.md5(str(file_path).encode()).hexdigest()[:8]

    def list_tracks(self, mood: Optional[str] = None) -> List[BGMTrack]:
        """
        列出可用 BGM

        Args:
            mood: 按情绪筛选

        Returns:
            BGM 列表
        """
        tracks = []

        # 添加本地曲目
        for track in self.local_tracks:
            if mood is None or track.mood == mood:
                tracks.append(track)

        # 添加预设曲目
        for preset in self.PRESET_BGMS:
            if mood is None or preset["mood"] == mood:
                track = BGMTrack(
                    id=preset["id"],
                    title=preset["title"],
                    artist=preset["artist"],
                    duration=preset["duration"],
                    mood=preset["mood"],
                    tags=preset["tags"],
                    source="preset"
                )
                tracks.append(track)

        return tracks

    def find_matching_bgm(
        self,
        duration: float,
        mood: str = "calm",
        tolerance: float = 30.0
    ) -> Optional[BGMTrack]:
        """
        查找匹配的 BGM

        Args:
            duration: 视频时长(秒)
            mood: 需要的情绪风格
            tolerance: 时长容差(秒)

        Returns:
            最匹配的 BGM
        """
        tracks = self.list_tracks(mood=mood)

        if not tracks:
            # 尝试宽松匹配
            tracks = self.list_tracks()
            if not tracks:
                return None

        # 优先选择时长接近的
        best_track = None
        best_score = float('inf')

        for track in tracks:
            # 时长差异评分
            duration_diff = abs(track.duration - duration)

            # 情绪匹配评分
            mood_score = 0 if track.mood == mood else 50

            # 总体评分
            score = duration_diff + mood_score * 10

            if score < best_score:
                best_score = score
                best_track = track

        return best_track

    def get_bgm_for_content(
        self,
        content_type: str,
        duration: float
    ) -> Optional[BGMTrack]:
        """
        根据内容类型获取 BGM

        Args:
            content_type: 内容类型 (introduction, equipment, feeding, etc.)
            duration: 视频时长

        Returns:
            推荐的 BGM
        """
        mood = self.CONTENT_MOOD_MAP.get(content_type, "calm")
        return self.find_matching_bgm(duration, mood)

    def get_bgm_for_script(
        self,
        script_keywords: List[str],
        duration: float
    ) -> Optional[BGMTrack]:
        """
        根据脚本关键词获取 BGM

        Args:
            script_keywords: 脚本关键词列表
            duration: 视频时长

        Returns:
            推荐的 BGM
        """
        # 简单的关键词匹配
        keyword_mood_map = {
            "警告": "serious",
            "危险": "serious",
            "注意": "serious",
            "安全": "calm",
            "放松": "calm",
            "宁静": "calm",
            "活力": "energetic",
            "成长": "upbeat",
            "探索": "adventure",
            "发现": "adventure",
            "趣味": "funny",
            "搞笑": "funny",
            "环境": "ambient",
            "设备": "ambient",
            "水": "calm",
            "自然": "nature"
        }

        detected_moods = []
        for keyword in script_keywords:
            for key, mood in keyword_mood_map.items():
                if key in keyword:
                    detected_moods.append(mood)

        # 统计最常见的情绪
        if detected_moods:
            from collections import Counter
            mood_counts = Counter(detected_moods)
            preferred_mood = mood_counts.most_common(1)[0][0]
        else:
            preferred_mood = "calm"

        return self.find_matching_bgm(duration, preferred_mood)

    def download_from_pixabay(self, query: str, duration: int = 60) -> Optional[str]:
        """
        从 Pixabay 下载 BGM (需要 API Key)

        Args:
            query: 搜索关键词
            duration: 时长限制

        Returns:
            下载的文件路径
        """
        api_key = os.environ.get("PIXABAY_API_KEY")

        if not api_key:
            print("未设置 PIXABAY_API_KEY 环境变量")
            print("请到 https://pixabay.com/api/ 获取 API Key")
            return None

        # Pixabay API 调用
        url = "https://pixabay.com/api/"
        params = {
            "key": api_key,
            "q": query,
            "media_type": "music",
            "duration": duration
        }

        try:
            import requests
            response = requests.get(url, params=params, timeout=30)

            if response.status_code == 200:
                data = response.json()
                if data["hits"]:
                    # 返回第一个结果
                    return data["hits"][0].get("previewURL")
        except Exception as e:
            print(f"Pixabay 下载失败: {e}")

        return None


def list_available_bgm(mood: Optional[str] = None):
    """列出可用 BGM"""
    finder = BGMFinder()
    tracks = finder.list_tracks(mood=mood)

    print("=" * 70)
    print(f"{'ID':<20} {'标题':<20} {'时长':<8} {'风格':<12} {'来源'}")
    print("-" * 70)

    for track in tracks:
        print(f"{track.id:<20} {track.title:<20} {track.duration:.0f}秒 "
              f"{track.mood:<12} {track.source}")

    print("-" * 70)
    print(f"共 {len(tracks)} 首 BGM")


def main():
    parser = argparse.ArgumentParser(description="BGM 匹配器")
    parser.add_argument("--list", "-l", action="store_true", help="列出可用 BGM")
    parser.add_argument("--mood", "-m", help="筛选风格 (calm/energetic/ambient/funny/serious/adventure)")
    parser.add_argument("--duration", "-d", type=float, help="视频时长(秒)")
    parser.add_argument("--content", "-c", help="内容类型")
    parser.add_argument("--query", "-q", help="搜索关键词 (用于 Pixabay)")
    parser.add_argument("--download", action="store_true", help="从 Pixabay 下载")
    parser.add_argument("--bgm-dir", help="本地 BGM 目录")

    args = parser.parse_args()

    finder = BGMFinder(bgm_dir=args.bgm_dir)

    # 列出 BGM
    if args.list:
        list_available_bgm(mood=args.mood)
        return

    # 查找匹配 BGM
    if args.duration:
        if args.mood:
            track = finder.find_matching_bgm(args.duration, args.mood)
        elif args.content:
            track = finder.get_bgm_for_content(args.content, args.duration)
        else:
            track = finder.find_matching_bgm(args.duration)

        if track:
            print(f"\n推荐的 BGM:")
            print(f"  标题: {track.title}")
            print(f"  艺术家: {track.artist}")
            print(f"  时长: {track.duration:.0f}秒")
            print(f"  风格: {track.mood}")
            print(f"  来源: {track.source}")
            if track.file_path:
                print(f"  文件: {track.file_path}")
        else:
            print("未找到匹配的 BGM")
        return

    # 下载 BGM
    if args.download and args.query:
        result = finder.download_from_pixabay(args.query, int(args.duration or 60))
        if result:
            print(f"下载链接: {result}")
        return

    # 无参数
    parser.print_help()
    print("\n示例:")
    print("  python3 bgm_finder.py --list")
    print("  python3 bgm_finder.py --duration 300 --mood calm")
    print("  python3 bgm_finder.py --content equipment --duration 180")


if __name__ == "__main__":
    main()
