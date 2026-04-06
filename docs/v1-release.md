# Deploy Baseline v1 发布说明

## 这是什么

`Deploy Baseline v1` 是一套面向新手、尤其是刚开始使用 vibe coding 的开发者的部署基线。

当前稳定发布版本是 `v1.1.0`，已于 `2026-04-06` 发布：

- `https://github.com/nonozone/deploy-baseline/releases/tag/v1.1.0`

它不是大厂级部署平台，也不是一个要覆盖所有基础设施场景的系统。它的目标更简单：

- 给新项目一个统一、清楚、可复制的部署起点
- 让第一次部署的人也能按文档走通
- 在部署失败时，知道应该看什么命令、看哪里
- 在上线后，至少具备基础的回滚和排障能力

## 适合谁

这套基线特别适合以下场景：

- 第一次把项目部署到服务器的新手
- 会写代码，但没有系统部署经验的开发者
- 使用 vibe coding 快速做出产品原型后，想补上基础工程流程的人
- 想给多个项目复用一套简单部署骨架的个人开发者或小团队

## v1 提供什么

v1 默认提供一条统一的主链路：

- 本地继续使用 `make dev`
- 服务器默认执行 `git pull` 后再运行 `make deploy`
- 默认部署通过服务器本地 `docker compose build` + `docker compose up -d` 完成
- `GHCR` 镜像发布保留为高级可选方案，而不是默认起点

v1 的核心命令如下：

```bash
make setup
make local-env-sync
make prod-env-sync
make dev
make deploy-check
make deploy
make rollback
make prod-status
make prod-health
make prod-version
make prod-logs
```

## 为什么是这些命令

这组命令覆盖了新手最常遇到的完整闭环：

- 本地启动：`make setup`、`make dev`
- 环境变量同步：`make local-env-sync`、`make prod-env-sync`
- 上线前检查：`make deploy-check`
- 发布与回滚：`make deploy`、`make rollback`
- 上线后排查：`make prod-status`、`make prod-health`、`make prod-version`、`make prod-logs`

目标不是让命令越来越多，而是让第一次接触部署的人能记住一小组稳定入口。

## v1 不追求什么

v1 明确不追求“大而全”。

它不打算在这个阶段支持：

- Kubernetes / Helm / Terraform
- 蓝绿发布、金丝雀发布、自动回滚
- 多云 / 多 provider 抽象层
- 复杂 secrets 平台
- Web 管理界面
- 大厂级发布治理与审计系统

如果一个功能会明显增加新手理解成本，而不能显著提升“第一次成功部署”的概率，那么它就不属于 v1。

## 现在已经具备的能力

当前 v1 已经具备：

- 统一的 `Makefile` 命令面
- 本地和生产环境变量的非破坏性同步
- 部署前检查
- 默认源码部署
- 默认 Git ref 回滚
- 可选镜像发布式部署
- 生产状态 / 健康 / 版本 / 日志排查命令
- 第一次部署教程
- 常见故障排查指南
- 可安装的 `deploy-baseline-kit` skill 产品入口
- 基于 `src/` 单一真源的模板、文档与规则打包链路

## 已知边界

在真实项目接入时，仍然需要你补上项目自己的内容，例如：

- 真实的 `Dockerfile`
- 应用启动命令
- 数据库迁移逻辑
- 项目特有的 secrets
- 项目自己的 `deploy/README.md`

也就是说，这套基线负责的是“统一骨架”和“默认流程”，不是替你决定业务项目的全部实现细节。

## 推荐阅读

如果你是第一次来到这个仓库，建议按这个顺序看：

1. `docs/v1-release.md`
2. `docs/deploy-baseline-kit.md`
3. `docs/baseline-standard.md`
4. `docs/deployment-sop.md`
5. `skills/deploy-baseline-kit/SKILL.md`

## 一句话总结

`Deploy Baseline v1` 的定位不是“更复杂”，而是“更容易正确地开始”。
