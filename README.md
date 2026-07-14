# haozhou-skills

Personal agent skills collection

## Skills

| Skill | 说明 |
|---|---|
| [literature-survey](./literature-survey/) | 深度文献调研与报告生成：六章深度调研报告（研究背景 / 技术脉络 / 重要工作 / 前沿动态 / 开源生态 / 开放问题）+ 论文总表附录 |

## 安装

skill 就是一个带 `SKILL.md` 的目录，把它放进你所用 agent 的 skills 目录即可。常见位置：

| Agent | skills 目录 |
|---|---|
| Claude Code | `~/.claude/skills/` |
| 通用 agent 约定（Codex 等） | `~/.agents/skills/` |

```bash
# 克隆仓库
git clone https://github.com/haozhou-wong/haozhou-skills.git

# 把想要的 skill 软链进 skills 目录（仓库更新即生效），SKILL 换成目录名，如 literature-survey
SKILLS_DIR=~/.agents/skills          # 按你的 agent 换目录
SKILL=literature-survey
mkdir -p "$SKILLS_DIR"
ln -s "$(pwd)/haozhou-skills/$SKILL" "$SKILLS_DIR/$SKILL"
# 不想软链就复制：cp -r haozhou-skills/$SKILL "$SKILLS_DIR/"
```

## 依赖

literature-survey 依赖 [paper-search-cli](https://github.com/dr-dumpling/paper-search-cli) 的 **CLI + 配套 skills**（检索、元数据核验、引文扩展、期刊指标、PDF 获取）

可选：[gh CLI](https://cli.github.com/)（查 GitHub star 与维护活跃度）。安装：`sudo apt install gh`；装好后 `gh auth login` 登录。
