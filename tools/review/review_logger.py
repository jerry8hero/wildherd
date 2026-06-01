#!/usr/bin/env python3
"""
Review 报告生成模块
"""

import json
import os
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any


class ReviewLogger:
    """Review 报告日志记录器"""

    def __init__(self, state_dir: str = "state"):
        self.state_dir = Path(state_dir)
        self.state_dir.mkdir(parents=True, exist_ok=True)

        # 获取当前日期用于报告文件名
        self.date_str = datetime.now().strftime("%Y%m%d_%H%M%S")

    def load_prompt(self, prompt_path: str) -> str:
        """加载 prompt 模板"""
        with open(prompt_path, 'r', encoding='utf-8') as f:
            return f.read()

    def save_state(self, file_path: str, status: str, rounds_data: List[Dict] = None):
        """保存文件处理状态（用于断点续传）"""
        state_file = self.state_dir / f"{Path(file_path).stem}.json"

        state = {
            "file_path": file_path,
            "status": status,
            "last_updated": datetime.now().isoformat(),
            "rounds": rounds_data or []
        }

        with open(state_file, 'w', encoding='utf-8') as f:
            json.dump(state, f, ensure_ascii=False, indent=2)

    def load_state(self, file_path: str) -> Dict[str, Any]:
        """加载文件处理状态"""
        state_file = self.state_dir / f"{Path(file_path).stem}.json"

        if state_file.exists():
            with open(state_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {"status": "pending"}

    def is_processed(self, file_path: str) -> bool:
        """检查文件是否已完成处理"""
        state = self.load_state(file_path)
        return state.get("status") == "completed"

    def parse_review_response(self, response: str, round_num: int) -> Dict[str, Any]:
        """解析 Review 响应，提取评分和问题列表"""
        result = {
            "round": round_num,
            "score": None,
            "issues": [],
            "content": response
        }

        # 尝试提取评分
        score_patterns = [
            r'评分[：:]\s*(\d+)',
            r'分数[：:]\s*(\d+)',
            r'.*?(\d+)\s*分',
            r'Score[：:]\s*(\d+)'
        ]

        for pattern in score_patterns:
            import re
            match = re.search(pattern, response)
            if match:
                result["score"] = int(match.group(1))
                break

        # 尝试提取问题列表（简化处理）
        issue_patterns = [
            r'问题[：:]\s*([^\n]+(?:\n[^\n]+)*?)(?=\n\n|$)',
            r'建议[：:]\s*([^\n]+(?:\n[^\n]+)*?)(?=\n\n|$)'
        ]

        return result

    def generate_report(self, results: List[Dict], output_dir: str = None) -> str:
        """生成汇总报告"""
        if output_dir is None:
            output_dir = self.state_dir
        else:
            output_dir = Path(output_dir)
            output_dir.mkdir(parents=True, exist_ok=True)

        report_path = output_dir / f"review_report_{self.date_str}.json"

        report = {
            "generated_at": datetime.now().isoformat(),
            "total_files": len(results),
            "files": results,
            "summary": self._generate_summary(results)
        }

        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)

        return str(report_path)

    def _generate_summary(self, results: List[Dict]) -> Dict[str, Any]:
        """生成汇总统计"""
        total = len(results)
        completed = sum(1 for r in results if r.get("status") == "completed")
        failed = sum(1 for r in results if r.get("status") == "failed")

        # 计算平均评分
        all_scores = []
        for r in results:
            for round_data in r.get("rounds", []):
                if round_data.get("score"):
                    all_scores.append(round_data["score"])

        avg_score = sum(all_scores) / len(all_scores) if all_scores else 0

        return {
            "total": total,
            "completed": completed,
            "failed": failed,
            "average_score": round(avg_score, 1),
            "total_rounds": len(all_scores)
        }