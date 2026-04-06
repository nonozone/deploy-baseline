# v1.1.0 升级指南

## 这份指南适合谁

适合以下几类用户：

- 已经在项目里使用过 `deploy-baseline-kit`
- 仓库里还保留旧的模板理解方式，准备切到新的 skill 产品口径
- 本地开发还在使用历史根目录 `.env`
- 想把本地安装方式、模板真源和规则真源统一到 `v1.1.0`

## 这次升级最重要的变化

从用户视角看，`v1.1.0` 主要有四个变化：

1. `deploy-baseline-kit` 现在是明确的产品前门
2. `src/` 成为模板、文档、规则的单一真源
3. 本地开发 env 标准路径变成 `deploy/env/app.dev.env`
4. 兼容目录仍然存在，但不再建议手工双写维护

## 如果你只是使用 skill

你通常只需要关心两件事：

1. 重新安装或同步本地 skill
2. 让目标项目逐步收敛到新的 env 路径和基线结构

推荐做法：

```bash
make verify
make install-local
```

如果你本地是软链接安装，更新仓库后通常不需要重复复制，只需要重新打开 Codex 会话。

如果你本地是复制安装，执行 `make install-local` 最直接。

## 如果你维护这个仓库本身

从 `v1.1.0` 开始，建议遵守下面这条规则：

- 改模板，优先改 `src/template/`
- 改规则，优先改 `src/rules/`
- 改产品文档，优先改 `src/docs/` 或 `docs/` 中的前门文档
- 不要直接把 `template/`、`skills/deploy-baseline-kit/assets/template/`、`skills/deploy-baseline-kit/references/` 当成主编辑面

改完后执行：

```bash
make sync-compat
make sync-rules
make verify
```

## env 升级方式

`v1.1.0` 之后的标准结构是：

```text
deploy/env/app.env.example
deploy/env/app.dev.env
deploy/env/app.prod.env
```

如果你的项目还在使用历史根目录 `.env`：

- 不需要先手工迁移很多次
- 可以直接执行 `make setup`
- 如果检测到旧 `.env` 且 `deploy/env/app.dev.env` 不存在，脚本会复制一份并给出明确提示

后续建议再执行：

```bash
make local-env-sync
make prod-env-sync
```

这两个命令只补缺失 key，不覆盖已有值。

## 从旧理解迁移到新理解

如果你之前把这个仓库理解成“模板仓库”，现在建议切换为：

- 默认使用 skill，而不是手工复制模板
- 把手工复制模板视为维护或调试兼容输出的手段
- 让目标项目尽量向基线收敛，而不是继续保留历史漂移

简单说：

- 用户入口是 `deploy-baseline-kit`
- 真源入口是 `src/`
- 兼容输出只是为了安装和过渡，不是长期主编辑面

## 推荐升级检查清单

升级到 `v1.1.0` 后，建议至少确认这些点：

- 本地 skill 已更新到最新版本
- `make dev` 默认读取的是 `deploy/env/app.dev.env`
- 项目没有继续把根目录 `.env` 当成标准开发路径
- 文档里对外描述已经切到 skill 产品口径
- 维护流程已经改成从 `src/` 刷新兼容输出
- `make verify` 可以通过

## 一句话建议

如果你是普通使用者，就更新本地 skill，然后让项目逐步收敛到新的 env 路径。

如果你是维护者，就把 `src/` 当成唯一真源，不再在多个兼容目录里手工双写。
