# deploy-baseline-kit 产品边界与行为说明

## 1. 这是什么

`deploy-baseline-kit` 是这个仓库的主产品。它的目标不是“尽量迁就项目现状”，而是让 Codex 在目标项目中执行“识别现状 -> 输出短方案 -> 一次确认 -> 标准化收敛”的流程。

它不是单纯的模板说明，也不是只做静态建议，而是一个可以实际介入项目结构标准化的 skill 产品。

推荐先配合 `docs/README.md` 一起看：

- `docs/README.md` 负责给出产品文档入口
- 本文负责说明 skill 的产品边界和当前稳定支持面
- `skills/deploy-baseline-kit/SKILL.md` 与其配套 references 负责定义实际执行规则

当前仓库正处于产品化收敛阶段：

- `src/template/` 是新的模板真源起点
- `src/docs/` 是新的产品文档真源起点
- `src/rules/` 是新的产品规则真源起点
- 旧 `template/` 与 `skills/deploy-baseline-kit/assets/template/` 暂时仍在，用于过渡兼容
- 兼容模板目录应通过 `make sync-compat` 或 `make build-skill` 从 `src/template/` 刷新，而不是手工双写

## 2. 它在实际使用中会怎么处理项目

当开发者在项目根目录或某个子目录调用 `deploy-baseline-kit` 时，Codex 会按下面的顺序处理：

1. 先识别真实项目根目录
2. 发现可部署面与命令面（deployable surfaces + command surfaces）：代码路径、public surface、部署命令、项目级入口、单元级脚本、已有部署资产
3. 构建“部署单元矩阵”（deployment unit matrix）
4. 构建“命令面矩阵”（command surface matrix）
5. 为每个部署单元给出推荐的 hosting mode 与 baseline action
6. 输出识别结果与矩阵化改造方案
7. 等待开发者一次确认（仍然只有一个确认点，但包含整个矩阵与未确定字段）
8. 在确认后按部署单元分别执行生成/收敛/排除/文档化
9. 按部署单元执行最低验证（只做与该单元 hosting mode 匹配的验证，Compose 只覆盖 self-hosted 单元）
10. 输出按部署单元拆分的结果摘要与残留风险

这意味着它不是一上来就直接改文件，而是先分析，再给短方案，再执行。

## 3. 它会识别哪些部署单元状态

`deploy-baseline-kit` 会对每个部署单元（deployment unit）按三类“成熟度”处理。单项目仓库是“只有一行的矩阵”，等价于只分析一个部署单元。

### 3.1 空目录或近似空目录（按单元）

特征：

- 几乎没有工程锚点
- 没有 Compose
- 没有 `Makefile`
- 没有 `deploy/`

处理方式：

- 优先按基线模板生成标准骨架

### 3.2 轻量已有项目（按单元）

特征：

- 已有应用代码或基础工程文件
- 有部分脚本、环境文件或容器配置
- 但部署结构尚未成体系

处理方式：

- 先识别缺失项
- 再给出补齐和收敛方案

### 3.3 重度已有部署项目（按单元）

特征：

- 已有较完整的 `Makefile`
- 已有多个 Compose 文件
- 已有 `deploy/` 或复杂历史脚本

处理方式：

- 先总结冲突点和改造范围
- 再请开发者在唯一确认点里，对“需要收敛的部署单元”选择“保守改造”或“强制收敛”

## 4. 它会不会直接改项目

默认不会在未确认前直接落盘。

`deploy-baseline-kit` 的设计原则是：

- 先分析
- 先给方案
- 先说明风险
- 再等待一次确认

只有在开发者明确确认后，它才进入文件生成或结构收敛阶段，而且默认目标是让项目尽量靠近 deploy baseline。

如果某些内容无法安全收敛，最终结果必须显式写成 `exceptions`，而不是悄悄保留成隐性偏差。

它不会在未确认的情况下，直接对项目做大规模落盘修改。

## 5. 它的确认边界是什么

整个流程只保留一个确认点。

这个确认点会尽量一次性收拢所有关键决策，例如：

- 识别到的项目根目录是否正确
- 部署单元矩阵是否正确（有哪些单元、各自 code path / public surface）
- 命令面矩阵是否正确（项目级入口与单元级入口是否识别准确，哪些单元没有 `dev`）
- 按部署单元拆分的现有资产清单（current assets by unit）
- 每个部署单元的 hosting mode 与 baseline action 是否接受
- 对 `self-hosted` 部署单元：确认 `dev_mode`（`full-docker` / `hybrid`）以及 `make dev` 会启动哪些单元
- 每个部署单元的回滚边界（rollback unit）是否明确且可执行
- 对需要收敛的部署单元，是走保守改造还是强制收敛
- 按部署单元拆分的验证计划（verification plan by unit）
- 如果有低置信字段（例如 hosting mode、deploy command、rollback unit），要求开发者在这一轮里补充确认或覆盖

确认之后，skill 不再逐文件追问。

但确认之后不代表“直接生成完就结束”，它还应继续做最低验证，并在最终结果里说明哪些验证已经完成、哪些没有完成，以及哪些内容被保留为 `exceptions`。

### 5.1 矩阵化确认示例（单条确认消息内）

- `core: self-hosted, dev_mode=hybrid, converge-self-hosted (conservative) (make dev: core + shared infra)`
- `www: external-static-hosting, exclude-from-compose（不建议 Dockerize，但仍然属于 baseline 的“需处理单元”）`
- `worker: external-platform, provider-managed（manifest/config + deploy/local-dev 命令 + secrets/ownership + rollback 边界的文档化）`

## 6. 它会生成或收敛哪些内容

确认后，`deploy-baseline-kit` 会围绕部署基线的目标结构进行处理。具体生成/收敛范围取决于部署单元的 hosting mode 与 baseline action。

对典型 `self-hosted` 部署单元，可能包括但不限于：

- `Makefile`
- `deploy/env/app.env.example`
- `deploy/env/app.dev.env`
- `deploy/env/app.prod.env`
- `docker-compose.yml`
- `docker-compose.dev.yml`
- `docker-compose.prod.yml`
- `scripts/`
- `deploy/`
- `deploy/env/`
- `deploy/scripts/`
- `deploy/README.md`

处理原则是：

- 新项目优先按基线生成
- 轻量项目优先补齐并收敛到标准路径
- 重度已有项目优先迁移有效逻辑，而不是保留历史目录漂移
- 历史路径可以迁移兼容，但不应继续作为主结构

对于 monorepo 或多单元项目，还应额外遵守：

- 根 `Makefile` 负责项目级统一入口
- 单元级开发/测试命令可以继续保留在各自 runner 中
- 不要求把所有单元命令都提升到根 `Makefile`
- 如果某个单元没有 `dev`，应明确报告，而不是假定它存在

对系统级配置文件，还应额外遵守一条保护原则：

- 默认采用 merge、追加或局部修改
- 不直接整文件覆盖已有 `Caddyfile`、`nginx.conf`、systemd unit、CI/CD workflow 等系统面配置
- 只有在开发者对该部署单元明确选择强制收敛（forced convergence）时，才允许整文件替换

## 7. 它在改造后至少应该验证什么

最低验证面建议至少包括：

- 对新增或修改过的 shell 脚本执行 `bash -n`
- 对 `self-hosted` 单元：对 Compose 文件执行 `docker compose config`，并检查 `healthcheck`、env 引用与回滚边界
- 对 `external-static-hosting` 单元：验证 build 命令、输出目录、路由/base path 假设与 env 合约
- 对 `external-platform` 单元：验证 manifest/config、deploy 命令、必需 secrets 文档与回滚边界说明
- 对项目级命令面执行 `make help`（如果本次引入或修改了 Make targets）
- 对 monorepo 的单元级命令面，核对各单元实际存在的 `dev/build/test/typecheck/migrate`，不要把不存在的脚本写进文档或方案里
- 如果项目已有 `build/test/typecheck`，则执行现有健康检查

如果某项验证因为环境原因无法执行，也应在最终结果中明确写出来。

## 8. 当前最稳定支持的范围

目前这套 skill 和部署基线，最稳定、最完整的产品线是：

- 基于 PostgreSQL 的部署基线生成与收敛

这包括：

- PostgreSQL 容器场景
- 新项目骨架生成
- 轻量已有项目的基线补齐
- 重度已有项目的分析、方案输出与确认后改造

如果项目最终采用 PostgreSQL 方案，当前支持是最完整的。

## 9. 已纳入设计但仍待进一步验证的范围

以下场景已经纳入设计，但当前仍属于“待真实项目继续验证”的范围：

- MySQL / MariaDB
- MongoDB
- 外部托管数据库
- 更复杂的 monorepo 结构
- 更复杂的多发布链路项目

这不表示这些场景不能处理。实际行为边界更接近：

- 仍会做扫描、矩阵化方案与单次确认
- 仍会尽力识别数据库类型与持久化/托管形态，并给出对应的 baseline action 与验证计划
- 但验证与收敛的置信度更低：更可能需要开发者在确认消息里补齐关键字段（例如连接方式、迁移策略、回滚边界）
- 对非 PostgreSQL 的仓库，应在最终结果里明确标注“低置信字段”和“未能完成/跳过的验证项”，避免假定可完全自动化

因此当前更稳妥的对外表述是：

- PostgreSQL 路线最完整
- 其他数据库类型按需求驱动逐步完善

同时 PostgreSQL 也不应只停留在“识别数据库类型”，还应对大版本部署差异保持敏感，例如数据目录、挂载策略和 `PGDATA` 约定。一个已经很实际的例子就是 `postgres:18`：如果还沿用 `17` 时代常见的 `/var/lib/postgresql/data` 挂载路径，就可能因为镜像的 `VOLUME /var/lib/postgresql` 与默认 `PGDATA` 变更，额外生成随机匿名卷，甚至把真实数据写进匿名卷。因此当前基线应把 PostgreSQL 18 的默认策略收敛为：命名卷挂到 `/var/lib/postgresql`，并显式使用 `PGDATA=/var/lib/postgresql/18/docker`。

## 10. 什么时候适合用它

比较适合的场景：

- 你要从空目录快速生成部署基线骨架
- 你要把一个已有项目收敛到统一部署接口
- 你想先让 Codex 分析项目，再决定怎么改
- 你希望减少手工整理 Compose、Makefile、deploy 文档的成本

## 11. 什么时候应该谨慎使用

建议谨慎使用或先走保守改造的场景：

- 项目已有大量历史部署脚本
- 项目存在多条独立发布链路
- 项目是复杂 monorepo，且多个子系统边界不清晰
- 项目数据库或中间件依赖较多，且当前文档严重缺失

在这些情况下，更合理的方式通常是：

- 先让 skill 做分析和方案输出
- 再选择保守改造，而不是直接强制收敛

## 12. env 模板应该怎么处理

推荐把 env 示例文件按关注点分组，例如：

1. project / runtime
2. database
3. publish ports
4. auth / secrets
5. provider-specific config
6. observability / verification

同时应遵守：

- `deploy/env/app.env.example` 是唯一 canonical env 示例来源
- 本地开发默认使用 `deploy/env/app.dev.env`
- 生产部署默认使用 `deploy/env/app.prod.env`
- 本地变量和生产变量不要无注释混写
- provider-specific 变量应标明是否可选
- 如果 `deploy/env/app.env.example` 新增了 active key，skill 在改造已有项目时应优先采用“非破坏性补齐缺失 key”的方式同步 `app.dev.env` 与 `app.prod.env`，而不是覆盖已有值
- 如果检测到历史根目录 `.env` 且 `deploy/env/app.dev.env` 尚不存在，可以在初始化阶段复制一次并明确提示开发者这是迁移产物
- 如果项目要引入新的 `.env` 分层或新的部署 env 文件，必须先检查现有 env 配置并做合理迁移，保留已有有效值；不能因为基线目录结构不同就直接覆盖旧 `.env`、`.env.local` 或 deploy env 文件

## 13. 为什么要做成 skill

如果只有模板和规范，开发者仍然需要自己完成：

- 看文档
- 判断项目现状
- 判断该怎么改
- 手工落标准文件

而 `deploy-baseline-kit` 的价值在于把这些动作串成一个可调用流程，让 Codex 能够：

- 主动识别项目
- 主动给出建议
- 在确认后主动执行改造

这会显著降低接入门槛，也让部署基线更像一个真正可用的工具，而不只是文档资产。

## 14. 当前仓库里哪些内容已经和 skill 同步更新

这次产品化收敛后，仓库里以下层次已经同步到同一套口径：

- `docs/README.md`
- `README.md`
- `skills/deploy-baseline-kit/SKILL.md`
- `src/rules/references/`
- `skills/deploy-baseline-kit/references/`
- `src/template/`

可以把它们理解成三层：

- 入口层：`README.md` 与 `docs/README.md`
- 行为说明层：`docs/deploy-baseline-kit.md`
- 执行规则层：`skills/deploy-baseline-kit/SKILL.md` 与 `references/`

其中：

- `src/template/`、`src/rules/` 是真源
- `template/`、`skills/deploy-baseline-kit/assets/template/` 与 `skills/deploy-baseline-kit/references/` 是兼容输出

如果后续继续演进 skill，原则上应至少同时检查这三层是否仍然一致。
