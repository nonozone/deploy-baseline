# 容器部署与 Make 通用基线包

这个目录是一套可整体迁移的通用资产，和当前项目业务代码无关。

用途：

- 统一各项目的 `Makefile` 顶层命令
- 统一容器部署分层方式
- 统一部署规范的文档结构
- 提供一套可复制后再按项目替换的模板骨架

目录说明：

- `docs/baseline-standard.md`：通用基线规范
- `docs/deployment-sop.md`：通用部署 SOP
- `template/`：可复制的模板骨架

建议使用方式：

1. 先阅读 `docs/baseline-standard.md`
2. 再阅读 `docs/deployment-sop.md`
3. 复制 `template/` 到新项目
4. 按模板中的占位符替换项目名、服务名、镜像名、端口和启动命令
5. 在目标项目中基于本 SOP 生成项目自己的部署规范

统一顶层命令建议固定为：

- `make dev`
- `make build`
- `make test`
- `make deploy`
- `make rollback`
- `make logs`

项目可以扩展自己的子命令，但不应破坏这组统一入口。
