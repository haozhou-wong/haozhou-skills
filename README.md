<h1 align="center">haozhou-skills</h1>

<p align="center">
  <a href="./LICENSE"><img alt="License: MIT" src="https://img.shields.io/github/license/haozhou-wong/haozhou-skills?style=flat-square"></a>
  <a href="https://agents.md"><img alt="AGENTS.md" src="https://img.shields.io/badge/AGENTS.md-000000?style=flat-square&logo=markdown"></a>
  <img alt="语言: 简体中文" src="https://img.shields.io/badge/%E8%AF%AD%E8%A8%80-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-red?style=flat-square">
</p>

个人的 agent 使用习惯，整理为一份全局指令文件 [`AGENTS.global.md`](./AGENTS.global.md)，可供 Claude Code、Codex CLI、Antigravity CLI、Grok Build、OpenCode、Pi、DeepSeek Harness 等 agent 使用。其中包含个人偏好，可以自行修改。

## 全局指令

`AGENTS.global.md` 分为七部分：

- 协作约定：发现问题直接指出，不覆盖用户的手动修改。
- 语言规则：用中文回复用户，文档、注释和提交信息沿用项目惯例。
- 写作风格：检查空话、模板化表达等问题的规则清单。
- 行为指南：编码前先思考，优先采用最简方案，只改必须改的代码，以可验证的目标推进任务。
- 编码准则：优先复用已有代码和依赖，做最小的完整改动，安全和信任边界上的校验不可省略。
- 工程规范：仓库整洁、文件命名和 uv、nvm、Docker 等环境管理约定。
- 提交规范：采用 Conventional Commits，提交和创建 PR 前须经用户确认，禁止添加 AI 署名。

## 安装

### 软链共享

把指令文件下载为中心文件 `~/.agents/AGENTS.md`。各 agent 统一链接到中心文件，更新时只需重新下载这一个文件。`~/.agents/AGENTS.md` 已存在时会被覆盖，需要保留的先备份。

```bash
mkdir -p ~/.agents
curl -fsSL https://raw.githubusercontent.com/haozhou-wong/haozhou-skills/main/AGENTS.global.md -o ~/.agents/AGENTS.md
```

再为每个要使用的 agent 建立指向中心文件的软链，`<路径>` 按需替换为下表中对应的文件：

```bash
ln -s ~/.agents/AGENTS.md <路径>
```

| Agent | 全局指令文件 |
| ----- | ------------ |
| Claude Code | `~/.claude/CLAUDE.md` |
| Codex CLI | `~/.codex/AGENTS.md` |
| Antigravity CLI（agy） | `~/.gemini/AGENTS.md` |
| Grok Build（grok） | `~/.grok/AGENTS.md` |
| OpenCode | `~/.config/opencode/AGENTS.md` |
| Pi | `~/.pi/agent/AGENTS.md` |
| DeepSeek Harness（dsh） | `~/.dsh/AGENTS.md` |

报错 `File exists` 表示目标位置已有文件，先改名备份再重新执行，例如：

```bash
mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
```

### 复制粘贴

在 GitHub 上打开 [`AGENTS.global.md`](./AGENTS.global.md)，点击 Copy raw file 按钮复制全文，粘贴到上表中对应的文件里。已有全局指令时，可以只合并需要的部分。

## 更新

软链共享方式重新下载中心文件即可更新，所有 agent 立即生效：

```bash
curl -fsSL https://raw.githubusercontent.com/haozhou-wong/haozhou-skills/main/AGENTS.global.md -o ~/.agents/AGENTS.md
```

复制粘贴方式需要手动重新复制。

## 卸载

软链共享方式删除各 agent 的软链和中心文件，有备份的改回原名：

```bash
rm <路径> ~/.agents/AGENTS.md
mv <路径>.bak <路径>
```

复制粘贴方式从文件中删除相应内容即可。

## 致谢

- [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)：`AGENTS.global.md` 中行为指南部分的来源，MIT 许可证
- [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)：`AGENTS.global.md` 中编码准则部分的来源，MIT 许可证

## 许可证

本项目采用 [MIT 许可证](./LICENSE)。
