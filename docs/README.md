# Documentation Guide

[中文](#中文) | [English](#english)

## 中文

### 推荐阅读顺序

如果你是第一次接触这个仓库，建议按下面顺序阅读：

1. `docs/baseline-standard.md`
2. `docs/deployment-sop.md`
3. `docs/deploy-baseline-kit.md`
4. `docs/roadmap-v1.1.md`

如果你是要直接把这套基线接入到真实项目里，建议这样走：

1. 先看 `docs/baseline-standard.md`，理解这套基线要求项目收敛成什么样
2. 再看 `docs/deployment-sop.md`，理解部署文档和操作流程的标准形状
3. 如果你打算手工复制模板，再看 `template/` 和 `template/deploy/README.md`
4. 如果你打算让 Codex 自动识别并改造项目，再看 `docs/deploy-baseline-kit.md` 和 `skills/deploy-baseline-kit/SKILL.md`

### 文档地图

- `docs/baseline-standard.md`
  基线标准本体，定义统一命令面、Compose 结构、环境变量和部署目录约定。
- `docs/deployment-sop.md`
  通用部署 SOP，定义项目级部署文档应该覆盖哪些章节和操作步骤。
- `docs/deploy-baseline-kit.md`
  `deploy-baseline-kit` 的行为边界、稳定支持范围和确认模型说明。
- `docs/roadmap-v1.1.md`
  仓库后续演进方向和优先级。
- `docs/superpowers/specs/`
  skill 设计规格，适合需要继续演进 skill 的维护者阅读。
- `docs/superpowers/plans/`
  已拆解的实现计划，适合继续推进具体 phase 的维护者阅读。

### 什么时候看 skill 设计文档

以下情况建议继续读 `docs/superpowers/specs/` 与 `docs/superpowers/plans/`：

- 你要继续扩 `deploy-baseline-kit`
- 你要补新的数据库产品线
- 你要增强 monorepo / mixed-surface 支持
- 你要为仓库补 fixture、验证命令或 runnable examples

## English

### Recommended Reading Order

If this is your first time in the repository, read in this order:

1. `docs/baseline-standard.md`
2. `docs/deployment-sop.md`
3. `docs/deploy-baseline-kit.md`
4. `docs/roadmap-v1.1.md`

If you want to apply the baseline to a real project, use this path:

1. Read `docs/baseline-standard.md` to understand the target baseline shape
2. Read `docs/deployment-sop.md` to understand the expected deployment-doc structure
3. If you will copy the template manually, inspect `template/` and `template/deploy/README.md`
4. If you want Codex to inspect and converge a project automatically, continue with `docs/deploy-baseline-kit.md` and `skills/deploy-baseline-kit/SKILL.md`

### Document Map

- `docs/baseline-standard.md`
  The baseline standard itself: command contract, Compose layers, env layout, and deploy directory conventions.
- `docs/deployment-sop.md`
  The generic deployment SOP that project-specific deploy docs should follow.
- `docs/deploy-baseline-kit.md`
  Behavior boundaries, stability notes, and confirmation semantics for `deploy-baseline-kit`.
- `docs/roadmap-v1.1.md`
  Near-term roadmap and optimization priorities.
- `docs/superpowers/specs/`
  Design specs for maintainers evolving the skill.
- `docs/superpowers/plans/`
  Implementation plans for concrete follow-up phases.

### When To Read The Skill Specs

Continue into `docs/superpowers/specs/` and `docs/superpowers/plans/` when you need to:

- extend `deploy-baseline-kit`
- add more database baselines
- deepen monorepo or mixed-surface support
- add fixtures, validation commands, or runnable examples
