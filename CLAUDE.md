# 视频文案工作流

## 生成文案

1. 使用 `@docs/video/prompts/video-script-assistant.md` 模板规范文案格式
2. 调用 MiniMax 生成文案（或在 Claude Code 对话中直接生成）
3. 保存到 `docs/video/scripts/[龟种]/[序号]-[标题].md`

## Review 文案

文案生成后，使用 DeepSeek 进行多轮迭代 Review：

```bash
# 单次 review（只看不改）
python3 tools/review/deepseek_reviewer.py review <文件路径>

# review + 自动修改
python3 tools/review/deepseek_reviewer.py review <文件路径> --apply

# 多轮迭代 review + 修改（默认3轮）
python3 tools/review/deepseek_reviewer.py iterate <文件路径>

# 自定义迭代轮数
python3 tools/review/deepseek_reviewer.py iterate <文件路径> --rounds 5
```

## 推荐流程

1. **生成文案** → Claude Code + MiniMax
2. **第一轮 Review** → `python3 tools/review/deepseek_reviewer.py review <文件> --apply`
3. **检查修改** → 查看文件内容，确认是否符合预期
4. **如需继续优化** → `python3 tools/review/deepseek_reviewer.py iterate <文件> --rounds 2`
5. **定稿** → 提交到远程 repo

## 注意事项

- Review 前确保文案已保存
- 每次修改会自动创建 `.bak` 备份
- `--reviewer bilibili` 会对 B站特性进行优化

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
