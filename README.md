# Deploy Baseline

[中文](#中文说明) | [English](#english)

部署基线：一套可迁移的容器部署与 `Make` 通用基线，用于在不同项目之间复用一致的开发、构建、测试与部署入口。

Deploy Baseline is a reusable deployment baseline for containerized projects, including monorepos with mixed deployment surfaces (self-hosted services, externally hosted static sites, and provider-managed platform units). It provides a consistent `Make`-based interface, layered Docker Compose structure, deployment SOPs, and a copyable project template.

## 中文说明

### 项目定位

这个仓库不是业务项目本身，而是一套可以被复制、裁剪、再落地到真实项目中的通用资产，目标是统一：

- 顶层 `Makefile` 命令入口
- 容器部署分层结构
- 部署文档与 SOP 结构
- 新项目初始化时的模板骨架

这套基线吸收了真实项目里反复验证过的模式，例如：

- 后端走 Docker、前端本地热更新的混合开发方式
- 后端容器化发布、前端静态发布的分离式部署方式
- 状态型服务的发布前检查脚本
- 启动契约变量与健康检查约定

### 仓库结构

- `docs/README.md`：文档入口与推荐阅读顺序
- `docs/baseline-standard.md`：通用基线规范
- `docs/deployment-sop.md`：通用部署 SOP
- `docs/deploy-baseline-kit.md`：`deploy-baseline-kit` 的实际行为边界与稳定支持范围说明
- `docs/roadmap-v1.1.md`：下一阶段的优化方向、优先级和任务清单
- `skills/deploy-baseline-kit/`：用于识别项目并生成/收敛部署基线的 Codex skill
- `template/`：可复制到新项目中的模板骨架
- `template/deploy/`：部署目录、示例环境变量和脚本
- `template/scripts/`：本地开发、构建、测试等脚本占位
- `fixtures/`：静态样板目录，用于记录项目分类、运行模式、推荐路径元信息，并支撑基础验证命令；`runnable/` 子目录则预留给未来可执行样板验证。

`fixtures/` 记录候选项目形态的差异、期望模式和建议路径，仓库级别的验证命令将覆盖这些元信息，同时该层结构也为后续的 runnable/ 可执行样板提供承载空间。

### 推荐阅读顺序

建议优先从 [docs/README.md](./docs/README.md) 进入。

最短阅读路径：

1. `docs/baseline-standard.md`
2. `docs/deployment-sop.md`
3. `docs/deploy-baseline-kit.md`
4. `docs/roadmap-v1.1.md`

### 验证命令
- `make verify-fixtures-static`：当前 Phase 1 只覆盖静态样板验证，命令会检查 `fixtures/` 下每个 `fixture.md` 是否满足预期字段。
- `make verify-baseline`：统一的基础验证入口，目前只是执行静态样板检查，用于为将来的其它层级验证提供挂钩点。

### 模板默认提供

- 标准 `Makefile`
- 三层 Compose 结构
- 本地脚本目录
- 部署脚本目录
- 中文部署文档模板
- GitHub Actions 工作流模板

模板不会替你决定业务技术栈，只负责提供统一工程接口与部署骨架。

### 建议使用方式

1. 先阅读 `docs/baseline-standard.md`
2. 再阅读 `docs/deployment-sop.md`
3. 如果要用 Codex 自动改造项目，再阅读 `docs/deploy-baseline-kit.md`
4. 如需了解后续演进方向，可参考 `docs/roadmap-v1.1.md`
5. 复制 `template/` 到目标项目，或在目标项目中调用 `deploy-baseline-kit`
6. 替换模板中的项目名、服务名、镜像名、端口和启动命令
7. 明确目标项目采用的本地运行模式与服务发布拆分方式
8. 按目标项目情况补齐 `deploy/README.md`、环境变量和脚本实现
9. 基于本仓库的 SOP 生成该项目自己的部署规范

### Codex Skill

仓库内提供了一个主 skill：`deploy-baseline-kit`。

它适用于以下场景：

- 从空目录或近似空目录生成部署基线骨架
- 对已有项目做部署基线识别、差距分析和结构收敛
- 自动判断项目根目录、运行模式和数据库类型
- 在一次确认后完成生成或改造，而不是逐文件反复确认

这个 skill 的主入口在 `skills/deploy-baseline-kit/SKILL.md`，设计说明在 `docs/superpowers/specs/2026-03-26-monorepo-mixed-deployment-surfaces-design.md`，行为边界说明在 `docs/deploy-baseline-kit.md`。

当前仓库内与 skill 对齐更新的文档包括：

- `docs/README.md`
- `docs/deploy-baseline-kit.md`
- `skills/deploy-baseline-kit/references/document-generation.md`
- `template/deploy/README.md`

当前这套 skill 的增强重点包括：

- 改造后必须执行最低验证面，而不是只生成文件
- 对反向代理、systemd、CI/CD 等系统级配置默认采用 merge 或追加策略
- PostgreSQL 路线当前最稳定，其他数据库类型已纳入设计但仍待更多真实项目验证
- env 模板要求按关注点分组，并明确区分本地开发与生产部署

推荐用法：

1. 在目标项目根目录或其子目录中运行 Codex
2. 显式调用 `deploy-baseline-kit`
3. 先查看 skill 输出的识别结果和改造方案
4. 确认后再让它执行实际文件修改

如果要让本地 Codex 自动发现这个 skill，可将 `skills/deploy-baseline-kit/` 安装或链接到 `~/.codex/skills/deploy-baseline-kit`，然后重启 Codex。

如果本地 Codex 使用的是软链接方式安装，例如：

- `~/.codex/skills/deploy-baseline-kit -> /path/to/deploy-baseline/skills/deploy-baseline-kit`

那么后续只需要更新仓库里的 `skills/deploy-baseline-kit/`，本地安装目录就会自动跟随更新。通常只需要重启 Codex 或开启新会话，就能让新版本 skill 生效。

如果本地 Codex 使用的是直接复制安装，而不是软链接，那么每次更新仓库里的 skill 后，还需要手动把最新版本再次复制到 `~/.codex/skills/deploy-baseline-kit`。

当前更稳定、支持最完整的路线是 PostgreSQL 项目；其他数据库类型已经纳入设计，但仍以真实项目需求和后续验证为主。

建议的最低验证面至少包括：

- 按部署单元执行最低验证面（每个 unit 的验证面不同，不应按全仓库单一路径假定）
- 对 `self-hosted` 单元：`bash -n`（新增/修改过的 shell）、`docker compose config`（该单元纳入 Compose 时）、`make help`（命令面）、如果已有 `build/test/typecheck` 则执行、检查生产 Compose 的 `healthcheck`/env 引用与该单元回滚边界说明
- 对 `external-static-hosting` 单元：验证 build 命令与输出目录、路由/base path 假设、env 合约（build-time vs runtime）与托管说明（不默认 Dockerize）
- 对 `external-platform` 单元：验证 manifest/config、deploy/local-dev 命令、secrets/ownership 边界与 rollback boundary 文档化（不强制 Compose）

手工使用 `template/` 和使用 `deploy-baseline-kit` 并不冲突：

- `template/` 适合手工复制和定制
- `deploy-baseline-kit` 适合让 Codex 自动分析并生成/改造目标项目

### 统一命令约定

建议项目统一保留以下顶层入口：

- `make dev`
- `make build`
- `make test`
- `make deploy`
- `make rollback`
- `make logs`

项目可以扩展自己的子命令，但不应破坏这组统一入口。

建议为这些顶层命令赋予稳定语义：

- `make dev`：项目默认开发入口。负责启动标准开发环境；在全量 Docker 模式下通常拉起完整开发栈，在混合开发模式下至少拉起容器侧依赖，并明确本地还需启动哪些进程。
- `make build`：项目级默认构建入口。负责生成项目默认交付物，例如应用镜像、后端构建产物或前端静态资源。
- `make test`：项目级默认测试入口。负责执行项目的默认测试集合，而不是只跑某个子模块的局部测试。
- `make deploy`：标准发布入口。负责执行项目约定的发布链路；在 mixed-surface/monorepo 中可以按部署单元发布，并明确哪些单元不在该链路内。
- `make rollback`：标准回滚入口。回滚边界应按部署单元定义（镜像 tag / 制品版本 / Git ref / provider release）；对不可回滚或不纳入回滚链路的单元必须明确写在文档里。
- `make logs`：默认日志查看入口。负责查看项目主要应用服务的运行日志，而不是要求使用者先记住具体容器名。

除了顶层入口，项目也可以保留一组常见辅助命令，方便用户发现和单独执行某个环节：

- `make help`：显示所有可用命令与简要说明，建议作为命令发现入口。
- `make setup`：初始化本地开发环境依赖。
- `make init`：首次初始化入口，通常可复用 `setup`。
- `make up` / `make down`：单独启动或停止开发态容器。
- `make deploy-check`：执行部署前检查，例如 Docker、Compose、环境文件、关键变量和挂载策略检查。
- `make prod-up` / `make prod-down` / `make prod-logs`：面向生产态容器的兼容或显式操作入口。
- `make db-up` / `make db-down` / `make db-shell`：面向数据库容器的辅助入口。

如果项目包含多个子应用或独立子链路，也可以扩展更细的子命令，例如：

- `make build-admin`
- `make build-web`
- `make test-backend`
- `make migrate`
- `make seed`

这些子命令的定位应当是“补充说明具体环节”，而不是替代统一顶层入口。

回滚版本语义建议：

- 生产发布应优先使用不可变版本标识
- 容器镜像优先使用 Git Commit SHA 或语义化版本号作为 tag
- 不建议把 `latest` 作为生产发布和回滚依据
- `make rollback` 应显式回滚到某个具体版本，而不是“回到当前默认镜像”
- 在 mixed-surface/monorepo 中，回滚边界必须按部署单元明确（以及哪些单元被排除在回滚链路之外）

### 适用场景

- 需要为多个项目统一部署约定
- 想为团队建立一致的容器化交付骨架
- 希望新项目快速拥有基础开发、测试与部署入口
- 需要把部署经验沉淀为可复制模板而不是口头约定

### 开源协议

部署基线使用 `Apache-2.0` 协议。你可以在遵守协议的前提下自由使用、修改和分发。

## English

### What This Repository Is

This repository is not an application by itself. It is a reusable baseline that can be copied into real projects to standardize:

- top-level `Makefile` commands
- layered container deployment structure
- deployment documentation and SOPs
- bootstrap template for new projects

The baseline reflects patterns proven in real delivery work, including:

- hybrid local development with Dockerized backend and hot-reload frontend
- split deployment where backend is containerized and frontend is shipped as static assets
- preflight checks for stateful services
- startup contract variables and health-check conventions

### Repository Layout

- `docs/README.md`: document index and recommended reading order
- `docs/baseline-standard.md`: baseline standards and conventions
- `docs/deployment-sop.md`: generic deployment SOP
- `docs/deploy-baseline-kit.md`: behavior boundaries and stability notes for `deploy-baseline-kit`
- `docs/roadmap-v1.1.md`: next-stage optimization priorities and task checklist
- `skills/deploy-baseline-kit/`: Codex skill for generating or converging projects onto this deployment baseline
- `template/`: copyable project skeleton
- `template/deploy/`: deployment scripts, env examples, and deployment docs
- `template/scripts/`: placeholders for local development, build, and test scripts
- `fixtures/`: static fixture descriptions that anchor classification metadata ahead of runnable assets, with a `runnable/` subtree reserved for the future executable fixtures.

`fixtures/` stores static descriptions of candidate project shapes, their expected runtime modes, and the guidance the baseline should provide; repo-level verification commands will cover this area to keep the metadata and layout consistent while leaving space for the `runnable/` subtree to house executable fixtures later.

### Recommended Reading Order

Start with [docs/README.md](./docs/README.md).

Shortest path:

1. `docs/baseline-standard.md`
2. `docs/deployment-sop.md`
3. `docs/deploy-baseline-kit.md`
4. `docs/roadmap-v1.1.md`

### Verification Commands
- `make verify-fixtures-static`: Phase 1 currently focuses solely on static fixture metadata validation, ensuring each `fixture.md` under `fixtures/` advertises the required fields.
- `make verify-baseline`: The repository-level verification entry point that today delegates to the static fixture check but is ready to layer additional baseline checks once later phases expand the slice.

### What The Template Includes

- a standard `Makefile`
- a three-layer Compose structure
- local script directories
- deployment script directories
- deployment documentation templates
- GitHub Actions workflow templates

The template does not choose your application stack. It only provides a consistent engineering interface and deployment skeleton.

### Recommended Adoption Flow

1. Read `docs/baseline-standard.md`
2. Read `docs/deployment-sop.md`
3. Read `docs/deploy-baseline-kit.md` if you want Codex to inspect and transform the project for you
4. Review `docs/roadmap-v1.1.md` if you want the current improvement roadmap
5. Copy `template/` into the target project, or invoke `deploy-baseline-kit` from the target repo
6. Replace placeholders for project name, service name, image name, ports, and startup commands
7. Decide the local runtime model and deployment split for the target project
8. Fill in `deploy/README.md`, environment files, and script implementations
9. Derive a project-specific deployment standard from this baseline

### Codex Skill

This repository also ships one primary skill: `deploy-baseline-kit`.

Use it when you want Codex to:

- generate a deployment baseline from an empty or near-empty directory
- inspect an existing project and converge it toward this baseline
- infer the real project root, runtime mode, and database type
- present one plan first, then apply changes after a single confirmation

The main entry is `skills/deploy-baseline-kit/SKILL.md`, the design spec lives at `docs/superpowers/specs/2026-03-26-monorepo-mixed-deployment-surfaces-design.md`, and the runtime behavior notes live at `docs/deploy-baseline-kit.md`.

The repository docs kept in sync with the skill include:

- `docs/README.md`
- `docs/deploy-baseline-kit.md`
- `skills/deploy-baseline-kit/references/document-generation.md`
- `template/deploy/README.md`

The current enhancement focus for this skill is:

- enforce post-edit verification instead of stopping at file generation
- protect system-facing config such as reverse proxies, service units, and CI/CD files by defaulting to merge-style edits
- treat PostgreSQL as the most mature path today while keeping other database families as designed-but-still-validating paths
- keep env templates grouped by concern and clearly separated between local development and production deployment

Recommended usage:

1. Run Codex from the target project root or any child directory
2. Explicitly invoke `deploy-baseline-kit`
3. Review the detected state and proposed transformation plan
4. Confirm once, then let the skill apply the file changes

To make the skill auto-discoverable for a local Codex installation, install or symlink `skills/deploy-baseline-kit/` into `~/.codex/skills/deploy-baseline-kit`, then restart Codex.

If the local Codex installation uses a symlink, for example:

- `~/.codex/skills/deploy-baseline-kit -> /path/to/deploy-baseline/skills/deploy-baseline-kit`

then updating the repository copy under `skills/deploy-baseline-kit/` is enough. The local skill will follow automatically, and a Codex restart or a new session is usually enough to pick up the new version.

If the local Codex installation uses a copied directory instead of a symlink, you must manually copy the updated skill into `~/.codex/skills/deploy-baseline-kit` after repository updates.

The most stable and complete path today is PostgreSQL-based projects; other database families are designed for but still need more real-project validation.

The recommended minimum verification surface includes:

- per-unit verification paths (different unit types have different minimum checks; do not assume one repo-wide Compose-only path)
- for `self-hosted` units: `bash -n` (new/modified shell scripts), `docker compose config` (when that unit is in Compose), `make help` (command surface), existing `build/test/typecheck` when present, and production Compose `healthcheck`/env references plus the unit's rollback-boundary notes
- for `external-static-hosting` units: build command + output directory, routing/base-path assumptions, env contract (build-time vs runtime), and hosting notes (do not Dockerize by default)
- for `external-platform` units: manifest/config, deploy/local-dev commands, secrets/ownership boundaries, and rollback-boundary documentation (do not force Compose)

Manual use of `template/` and automated use of `deploy-baseline-kit` are complementary:

- `template/` is the direct copy-and-customize path
- `deploy-baseline-kit` is the analyze-and-generate or analyze-and-converge path

### Standard Command Contract

Projects are encouraged to keep these top-level commands:

- `make dev`
- `make build`
- `make test`
- `make deploy`
- `make rollback`
- `make logs`

Projects may extend the command set, but should preserve this common entry surface.

These top-level commands should keep stable meanings across projects:

- `make dev`: the default local development entry. In full Docker mode it usually starts the full dev stack; in hybrid mode it should at least start containerized dependencies and make the remaining local processes explicit.
- `make build`: the project-wide default build entry. It should produce the default deliverable, such as an app image, backend artifact, or frontend static bundle.
- `make test`: the project-wide default test entry. It should run the default test surface for the project, not just one narrow submodule.
- `make deploy`: the standard release entry for the project's defined deployment paths; in mixed-surface repos it may deploy one or more deployment units, and units outside the unified path must be explicitly documented.
- `make rollback`: the standard rollback entry. Rollback boundaries must be defined per deployment unit (image tag, artifact version, Git revision, provider release). Units that cannot be rolled back or are excluded from rollback must be explicitly documented.
- `make logs`: the default log-viewing entry for the main application service, so users do not need to memorize container names first.

Projects can also expose common helper commands so users can discover and run one step in isolation when needed:

- `make help`: list available commands and short descriptions; this should be the command discovery entry.
- `make setup`: initialize local development prerequisites.
- `make init`: first-time initialization entry, often reusing `setup`.
- `make up` / `make down`: start or stop development containers without running the full `dev` flow.
- `make deploy-check`: run pre-deployment checks for Docker, Compose, env files, critical variables, and persistence settings.
- `make prod-up` / `make prod-down` / `make prod-logs`: explicit or compatibility production-container operations.
- `make db-up` / `make db-down` / `make db-shell`: helper commands for database container operations.

If a project has multiple sub-apps or separate release tracks, it may also add narrower commands such as:

- `make build-admin`
- `make build-web`
- `make test-backend`
- `make migrate`
- `make seed`

These subcommands should clarify specific steps, not replace the shared top-level contract.

Rollback version semantics:

- production releases should prefer immutable version identifiers
- container images should prefer Git commit SHA or semantic version tags
- `latest` should not be used as the production release or rollback reference
- `make rollback` should target an explicit version, not an implicit default image
- in mixed-surface/monorepo repos, rollback boundaries should be explicit per unit (and exclusions should be documented)

### Good Fit For

- teams standardizing deployment conventions across multiple repositories
- projects that need a repeatable container delivery skeleton
- new services that need a quick starting point for development, testing, and deployment
- organizations turning deployment practice into reusable templates

### License

This project is licensed under `Apache-2.0`. See [`LICENSE`](./LICENSE) for details.
