#!/usr/bin/env python3
"""
状态管理模块（用于断点续传）
"""

import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any, Optional


class StateManager:
    """文件处理状态管理器"""

    def __init__(self, state_dir: str = "state"):
        self.state_dir = Path(state_dir)
        self.state_dir.mkdir(parents=True, exist_ok=True)

    def _get_state_file(self, file_path: str) -> Path:
        """获取状态文件路径"""
        # 使用文件名的 hash 作为状态文件名，避免路径中的特殊字符问题
        import hashlib
        name = Path(file_path).stem
        # 保留原始后缀以便识别
        suffix = Path(file_path).suffix
        state_name = f"{name}{suffix}.state.json"
        return self.state_dir / state_name

    def save_state(self, file_path: str, status: str, rounds_data: List[Dict] = None,
                   last_round_content: str = None, error: str = None):
        """保存文件处理状态"""
        state_file = self._get_state_file(file_path)

        state = {
            "file_path": file_path,
            "status": status,  # pending, in_progress, completed, failed
            "last_updated": datetime.now().isoformat(),
            "rounds": rounds_data or [],
            "last_round_content": last_round_content,
            "error": error
        }

        with open(state_file, 'w', encoding='utf-8') as f:
            json.dump(state, f, ensure_ascii=False, indent=2)

    def load_state(self, file_path: str) -> Dict[str, Any]:
        """加载文件处理状态"""
        state_file = self._get_state_file(file_path)

        if state_file.exists():
            with open(state_file, 'r', encoding='utf-8') as f:
                return json.load(f)

        return {"status": "pending"}

    def is_completed(self, file_path: str) -> bool:
        """检查文件是否已完成处理"""
        state = self.load_state(file_path)
        return state.get("status") == "completed"

    def get_in_progress_files(self) -> List[str]:
        """获取所有进行中的文件（用于断点恢复）"""
        in_progress = []
        for state_file in self.state_dir.glob("*.json"):
            try:
                with open(state_file, 'r', encoding='utf-8') as f:
                    state = json.load(f)
                if state.get("status") == "in_progress":
                    in_progress.append(state.get("file_path"))
            except Exception:
                continue
        return in_progress

    def clear_state(self, file_path: str = None):
        """清除状态文件"""
        if file_path:
            state_file = self._get_state_file(file_path)
            if state_file.exists():
                state_file.unlink()
        else:
            # 清除所有状态文件
            for state_file in self.state_dir.glob("*.json"):
                state_file.unlink()

    def get_all_states(self) -> List[Dict[str, Any]]:
        """获取所有状态（用于生成报告）"""
        states = []
        for state_file in self.state_dir.glob("*.json"):
            try:
                with open(state_file, 'r', encoding='utf-8') as f:
                    states.append(json.load(f))
            except Exception:
                continue
        return states