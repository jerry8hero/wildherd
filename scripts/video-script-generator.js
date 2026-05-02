#!/usr/bin/env node

/**
 * 文案自动化生成脚本
 * 使用 MiniMax API 生成"冷到你唔信"系列文案
 *
 * 使用方法：
 *   node scripts/video-script-generator.js --config configs/species-list.txt
 *   node scripts/video-script-generator.js --species "绿海龟"
 *   node scripts/video-script-generator.js --list  // 查看支持物种
 */

const fs = require('fs');
const path = require('path');

// MiniMax API 配置
const API_KEY = process.env.MINIMAX_API_KEY || process.env.API_KEY;
const API_BASE = 'https://api.minimax.chat/v1';

// 默认输出目录
const BASE_DIR = path.join(__dirname, '..', 'docs', 'video', 'scripts', '冷到你唔信');

// 文案模板（精简版）
const PROMPT_TEMPLATES = {
  videoScript: `生成B站风格视频文案，主题：{species}

要求：
- 开场：打招呼 + 引入问题 + 价值承诺
- 3-5个段落，用"第X站：主题"格式，每段≤100字
- 语言口语化，有网感
- 结尾：下期预告 + 三连引导
- 可直接朗读`,

  cantoneseScript: `翻译成粤语口语，保持原意和结构：

{script}

只输出译文，不加注释。`,

  bilibiliContent: `根据以下文案生成B站发布信息，输出纯JSON：

{script}

JSON字段：species（物种名）, titles（10个标题）, recommended（推荐标题）, tags（标签数组）, description（简介≤80字）, timeline（时间轴数组）, nextPreview（下期预告）, polls（3个投票，格式"问题|选项A|选项B|..."）, coverText（5个封面文案）, pinnedComment（置顶评论）`
};

/**
 * 调用 MiniMax API
 */
async function callMinimax(prompt, model = 'MiniMax-Text-01') {
  if (!API_KEY) {
    throw new Error('请设置环境变量 MINIMAX_API_KEY 或 API_KEY');
  }

  const response = await fetch(`${API_BASE}/text/chatcompletion_pro?GroupId=${process.env.MINIMAX_GROUP_ID || ''}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${API_KEY}`
    },
    body: JSON.stringify({
      model,
      tokens_to_generate: 8192,
      temperature: 0.7,
      top_p: 0.95,
      prompt: {
        messages: [
          { role: 'user', content: prompt }
        ]
      }
    })
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`API调用失败: ${response.status} - ${error}`);
  }

  const data = await response.json();
  return data.choices?.[0]?.text || data.choices?.[0]?.message?.content || '';
}

/**
 * 生成视频文案
 */
async function generateVideoScript(species) {
  console.log(`\n📝 正在生成视频文案: ${species}`);
  const prompt = PROMPT_TEMPLATES.videoScript.replace('{species}', species);
  return await callMinimax(prompt);
}

/**
 * 生成粤语版文案
 */
async function generateCantoneseScript(script) {
  console.log(' Cantonese translation...');
  const prompt = PROMPT_TEMPLATES.cantoneseScript.replace('{script}', script);
  return await callMinimax(prompt);
}

/**
 * 生成B站发布内容
 */
async function generateBilibiliContent(script) {
  console.log('📋 Generating B站 content...');
  const prompt = PROMPT_TEMPLATES.bilibiliContent.replace('{script}', script);

  // 解析 JSON 输出
  const response = await callMinimax(prompt);

  // 尝试解析 JSON
  try {
    // 移除可能的markdown代码块
    let jsonStr = response.replace(/```json\n?|```\n?/g, '').trim();
    return JSON.parse(jsonStr);
  } catch (e) {
    console.warn('⚠️ JSON解析失败，返回原始文本');
    return { error: response };
  }
}

/**
 * 保存文案到文件
 */
function saveToFile(dirPath, fileName, content) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }

  const filePath = path.join(dirPath, fileName);
  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`  ✅ 已保存: ${fileName}`);
}

/**
 * 格式化B站内容为Markdown
 */
function formatBilibiliContent(data) {
  if (data.error) {
    return `# B站发布内容 - 错误\n\n无法解析B站内容，请手动创建。\n\n原始输出:\n${data.error}`;
  }

  const format = (items, prefix = '') => {
    if (Array.isArray(items)) {
      return items.map((item, i) => `${prefix}${i + 1}. ${item}`).join('\n');
    }
    return items || '';
  };

  return `# B站发布内容 - ${data.species || '未知物种'}

---

## 【标题候选】

${format(data.titles || data['标题候选'] || [])}

---

## 【推荐标题】

${data.recommendedTitle || data['推荐标题'] || ''}

---

## 【标签】

${Array.isArray(data.tags) ? data.tags.join('，') : (data['标签'] || '')}

---

## 【简介】

${data.description || data['简介'] || ''}

---

## 【时间轴】

${Array.isArray(data.timeline) ? data.timeline.map(t => `- ${t}`).join('\n') : (data['时间轴'] || '')}

---

## 【下期预告】

${data.nextPreview || data['下期预告'] || ''}

---

## 【投票弹幕】

${Array.isArray(data.polls) ? data.polls.map((poll, i) => `**问题${i + 1}**\n${poll}`).join('\n\n') : (data['投票弹幕'] || '')}

---

## 【封面文案】

${Array.isArray(data.coverText) ? data.coverText.map((text, i) => `### 方案${i + 1}\n\n${text}`).join('\n\n') : (data['封面文案'] || '')}

---

## 【置顶评论】

${data.pinnedComment || data['置顶评论'] || ''}
`;
}

/**
 * 处理单个物种
 */
async function processSpecies(species, baseDir = BASE_DIR) {
  console.log(`\n${'='.repeat(50)}`);
  console.log(`🎬 开始处理: ${species}`);
  console.log('='.repeat(50));

  // 创建目录
  const dirName = species.replace(/[\\/:*?"<>|]/g, '');
  const dirPath = path.join(baseDir, dirName);

  try {
    // 1. 生成视频文案
    const script = await generateVideoScript(species);

    // 2. 生成粤语版
    const cantoneseScript = await generateCantoneseScript(script);

    // 3. 生成B站发布内容
    const bilibiliData = await generateBilibiliContent(script);
    const bilibiliContent = formatBilibiliContent(bilibiliData);

    // 4. 保存文件
    const timestamp = Date.now();
    saveToFile(dirPath, `${timestamp}_${dirName}_视频文案.md`, script);
    saveToFile(dirPath, `${timestamp}_${dirName}_视频文案_粤语.md`, cantoneseScript);
    saveToFile(dirPath, `${timestamp}_${dirName}_B站发布内容.md`, bilibiliContent);

    console.log(`\n✅ ${species} 处理完成！`);
    return { success: true, species };
  } catch (error) {
    console.error(`\n❌ ${species} 处理失败: ${error.message}`);
    return { success: false, species, error: error.message };
  }
}

/**
 * 从配置文件读取物种列表
 */
function readSpeciesList(configPath) {
  if (!fs.existsSync(configPath)) {
    throw new Error(`配置文件不存在: ${configPath}`);
  }

  const content = fs.readFileSync(configPath, 'utf8');
  const lines = content.split('\n').filter(line => {
    line = line.trim();
    return line && !line.startsWith('#') && !line.startsWith('//');
  });

  return lines;
}

/**
 * 显示帮助信息
 */
function showHelp() {
  console.log(`
🎬 文案自动化生成脚本

用法:
  node video-script-generator.js --config <文件>   从配置文件读取物种列表
  node video-script-generator.js --species <名称>   生成单个物种文案
  node video-script-generator.js --list            查看已处理的物种

示例:
  node video-script-generator.js --species "绿海龟"
  node video-script-generator.js --config ./species-list.txt

环境变量:
  MINIMAX_API_KEY      MiniMax API 密钥（必填）
  MINIMAX_GROUP_ID     MiniMax Group ID

配置文件格式:
  # 物种列表（每行一个）
  绿海龟
  四爪陆龟
  塞舌尔巨龟
`);
}

// 主入口
async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--help') || args.includes('-h')) {
    showHelp();
    return;
  }

  if (!API_KEY) {
    console.error('❌ 请设置环境变量 MINIMAX_API_KEY 或 API_KEY');
    console.error('   例如: export MINIMAX_API_KEY=your_api_key');
    showHelp();
    return;
  }

  // 解析参数
  const configIndex = args.indexOf('--config');
  const speciesIndex = args.indexOf('--species');

  if (args.includes('--list')) {
    // 列出已处理的物种
    const dirs = fs.readdirSync(BASE_DIR).filter(d =>
      fs.statSync(path.join(BASE_DIR, d)).isDirectory()
    );
    console.log(`\n📁 已处理 ${dirs.length} 个物种:`);
    dirs.sort().forEach(d => console.log(`  - ${d}`));
    return;
  }

  if (configIndex !== -1) {
    // 从配置文件读取
    const configPath = path.resolve(args[configIndex + 1]);
    const speciesList = readSpeciesList(configPath);

    console.log(`\n📋 开始处理 ${speciesList.length} 个物种...`);

    const results = [];
    for (const species of speciesList) {
      const result = await processSpecies(species);
      results.push(result);
      // 简单延迟避免API限流
      await new Promise(r => setTimeout(r, 1000));
    }

    // 汇总结果
    const success = results.filter(r => r.success).length;
    const failed = results.filter(r => !r.success).length;
    console.log(`\n${'='.repeat(50)}`);
    console.log(`📊 处理完成: 成功 ${success}，失败 ${failed}`);

    if (failed > 0) {
      console.log('失败列表:');
      results.filter(r => !r.success).forEach(r => {
        console.log(`  - ${r.species}: ${r.error}`);
      });
    }
    return;
  }

  if (speciesIndex !== -1) {
    // 处理单个物种
    const species = args[speciesIndex + 1];
    await processSpecies(species);
    return;
  }

  showHelp();
}

main().catch(console.error);