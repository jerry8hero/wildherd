# 视频文案工作流

## 生成文案

1. 使用 `@docs/video/prompts/video-script-assistant.md` 模板规范文案格式
2. 调用 MiniMax 生成文案（或在 Claude Code 对话中直接生成）
3. 保存到 `docs/video/scripts/[龟种]/[序号]-[标题].md`

## Review 文案

文案生成后，使用 MiniMax 进行多轮迭代 Review：

### 方式一：自动 Review（推荐）

使用 `scripts/auto_review.py` 进行 3 轮分维度自动优化：

```bash
cd scripts

# 处理 005-020
python auto_review.py 5 20

# 处理 002-101
python auto_review.py 2 101

# 指定子目录
python auto_review.py 2 10 "冷到你唔信/第一册-哺乳动物"
```

**评审维度：**
| 轮次 | 重点 | 说明 |
|------|------|------|
| 第1轮 | 开场吸引力 | 检查开头是否 5 秒内抓住观众 |
| 第2轮 | 叙事结构 | 检查信息密度、逻辑流畅性 |
| 第3轮 | 结尾互动性 | 检查三件套、顺口溜、悬念 |

**特性：** 失败自动重试（3次）| 断点续传 | 生成 JSON 报告

### 方式二：手动 Review（MiniMax）

1. **复制文案** → 打开 `docs/video/prompts/review-prompt-template.md` 获取快捷版 Prompt
2. **粘贴到 MiniMax** → 使用 `x claude mm` 命令调用 MiniMax
3. **Review + 修改** → 根据建议修改文案
4. **迭代优化** → 重复 Review 直到满意

### 快捷流程

```
review 并修改以下文案，保持B站风格，直接输出完整修改版：
[粘贴文案]
```

### 分步流程

```
# 第一轮 Review
review 以下文案，给出修改建议：
[粘贴文案]

# 修改
根据建议修改文案，直接输出完整新版：

# 迭代确认
再 review 一次，确认是否定稿：
[粘贴当前文案]
```

## 生成封面图片提示词

文案定稿后，根据 `B站发布内容.md` 中的「封面文案」部分，生成 16:9 比例的文生图提示词：

1. **读取封面文案** → 提取「方案一（推荐）」的文字内容
2. **生成提示词** → 按照以下结构生成英文提示词：
   - 画面主体：龟的表情、姿态、场景
   - 文字叠加：中文文本的三行内容
   - 视觉风格：色彩、氛围、参考风格
   - 辅助元素：图标、符号等
3. **追加到文案文件** → 在「封面文案」部分添加 `## 封面生图提示词` 小节

### 提示词结构模板

```
16:9 horizontal illustration for Bilibili video thumbnail

[画面主体描述：龟的种类、表情、姿态、所在环境]

Above the [主体], bold Chinese text overlay:
"[第一行标题]" (top line, [颜色] with [效果])
"[第二行警告/强调]" (middle line, [颜色] warning text)
"[第三行补充]" (bottom line, smaller [颜色] text)

Visual style: [风格描述：动漫风/写实风/电影感等]
Color scheme: [主色调] with [辅助色] accents, high contrast
Background: [背景描述]
Mood: [整体氛围：紧迫/温馨/搞笑等]
```

### 示例输出格式

```markdown
## 封面生图提示词

### 方案一

```
16:9 horizontal illustration for Bilibili video thumbnail

A baby alligator turtle in a transparent tank, looking scared
and stressed, large expressive eyes, slightly withdrawn into shell.

Above the turtle, bold Chinese text overlay:
"新龟到家第一周" (top line, large white text with red outline)
"这5步做错=送命" (middle line, yellow warning text)
"新手必看急救指南" (bottom line, smaller white text)

Visual style: anime comic, bold outlines, vivid colors
Color scheme: dark background with red/black/yellow accents, high contrast
Background: water ripples with floating question marks and ⚠️ symbols
Mood: tense, urgent, critical situation for new turtle owners
```
```

### 使用 Gemini 生成封面

```bash
# 在 Gemini 中输入上述提示词
# 比例设为 16:9 (1920x1080 或类似比例)
# 生成后下载，使用剪映叠加字幕文字
```
