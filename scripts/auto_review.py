#!/usr/bin/env python3
"""
自动化文案Review脚本
对视频文案进行3轮迭代优化（分维度针对性评审）

功能：
1. 评审维度精细化 - 三套 prompt 分别针对开场、叙事、结尾
2. 配置外置化 - config.json + 环境变量管理 API_KEY
3. 评分与报告机制 - 每轮输出评分和问题列表，生成 JSON 报告
4. 健壮性提升 - 失败重试（最多3次）、断点续传
"""

import json
import sys
from datetime import datetime
from pathlib import Path

from review_core import ReviewConfig, MiniMaxClient
from state_manager import StateManager


class ReviewReport:
    """Review 报告生成器"""

    def __init__(self):
        self.results = []
        self.start_time = datetime.now()

    def add_result(self, file_path: str, status: str, rounds_data: list = None,
                   error: str = None, original_len: int = 0, final_len: int = 0):
        self.results.append({
            "file_path": file_path,
            "status": status,
            "rounds": rounds_data or [],
            "error": error,
            "original_length": original_len,
            "final_length": final_len,
            "timestamp": datetime.now().isoformat()
        })

    def generate_report(self, output_path: str = None) -> dict:
        """生成汇总报告"""
        if output_path is None:
            output_path = Path(__file__).parent / "state" / f"review_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

        # 计算统计
        total = len(self.results)
        completed = sum(1 for r in self.results if r["status"] == "completed")
        failed = sum(1 for r in self.results if r["status"] == "failed")

        # 计算平均评分
        all_scores = []
        for r in self.results:
            for round_data in r.get("rounds", []):
                if round_data.get("score"):
                    all_scores.append(round_data["score"])

        summary = {
            "total": total,
            "completed": completed,
            "failed": failed,
            "average_score": round(sum(all_scores) / len(all_scores), 1) if all_scores else 0,
            "total_review_rounds": len(all_scores),
            "duration_seconds": (datetime.now() - self.start_time).seconds
        }

        report = {
            "generated_at": datetime.now().isoformat(),
            "summary": summary,
            "files": self.results
        }

        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, ensure_ascii=False, indent=2)

        return report


def load_prompt_template(prompts_dir: Path, filename: str) -> str:
    """加载 Prompt 模板"""
    prompt_path = prompts_dir / filename
    with open(prompt_path, 'r', encoding='utf-8') as f:
        content = f.read()
    # 返回除了最后一行之外的内容（最后一行是提示语）
    lines = content.strip().split('\n')
    return '\n'.join(lines[:-1])


def parse_review_output(output: str, round_num: int) -> dict:
    """解析 Review 输出，提取评分和问题"""
    result = {
        "round": round_num,
        "score": None,
        "issues": [],
        "content": output
    }

    # 尝试提取评分
    import re
    score_patterns = [
        r'评分[：:]\s*(\d+)',
        r'分数[：:]\s*(\d+)',
        r'Score[：:]\s*(\d+)',
        r'(\d+)\s*/\s*10',
        r'(\d+)\s*分'
    ]

    for pattern in score_patterns:
        match = re.search(pattern, output)
        if match:
            result["score"] = int(match.group(1))
            break

    return result


def extract_main_content(content: str) -> str:
    """提取视频正文文案部分（#之后，---之前）"""
    parts = content.split('---')
    if parts:
        return parts[0].strip()
    return content


def reassemble_content(original_content: str, optimized_content: str) -> str:
    """重新组装完整文案（保留 --- 之后的 B站发布内容）"""
    parts = original_content.split('---')
    if len(parts) > 1:
        return optimized_content + '\n\n---\n\n' + '---'.join(parts[1:])
    return optimized_content


def three_round_review(file_path: str, config: ReviewConfig, client: MiniMaxClient) -> dict:
    """对单个文件进行3轮Review，返回结果详情"""
    result = {
        "file_path": file_path,
        "status": "in_progress",
        "rounds": [],
        "error": None
    }

    print(f"  处理文件: {file_path}")

    # 加载 prompt 模板
    prompt_r1 = load_prompt_template(config.prompts_dir, "round1_opening.md")
    prompt_r2 = load_prompt_template(config.prompts_dir, "round2_narrative.md")
    prompt_r3 = load_prompt_template(config.prompts_dir, "round3_ending.md")

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        original_len = len(content)
        main_content = extract_main_content(content)

        print(f"    原文案长度: {len(main_content)} 字符")

        # 第1轮Review - 开场
        print(f"    第1轮Review（开场）...")
        reviewed_1 = client.call(main_content, prompt_r1, 1)
        parsed_1 = parse_review_output(reviewed_1, 1)
        result["rounds"].append(parsed_1)
        print(f"      评分: {parsed_1.get('score', 'N/A')}")

        # 第2轮Review - 叙事
        print(f"    第2轮Review（叙事）...")
        reviewed_2 = client.call(reviewed_1, prompt_r2, 2)
        parsed_2 = parse_review_output(reviewed_2, 2)
        result["rounds"].append(parsed_2)
        print(f"      评分: {parsed_2.get('score', 'N/A')}")

        # 第3轮Review - 结尾
        print(f"    第3轮Review（结尾）...")
        reviewed_3 = client.call(reviewed_2, prompt_r3, 3)
        parsed_3 = parse_review_output(reviewed_3, 3)
        result["rounds"].append(parsed_3)
        print(f"      评分: {parsed_3.get('score', 'N/A')}")

        print(f"    优化后长度: {len(reviewed_3)} 字符")

        # 重新组装并保存
        final_content = reassemble_content(content, reviewed_3)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(final_content)

        result["status"] = "completed"
        result["original_length"] = original_len
        result["final_length"] = len(final_content)
        print(f"    ✓ 完成")

    except Exception as e:
        result["status"] = "failed"
        result["error"] = str(e)
        print(f"    ✗ 错误: {e}")

    return result


def process_directory(base_dir: str, start_num: int = 2, end_num: int = 101,
                      config: ReviewConfig = None, client: MiniMaxClient = None,
                      state_mgr: StateManager = None, report: ReviewReport = None):
    """处理目录下的所有视频文案文件"""
    base_path = Path(base_dir)

    for num in range(start_num, end_num + 1):
        num_str = f"{num:03d}"

        # 查找对应的目录
        matching_dirs = list(base_path.glob(f"{num_str}-*"))

        if not matching_dirs:
            print(f"跳过 {num_str}: 未找到对应目录")
            continue

        dir_path = matching_dirs[0]
        if not dir_path.is_dir():
            continue

        # 查找markdown文件
        md_files = list(dir_path.glob("*.md"))
        if not md_files:
            print(f"跳过 {num_str}: 目录中无md文件")
            continue

        file_path = str(md_files[0])

        # 检查是否已完成（断点续传）
        if state_mgr.is_completed(file_path):
            print(f"跳过 {num_str}: 已完成处理")
            continue

        # 标记为进行中
        state_mgr.save_state(file_path, "in_progress")

        # 执行3轮review
        result = three_round_review(file_path, config, client)

        # 更新状态
        state_mgr.save_state(
            file_path,
            result["status"],
            rounds_data=result.get("rounds"),
            error=result.get("error")
        )

        # 添加到报告
        report.add_result(
            file_path,
            result["status"],
            rounds_data=result.get("rounds"),
            error=result.get("error"),
            original_len=result.get("original_length", 0),
            final_len=result.get("final_length", 0)
        )


def main():
    # 加载配置
    try:
        config = ReviewConfig()
    except FileNotFoundError as e:
        print(f"配置文件未找到: {e}")
        print("请确保 config.json 存在，或复制 .env.example 为 .env 并填入 API_KEY")
        sys.exit(1)
    except ValueError as e:
        print(f"配置错误: {e}")
        print("请确保设置了 MINIMAX_API_KEY 环境变量")
        sys.exit(1)

    # 初始化组件
    client = MiniMaxClient(config)
    state_mgr = StateManager(str(config.state_dir))
    report = ReviewReport()

    # 解析命令行参数
    if len(sys.argv) > 1:
        start = int(sys.argv[1])
        end = int(sys.argv[2]) if len(sys.argv) > 2 else start
    else:
        start = config.default_start
        end = config.default_end

    # 可选：指定文案子目录
    sub_dir = sys.argv[3] if len(sys.argv) > 3 else None

    base_dir = config.scripts_base
    if sub_dir:
        base_dir = Path(base_dir) / sub_dir
    else:
        base_dir = Path(base_dir)

    print(f"开始处理: {start:03d} - {end:03d}")
    print(f"目录: {base_dir}")
    print("=" * 50)

    process_directory(
        str(base_dir), start, end,
        config=config,
        client=client,
        state_mgr=state_mgr,
        report=report
    )

    print("=" * 50)

    # 生成报告
    report_path = Path(config.state_dir) / f"review_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    summary = report.generate_report(str(report_path))
    print(f"处理完成!")
    print(f"  总文件数: {summary['summary']['total']}")
    print(f"  完成: {summary['summary']['completed']}")
    print(f"  失败: {summary['summary']['failed']}")
    print(f"  平均评分: {summary['summary']['average_score']}")
    print(f"报告已保存: {report_path}")


if __name__ == "__main__":
    main()