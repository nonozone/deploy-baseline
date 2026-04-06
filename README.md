# Deploy Baseline Kit

[中文](#中文说明) | [English](#english)

`deploy-baseline-kit` 是一个可安装的 skill 产品，用于识别真实项目、说明它与部署基线的差距，并把项目尽可能收敛到统一的 deploy baseline 结构。

`deploy-baseline-kit` is an installable skill product for inspecting real repositories, explaining baseline gaps, and converging projects toward a standardized deployment baseline.

## 中文说明

### 当前稳定版

- 当前稳定版：`v1.0.2`
- 发布时间：`2026-04-05`
- Release：`https://github.com/nonozone/deploy-baseline/releases/tag/v1.0.2`

### 产品定位

这个仓库应被理解为一个 skill 产品仓库，而不是“模板仓库顺带附带一个 skill”。

主场景：

- 识别已有项目的部署结构
- 说明项目与 deploy baseline 的差距
- 在一次主要确认后，把项目尽可能收敛到统一基线

次场景：

- 为近空项目生成同一套基线骨架

当前产品原则：

- 优先让目标项目靠近基线，而不是优先兼容历史差异
- `deploy-baseline-kit` 是主入口
- `src/` 是单一真源
- 无法安全收敛的差异必须显式记录为 `exceptions`

### 仓库结构

- `skills/deploy-baseline-kit/`
  当前 skill 入口、安装契约与打包产物内容。
- `src/template/`
  基线模板真源。
- `src/rules/`
  skill 执行规则与 references 真源。
- `src/docs/`
  产品文档真源起点。
- `docs/`
  当前对外文档入口。
- `internal/`
  设计规格与实现计划，仅面向维护者。
- `template/`
  兼容输出目录，由 `src/template/` 刷新，不再是主入口。
- `skills/deploy-baseline-kit/assets/template/`
  skill 安装包内的兼容模板输出，由 `src/template/` 刷新。
- `skills/deploy-baseline-kit/references/`
  skill 安装包内的兼容规则输出，由 `src/rules/references/` 刷新。
- `dist/`
  自包含打包产物目录。

### 推荐阅读顺序

建议先从 [docs/README.md](./docs/README.md) 进入。

最短阅读路径：

1. `docs/deploy-baseline-kit.md`
2. `docs/baseline-standard.md`
3. `docs/deployment-sop.md`
4. `skills/deploy-baseline-kit/SKILL.md`

如果你是维护者，再继续看：

1. `src/template/`
2. `src/rules/`
3. `internal/specs/`
4. `internal/plans/`

### 使用方式

推荐把它当成目标项目中的安装型 skill 使用：

1. 在目标项目根目录或子目录中运行 Codex
2. 显式调用 `deploy-baseline-kit`
3. 先查看识别结果、部署单元矩阵、命令面矩阵与 `exceptions`
4. 在唯一确认点确认方案
5. 让 skill 完成收敛并执行最低验证

手工编辑 `src/template/` 只适用于维护这个产品本身，不应再作为普通用户的主使用路径。

### env 约定

env 路径已经统一为：

- `deploy/env/app.env.example`
  唯一 canonical env 示例来源。
- `deploy/env/app.dev.env`
  本地开发默认 env 文件，`make dev` 默认读取它。
- `deploy/env/app.prod.env`
  生产部署 env 文件。

迁移规则：

- `make setup` 会优先基于 `deploy/env/app.env.example` 创建 `deploy/env/app.dev.env`
- 如果检测到历史根目录 `.env`，且 `deploy/env/app.dev.env` 尚不存在，会自动复制一份并给出明确提示，作为一次性平滑迁移
- `make local-env-sync` 与 `make prod-env-sync` 只补齐缺失 key，不覆盖已有值

### 构建、打包与验证

常用命令：

- `make build-skill`
  基于单一真源构建 skill 产物，并刷新兼容输出。
- `make package`
  生成自包含 skill 包。
- `make install-local`
  安装到本地 Codex skills 目录。
- `make sync-compat`
  将 `src/template/` 刷新到兼容模板目录。
- `make sync-rules`
  将 `src/rules/references/` 刷新到 skill references 兼容目录。
- `make verify`
  执行仓库级一致性校验。

### 最低验证面

当前基线要求至少覆盖：

- shell 脚本 `bash -n`
- 需要纳入 Compose 的 `self-hosted` 单元执行 `docker compose config`
- `make help` 的命令面检查
- 项目已有 `build/test/typecheck` 时执行现有健康检查
- env 引用、`healthcheck` 与回滚边界检查

### 适用场景

- 你要把已有项目收敛到统一部署接口
- 你要给团队建立标准化的部署基线
- 你希望用一次确认完成结构化生成或收敛
- 你希望安装一个可复用的 skill，而不是维护多套散落模板

### 开源协议

本项目使用 `Apache-2.0` 协议。详见 [`LICENSE`](./LICENSE)。

## English

### Current Stable Release

- Current stable release: `v1.0.2`
- Published on: `2026-04-05`
- Release: `https://github.com/nonozone/deploy-baseline/releases/tag/v1.0.2`

### Product Positioning

This repository should be understood as a skill product repository, not as a template repository that happens to ship a skill.

Primary use case:

- inspect an existing repository's deployment shape
- explain the gap from the baseline
- converge the repository toward the standard structure after one main confirmation

Secondary use case:

- bootstrap a near-empty repository with the same baseline

Product principles:

- converge target projects toward the baseline instead of preserving local drift by default
- `deploy-baseline-kit` is the front door
- `src/` is the single source of truth
- any deviation that cannot be normalized safely must be recorded as an explicit `exception`

### Repository Layout

- `skills/deploy-baseline-kit/`
  Live skill entry, install contract, and packaged skill content.
- `src/template/`
  Canonical baseline template source.
- `src/rules/`
  Canonical execution rules and references source.
- `src/docs/`
  Canonical product-doc source.
- `docs/`
  Product-facing repository docs.
- `internal/`
  Design specs and implementation plans for maintainers.
- `template/`
  Compatibility output refreshed from `src/template/`, not the primary product surface.
- `skills/deploy-baseline-kit/assets/template/`
  Compatibility template output for installed skill packages, refreshed from `src/template/`.
- `skills/deploy-baseline-kit/references/`
  Compatibility rules output for installed skill packages, refreshed from `src/rules/references/`.
- `dist/`
  Self-contained package output directory.

### Recommended Reading Order

Start from [docs/README.md](./docs/README.md).

Shortest product path:

1. `docs/deploy-baseline-kit.md`
2. `docs/baseline-standard.md`
3. `docs/deployment-sop.md`
4. `skills/deploy-baseline-kit/SKILL.md`

Maintainer path:

1. `src/template/`
2. `src/rules/`
3. `internal/specs/`
4. `internal/plans/`

### How To Use It

Treat it as an installable skill inside the target project:

1. Run Codex from the target repository root or any child directory
2. Explicitly invoke `deploy-baseline-kit`
3. Review the detected state, deployment-unit matrix, command-surface matrix, and `exceptions`
4. Confirm once
5. Let the skill converge the project and run the minimum verification surface

Directly editing `src/template/` is for product maintenance, not for normal adoption.

### Env Contract

The env layout is standardized as:

- `deploy/env/app.env.example`
  The single canonical env example source.
- `deploy/env/app.dev.env`
  The default local-development env file used by `make dev`.
- `deploy/env/app.prod.env`
  The production deployment env file.

Migration rules:

- `make setup` initializes `deploy/env/app.dev.env` from `deploy/env/app.env.example`
- if a legacy root `.env` exists and `deploy/env/app.dev.env` does not, setup copies it once and prints a clear migration notice
- `make local-env-sync` and `make prod-env-sync` only fill missing keys and never overwrite existing values

### Build, Package, And Verify

Common commands:

- `make build-skill`
  Build the skill from the canonical sources and refresh compatibility outputs.
- `make package`
  Produce a self-contained skill package.
- `make install-local`
  Install the skill into the local Codex skills directory.
- `make sync-compat`
  Refresh compatibility template outputs from `src/template/`.
- `make sync-rules`
  Refresh compatibility rule outputs from `src/rules/references/`.
- `make verify`
  Run repository-level consistency checks.

### Minimum Verification Surface

The baseline currently expects at least:

- `bash -n` for new or changed shell scripts
- `docker compose config` for `self-hosted` units that are actually in Compose
- `make help` command-surface verification
- existing `build/test/typecheck` health checks when the project already has them
- checks for env references, `healthcheck`, and rollback boundaries

### Good Fit For

- converging existing projects onto a standardized deployment interface
- establishing a standard deployment baseline across multiple repositories
- using one confirmation gate to drive structured generation or convergence
- shipping a reusable skill product instead of maintaining multiple drifting template paths

### License

This project is licensed under `Apache-2.0`. See [`LICENSE`](./LICENSE) for details.
