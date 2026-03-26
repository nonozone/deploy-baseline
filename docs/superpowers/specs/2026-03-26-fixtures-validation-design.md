# `fixtures` 样板验证体系设计说明

## 1. 目标

为 `deploy-baseline` 建立一套放在仓库内维护的样板验证体系，用于验证以下两类能力：

- `deploy-baseline-kit` 对不同项目形态的识别、分类和改造建议是否稳定
- 基线模板和默认 PostgreSQL 路线是否具有可重复验证的最低可执行性

这套体系不是为了把仓库扩展成示例应用集合，而是为了给基线本身提供稳定的回归面。

## 2. 设计原则

### 2.1 仓库内维护

样板项目直接放在当前仓库内，而不是拆成外部仓库。

这样做的原因是：

- 便于在同一仓库中维护文档、模板、skill 和样板
- 便于后续把样板验证接入统一验证命令
- 便于在 README 和路线图中直接引用

### 2.2 静态夹具为主，可运行样板为辅

首批样板采用混合策略：

- 大部分样板使用最小静态夹具
- 少量样板使用可运行项目

静态夹具主要验证：

- root detection
- 项目分类
- 运行模式识别
- 数据库类型识别
- 推荐改造路径

可运行样板主要验证：

- `make help`
- `docker compose config`
- shell 脚本语法
- PostgreSQL 主路线的 healthcheck、env 和 volume 约定

### 2.3 首批范围收敛

第一版不追求覆盖所有技术栈，而是优先覆盖：

- 新项目
- 轻量已有项目
- 重度已有部署项目
- 前后端分离项目
- monorepo 子项目入口
- PostgreSQL 之外的一个数据库对照样板

### 2.4 为后续自动验证预留结构

样板目录、元信息文件和验证分层都需要为后续的：

- `make verify-fixtures-static`
- `make verify-fixtures-runnable`
- `make verify-baseline`

预留清晰边界。

## 3. 目录结构

建议在仓库根目录新增 `fixtures/`，采用如下结构：

```text
fixtures/
  empty-project/
    fixture.md
  lightweight-existing/
    fixture.md
    ...
  heavy-existing-deploy/
    fixture.md
    ...
  frontend-backend-split/
    fixture.md
    ...
  monorepo-subproject/
    fixture.md
    ...
  mysql-compare/
    fixture.md
    ...
  runnable/
    pg-new-project/
      fixture.md
      ...
    pg-existing-project/
      fixture.md
      ...
```

分层原则如下：

- `fixtures/` 顶层为静态夹具
- `fixtures/runnable/` 为可运行样板

不要在第一版中再引入更深的层级，避免样板结构本身变复杂。

## 4. 首批样板清单

### 4.1 静态夹具

#### `fixtures/empty-project/`

用途：

- 验证 skill 能识别空目录或近似空目录
- 验证建议路径是否为新项目基线骨架生成

#### `fixtures/lightweight-existing/`

用途：

- 验证 skill 能识别轻量已有项目
- 验证是否推荐补齐与收敛，而不是强行重写

特征建议：

- 有少量应用代码
- 有部分 env 或脚本
- 没有完整 `deploy/` 体系

#### `fixtures/heavy-existing-deploy/`

用途：

- 验证 skill 能识别重度已有部署项目
- 验证是否在唯一确认点中提示“保守改造 / 强制收敛”

特征建议：

- 有 `Makefile`
- 有多个 Compose 文件
- 有 `deploy/` 或复杂部署脚本

#### `fixtures/frontend-backend-split/`

用途：

- 验证 skill 能识别前后端分离形态
- 验证是否倾向给出 `hybrid development` 判断

#### `fixtures/monorepo-subproject/`

用途：

- 验证从子目录触发 skill 时，是否能正确判断项目根和作用范围

特征建议：

- 至少包含两个 app
- 包含共享目录，例如 `packages/`

#### `fixtures/mysql-compare/`

用途：

- 验证 skill 不会把 PostgreSQL 当作所有项目默认事实
- 验证对非 PostgreSQL 路线采用更保守的稳定性表达

### 4.2 可运行样板

#### `fixtures/runnable/pg-new-project/`

用途：

- 验证 PostgreSQL 新项目基线主路径可以跑通最低验证面

#### `fixtures/runnable/pg-existing-project/`

用途：

- 验证 PostgreSQL 轻量已有项目在收敛后仍能满足最低命令面和 Compose 校验

## 5. `fixture.md` 元信息规范

每个样板目录必须包含一个 `fixture.md`，用于固定描述该样板的预期。

第一版只允许使用以下字段：

- `name`
- `scenario`
- `expected_root`
- `expected_classification`
- `expected_mode`
- `expected_database`
- `support_level`
- `expected_recommendation`
- `verification_level`
- `notes`

示例：

```md
# Fixture Metadata

- name: lightweight-existing
- scenario: lightweight existing project
- expected_root: .
- expected_classification: lightweight existing project
- expected_mode: hybrid development
- expected_database: postgresql
- support_level: stable
- expected_recommendation: conservative convergence
- verification_level: static
- notes: contains partial env, app code, and incomplete deploy assets
```

约束如下：

- 第一版统一使用 Markdown 列表，不额外引入 YAML 或 JSON
- 字段顺序保持固定，便于人工阅读和后续脚本检查
- `support_level` 应与仓库整体成熟度表达一致，例如 `stable`、`baseline`、`experimental`
- `verification_level` 只允许 `static` 或 `runnable`

## 6. 验收目标

### 6.1 静态夹具验收目标

静态夹具不要求真正完成部署执行，第一版主要验证：

- 是否能识别正确根目录
- 是否能识别正确项目分类
- 是否能识别建议运行模式
- 是否能识别数据库类型
- 是否能给出合理推荐路径
- 是否能识别高风险改动点

### 6.2 可运行样板验收目标

可运行样板需要覆盖最低执行面：

- `make help`
- `docker compose config`
- `bash -n` for scripts
- env 示例文件与 Compose 引用一致
- PostgreSQL 路线的 healthcheck 和 volume 说明一致

第一版不强求完整远程部署自动化，只验证本地最低可执行性。

## 7. 与统一验证入口的关系

这套样板体系需要直接为后续验证入口提供结构基础。

建议后续新增以下命令：

### 7.1 `make verify-fixtures-static`

职责：

- 检查静态夹具目录完整性
- 检查 `fixture.md` 必填字段
- 检查样板文件面是否满足预期约束

### 7.2 `make verify-fixtures-runnable`

职责：

- 检查可运行样板的命令面与 Compose 可展开性
- 执行 `make help`
- 执行 `docker compose config`
- 执行 `bash -n`

### 7.3 `make verify-baseline`

职责：

- 聚合仓库自身检查
- 串联静态夹具验证
- 在环境允许时串联可运行样板验证

## 8. 实现顺序

建议按下面顺序推进：

1. 新增 `fixtures/` 目录和首批样板骨架
2. 为每个样板补 `fixture.md`
3. 在 README 和路线图中加入样板体系入口
4. 实现 `verify-fixtures-static`
5. 再实现 `verify-fixtures-runnable`

这样可以先扩大识别与分类回归面，再逐步补运行级验证。

## 9. 非目标

第一版不把以下事项作为目标：

- 为所有样板补完整业务应用实现
- 覆盖所有数据库与中间件组合
- 在没有真实验证前把非 PostgreSQL 路线表述为稳定支持
- 一开始就把所有样板接入重型 CI 流程

## 10. 预期结果

完成后，`deploy-baseline` 将新增一层面向自身的验证资产：

- 有固定结构的样板项目集合
- 有统一格式的样板元信息
- 有分层验证思路
- 有可直接接入 `make verify-baseline` 的目录基础

这会让仓库后续的优化重点从“继续补概念”转向“扩大回归面和提升可信度”。
