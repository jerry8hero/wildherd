#!/usr/bin/env python3
"""
内容审核检查脚本

功能：
- 知识准确性检查（物种名称、数据、饲养方法）
- 安全提示检查
- 法规信息检查
- 完整性检查

用法:
    python3 content_checker.py <文件路径>                    # 检查单个文件
    python3 content_checker.py --all                         # 检查所有待审核文件
    python3 content_checker.py <文件路径> --fix              # 自动修复可修复的问题
"""

import os
import sys
import re
import json
import yaml
import argparse
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass


# 爬宠知识库（内置基础验证规则）
KNOWLEDGE_BASE = {
    "大鳄龟": {
        "学名": "真鳄龟",
        "英文名": "Macrochelys temminckii",
        "体型": "60-70厘米，60公斤以上",
        "寿命": "60-100年",
        "水温": "24-29°C",
        "食性": "肉食性鱼类、水鸟、螃蟹"
    },
    "小鳄龟": {
        "学名": "拟鳄龟",
        "英文名": "Chelydra serpentina",
        "体型": "30-40厘米，20-30公斤",
        "寿命": "30-50年",
        "水温": "25-30°C",
        "食性": "肉食性"
    },
    "北美拟鳄龟": {
        "学名": "北美拟鳄龟",
        "英文名": "Chelydra serpentina serpentina",
        "体型": "30-40厘米",
        "分布": "北美"
    },
    "佛州拟鳄龟": {
        "学名": "佛州拟鳄龟",
        "英文名": "Chelydra serpentina osceola",
        "特点": "性格更凶猛"
    },
    "草龟": {
        "学名": "中华草龟",
        "英文名": "Mauremys reevesii",
        "体型": "20-30厘米",
        "寿命": "20-30年"
    },
    "巴西龟": {
        "学名": "红耳龟",
        "英文名": "Trachemys scripta elegans",
        "体型": "20-30厘米"
    }
}

# 法规相关关键词
LEGAL_KEYWORDS = [
    "外来入侵物种",
    "入侵物种",
    "放生",
    "违法",
    "生态破坏"
]

# 安全提示关键词
SAFETY_KEYWORDS = [
    "咬伤",
    "咬合力",
    "不要徒手",
    "长柄钳子",
    "安全操作"
]


@dataclass
class CheckResult:
    """检查结果"""
    check_type: str
    passed: bool
    issues: List[Dict]
    summary: str

    def to_dict(self) -> Dict:
        return {
            "check_type": self.check_type,
            "passed": self.passed,
            "issues": self.issues,
            "summary": self.summary
        }


class ContentChecker:
    """内容检查器"""

    def __init__(self, content: str, file_path: str = ""):
        self.content = content
        self.file_path = file_path
        self.lines = content.split("\n")
        self.issues: List[Dict] = []

    def check_species_names(self) -> CheckResult:
        """检查物种名称是否正确"""
        issues = []

        # 检查是否提到了物种名称
        species_found = []
        for name, info in KNOWLEDGE_BASE.items():
            if name in self.content:
                species_found.append(name)
                # 检查学名是否正确
                if info.get("学名") and info["学名"] not in self.content:
                    issues.append({
                        "severity": "warning",
                        "type": "missing_scientific_name",
                        "message": f"提到了{name}但未提及学名「{info['学名']}」",
                        "suggestion": f"建议添加学名信息：{info['学名']}"
                    })

        if not species_found:
            issues.append({
                "severity": "info",
                "type": "no_species",
                "message": "未识别到已知物种名称",
                "suggestion": "如果内容涉及特定物种，请确保名称正确"
            })

        return CheckResult(
            check_type="species_names",
            passed=len([i for i in issues if i["severity"] == "error"]) == 0,
            issues=issues,
            summary=f"检查了{len(species_found)}个物种" if species_found else "未识别到已知物种"
        )

    def check_data_accuracy(self) -> CheckResult:
        """检查数据准确性"""
        issues = []

        # 检查体型数据
        size_patterns = [
            (r'(\d+)\s*~?\s*(\d+)\s*厘米', '体型厘米'),
            (r'(\d+)\s*公斤', '体重公斤'),
            (r'(\d+)\s*年', '寿命年')
        ]

        for pattern, data_type in size_patterns:
            matches = re.findall(pattern, self.content)
            for match in matches:
                if data_type == '体型厘米':
                    size = int(match[0]) if len(match) == 1 else (int(match[0]) + int(match[1])) // 2
                    if size > 100:
                        issues.append({
                            "severity": "warning",
                            "type": "unusual_data",
                            "message": f"体型数据{size}厘米似乎过大，请核实",
                            "location": "数据引用"
                        })

        # 检查温度数据
        temp_matches = re.findall(r'(\d+)\s*°?C', self.content)
        for temp in temp_matches:
            temp_val = int(temp)
            if temp_val < 10 or temp_val > 40:
                issues.append({
                    "severity": "warning",
                    "type": "unusual_data",
                    "message": f"温度数据{temp_val}°C似乎异常，请核实",
                    "location": "水温设置"
                })

        # 计算体型数据匹配数
        size_pattern = r'(\d+)\s*~?\s*(\d+)\s*厘米'
        size_count = len(re.findall(size_pattern, self.content))

        return CheckResult(
            check_type="data_accuracy",
            passed=len([i for i in issues if i["severity"] == "error"]) == 0,
            issues=issues,
            summary=f"检查了{len(temp_matches)}处温度数据和{size_count}处体型数据"
        )

    def check_safety_warnings(self) -> CheckResult:
        """检查安全提示"""
        issues = []

        # 如果内容涉及鳄龟，检查是否有安全提示
        if "鳄龟" in self.content or "大鳄龟" in self.content or "小鳄龟" in self.content:
            has_safety_warning = any(kw in self.content for kw in SAFETY_KEYWORDS)

            if not has_safety_warning:
                issues.append({
                    "severity": "error",
                    "type": "missing_safety_warning",
                    "message": "涉及鳄龟内容但缺少安全操作提示",
                    "suggestion": "必须添加：不要徒手抓取、移动时使用长柄钳子、咬伤风险等安全提示"
                })

        # 检查是否有咬伤相关警告
        if "咬" in self.content and "警告" not in self.content and "注意" not in self.content:
            issues.append({
                "severity": "warning",
                "type": "weak_warning",
                "message": "提到了咬相关内容但警告力度不足",
                "suggestion": "建议加强安全警告措辞"
            })

        return CheckResult(
            check_type="safety_warnings",
            passed=len([i for i in issues if i["severity"] == "error"]) == 0,
            issues=issues,
            summary="安全提示检查通过" if issues and issues[0]["severity"] != "error" or not issues else issues[0]["message"] if issues else "安全提示完整"
        )

    def check_legal_information(self) -> CheckResult:
        """检查法规信息"""
        issues = []

        # 如果提到鳄龟，必须检查是否有放生相关的法规提示
        if "鳄龟" in self.content:
            has_legal_info = any(kw in self.content for kw in LEGAL_KEYWORDS)

            if not has_legal_info:
                issues.append({
                    "severity": "error",
                    "type": "missing_legal_warning",
                    "message": "涉及鳄龟但缺少入侵物种相关法规提示",
                    "suggestion": "必须添加：鳄龟是外来入侵物种，放生野外违法，会对生态造成破坏"
                })

        # 检查法规信息的一致性
        if "放生" in self.content and "违法" not in self.content:
            issues.append({
                "severity": "error",
                "type": "incomplete_legal_info",
                "message": "提到了放生但未说明这是违法行为",
                "suggestion": "必须明确说明：放生鳄龟是违法行为"
            })

        return CheckResult(
            check_type="legal_information",
            passed=len([i for i in issues if i["severity"] == "error"]) == 0,
            issues=issues,
            summary="法规信息检查通过" if not issues else issues[0]["message"]
        )

    def check_completeness(self) -> CheckResult:
        """检查内容完整性"""
        issues = []

        # 检查标题
        has_title = self.lines and (self.lines[0].startswith("# ") or len(self.lines[0]) > 10)
        if not has_title:
            issues.append({
                "severity": "warning",
                "type": "missing_title",
                "message": "未找到明确的标题",
                "suggestion": "确保文件开头有清晰的标题"
            })

        # 检查是否有三连引导
        if "三连" not in self.content and "点赞" not in self.content:
            issues.append({
                "severity": "info",
                "type": "no_cta",
                "message": "缺少互动引导（三连、点赞等）",
                "suggestion": "建议添加互动引导语句"
            })

        # 检查结尾完整性
        has_ending = len(self.content) > 500 and any(kw in self.content[-500:] for kw in ["下期", "再见", "好了", "结束"])
        if not has_ending:
            issues.append({
                "severity": "info",
                "type": "weak_ending",
                "message": "结尾可能不够完整",
                "suggestion": "建议添加下期预告和告别语"
            })

        return CheckResult(
            check_type="completeness",
            passed=True,  # 完整性不是阻塞性问题
            issues=issues,
            summary=f"发现{len(issues)}处可优化项"
        )

    def check_facts_ai(self, api_key: str = "", group_id: str = "") -> Optional[CheckResult]:
        """
        使用AI检查事实准确性（需要MiniMax API）

        Args:
            api_key: MiniMax API Key
            group_id: MiniMax Group ID

        Returns:
            AI检查结果，如果API不可用则返回None
        """
        if not api_key or not group_id:
            return None

        try:
            import requests

            prompt = f"""你是一个爬宠知识专家。请审查以下视频脚本，检查其中可能存在的知识性错误。

审查要点：
1. 物种信息是否准确（学名、体型、习性等）
2. 饲养方法是否正确（水温、食物、环境等）
3. 是否有科学依据
4. 安全提示是否充分

视频脚本：
{self.content[:3000]}  # 限制长度

请指出任何可能存在的问题，用JSON格式返回：
{{
  "has_issues": true/false,
  "issues": [
    {{"severity": "high/medium/low", "topic": "主题", "description": "问题描述", "suggestion": "建议"}}
  ]
}}
"""

            # MiniMax Coding Plan 使用国内版 API
            url = f"https://api.minimaxi.com/v1/text/chatcompletion_pro?GroupId={group_id}"
            headers = {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {api_key}"
            }
            payload = {
                "model": "abab6.5s-chat",
                "tokens_to_generate": 1024,
                "temperature": 0.3,
                "messages": [{
                    "sender_type": "USER",
                    "sender_name": "审核员",
                    "text": prompt
                }]
            }

            response = requests.post(url, headers=headers, json=payload, timeout=60)
            result = response.json()

            # 解析AI返回
            if "choices" in result and result["choices"]:
                import json
                try:
                    ai_result = json.loads(result["choices"][0]["text"])
                    return CheckResult(
                        check_type="ai_fact_check",
                        passed=not ai_result.get("has_issues", False),
                        issues=ai_result.get("issues", []),
                        summary=f"AI发现了{len(ai_result.get('issues', []))}处潜在问题" if ai_result.get("has_issues") else "AI检查通过"
                    )
                except json.JSONDecodeError:
                    return None

        except Exception as e:
            print(f"AI检查失败: {e}")

        return None

    def run_all_checks(self, use_ai: bool = False, api_key: str = "", group_id: str = "") -> Dict[str, CheckResult]:
        """运行所有检查"""
        results = {}

        print("正在执行知识准确性检查...")
        results["species_names"] = self.check_species_names()

        print("正在执行数据准确性检查...")
        results["data_accuracy"] = self.check_data_accuracy()

        print("正在执行安全提示检查...")
        results["safety_warnings"] = self.check_safety_warnings()

        print("正在执行法规信息检查...")
        results["legal_information"] = self.check_legal_information()

        print("正在执行完整性检查...")
        results["completeness"] = self.check_completeness()

        if use_ai and api_key and group_id:
            print("正在执行AI事实检查...")
            ai_result = self.check_facts_ai(api_key, group_id)
            if ai_result:
                results["ai_fact_check"] = ai_result

        return results


def format_issue(issue: Dict) -> str:
    """格式化问题显示"""
    severity_colors = {
        "error": "\033[91m",  # 红色
        "warning": "\033[93m",  # 黄色
        "info": "\033[94m",  # 蓝色
        "high": "\033[91m",
        "medium": "\033[93m",
        "low": "\033[94m"
    }
    color = severity_colors.get(issue.get("severity", "info"), "\033[0m")
    end = "\033[0m"

    lines = [
        f"  {color}⚠ {issue['message']}{end}",
        f"    建议: {issue.get('suggestion', 'N/A')}"
    ]
    if issue.get("location"):
        lines.insert(1, f"    位置: {issue['location']}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="内容审核检查工具")
    parser.add_argument("file", nargs="?", help="要检查的文件路径")
    parser.add_argument("--all", action="store_true", help="检查所有待审核文件")
    parser.add_argument("--use-ai", action="store_true", help="使用AI进行深度检查")
    parser.add_argument("--api-key", default=os.environ.get("MINIMAX_API_KEY", ""), help="MiniMax API Key")
    parser.add_argument("--group-id", default=os.environ.get("MINIMAX_GROUP_ID", ""), help="MiniMax Group ID")
    parser.add_argument("--output", "-o", help="输出JSON结果到文件")

    args = parser.parse_args()

    # 检查API配置
    use_ai = args.use_ai and args.api_key and args.group_id
    if args.use_ai and not (args.api_key and args.group_id):
        print("\033[93m警告: 未提供API密钥，AI检查将被跳过\033[0m")
        print("请设置环境变量 MINIMAX_API_KEY 和 MINIMAX_GROUP_ID")
        print("")

    if args.all:
        # 检查所有Markdown文件
        script_dir = Path(__file__).parent.parent / "docs" / "video-scripts"
        files = list(script_dir.glob("**/*.md"))
        files = [f for f in files if "B站发布内容" not in f.name and "_小红书" not in f.name]
    elif args.file:
        files = [Path(args.file)]
    else:
        print("\033[91m错误: 请提供文件路径或使用 --all 检查所有文件\033[0m")
        parser.print_help()
        return

    all_results = {}

    for file_path in files:
        print(f"\n{'='*60}")
        print(f"检查文件: {file_path.name}")
        print('='*60)

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            checker = ContentChecker(content, str(file_path))
            results = checker.run_all_checks(use_ai, args.api_key, args.group_id)

            all_results[str(file_path)] = {k: v.to_dict() for k, v in results.items()}

            # 显示结果
            has_errors = False
            for check_name, result in results.items():
                check_title = {
                    "species_names": "📚 物种名称",
                    "data_accuracy": "📊 数据准确性",
                    "safety_warnings": "⚠️ 安全提示",
                    "legal_information": "⚖️ 法规信息",
                    "completeness": "📋 完整性",
                    "ai_fact_check": "🤖 AI事实检查"
                }.get(check_name, check_name)

                status = "\033[92m✓ 通过\033[0m" if result.passed else "\033[91m✗ 未通过\033[0m"
                print(f"\n{check_title}: {status}")
                print(f"  {result.summary}")

                if result.issues:
                    for issue in result.issues:
                        print(format_issue(issue))
                        if issue.get("severity") in ["error", "high"]:
                            has_errors = True

            if not any(r.passed == False for r in results.values()):
                print("\n\033[92m✅ 所有检查通过！\033[0m")
            elif has_errors:
                print("\n\033[91m❌ 存在阻塞性问题，请修复后再提交审核\033[0m")
            else:
                print("\n\033[93m⚠️ 存在警告，建议优化但不阻塞审核\033[0m")

        except FileNotFoundError:
            print(f"\033[91m错误: 文件不存在 {file_path}\033[0m")
        except Exception as e:
            print(f"\033[91m错误: {e}\033[0m")
            import traceback
            traceback.print_exc()

    # 保存结果
    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(all_results, f, ensure_ascii=False, indent=2)
        print(f"\n结果已保存到: {output_path}")


if __name__ == "__main__":
    main()
