# Frontend Image Composition

一个专注于前端页面视觉增强、AI 素材生成与页面集成的 OpenCode skill。

## 功能简介

这个 skill 适用于以下场景：

- 用户给你一个 UI 截图、页面参考图或现有前端页面，希望优化视觉效果
- 需要判断一个页面是否真的适合加图，而不是盲目堆插画
- 需要生成适合前端直接使用的透明背景素材
- 需要结合项目目录结构，自动决定素材保存路径
- 需要检查 AI 生成素材是否有明显瑕疵，再决定是否集成

## 仓库内容

- `SKILL.md`：主 skill 定义
- `prompt-templates.md`：生成素材时的提示词模板
- `asset-review-checklist.md`：素材审查清单

## 适用范围

这个 skill 偏向“前端视觉工作流”，而不是单纯的图片生成工具。它更关注：

1. 页面是否适合加图
2. 应该生成哪种素材
3. 素材放在哪个目录
4. 素材能不能真的上页面

## 安装方式

把整个目录复制到你的 OpenCode skills 目录：

```bash
# Windows
cp -r frontend-image-composition C:\Users\<username>\.config\opencode\skills\

# macOS/Linux
cp -r frontend-image-composition ~/.config/opencode/skills/
```

## 使用建议

适合这样触发：

- “帮我看看这个页面适不适合加素材”
- “给这个前端页面做一版视觉增强”
- “生成一个透明背景插画，直接集成进这个页面”
- “替换这个 AI 味太重的素材”

## 备注

如果你的环境还没有正确配置图片生成链路，这个 skill 可以作为前端素材工作流的上层能力使用；真正的生图工具通常来自插件或图片生成接口，而不是这个 skill 本身。
