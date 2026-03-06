#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
知识库采集工具 V2.0
支持多数据源：百度百科、爬宠网站、维基百科等
"""

import json
import os
import sys
import re
import time
import hashlib
from datetime import datetime
from urllib.parse import quote, urljoin

try:
    import requests
    from bs4 import BeautifulSoup
except ImportError:
    print("请安装依赖: pip3 install requests beautifulsoup4")
    sys.exit(1)

# 配置
import os
# 使用相对于当前工作目录的路径
KNOWLEDGE_FILE = "assets/data/knowledge_base_v2.json"
# 如果文件不存在，尝试使用绝对路径
if not os.path.exists(KNOWLEDGE_FILE):
    KNOWLEDGE_FILE = "/home/bigrice/workspace/github/private/wildherd/assets/data/knowledge_base_v2.json"
API_DELAY = 1.5  # 请求间隔(秒)

class KnowledgeCollector:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        })
        self.knowledge_data = self._load_knowledge()

    def _load_knowledge(self):
        """加载知识库"""
        if os.path.exists(KNOWLEDGE_FILE):
            try:
                with open(KNOWLEDGE_FILE, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                pass
        return self._default_data()

    def _default_data(self):
        return {
            "version": "2.0",
            "lastUpdated": datetime.now().strftime("%Y-%m-%d"),
            "config": {"enableCloudSync": False, "cacheEnabled": True, "autoUpdate": False},
            "categories": [
                {"id": "turtle", "name": "龟类", "icon": "turtle", "description": "各类宠物龟", "count": 0},
                {"id": "lizard", "name": "蜥蜴", "icon": "lizard", "description": "蜥蜴类宠物", "count": 0},
                {"id": "gecko", "name": "守宫", "icon": "gecko", "description": "守宫类爬宠", "count": 0},
                {"id": "snake", "name": "蛇类", "icon": "snake", "description": "宠物蛇", "count": 0},
                {"id": "amphibian", "name": "两栖类", "icon": "amphibian", "description": "两栖宠物", "count": 0}
            ],
            "species": [],
            "articles": [],
            "tips": [],
            "faqs": [],
            "sources": []
        }

    def _save_knowledge(self):
        """保存知识库"""
        self.knowledge_data["lastUpdated"] = datetime.now().strftime("%Y-%m-%d")

        # 更新分类计数
        for cat in self.knowledge_data["categories"]:
            cat["count"] = len([s for s in self.knowledge_data["species"] if s.get("category") == cat["id"]])

        with open(KNOWLEDGE_FILE, 'w', encoding='utf-8') as f:
            json.dump(self.knowledge_data, f, ensure_ascii=False, indent=2)
        print(f"✓ 已保存到: {KNOWLEDGE_FILE}")

    def _generate_id(self, text):
        """生成唯一ID"""
        return hashlib.md5(text.encode()).hexdigest()[:8]

    def _clean_text(self, text):
        """清理文本"""
        if not text:
            return ""
        # 移除多余空白
        text = re.sub(r'\s+', ' ', text)
        # 移除特殊字符
        text = re.sub(r'[\x00-\x08\x0b-\x0c\x0e-\x1f\x7f-\x9f]', '', text)
        return text.strip()

    # ========== 数据源 ==========

    def search_baidu(self, keyword, max_results=5):
        """百度搜索"""
        print(f"🔍 百度搜索: {keyword}")
        url = f"https://www.baidu.com/s?wd={quote(keyword)}&rn={max_results * 10}"

        try:
            resp = self.session.get(url, timeout=10)
            resp.encoding = 'utf-8'
            soup = BeautifulSoup(resp.text, 'html.parser')

            results = []
            for item in soup.select('.result')[:max_results]:
                title_elem = item.select_one('.t')
                if not title_elem:
                    continue

                link = item.select_one('a')
                if not link:
                    continue

                abstract = item.select_one('.c-abstract')
                result = {
                    "title": self._clean_text(title_elem.get_text()),
                    "url": link.get('href', ''),
                    "abstract": self._clean_text(abstract.get_text()) if abstract else ""
                }
                if result["title"] and result["url"]:
                    results.append(result)

            time.sleep(API_DELAY)
            return results
        except Exception as e:
            print(f"  ❌ 搜索失败: {e}")
            return []

    def fetch_baike(self, keyword):
        """获取百度百科内容"""
        print(f"📖 获取百度百科: {keyword}")

        # 尝试直接访问百科页面
        url = f"https://baike.baidu.com/item/{quote(keyword)}"

        try:
            resp = self.session.get(url, timeout=10)
            resp.encoding = 'utf-8'

            if resp.status_code != 200:
                # 尝试搜索
                search_results = self.search_baidu(f"{keyword} 百度百科", 3)
                if search_results:
                    for r in search_results:
                        if 'baike.baidu.com' in r.get('url', ''):
                            resp = self.session.get(r['url'], timeout=10)
                            break

            soup = BeautifulSoup(resp.text, 'html.parser')

            # 提取标题
            title = soup.title.string if soup.title else keyword
            title = self._clean_text(title.replace('_百度百科', ''))

            # 提取主要描述
            desc_elem = soup.select_one('.lemma-summary')
            description = self._clean_text(desc_elem.get_text()) if desc_elem else ""

            # 提取属性信息
            properties = {}
            for prop in soup.select('.property'):
                key = self._clean_text(prop.select_one('.prop-title').get_text())
                value = self._clean_text(prop.select_one('.prop-content').get_text())
                if key and value:
                    properties[key] = value

            # 提取图片
            image = ""
            img_elem = soup.select_one('.lemma-picture')
            if img_elem:
                image = img_elem.get('src', '')

            time.sleep(API_DELAY)

            return {
                "title": title,
                "description": description,
                "properties": properties,
                "image": image,
                "source": "百度百科",
                "url": resp.url
            }

        except Exception as e:
            print(f"  ❌ 获取失败: {e}")
            return None

    def fetch_wiki(self, keyword):
        """获取维基百科内容"""
        print(f"📖 获取维基百科: {keyword}")

        url = f"https://zh.wikipedia.org/wiki/{quote(keyword)}"

        try:
            resp = self.session.get(url, timeout=10)
            if resp.status_code != 200:
                return None

            soup = BeautifulSoup(resp.text, 'html.parser')

            # 标题
            title = soup.select_one('#firstHeading')
            title = self._clean_text(title.get_text()) if title else keyword

            # 描述
            desc = soup.select_one('.mw-parser-output > p')
            description = self._clean_text(desc.get_text()) if desc else ""

            # 信息框
            infobox = {}
            info_table = soup.select_one('.infobox')
            if info_table:
                for row in info_table.select('tr'):
                    header = row.select_one('th')
                    data = row.select_one('td')
                    if header and data:
                        key = self._clean_text(header.get_text())
                        value = self._clean_text(data.get_text())
                        infobox[key] = value

            time.sleep(API_DELAY)

            return {
                "title": title,
                "description": description,
                "infobox": infobox,
                "source": "维基百科",
                "url": resp.url
            }

        except Exception as e:
            print(f"  ❌ 获取失败: {e}")
            return None

    # ========== 数据解析 ==========

    def parse_species_info(self, name, category="turtle"):
        """解析物种信息"""
        species = {
            "id": f"species_{self._generate_id(name)}",
            "nameChinese": name,
            "nameEnglish": "",
            "scientificName": "",
            "category": category,
            "description": "",
            "difficulty": 2,
            "lifespan": "",
            "size": "",
            "distribution": "",
            "habitat": "",
            "diet": "",
            "temperature": "25-30°C",
            "humidity": "50-70%",
            "feeding": "",
            "housing": "",
            "care": "",
            "tags": [category],
            "imageUrl": "",
            "sources": []
        }

        # 获取百度百科
        baike = self.fetch_baike(name)
        if baike:
            species["description"] = baike.get("description", "")[:500]
            species["imageUrl"] = baike.get("image", "")
            species["sources"].append(baike.get("source", ""))

            props = baike.get("properties", {})
            if "别称" in props: species["tags"].append(props["别称"])
            if "分布区域" in props: species["distribution"] = props["分布区域"]
            if "原产地" in props: species["distribution"] = props["原产地"]
            if "食性" in props: species["diet"] = props["食性"]
            if "寿命" in props: species["lifespan"] = props["寿命"]
            if "体型" in props: species["size"] = props["体型"]

        # 获取维基百科
        wiki = self.fetch_wiki(name)
        if wiki:
            if not species["description"]:
                species["description"] = wiki.get("description", "")[:500]
            species["sources"].append(wiki.get("source", ""))

            infobox = wiki.get("infobox", {})
            if "学名" in infobox:
                species["scientificName"] = infobox["学名"]
            if "亚科" in infobox and not species["scientificName"]:
                species["scientificName"] = infobox["亚科"]

        # 智能判断难度
        if "龟" in name or "守宫" in name:
            species["difficulty"] = 1  # 入门级

        return species

    def add_species(self, name, category="turtle"):
        """添加物种"""
        # 检查是否已存在
        for s in self.knowledge_data["species"]:
            if name in s.get("nameChinese", "") or name in s.get("nameEnglish", ""):
                print(f"  ⚠️ 物种已存在: {s['nameChinese']}")
                return s

        print(f"\n{'='*50}")
        print(f"正在添加物种: {name}")
        print(f"{'='*50}")

        species = self.parse_species_info(name, category)

        self.knowledge_data["species"].append(species)
        self._save_knowledge()

        print(f"\n✓ 成功添加: {species['nameChinese']}")
        print(f"  英文名: {species['nameEnglish']}")
        print(f"  学名: {species['scientificName']}")
        print(f"  分类: {species['category']}")
        print(f"  描述: {species['description'][:100]}...")

        return species

    def add_batch(self, species_list, category="turtle"):
        """批量添加物种"""
        print(f"\n开始批量添加 {len(species_list)} 个物种...")
        for i, name in enumerate(species_list, 1):
            print(f"\n[{i}/{len(species_list)}] {name}")
            self.add_species(name, category)

    def list_species(self):
        """列出所有物种"""
        species = self.knowledge_data.get("species", [])
        if not species:
            print("知识库为空")
            return

        print(f"\n{'='*60}")
        print(f"知识库共有 {len(species)} 个物种")
        print(f"{'='*60}")

        # 按分类显示
        categories = {}
        for s in species:
            cat = s.get("category", "other")
            if cat not in categories:
                categories[cat] = []
            categories[cat].append(s)

        for cat, items in categories.items():
            cat_name = next((c["name"] for c in self.knowledge_data["categories"] if c["id"] == cat), cat)
            print(f"\n📁 {cat_name} ({len(items)}个)")
            print("-" * 40)
            for s in items:
                print(f"  • {s.get('nameChinese', '')} - {s.get('nameEnglish', '')}")
                if s.get("description"):
                    print(f"    {s['description'][:50]}...")

    def search_local(self, keyword):
        """本地搜索"""
        keyword = keyword.lower()
        results = []

        for s in self.knowledge_data.get("species", []):
            if (keyword in s.get("nameChinese", "").lower() or
                keyword in s.get("nameEnglish", "").lower() or
                keyword in s.get("scientificName", "").lower() or
                keyword in s.get("description", "").lower()):
                results.append(s)

        return results

    def export_json(self, filepath):
        """导出JSON"""
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(self.knowledge_data, f, ensure_ascii=False, indent=2)
        print(f"✓ 已导出到: {filepath}")


def main():
    collector = KnowledgeCollector()

    if len(sys.argv) < 2:
        print("""
╔══════════════════════════════════════════════════════╗
║         知识库采集工具 V2.0                          ║
╠══════════════════════════════════════════════════════╣
║  用法:                                               ║
║    python3 collector.py add <物种名> [分类]          ║
║    python3 collector.py batch <文件>                 ║
║    python3 collector.py list                        ║
║    python3 collector.py search <关键词>              ║
║    python3 collector.py export <文件>                ║
╠══════════════════════════════════════════════════════╣
║  分类: turtle, lizard, gecko, snake, amphibian      ║
╚══════════════════════════════════════════════════════╝
""")
        # 交互模式
        while True:
            print("\n请选择操作:")
            print("1. 添加物种")
            print("2. 批量添加")
            print("3. 查看列表")
            print("4. 搜索")
            print("5. 导出")
            print("0. 退出")

            choice = input("\n> ").strip()

            if choice == "1":
                name = input("物种名称: ").strip()
                if name:
                    cat = input("分类 (turtle/lizard/gecko/snake/amphibian): ").strip() or "turtle"
                    collector.add_species(name, cat)

            elif choice == "2":
                print("请输入物种列表(逗号分隔):")
                names = input("> ").strip()
                if names:
                    cat = input("分类: ").strip() or "turtle"
                    species_list = [n.strip() for n in names.split(",")]
                    collector.add_batch(species_list, cat)

            elif choice == "3":
                collector.list_species()

            elif choice == "4":
                keyword = input("搜索关键词: ").strip()
                if keyword:
                    results = collector.search_local(keyword)
                    print(f"\n找到 {len(results)} 个结果:")
                    for s in results:
                        print(f"  • {s['nameChinese']} ({s.get('nameEnglish', '')})")

            elif choice == "5":
                path = input("导出路径: ").strip()
                if path:
                    collector.export_json(path)

            elif choice == "0":
                break

    else:
        # 命令行模式
        cmd = sys.argv[1]

        if cmd == "add" and len(sys.argv) >= 3:
            name = sys.argv[2]
            category = sys.argv[3] if len(sys.argv) > 3 else "turtle"
            collector.add_species(name, category)

        elif cmd == "batch" and len(sys.argv) >= 3:
            path = sys.argv[2]
            category = sys.argv[3] if len(sys.argv) > 3 else "turtle"
            if os.path.exists(path):
                with open(path, 'r', encoding='utf-8') as f:
                    names = [line.strip() for line in f if line.strip()]
                collector.add_batch(names, category)
            else:
                print(f"文件不存在: {path}")

        elif cmd == "list":
            collector.list_species()

        elif cmd == "search" and len(sys.argv) >= 3:
            keyword = sys.argv[2]
            results = collector.search_local(keyword)
            print(f"\n找到 {len(results)} 个结果:")
            for s in results:
                print(f"  • {s['nameChinese']} - {s.get('nameEnglish', '')}")

        elif cmd == "export" and len(sys.argv) >= 3:
            collector.export_json(sys.argv[2])

        else:
            print("未知命令")


if __name__ == "__main__":
    main()
