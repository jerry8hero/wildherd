#!/usr/bin/env python3
"""
发布记录自动更新脚本
- 读取 发布记录.yml
- 生成 data.js（供 HTML 页面使用）
- 生成 index.html（展示页面）
"""

import yaml
import json
from datetime import datetime

def load_yaml_data():
    with open('发布记录.yml', 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)

def calculate_status(item):
    """根据链接和日期自动计算状态"""
    link = item.get('链接', '').strip()
    date = item.get('发布日期', '').strip()
    views = item.get('播放量', '').strip()

    if link:
        if views:
            return "已复盘"
        elif date:
            return "已发布"
        else:
            return "已发布"
    else:
        return "待发布"

def transform_data(data):
    """转换数据，添加自动计算的状态"""
    result = {}
    for category, items in data.items():
        if isinstance(items, list):
            result[category] = []
            for item in items:
                new_item = dict(item)
                new_item['状态'] = calculate_status(item)
                result[category].append(new_item)
        elif category == '统计':
            result[category] = data[category]
    return result

def generate_data_js(data):
    """生成 data.js 文件"""
    js_content = f"// 自动生成于 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
    js_content += "const videoData = " + json.dumps(data, ensure_ascii=False, indent=2) + ";"
    with open('data.js', 'w', encoding='utf-8') as f:
        f.write(js_content)
    print("已生成 data.js")

def generate_html():
    """生成 index.html"""
    html = '''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>视频发布记录 - 自动状态版</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #f5f5f5; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { text-align: center; color: #333; margin-bottom: 10px; }
        .stats { display: flex; justify-content: center; gap: 30px; margin-bottom: 20px; }
        .stat-item { background: white; padding: 15px 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; }
        .stat-value { font-size: 2em; font-weight: bold; color: #333; }
        .stat-label { color: #666; font-size: 0.9em; }
        .stat-published .stat-value { color: #52c41a; }
        .stat-pending .stat-value { color: #faad14; }
        .filters { background: white; padding: 15px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .filter-row { display: flex; gap: 15px; flex-wrap: wrap; align-items: center; }
        select, input { padding: 8px 12px; border: 1px solid #d9d9d9; border-radius: 4px; font-size: 14px; }
        input[type="text"] { width: 200px; }
        .series-list { display: flex; gap: 10px; flex-wrap: wrap; }
        .series-tag { padding: 6px 16px; border: 1px solid #d9d9d9; border-radius: 20px; cursor: pointer; transition: all 0.2s; }
        .series-tag:hover { border-color: #1890ff; color: #1890ff; }
        .series-tag.active { background: #1890ff; color: white; border-color: #1890ff; }
        .series-tag .count { background: rgba(0,0,0,0.1); padding: 2px 6px; border-radius: 10px; font-size: 0.8em; margin-left: 5px; }
        .series-tag.active .count { background: rgba(255,255,255,0.3); }
        table { width: 100%; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #f0f0f0; }
        th { background: #fafafa; font-weight: 600; color: #333; }
        tr:hover { background: #fafafa; }
        .status { padding: 4px 12px; border-radius: 12px; font-size: 12px; display: inline-block; }
        .status-published { background: #d4edda; color: #155724; }
        .status-reviewed { background: #cce5ff; color: #004085; }
        .status-pending { background: #fff3cd; color: #856404; }
        .link { color: #1890ff; text-decoration: none; }
        .link:hover { text-decoration: underline; }
        .empty { text-align: center; padding: 40px; color: #999; }
        .update-time { text-align: center; color: #999; font-size: 0.85em; margin-top: 20px; }
        @media (max-width: 768px) {
            table { font-size: 14px; }
            th, td { padding: 8px 10px; }
            .stats { flex-wrap: wrap; }
            .filter-row { flex-direction: column; align-items: stretch; }
            input[type="text"] { width: 100%; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>视频发布记录</h1>

        <div class="stats">
            <div class="stat-item stat-published">
                <div class="stat-value" id="stat-published">0</div>
                <div class="stat-label">已发布</div>
            </div>
            <div class="stat-item stat-reviewed">
                <div class="stat-value" id="stat-reviewed">0</div>
                <div class="stat-label">已复盘</div>
            </div>
            <div class="stat-item stat-pending">
                <div class="stat-value" id="stat-pending">0</div>
                <div class="stat-label">待发布</div>
            </div>
        </div>

        <div class="filters">
            <div class="filter-row">
                <input type="text" id="search" placeholder="搜索标题...">
                <select id="status-filter">
                    <option value="">全部状态</option>
                    <option value="已发布">已发布</option>
                    <option value="已复盘">已复盘</option>
                    <option value="待发布">待发布</option>
                </select>
                <div class="series-list" id="series-filters"></div>
            </div>
        </div>

        <div id="content"></div>

        <div class="update-time" id="update-time"></div>
    </div>

    <script src="data.js"></script>
    <script>
        const categories = Object.keys(videoData).filter(k => k !== '统计');
        let currentSeries = '';
        let currentStatus = '';
        let searchText = '';

        function getStatusClass(status) {
            if (status === '已发布') return 'status-published';
            if (status === '已复盘') return 'status-reviewed';
            return 'status-pending';
        }

        function renderStats() {
            let published = 0, reviewed = 0, pending = 0;
            categories.forEach(cat => {
                videoData[cat].forEach(item => {
                    if (item['状态'] === '已发布') published++;
                    else if (item['状态'] === '已复盘') reviewed++;
                    else pending++;
                });
            });
            document.getElementById('stat-published').textContent = published;
            document.getElementById('stat-reviewed').textContent = reviewed;
            document.getElementById('stat-pending').textContent = pending;
        }

        function renderSeriesFilters() {
            const container = document.getElementById('series-filters');
            let html = '<div class="series-tag active" data-series="">全部<span class="count">' + categories.length + '</span></div>';
            categories.forEach(cat => {
                const count = videoData[cat].length;
                html += '<div class="series-tag" data-series="' + cat + '">' + cat + '<span class="count">' + count + '</span></div>';
            });
            container.innerHTML = html;

            container.querySelectorAll('.series-tag').forEach(tag => {
                tag.addEventListener('click', () => {
                    container.querySelectorAll('.series-tag').forEach(t => t.classList.remove('active'));
                    tag.classList.add('active');
                    currentSeries = tag.dataset.series;
                    renderTable();
                });
            });
        }

        function renderTable() {
            const content = document.getElementById('content');
            const seriesToShow = currentSeries ? [currentSeries] : categories;

            let html = '<table><thead><tr><th>期数</th><th>标题</th><th>状态</th><th>发布日期</th><th>播放量</th><th>链接</th></tr></thead><tbody>';
            let hasData = false;

            seriesToShow.forEach(cat => {
                videoData[cat].forEach(item => {
                    const status = item['状态'];
                    const matchStatus = !currentStatus || status === currentStatus;
                    const matchSearch = !searchText || item['标题'].includes(searchText);

                    if (matchStatus && matchSearch) {
                        hasData = true;
                        const link = item['链接'];
                        const linkHtml = link
                            ? '<a href="' + link + '" target="_blank" class="link">查看</a>'
                            : '-';
                        html += '<tr><td>' + item['期数'] + '</td><td>' + item['标题'] + '</td>' +
                            '<td><span class="status ' + getStatusClass(status) + '">' + status + '</span></td>' +
                            '<td>' + (item['发布日期'] || '-') + '</td><td>' + (item['播放量'] || '-') + '</td>' +
                            '<td>' + linkHtml + '</td></tr>';
                    }
                });
            });

            if (!hasData) {
                html = '<div class="empty">没有找到匹配的记录</div>';
            } else {
                html += '</tbody></table>';
            }
            content.innerHTML = html;
        }

        document.getElementById('search').addEventListener('input', (e) => {
            searchText = e.target.value;
            renderTable();
        });

        document.getElementById('status-filter').addEventListener('change', (e) => {
            currentStatus = e.target.value;
            renderTable();
        });

        renderStats();
        renderSeriesFilters();
        renderTable();
        document.getElementById('update-time').textContent = '数据更新时间: ' + document.currentScript ? document.scripts[document.scripts.length - 1].src : '';
    </script>
</body>
</html>
'''

    # 处理 update-time 的 JS 变量问题
    html = html.replace(
        "document.getElementById('update-time').textContent = '数据更新时间: ' + document.currentScript ? document.scripts[document.scripts.length - 1].src : '';",
        "document.getElementById('update-time').textContent = '数据更新时间: ' + new Date().toLocaleString('zh-CN');"
    )

    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(html)
    print("已生成 index.html")

def main():
    print("读取 发布记录.yml...")
    data = load_yaml_data()
    transformed = transform_data(data)
    generate_data_js(transformed)
    generate_html()
    print("\n完成！现在可以：")
    print("1. 打开 index.html 查看发布记录页面")
    print("2. 每次更新 yml 后重新运行此脚本")

if __name__ == '__main__':
    main()
