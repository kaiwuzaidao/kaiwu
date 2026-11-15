# Changelog

## Unreleased

## 0.2.0

### 新增

- 入口转发 `login`、`whoami`、`logout`、`project` 与 `access`，可从终端完成设备授权、开通项目、同步清单和维护成员授权。（ADR 0035、0036、0042）
- `project-up` 和 `project-down` 可在本地接入或停止生成的项目。（ADR 0025、0027）

### 变更

- 首次运行 `./kaiwu up` 时，空的平台库从 V127 初始化。从 v0.1.0（V44）升级须保留旧库并准备新库；已有安装请先按 `workspace/kaiwu-system-service/docs/UPGRADING.md` 的数据库一节选择升级路径。（ADR 0047）
- 发行版的 `up` 默认使用同版本的预构建镜像，显式传入 `--build` 可从源码构建。（ADR 0027）

### 修复

- `logs` 和 `local-logs` 透传日志参数，可使用 `--tail` 限制行数、用 `-f` 跟随输出。（ADR 0027）
