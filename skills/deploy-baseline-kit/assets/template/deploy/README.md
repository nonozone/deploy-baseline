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
- 如果启用高级镜像部署，说明镜像仓库访问要求
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

- `deploy/env/app.env.example` 是唯一 canonical env 示例来源
- 本地开发默认使用 `deploy/env/app.dev.env`
- 真实生产变量来源
- `deploy/env/app.prod.env` 中哪些变量必须替换
- 哪些变量属于敏感信息
- 如果 `deploy/env/app.env.example` 新增了 active key，应如何执行 `make local-env-sync` / `make prod-env-sync` 或等价同步操作
- 如果项目后来引入了新的 env 分层或新的部署 env 文件，应如何先检查现有 env 配置并做迁移，而不是直接覆盖旧配置

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
make prod-env-sync
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

默认源码部署主链路：

- 在服务器 `git pull` 更新代码后，直接执行 `make deploy`
- `make deploy` 默认会在服务器本地执行 `docker compose build` + `docker compose up -d`

高级可选镜像部署：

- 可选使用 GitHub Actions 构建并推送镜像
- 在服务器执行 `DEPLOY_MODE=image DEPLOY_IMAGE=<image:tag> make deploy`

推荐约定：

- 默认部署模型是源码部署，不依赖镜像仓库
- 如果启用高级镜像部署，默认示例仓库使用 `GHCR`
- 如果启用高级镜像部署，镜像 tag 使用 `sha-<git-sha>` 或语义化版本号
- 不要依赖 `latest` 作为发布或回滚依据
- 部署后建议执行 `make prod-health`，排障时先看 `make prod-status`，确认版本时执行 `make prod-version`

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

默认源码回滚推荐执行方式：

```bash
ROLLBACK_REF=<git-tag-or-commit> make rollback
```

高级镜像回滚执行方式：

```bash
ROLLBACK_IMAGE=ghcr.io/<owner>/<repo>:sha-<git-sha> make rollback
```

推荐回滚后立即执行：

```bash
make prod-health
```

必须补充：

- 按部署单元定义的回滚单位
- 回滚命令
- 回滚后验证方式

推荐至少说明：

- 使用什么镜像 tag 规则
- 默认源码回滚使用什么 Git tag / Git Commit SHA 规则
- 是否使用 Git Commit SHA 或语义化版本号
- 为什么不能使用 `latest` 作为回滚依据
- 执行源码回滚时如何显式指定目标 ref
- 如果启用镜像回滚，执行时如何显式指定目标镜像版本
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

如果项目使用 `postgres:18` 或更高版本，建议额外明确写清：

- 不要再沿用 `17` 及以下常见的 `/var/lib/postgresql/data` 挂载方式
- 推荐把命名卷挂到 `/var/lib/postgresql`
- 推荐显式写出 `PGDATA=/var/lib/postgresql/18/docker`
- 升级或修复时，先执行 `docker inspect <container>` 确认挂载，再执行 `SELECT current_setting('data_directory');` 确认真实数据目录
- 如果已经出现随机匿名卷，应先停库、迁移数据到命名卷、验证无误后再删除旧卷

## 14. Provider 特有说明

如果项目包含 `external-platform` 或 `external-static-hosting` 单元，至少说明：

- provider 名称
- manifest/config 文件位置
- deploy/local dev 命令
- secrets 来源与归属边界
- CDN、DNS、缓存刷新或平台回滚限制

## 15. 第一次部署教程

建议按下面顺序执行，先保证“能成功一次”，再考虑优化。

### 15.1 第一次本地启动

```bash
make setup
make dev
```

说明：

- `make setup` 会基于 `deploy/env/app.env.example` 初始化本地环境，并补齐 `deploy/env/app.dev.env` 与 `deploy/env/app.prod.env` 缺失项
- 如果检测到历史遗留的根目录 `.env` 且 `deploy/env/app.dev.env` 尚不存在，会自动复制一份用于平滑迁移
- `make dev` 会以前台方式启动开发环境，并在进入持续日志前统一显示应用首页、健康检查和 PostgreSQL 入口
- 如果 `deploy/env/app.env.example` 后续新增了变量，可再次执行 `make local-env-sync`

### 15.2 第一次准备生产环境变量

```bash
make prod-env-sync
```

然后至少确认以下内容已替换成真实值：

- `deploy/env/app.prod.env` 中的 `DB_PASSWORD`
- 其他项目实际需要的 secrets 或 provider 配置
- 如果启用高级镜像部署，再额外确认 `deploy/env/app.prod.env` 中的 `APP_IMAGE`

### 15.3 第一次手动部署

在服务器更新代码后执行：

```bash
git pull
make deploy-check
make deploy
make prod-health
make prod-version
```

如果要显式指定源码版本，建议先切到目标代码后再执行：

```bash
git checkout <git-tag-or-commit>
make deploy
```

如果要走高级镜像部署：

```bash
DEPLOY_MODE=image DEPLOY_IMAGE=ghcr.io/<owner>/<repo>:sha-<git-sha> make deploy
```

### 15.4 第一次通过 CI 部署

这属于高级可选链路，不是默认新手路径。

确保仓库已配置：

- `DEPLOY_HOST`
- `DEPLOY_USER`
- `DEPLOY_PATH`
- `SSH_PRIVATE_KEY`
- `APP_PROD_ENV`

然后推送到 `main`，CI 会：

1. 构建镜像并推送到 `GHCR`
2. SSH 到服务器
3. 执行 `make deploy-check`
4. 执行 `DEPLOY_MODE=image DEPLOY_IMAGE=<image:tag> make deploy`
5. 执行 `make prod-health`

### 15.5 第一次回滚

```bash
ROLLBACK_REF=<old-git-tag-or-commit> make rollback
make prod-health
make prod-version
```

如果你启用了高级镜像部署，也可以执行：

```bash
ROLLBACK_IMAGE=ghcr.io/<owner>/<repo>:sha-<old-git-sha> make rollback
```

## 16. 常见故障排查

新手建议按这个顺序排查，不要一上来就改脚本：

```bash
make prod-status
make prod-health
make prod-version
make prod-logs
```

至少覆盖：

- 环境文件缺失
- 端口冲突
- 容器启动失败
- 健康检查失败
- 数据库未就绪

### 16.1 `make deploy-check` 失败

优先检查：

- `deploy/env/app.prod.env` 是否存在
- `DB_PASSWORD` 是否为空，或仍是旧模板占位值
- `docker compose config -q` 是否报错
- 如果是 PostgreSQL 18，执行 `make prod-pg-check` 确认挂载点是否为 `/var/lib/postgresql`
- 如果启用高级镜像部署，再检查 `APP_IMAGE` 是否为空、仍是 `sampleapp:*`，或仍指向错误镜像 tag

### 16.2 `make deploy` 失败

优先检查：

- 服务器是否能访问镜像仓库
- 目标镜像 tag 是否真实存在
- `make prod-health` 是否失败
- `make prod-logs` 中是否有启动异常

### 16.3 `make prod-health` 失败

优先检查：

- 应用是否真正监听了 `APP_INTERNAL_PORT`
- 健康检查路径是否与 `APP_HEALTHCHECK_PATH` 一致
- 数据库是否可达
- 应用是否因为缺少环境变量而启动失败

### 16.4 想确认线上到底跑的是哪个版本

执行：

```bash
make prod-version
```

### 16.5 回滚后还不正常

优先检查：

- 回滚镜像 tag 是否正确
- 回滚后的数据库状态是否仍兼容旧代码
- `make prod-health` 是否通过
- `make prod-logs` 是否显示旧版本仍然启动失败

## 17. 项目特有说明

把这个项目自己的特殊部署前置条件、依赖或限制写在这里。
