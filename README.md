# Frontend Image Composition

一个专注于前端页面视觉增强、AI 素材生成与页面集成的 OpenCode skill。

## 功能简介

这个 skill 适用于以下场景：

- 用户给你一个 UI 截图、页面参考图或现有前端页面，希望优化视觉效果
- 需要判断一个页面是否真的适合加图，而不是盲目堆插画
- 需要生成适合前端直接使用的透明背景素材
- 需要结合项目目录结构，自动决定素材保存路径
- 需要检查 AI 生成素材是否有明显瑕疵，再决定是否集成

## 图片生成能力说明

这个 skill 所依赖的图片生成链路基于 **OpenAI Images API**，默认模型为：

- `gpt-image-2`

请求方式应为：

- `POST {baseURL}/images/generations`

也就是说，图片生成**不是**通过聊天接口完成的，而是通过 OpenAI 兼容的图片生成端点完成的。

只要你的供应商兼容 OpenAI Images API，这个 skill 就可以工作。当前配套插件默认兼容以下三种返回格式：

1. `b64_json`
2. `data:image/...;base64,...`
3. `http/https` 远程图片 URL

## 仓库内容

- `SKILL.md`：主 skill 定义
- `prompt-templates.md`：生成素材时的提示词模板
- `asset-review-checklist.md`：素材审查清单
- `setup.ps1`：安装阶段的一次性配置脚本

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

### 安装后初始化配置（推荐）

本仓库提供了一个安装阶段的一次性初始化脚本：

```powershell
.\setup.ps1
```

这个脚本的目标是：

- 确保 `opencode.json` 已挂载：
  - `oh-my-openagent`
  - `./plugins/image-generator/index.js`
- 修正 `oh-my-openagent.json` 中图片相关 agent / category 的基础配置
- 移除把 `gpt-image-2` 当成通用聊天 fallback 的错误配置

脚本只应该在**安装或升级阶段**运行一次，而不是每次使用 skill 前都运行。

### 给 AI 的安装指令示例

你可以直接让 AI 帮你安装并初始化：

- “安装 frontend-image-composition，并运行 setup.ps1 完成图片生成配置”
- “帮我把 frontend-image-composition 装好，并接通 `gpt-image-2` 图片接口”

## 使用建议

适合这样触发：

- “帮我看看这个页面适不适合加素材”
- “给这个前端页面做一版视觉增强”
- “生成一个透明背景插画，直接集成进这个页面”
- “替换这个 AI 味太重的素材”

## 备注

如果你的环境还没有正确配置图片生成链路，建议优先运行 `setup.ps1` 完成安装阶段配置。

这个 skill 本身负责的是**前端素材工作流**，而不是重新实现图片生成工具本身；真正的图片生成能力通常来自插件和 OpenAI Images API。
