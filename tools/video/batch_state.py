#!/usr/bin/env python3
"""
批量视频制作工作流 - 状态管理

负责批量任务的创建、状态追踪、断点续传
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Optional, Any
from datetime import datetime
from dataclasses import dataclass, asdict, field
import shutil

from batch_config import BATCH_STATUS_DIR, VIDEO_OUTPUT_DIR, TASK_STATUS, STEP_STATUS


@dataclass
class StepState:
    """单步状态"""
    status: str = STEP_STATUS["PENDING"]
    output: Optional[str] = None
    error: Optional[str] = None
    duration: Optional[float] = None

    def to_dict(self) -> Dict:
        return {k: v for k, v in asdict(self).items() if v is not None}

    @classmethod
    def from_dict(cls, data: Dict) -> 'StepState':
        return cls(
            status=data.get("status", STEP_STATUS["PENDING"]),
            output=data.get("output"),
            error=data.get("error"),
            duration=data.get("duration")
        )


@dataclass
class TaskState:
    """单个任务状态"""
    task_id: str
    script_path: str
    turtle_type: str = ""
    status: str = TASK_STATUS["PENDING"]
    steps: Dict[str, StepState] = field(default_factory=dict)
    error: Optional[str] = None
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())
    updated_at: str = field(default_factory=lambda: datetime.now().isoformat())
    completed_at: Optional[str] = None

    def to_dict(self) -> Dict:
        return {
            "task_id": self.task_id,
            "script_path": self.script_path,
            "turtle_type": self.turtle_type,
            "status": self.status,
            "steps": {k: v.to_dict() for k, v in self.steps.items()},
            "error": self.error,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "completed_at": self.completed_at
        }

    @classmethod
    def from_dict(cls, data: Dict) -> 'TaskState':
        steps = {k: StepState.from_dict(v) for k, v in data.get("steps", {}).items()}
        return cls(
            task_id=data["task_id"],
            script_path=data["script_path"],
            turtle_type=data.get("turtle_type", ""),
            status=data.get("status", TASK_STATUS["PENDING"]),
            steps=steps,
            error=data.get("error"),
            created_at=data.get("created_at", datetime.now().isoformat()),
            updated_at=data.get("updated_at", datetime.now().isoformat()),
            completed_at=data.get("completed_at")
        )


@dataclass
class BatchState:
    """批量任务状态"""
    batch_id: str
    config: Dict[str, Any]
    tasks: List[TaskState] = field(default_factory=list)
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())
    updated_at: str = field(default_factory=lambda: datetime.now().isoformat())
    completed_at: Optional[str] = None

    def to_dict(self) -> Dict:
        return {
            "batch_id": self.batch_id,
            "config": self.config,
            "tasks": [t.to_dict() for t in self.tasks],
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "completed_at": self.completed_at
        }

    @classmethod
    def from_dict(cls, data: Dict) -> 'BatchState':
        tasks = [TaskState.from_dict(t) for t in data.get("tasks", [])]
        return cls(
            batch_id=data["batch_id"],
            config=data.get("config", {}),
            tasks=tasks,
            created_at=data.get("created_at", datetime.now().isoformat()),
            updated_at=data.get("updated_at", datetime.now().isoformat()),
            completed_at=data.get("completed_at")
        )

    def get_summary(self) -> Dict:
        """获取任务摘要"""
        summary = {
            "total": len(self.tasks),
            "pending": 0,
            "processing": 0,
            "completed": 0,
            "failed": 0,
            "skipped": 0
        }
        for task in self.tasks:
            summary[task.status.lower()] = summary.get(task.status.lower(), 0) + 1
        return summary

    def get_task(self, task_id: str) -> Optional[TaskState]:
        """根据 task_id 获取任务"""
        for task in self.tasks:
            if task.task_id == task_id:
                return task
        return None

    def update_task_status(self, task_id: str, status: str, error: Optional[str] = None):
        """更新任务状态"""
        task = self.get_task(task_id)
        if task:
            task.status = status
            task.updated_at = datetime.now().isoformat()
            if error:
                task.error = error
            if status == TASK_STATUS["COMPLETED"]:
                task.completed_at = datetime.now().isoformat()

    def update_step_status(self, task_id: str, step: str, status: str,
                          output: Optional[str] = None, error: Optional[str] = None,
                          duration: Optional[float] = None):
        """更新步骤状态"""
        task = self.get_task(task_id)
        if task:
            if step not in task.steps:
                task.steps[step] = StepState()
            task.steps[step].status = status
            if output:
                task.steps[step].output = output
            if error:
                task.steps[step].error = error
            if duration:
                task.steps[step].duration = duration
            task.updated_at = datetime.now().isoformat()


class BatchStateManager:
    """批量状态管理器"""

    def __init__(self, batch_id: Optional[str] = None):
        """
        初始化状态管理器

        Args:
            batch_id: 批量任务ID，如果为None则创建新ID
        """
        if batch_id:
            self.batch_id = batch_id
            self.state_file = BATCH_STATUS_DIR / f"{batch_id}.json"
            self._state = self._load_state()
        else:
            self.batch_id = self._generate_batch_id()
            self.state_file = BATCH_STATUS_DIR / f"{self.batch_id}.json"
            self._state = None

    def _generate_batch_id(self) -> str:
        """生成批量任务ID"""
        return f"batch_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    def _load_state(self) -> Optional[BatchState]:
        """加载状态文件"""
        if self.state_file.exists():
            try:
                with open(self.state_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                return BatchState.from_dict(data)
            except Exception as e:
                print(f"Warning: Failed to load state file: {e}")
                return None
        return None

    def _save_state(self):
        """保存状态文件"""
        if self._state:
            self.state_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self.state_file, 'w', encoding='utf-8') as f:
                json.dump(self._state.to_dict(), f, ensure_ascii=False, indent=2)

    def create_batch(self, config: Dict[str, Any], tasks: List[Dict]) -> BatchState:
        """
        创建新的批量任务

        Args:
            config: 配置参数
            tasks: 任务列表

        Returns:
            BatchState
        """
        task_states = []
        for t in tasks:
            task_state = TaskState(
                task_id=t["task_id"],
                script_path=t["script_path"],
                turtle_type=t.get("turtle_type", "")
            )
            task_states.append(task_state)

        self._state = BatchState(
            batch_id=self.batch_id,
            config=config,
            tasks=task_states
        )
        self._save_state()
        return self._state

    def load_batch(self, batch_id: str) -> Optional[BatchState]:
        """加载已存在的批量任务"""
        self.batch_id = batch_id
        self.state_file = BATCH_STATUS_DIR / f"{batch_id}.json"
        self._state = self._load_state()
        return self._state

    def get_state(self) -> Optional[BatchState]:
        """获取当前状态"""
        return self._state

    def update_task(self, task_id: str, status: str, error: Optional[str] = None):
        """更新任务状态"""
        if self._state:
            self._state.update_task_status(task_id, status, error)
            self._save_state()

    def update_step(self, task_id: str, step: str, status: str,
                    output: Optional[str] = None, error: Optional[str] = None,
                    duration: Optional[float] = None):
        """更新步骤状态"""
        if self._state:
            self._state.update_step_status(task_id, step, status, output, error, duration)
            self._save_state()

    def get_pending_tasks(self) -> List[TaskState]:
        """获取待处理任务"""
        if not self._state:
            return []
        return [t for t in self._state.tasks if t.status == TASK_STATUS["PENDING"]]

    def get_failed_tasks(self) -> List[TaskState]:
        """获取失败任务"""
        if not self._state:
            return []
        return [t for t in self._state.tasks if t.status == TASK_STATUS["FAILED"]]

    @staticmethod
    def list_batches() -> List[Dict]:
        """列出所有批量任务"""
        batches = []
        if BATCH_STATUS_DIR.exists():
            for f in BATCH_STATUS_DIR.glob("batch_*.json"):
                try:
                    with open(f, 'r', encoding='utf-8') as fp:
                        data = json.load(fp)
                    summary = {
                        "total": len(data.get("tasks", [])),
                        "completed": 0,
                        "failed": 0
                    }
                    for t in data.get("tasks", []):
                        status = t.get("status", "").lower()
                        if status == "completed":
                            summary["completed"] += 1
                        elif status == "failed":
                            summary["failed"] += 1
                    batches.append({
                        "batch_id": data.get("batch_id"),
                        "created_at": data.get("created_at"),
                        "updated_at": data.get("updated_at"),
                        **summary
                    })
                except Exception:
                    pass
        return sorted(batches, key=lambda x: x.get("created_at", ""), reverse=True)
