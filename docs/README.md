# Deploy Baseline Kit Docs

[中文](#中文) | [English](#english)

## 中文

### 当前稳定版

- 当前稳定版：`v1.0.2`
- 发布时间：`2026-04-05`
- Release：`https://github.com/nonozone/deploy-baseline/releases/tag/v1.0.2`

### 推荐阅读顺序

如果你是第一次接触这个仓库，建议按下面顺序阅读：

1. `docs/deploy-baseline-kit.md`
2. `docs/baseline-standard.md`
3. `docs/deployment-sop.md`
4. `docs/v1-release.md`

如果你是要把这个 skill 用到真实项目里，建议这样走：

1. 先看 `docs/baseline-standard.md`，理解这套基线要求项目收敛成什么样
2. 再看 `docs/deployment-sop.md`，理解部署文档和操作流程的标准形状
3. 再看 `skills/deploy-baseline-kit/SKILL.md`，理解实际执行规则
4. 如果你要维护这套产品本身，再看 `src/template/`、`src/rules/` 和 `internal/`

### 文档地图

- `docs/baseline-standard.md`
  基线标准本体，定义 skill 要把目标项目收敛成什么形状。
- `docs/v1-release.md`
  历史发布说明，适合理解仓库之前的定位与边界。
- `docs/deployment-sop.md`
  通用部署 SOP，定义项目级部署文档应该覆盖哪些章节和操作步骤。
- `docs/deploy-baseline-kit.md`
  `deploy-baseline-kit` 的产品边界、确认模型和收敛行为说明。
- `skills/deploy-baseline-kit/SKILL.md`
  skill 的安装入口与执行契约。
- `internal/specs/2026-04-06-deploy-baseline-kit-productization-design.md`
  当前产品化收敛设计。
- `internal/specs/`
  skill 设计规格，适合需要继续演进 skill 的维护者阅读。
- `internal/plans/`
  已拆解的实现计划，适合继续推进具体 phase 的维护者阅读。

### 什么时候看内部设计文档

以下情况建议继续读 `internal/specs/` 与 `internal/plans/`：

- 你要继续扩 `deploy-baseline-kit`
- 你要补新的数据库产品线
- 你要增强 monorepo / mixed-surface 支持
- 你要为仓库补 fixture、验证命令或 runnable examples

## English

### Current Stable Release

- Current stable release: `v1.0.2`
- Published on: `2026-04-05`
- Release: `https://github.com/nonozone/deploy-baseline/releases/tag/v1.0.2`

### Recommended Reading Order

If this is your first time in the repository, read in this order:

1. `docs/deploy-baseline-kit.md`
2. `docs/baseline-standard.md`
3. `docs/deployment-sop.md`
4. `docs/v1-release.md`

If you want to use the skill on a real project, use this path:

1. Read `docs/baseline-standard.md` to understand the target baseline shape
2. Read `docs/deployment-sop.md` to understand the expected deployment-doc structure
3. Read `skills/deploy-baseline-kit/SKILL.md` to understand the installed behavior contract
4. Inspect `src/template/`, `src/rules/`, and `internal/` only when you are maintaining the product itself

### Document Map

- `docs/baseline-standard.md`
  The baseline standard itself: command contract, Compose layers, env layout, and deploy directory conventions.
- `docs/v1-release.md`
  The v1 release note: project positioning, core commands, intended audience, and explicit product boundary.
- `docs/deployment-sop.md`
  The generic deployment SOP that project-specific deploy docs should follow.
- `docs/deploy-baseline-kit.md`
  Behavior boundaries, stability notes, and confirmation semantics for `deploy-baseline-kit`.
- `skills/deploy-baseline-kit/SKILL.md`
  The skill entrypoint and execution contract.
- `internal/specs/`
  Design specs for maintainers evolving the skill.
- `internal/plans/`
  Implementation plans for concrete follow-up phases.

### When To Read The Skill Specs

Continue into `internal/specs/` and `internal/plans/` when you need to:

- extend `deploy-baseline-kit`
- add more database baselines
- deepen monorepo or mixed-surface support
- add fixtures, validation commands, or runnable examples
