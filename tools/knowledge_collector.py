#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
知识库内容采集工具
从网页获取爬宠相关信息并保存到知识库
"""

import json
import os
import sys
import re
import time
from datetime import datetime

# 尝试导入所需库
try:
    import requests
    from bs4 import BeautifulSoup
except ImportError:
    print("请安装依赖: pip3 install requests beautifulsoup4")
    sys.exit(1)

# 知识库数据文件路径
KNOWLEDGE_FILE = "knowledge_base_v2.json"

class KnowledgeCollector:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        self.knowledge_data = self.load_knowledge()

    def load_knowledge(self):
        """加载现有知识库"""
        if os.path.exists(KNOWLEDGE_FILE):
            with open(KNOWLEDGE_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {
            "version": "1.0",
            "lastUpdated": datetime.now().strftime("%Y-%m-%d"),
            "categories": [],
            "species": [],
            "articles": [],
            "tips": [],
            "faqs": []
        }

    def save_knowledge(self):
        """保存知识库"""
        self.knowledge_data["lastUpdated"] = datetime.now().strftime("%Y-%m-%d")
        with open(KNOWLEDGE_FILE, 'w', encoding='utf-8') as f:
            json.dump(self.knowledge_data, f, ensure_ascii=False, indent=2)
        print(f"知识库已保存到: {KNOWLEDGE_FILE}")

    def search_web(self, keyword, max_results=5):
        """搜索网页内容"""
        print(f"\n正在搜索: {keyword}")
        print("=" * 50)

        # 使用百度搜索（简单实现）
        search_urls = [
            f"https://www.baidu.com/s?wd={keyword}%20饲养&rn={max_results * 20}",
            f"https://www.baidu.com/s?wd={keyword}%20习性&rn={max_results * 20}",
        ]

        results = []
        for url in search_urls:
            try:
                response = self.session.get(url, timeout=10)
                soup = BeautifulSoup(response.text, 'html.parser')

                # 提取搜索结果
                for item in soup.select('.result')[:max_results]:
                    title_elem = item.select_one('.t')
                    title = title_elem.get_text(strip=True) if title_elem else ""

                    url_elem = item.select_one('a')
                    link = url_elem.get('href') if url_elem else ""

                    abstract_elem = item.select_one('.c-abstract')
                    abstract = abstract_elem.get_text(strip=True) if abstract_elem else ""

                    if title and link:
                        results.append({
                            "title": title,
                            "url": link,
                            "abstract": abstract
                        })

                time.sleep(1)  # 避免请求过快

            except Exception as e:
                print(f"搜索出错: {e}")
                continue

        return results

    def fetch_page_content(self, url):
        """获取页面详细内容"""
        try:
            response = self.session.get(url, timeout=15)
            response.encoding = 'utf-8'
            soup = BeautifulSoup(response.text, 'html.parser')

            # 移除脚本和样式
            for script in soup(["script", "style"]):
                script.decompose()

            # 获取标题
            title = soup.title.string if soup.title else ""

            # 获取主要内容（简化处理）
            content = soup.get_text(separator='\n', strip=True)

            return {
                "title": title,
                "content": content[:5000]  # 限制内容长度
            }
        except Exception as e:
            print(f"获取页面失败: {e}")
            return None

    def parse_species_info(self, content, species_name):
        """从内容中解析物种信息"""
        info = {
            "nameChinese": species_name,
            "description": "",
            "difficulty": 1,
            "lifespan": "",
            "size": "",
            "distribution": "",
            "habitat": "",
            "diet": "",
            "temperature": "",
            "humidity": "",
            "tags": []
        }

        keywords = {
            "饲养难度": ["难度", "容易", "困难"],
            "寿命": ["寿命", "年"],
            "体型": ["体型", "大小", "cm"],
            "分布": ["分布", "产地", "原产"],
            "栖息地": ["栖息", "环境", "生活"],
            "食性": ["食性", "吃", "食物"],
            "温度": ["温度", "°C", "度"],
            "湿度": ["湿度", "%"]
        }

        # 简单的关键词匹配
        for key, patterns in keywords.items():
            for pattern in patterns:
                if pattern in content:
                    # 尝试提取相关信息
                    idx = content.find(pattern)
                    snippet = content[max(0, idx-20):idx+100]
                    if key == "description":
                        info["description"] = snippet[:200]
                    elif key == "difficulty":
                        info["difficulty"] = 2  # 默认中等难度
                    # ... 可以添加更多解析逻辑

        return info

    def add_species(self, species_name, category="turtle"):
        """添加物种到知识库"""
        # 搜索相关信息
        results = self.search_web(species_name)

        if not results:
            print("未找到相关信息")
            return False

        # 获取第一个结果的详细内容
        print(f"\n获取详情: {results[0]['title']}")
        detail = self.fetch_page_content(results[0]['url'])

        if detail:
            # 解析物种信息
            species_info = self.parse_species_info(detail['content'], species_name)
            species_info["id"] = f"species_{len(self.knowledge_data['species']) + 1:03d}"
            species_info["category"] = category

            # 保存到知识库
            self.knowledge_data['species'].append(species_info)
            self.save_knowledge()

            print(f"\n✓ 已添加物种: {species_name}")
            print(f"  分类: {category}")
            print(f"  描述: {species_info['description'][:100]}...")
            return True

        return False

    def search_and_import(self, keyword, category="turtle"):
        """搜索并导入物种"""
        # 检查是否已存在
        for species in self.knowledge_data['species']:
            if keyword in species.get('nameChinese', '') or keyword in species.get('nameEnglish', ''):
                print(f"物种已存在: {species['nameChinese']}")
                return species

        # 添加新物种
        return self.add_species(keyword, category)

    def list_species(self):
        """列出所有物种"""
        print("\n知识库中的物种:")
        print("=" * 50)
        for s in self.knowledge_data['species']:
            print(f"  {s.get('id')}: {s.get('nameChinese')} ({s.get('nameEnglish', '')})")

def main():
    collector = KnowledgeCollector()

    if len(sys.argv) < 2:
        # 交互模式
        print("\n=== 知识库内容采集工具 ===")
        print("1. 添加物种")
        print("2. 查看物种列表")
        print("3. 保存并退出")

        while True:
            choice = input("\n请选择 (1/2/3): ").strip()

            if choice == "1":
                name = input("请输入物种名称: ").strip()
                if name:
                    category = input("请输入分类 (turtle/lizard/gecko/snake/amphibian): ").strip() or "turtle"
                    collector.search_and_import(name, category)

            elif choice == "2":
                collector.list_species()

            elif choice == "3":
                print("退出")
                break

    else:
        # 命令行模式
        command = sys.argv[1]
        if command == "add":
            name = sys.argv[2] if len(sys.argv) > 2 else input("物种名称: ")
            category = sys.argv[3] if len(sys.argv) > 3 else "turtle"
            collector.search_and_import(name, category)
        elif command == "list":
            collector.list_species()

if __name__ == "__main__":
    main()
