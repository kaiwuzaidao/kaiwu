# Kaiwu 仓库地图

开源入口负责「从哪里开始」，产品能力仍由五个独立仓库维护。

`kaiwu-deploy` 是可选的：只在走 Kubernetes + ArgoCD 时才需要，执行
`./kaiwu deploy-init` 之后才会出现在 `workspace/` 里。其余四个仓由
`./kaiwu up` 一并取下。

| 仓库 | 负责什么 | 不负责什么 |
| --- | --- | --- |
| `kaiwu` | 主页、首次初始化、仓库导航、发行入口 | 产品源码、部署状态、Secret |
| `kaiwu-system-service` | 控制面后端、项目工厂、统一启动器、Helm Chart | 业务项目源码 |
| `kaiwu-gateway-service` | 外部认证、会话、显式路由、Gateway Context | 权限事实、业务规则 |
| `kaiwu-system-web` | 平台管理前端 | 生成业务前端 |
| `kaiwu-system-starter` | 业务服务本地鉴权与接入契约 | System 领域模型 |
| `kaiwu-deploy`（可选） | 平台与业务项目的 GitOps 期望状态 | Helm Chart、明文 Secret、业务源码 |

## 为什么不用 monorepo

平台组件、SDK、部署声明和生成业务项目有不同的发布、权限与回滚节奏。保持独立仓库，可以让
业务代码不被平台升级覆盖，也避免 Starter 与 System 形成跨仓循环发布。

## 为什么普通用户不使用 submodule

Submodule 适合清楚知道自己在维护多仓依赖的人，但会给第一次下载增加初始化、游离 HEAD、更新和
贡献流程差异。Kaiwu 入口通过同名 Release tag 和工作区锁文件解决版本一致性，使用者只需一条
初始化命令。

## 版本规则

- 稳定发行：入口与五个产品仓使用同名不可变 tag。
- 开发态：入口和各仓可使用默认分支，不宣称为稳定发行。
- Fork：通过 `KAIWU_REPOSITORY_BASE_URL` 选择组织，通过 `KAIWU_REPOSITORY_REF` 固定版本。
- 初始化发现同名 tag 缺失时必须失败，不回退到默认分支。
