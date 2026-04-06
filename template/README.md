# 通用模板骨架说明

这个模板目录用于复制到新项目中作为初始骨架。

复制后需要至少完成以下动作：

1. 先确定项目采用“全量 Docker”还是“混合开发”模式
2. 先确定哪些服务归 `make deploy` 管理，哪些服务独立发布
3. 替换项目名、服务名、镜像名
4. 替换 `scripts/` 与 `deploy/scripts/` 中的占位逻辑
5. 根据项目实际情况补齐 `deploy/README.md`
6. 填写 `.env.example` 与 `deploy/env/*.example`

模板默认提供：

- 标准 `Makefile`
- 三层 Compose 结构
- 本地脚本目录
- 部署脚本目录
- 中文部署文档模板
- GitHub Actions 工作流模板

使用要求：

- 不要在没定义运行模式前直接套模板
- 不要默认所有服务都用同一条部署链路
- 必须把启动契约、健康检查、回滚边界写清楚
- 必须在接入后执行最低验证面，而不是只生成文件
- 默认不要整文件覆盖系统级配置，例如反向代理、systemd、CI/CD 文件

模板里的 `Makefile` 默认提供两层命令：

- 顶层统一入口：`make dev`、`make build`、`make test`、`make deploy`、`make rollback`、`make logs`
- 常见辅助入口：`make help`、`make setup`、`make init`、`make local-env-sync`、`make prod-env-sync`、`make up`、`make down`、`make deploy-check`、`make prod-up`、`make prod-down`、`make prod-logs`、`make prod-status`、`make prod-health`、`make prod-version`、`make pg-check`、`make prod-pg-check`、`make db-up`、`make db-down`、`make db-shell`

建议先把顶层统一入口的语义定义清楚，再决定哪些辅助命令需要保留、裁剪或扩展。

### Shell 补全

如果你希望在 `zsh` 或 `bash` 里输入 `make <Tab>` 时看到命令提示，模板默认提供：

- `scripts/make-completion.sh`

临时启用：

```bash
source scripts/make-completion.sh
```

长期启用可加入你的 shell 配置：

```bash
# bash
echo 'source /path/to/project/scripts/make-completion.sh' >> ~/.bashrc

# zsh
echo 'source /path/to/project/scripts/make-completion.sh' >> ~/.zshrc
```

说明：

- 该脚本会从当前项目 `Makefile` 中提取带 `##` 说明的 target
- 因此新增命令后，重新 `source scripts/make-completion.sh` 即可刷新补全
- `zsh` 需要已有 `compinit` / `compdef` 环境；大多数默认配置已自带

模板里的 GitHub Actions 默认提供：

- `.github/workflows/ci.yml`：执行 `make build` / `make test`
- `.github/workflows/deploy.yml`：可选的 GHCR 镜像部署示例，默认仅手动触发

其中 `deploy.yml` 默认带“静默跳过”门槛：

- 如果未配置部署所需 Secrets，workflow 会给出 warning 并跳过部署
- 不会因为新项目尚未配置远端环境而直接报错失败

默认要求的 Secrets 包括：

- `DEPLOY_HOST`
- `DEPLOY_USER`
- `DEPLOY_PATH`
- `SSH_PRIVATE_KEY`
- `APP_PROD_ENV`

可选项：

- `DEPLOY_SSH_PORT`

默认部署主链路：

- 本地开发继续使用 `make dev`
- 服务器默认执行 `git pull && make deploy`
- `make deploy` 默认走源码部署：服务器本地执行 `docker compose build` + `docker compose up -d`
- `make rollback` 默认支持 `ROLLBACK_REF=<git-tag-or-commit> make rollback`
- 生产排障入口建议使用 `make prod-status`、`make prod-health`、`make prod-version`、`make prod-logs`

高级可选链路：

- 可选保留 `GHCR` 镜像部署
- 模板提供 `.github/workflows/deploy.yml` 作为高级示例
- 镜像部署需显式使用 `DEPLOY_MODE=image`
- 镜像回滚需显式使用 `ROLLBACK_IMAGE=<image:tag> make rollback`

推荐先掌握的核心命令：

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

建议的新手使用顺序：

- 第一次本地启动：`make setup` → `make dev`
- 环境变量模板更新后：`make local-env-sync` / `make prod-env-sync`
- 排查 PostgreSQL 真实数据目录：`make pg-check` / `make prod-pg-check`
- 发布前：`make deploy-check`
- 发布后排查：`make prod-status` → `make prod-health` → `make prod-version` → `make prod-logs`

v1 边界定义：

- 这是一个面向新手和 vibe coding 场景的部署基线，不是大厂级部署平台
- v1 的目标是：简单、默认安全、能部署、能回滚、能排障
- v1 默认主链路是：本地 `make dev`，服务器 `git pull && make deploy`
- v1 保留 `GHCR` 镜像发布作为高级可选方案，而不是默认起点
- v1 到此为止的重点能力，就是上面的核心命令集

v1 明确不做：

- 不做 Kubernetes / Helm / Terraform
- 不做蓝绿、金丝雀、自动回滚
- 不做多云 / 多 provider 抽象层
- 不做复杂 secrets 平台或 Web 管理后台
- 不为了“更像大厂”继续堆高复杂度

如果要继续演进，也应优先补“更清楚的 README / 教程 / 故障排查”，而不是先扩展更多部署模型。

版本与回滚建议：

- 默认源码部署应保证服务器可直接基于当前代码执行构建
- 默认回滚建议使用 Git tag 或 Git Commit SHA
- 如果启用高级镜像部署，`APP_IMAGE` 不应长期保留 `latest` 风格
- 如果启用高级镜像部署，建议使用 `ghcr.io/<owner>/<repo>:sha-<git-sha>` 或 `ghcr.io/<owner>/<repo>:<semver>`
- 部署文档中必须写清源码回滚规则，若启用镜像部署也必须写清镜像 tag 规则和回滚验证方式

PostgreSQL 18 数据卷注意事项：

- `postgres:18-alpine` 不应再把命名卷挂到 `/var/lib/postgresql/data`
- 推荐把命名卷挂到 `/var/lib/postgresql`，并显式设置 `PGDATA=/var/lib/postgresql/18/docker`
- 否则 Docker 可能会因为镜像的 `VOLUME /var/lib/postgresql` 自动补一个匿名卷，导致真数据落进随机卷
- 如果历史项目已出现随机卷，先用 `docker inspect` 和 `SELECT current_setting('data_directory');` 确认真数据目录，再迁移卷，不要直接删卷
- 模板默认提供 `make pg-check` / `make prod-pg-check`，可直接查看当前挂载、`PGDATA` 和 `data_directory`

env 模板建议：

- 按 project/runtime、database、publish ports、auth/secrets、provider-specific、observability/verification 分组
- `.env.example` 面向第一次本地接入，尽量只保留最小本地入口变量
- `deploy/env/*.env.example` 面向部署运行时
- 数据库和其他运行时细节优先放在 `deploy/env/*.env.example`
- 敏感值默认留空；可选高级镜像部署变量也默认留空，需要时再手动填写固定 tag
- 非敏感默认值可以保留可运行示例，外部非敏感地址可以使用 `example.com` 风格示例
- 如果 `.env.example` 或 `deploy/env/app.prod.env.example` 后续新增了 active key：本地 `.env` 可运行 `make local-env-sync` 非破坏性补齐；生产 `deploy/env/app.prod.env` 可运行 `make prod-env-sync` 非破坏性补齐；两者都不会覆盖已有值
- 如果项目准备引入新的 `.env` 分层或新的部署 env 文件，必须先检查现有 env 配置并做合理迁移，不能直接用模板覆盖旧 `.env` 或现有 deploy env 文件

模板不会替你决定项目技术栈，只负责提供统一工程接口。
