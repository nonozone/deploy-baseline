# 容器部署与 Make 通用基线规范

## 1. 目标

这份规范用于统一不同项目的容器部署方式、环境变量管理方式和 `Makefile` 操作入口。

目标不是约束项目技术栈，而是统一工程接口，确保团队在切换项目时：

- 目录结构容易识别
- 常用命令保持一致
- 部署文档格式一致
- 新项目能快速复制落地

## 2. 适用范围

这套规范适用于以下类型项目：

- 使用 Docker Compose 管理本地开发环境或生产部署
- 使用 `make` 统一开发、构建、测试或部署入口
- 存在一个或多个应用服务，并可能依赖数据库、缓存、前端、Worker 或网关

不限制后端语言和前端框架，但要求在工程接口层遵守同一套命名规则。

## 3. 核心原则

### 3.1 命令接口统一

不同项目必须尽量收敛为相同的顶层命令。最少应保留：

- `make dev`
- `make build`
- `make test`
- `make deploy`
- `make rollback`
- `make logs`

项目可以保留扩展命令，例如：

- `make db-reset`
- `make migrate`
- `make seed`
- `make build-admin`
- `make build-web`

但扩展命令不能替代统一顶层命令。

### 3.2 容器负责运行环境统一

容器和 Compose 文件负责描述：

- 服务如何启动
- 服务之间如何依赖
- 端口如何暴露
- 数据如何持久化
- 健康检查如何执行

不要把运行环境约定分散写进 README 或随手脚本中。

### 3.3 Make 负责操作入口统一

`Makefile` 的职责是暴露操作入口，不是承载复杂实现逻辑。

规则如下：

- `Makefile` 只做命令收口
- 复杂逻辑下沉到 `scripts/` 或 `deploy/scripts/`
- 每个 target 必须带中文说明
- 必须提供 `make help`

### 3.4 文档与模板分离

规范文档负责定义标准，模板负责提供默认实现。

不要把“项目说明”“规范说明”“模板使用说明”混写在一个 README 中。

### 3.5 渐进迁移

旧项目不要求一次性完全重构。

建议迁移顺序：

1. 先统一命令名
2. 再统一 Compose 分层
3. 再统一环境变量来源
4. 最后统一部署文档与回滚流程

## 4. 标准目录结构

建议项目按以下结构组织：

```text
project-root/
├── Makefile
├── .env.example
├── docker-compose.yml
├── docker-compose.dev.yml
├── docker-compose.prod.yml
├── deploy/
│   ├── README.md
│   ├── env/
│   │   ├── app.env.example
│   │   └── app.prod.env.example
│   └── scripts/
│       ├── preflight.sh
│       ├── deploy.sh
│       └── rollback.sh
├── scripts/
│   ├── setup.sh
│   ├── dev.sh
│   ├── build.sh
│   └── test.sh
└── docs/
    └── engineering/
        └── deployment-baseline.md
```

## 5. 文件职责

### 5.1 `Makefile`

负责统一入口：

- 开发
- 构建
- 测试
- 部署
- 回滚
- 日志

不建议把长命令、复杂条件判断、业务流程直接塞进 `Makefile`。

### 5.2 `docker-compose.yml`

负责放跨环境共享内容，通常包括：

- 数据库
- 缓存
- 公共 volume
- 公共 network
- 可复用的基础 service 定义

### 5.3 `docker-compose.dev.yml`

负责放开发态差异，例如：

- 热更新
- 本地源码挂载
- 调试开关
- 本地端口暴露

### 5.4 `docker-compose.prod.yml`

负责放生产态差异，例如：

- 发布端口
- 重启策略
- 持久化目录
- 生产环境变量
- 健康检查

### 5.5 `.env.example`

负责本地开发变量示例，不放真实敏感信息。

### 5.6 `deploy/env/*.example`

负责部署阶段变量示例，强调部署变量与本地开发变量分层管理。

### 5.7 `scripts/`

负责本地开发与构建辅助脚本。

### 5.8 `deploy/scripts/`

负责部署前检查、部署、回滚等线上操作脚本。

### 5.9 `deploy/README.md`

负责项目自己的部署说明文档。文档结构应遵守通用部署 SOP。

## 6. Compose 分层规则

推荐采用三层结构：

### 6.1 基础层

`docker-compose.yml`

作用：

- 定义跨环境共享服务
- 定义命名卷
- 定义默认网络

### 6.2 开发层

`docker-compose.dev.yml`

作用：

- 叠加开发模式特有服务
- 叠加开发端口与源码挂载
- 叠加本地调试参数

### 6.3 生产层

`docker-compose.prod.yml`

作用：

- 叠加生产发布配置
- 叠加持久化策略
- 叠加健康检查与重启策略

## 7. 环境变量规则

### 7.1 分层原则

环境变量至少分为两层：

1. 本地开发变量
2. 部署运行变量

需要时可以继续拆分：

- 构建变量
- 预发布变量
- 生产敏感变量

### 7.2 约束规则

- 本地开发变量放在 `.env.example`
- 部署变量样例放在 `deploy/env/*.example`
- 敏感信息不能提交进仓库
- Compose 文件只引用变量，不写死密钥
- 能提供默认值的变量，应明确写出默认值来源

### 7.3 命名建议

- 端口统一使用 `*_PORT`
- 监听地址或发布地址统一使用 `*_HOST` 或 `*_URL`
- 生产发布 IP 和端口单独定义，例如 `APP_PUBLISH_IP`、`APP_PUBLISH_PORT`
- 布尔值显式写为 `true` 或 `false`

## 8. 标准命令约束

建议统一保留以下命令族：

### 8.1 初始化类

- `make setup`
- `make init`

### 8.2 开发类

- `make dev`
- `make up`
- `make down`
- `make logs`

### 8.3 质量类

- `make test`
- `make build`

需要时可补充：

- `make lint`
- `make check`
- `make ci`

### 8.4 部署类

- `make deploy-check`
- `make deploy`
- `make rollback`

## 9. 项目允许扩展的边界

项目可以扩展：

- 多个前端服务
- 多个 Worker
- 反向代理
- 独立的构建 target
- 更复杂的部署脚本

但必须保留：

- 标准文件名
- 标准顶层命令
- 标准部署文档结构

## 10. 项目接入方式

新项目接入建议按下面顺序执行：

1. 复制模板目录
2. 替换项目名、服务名、镜像名、端口
3. 替换模板脚本中的占位启动命令
4. 填写 `.env.example` 和 `deploy/env/*.example`
5. 补写项目自己的 `deploy/README.md`
6. 验证 `make dev`、`make build`、`make test`、`make deploy`

旧项目接入建议按下面顺序执行：

1. 先统一命令命名
2. 再拆 Compose 分层
3. 再整理环境变量来源
4. 最后对齐部署文档

## 11. 禁止事项

以下做法不建议继续使用：

- 把复杂发布逻辑直接写进 `Makefile`
- 同时用一份真实 env 文件服务开发和生产
- 在 Compose 文件中写死密钥
- 每个项目自己发明一套顶层命令
- 只写操作说明，不提供可执行脚本

## 12. 交付要求

一套合格的项目基线，至少要满足：

- 开发、构建、测试、部署、回滚命令明确
- Compose 分层清晰
- 本地和部署变量分离
- 部署文档可执行
- 模板可复制
- 文档全部使用中文
