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
