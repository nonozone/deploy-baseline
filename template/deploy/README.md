# 项目部署规范

> 这个文件是项目自己的部署文档入口，编写时应遵守通用部署 SOP。

## 1. 适用范围

说明这个部署文档适用于哪个环境、哪些部署单元、哪些角色。

## 2. 部署单元矩阵

至少说明：

- 部署单元名称
- 对应代码路径
- public surface（域名、子域名、路由或 `internal`）
- runtime
- hosting mode（`self-hosted` / `external-static-hosting` / `external-platform`）
- deploy command
- rollback unit
- baseline action

如果是单项目仓库，也建议明确写成“一行矩阵”，避免文档默认假定未来永远只有一个部署面。

## 3. 前置条件

至少说明：

- 服务器要求
- Docker 与 Compose 版本要求
- 部署用户与目录要求
- 镜像仓库访问要求
- provider CLI 或平台权限要求（如果存在）

## 4. 本地运行模式说明

必须说明当前仓库的本地运行方式，尤其是 `self-hosted` 部署单元采用哪一种方式：

- 全量 Docker
- 混合开发

如果是混合开发，还要补充：

- 哪些服务走 Docker
- 哪些服务本地运行
- `make dev` 会启动哪些部署单元或依赖
- 哪些部署单元被排除在 `make dev` 之外
- 开发人员还需要额外执行哪些命令

## 5. 服务发布拆分说明

至少说明：

- 哪些部署单元归 `make deploy` 管理
- 哪些部署单元独立发布
- 哪些部署单元不进入 Compose
- 哪些部署单元由 provider 托管
- 数据库是否和应用共用同一套 Compose

## 6. 目录与文件约定

至少说明：

- 项目部署目录
- 环境文件位置
- 数据目录或命名卷策略
- 日志查看方式

## 7. 环境变量说明

至少说明：

- 真实生产变量来源
- `deploy/env/app.prod.env` 中哪些变量必须替换
- 哪些变量属于敏感信息
- 如果 `deploy/env/app.prod.env.example` 新增了 active key，应如何执行 `make env-sync` 或等价同步操作

建议按关注点分组说明：

- project / runtime
- database
- publish ports
- auth / secrets
- provider-specific config
- observability / verification

## 8. 部署前检查

标准入口：

```bash
make deploy-check
```

如示例文件结构有更新，建议先执行：

```bash
make env-sync
```

如果项目包含数据库或存储，还应说明是否存在额外自检脚本，例如：

- 持久化目录检查
- 命名卷检查
- 运行中挂载检查

建议同时说明最低验证面，例如：

- `bash -n` 检查部署脚本
- 对 `self-hosted` 单元执行 `docker compose config`
- `make help` 检查命令面
- 如果项目已有 `build/test/typecheck`，说明是否执行
- 对静态托管单元说明 build 输出目录、路由/base path 与 env contract 的校验方式
- 对 provider-managed 单元说明 manifest/config、deploy 命令和 secrets 文档的校验方式

## 9. 标准发布流程

标准入口：

```bash
make deploy
```

需要明确写出项目是否还需要：

- 数据库迁移
- 静态资源发布
- 缓存预热
- 网关刷新
- provider 平台单独发布

## 10. 启动契约与发布完成判定

至少说明：

- 是否等待数据库就绪
- 是否自动执行数据库迁移
- 启动契约变量有哪些
- 什么条件下可以认为发布完成

建议至少覆盖：

- `WAIT_FOR_DB`
- `RUN_DB_MIGRATIONS`
- `DB_WAIT_TIMEOUT`
- `APP_INTERNAL_PORT`
- `APP_HEALTHCHECK_PATH`
- `APP_HEALTHCHECK_TIMEOUT`

推荐默认约定：

- 健康检查路径使用 `/health`
- 成功标准为返回 `200`
- 发布完成至少要求应用容器进入 healthy 状态

如果项目包含数据库迁移，还应写清回滚边界，避免把“代码可回滚”误写成“全量无损回滚”。

如果某些部署单元不是 `self-hosted`，需要明确说明它们不适用这一节的哪些约束。

## 11. 日志与健康检查

建议至少写清：

- 查看哪个服务日志
- 使用什么命令
- 健康检查接口是什么
- 发布完成后如何确认服务可用
- 对外部平台或静态站，如何确认发布完成

如果沿用模板默认约定，建议明确说明：

- 应用容器健康检查依赖 `/health`
- `make deploy` 执行后会等待应用进入 healthy 状态
- 如果超时或 unhealthy，应先查看应用日志再继续排查

## 12. 回滚流程

标准入口：

```bash
make rollback
```

必须补充：

- 按部署单元定义的回滚单位
- 回滚命令
- 回滚后验证方式

推荐至少说明：

- 使用什么镜像 tag 规则
- 是否使用 Git Commit SHA 或语义化版本号
- 为什么不能使用 `latest` 作为回滚依据
- 执行回滚时如何显式指定目标版本
- 哪些部署单元被排除在自托管回滚链路之外

如果项目包含数据库或状态型服务，建议额外说明：

- 是否存在 major version 相关部署陷阱
- 是否需要在修改挂载路径前先备份
- 回滚是否仅限代码层或镜像层

## 13. 持久化与卷说明

至少覆盖：

- 命名卷
- bind mount
- 数据路径
- major version 相关存储注意事项
- 修改挂载策略前是否必须备份

## 14. Provider 特有说明

如果项目包含 `external-platform` 或 `external-static-hosting` 单元，至少说明：

- provider 名称
- manifest/config 文件位置
- deploy/local dev 命令
- secrets 来源与归属边界
- CDN、DNS、缓存刷新或平台回滚限制

## 15. 常见故障排查

至少覆盖：

- 环境文件缺失
- 端口冲突
- 容器启动失败
- 健康检查失败
- 数据库未就绪

## 16. 项目特有说明

把这个项目自己的特殊部署前置条件、依赖或限制写在这里。
