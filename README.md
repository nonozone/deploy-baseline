# Deploy Baseline

[中文](#中文说明) | [English](#english)

部署基线：一套可迁移的容器部署与 `Make` 通用基线，用于在不同项目之间复用一致的开发、构建、测试与部署入口。

Deploy Baseline is a reusable deployment baseline for containerized projects. It provides a consistent `Make`-based interface, layered Docker Compose structure, deployment SOPs, and a copyable project template.

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

- `docs/baseline-standard.md`：通用基线规范
- `docs/deployment-sop.md`：通用部署 SOP
- `skills/deploy-baseline-kit/`：用于识别项目并生成/收敛部署基线的 Codex skill
- `template/`：可复制到新项目中的模板骨架
- `template/deploy/`：部署目录、示例环境变量和脚本
- `template/scripts/`：本地开发、构建、测试等脚本占位

### 模板默认提供

- 标准 `Makefile`
- 三层 Compose 结构
- 本地脚本目录
- 部署脚本目录
- 中文部署文档模板

模板不会替你决定业务技术栈，只负责提供统一工程接口与部署骨架。

### 建议使用方式

1. 先阅读 `docs/baseline-standard.md`
2. 再阅读 `docs/deployment-sop.md`
3. 复制 `template/` 到目标项目
4. 替换模板中的项目名、服务名、镜像名、端口和启动命令
5. 明确目标项目采用的本地运行模式与服务发布拆分方式
6. 按目标项目情况补齐 `deploy/README.md`、环境变量和脚本实现
7. 基于本仓库的 SOP 生成该项目自己的部署规范

### Codex Skill

仓库内提供了一个主 skill：`deploy-baseline-kit`。

它适用于以下场景：

- 从空目录或近似空目录生成部署基线骨架
- 对已有项目做部署基线识别、差距分析和结构收敛
- 自动判断项目根目录、运行模式和数据库类型
- 在一次确认后完成生成或改造，而不是逐文件反复确认

这个 skill 的主入口在 `skills/deploy-baseline-kit/SKILL.md`，设计说明在 `docs/superpowers/specs/2026-03-23-deploy-baseline-kit-design.md`。

推荐用法：

1. 在目标项目根目录或其子目录中运行 Codex
2. 显式调用 `deploy-baseline-kit`
3. 先查看 skill 输出的识别结果和改造方案
4. 确认后再让它执行实际文件修改

如果要让本地 Codex 自动发现这个 skill，可将 `skills/deploy-baseline-kit/` 安装或链接到 `~/.codex/skills/deploy-baseline-kit`，然后重启 Codex。

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

- `docs/baseline-standard.md`: baseline standards and conventions
- `docs/deployment-sop.md`: generic deployment SOP
- `skills/deploy-baseline-kit/`: Codex skill for generating or converging projects onto this deployment baseline
- `template/`: copyable project skeleton
- `template/deploy/`: deployment scripts, env examples, and deployment docs
- `template/scripts/`: placeholders for local development, build, and test scripts

### What The Template Includes

- a standard `Makefile`
- a three-layer Compose structure
- local script directories
- deployment script directories
- deployment documentation templates

The template does not choose your application stack. It only provides a consistent engineering interface and deployment skeleton.

### Recommended Adoption Flow

1. Read `docs/baseline-standard.md`
2. Read `docs/deployment-sop.md`
3. Copy `template/` into the target project
4. Replace placeholders for project name, service name, image name, ports, and startup commands
5. Decide the local runtime model and deployment split for the target project
6. Fill in `deploy/README.md`, environment files, and script implementations
7. Derive a project-specific deployment standard from this baseline

### Codex Skill

This repository also ships one primary skill: `deploy-baseline-kit`.

Use it when you want Codex to:

- generate a deployment baseline from an empty or near-empty directory
- inspect an existing project and converge it toward this baseline
- infer the real project root, runtime mode, and database type
- present one plan first, then apply changes after a single confirmation

The main entry is `skills/deploy-baseline-kit/SKILL.md`, and the design spec lives at `docs/superpowers/specs/2026-03-23-deploy-baseline-kit-design.md`.

Recommended usage:

1. Run Codex from the target project root or any child directory
2. Explicitly invoke `deploy-baseline-kit`
3. Review the detected state and proposed transformation plan
4. Confirm once, then let the skill apply the file changes

To make the skill auto-discoverable for a local Codex installation, install or symlink `skills/deploy-baseline-kit/` into `~/.codex/skills/deploy-baseline-kit`, then restart Codex.

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

### Good Fit For

- teams standardizing deployment conventions across multiple repositories
- projects that need a repeatable container delivery skeleton
- new services that need a quick starting point for development, testing, and deployment
- organizations turning deployment practice into reusable templates

### License

This project is licensed under `Apache-2.0`. See [`LICENSE`](./LICENSE) for details.
