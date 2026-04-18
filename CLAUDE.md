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
