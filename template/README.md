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
- 常见辅助入口：`make help`、`make setup`、`make init`、`make up`、`make down`、`make deploy-check`、`make prod-up`、`make prod-down`、`make prod-logs`、`make db-up`、`make db-down`、`make db-shell`

建议先把顶层统一入口的语义定义清楚，再决定哪些辅助命令需要保留、裁剪或扩展。

模板里的 GitHub Actions 默认提供：

- `.github/workflows/ci.yml`：执行 `make build` / `make test`
- `.github/workflows/deploy.yml`：在 `push main` 时尝试自动部署

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

版本与回滚建议：

- `APP_IMAGE` 不应长期保留 `latest` 风格
- 正式接入时，建议改为 `your-image:<git-sha>` 或 `your-image:<semver>`
- `make rollback` 应显式指定要回滚到的镜像版本
- 部署文档中必须写清镜像 tag 规则和回滚验证方式

env 模板建议：

- 按 project/runtime、database、publish ports、auth/secrets、provider-specific、observability/verification 分组
- `.env.example` 面向本地开发
- `deploy/env/*.env.example` 面向部署运行时

模板不会替你决定项目技术栈，只负责提供统一工程接口。
