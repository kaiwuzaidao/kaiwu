# v0.2.0 仓库地图

从[入口仓](https://github.com/kaiwuzaidao/kaiwu)运行 `./kaiwu init` 或 `./kaiwu up`，启动器会将四个运行所需的产品仓检出到 `workspace/`。实际仓库清单由 System 的 [kaiwu-workspace.env](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/kaiwu-workspace.env) 维护。

| 要找的内容 | 公开仓库 |
| --- | --- |
| 项目、成员与角色、项目工厂、助手、数据库迁移和 Helm Chart | [kaiwu-system-service](https://github.com/kaiwuzaidao/kaiwu-system-service/tree/v0.2.0) |
| 登录会话、项目路由、转发时签发的 Gateway Context | [kaiwu-gateway-service](https://github.com/kaiwuzaidao/kaiwu-gateway-service/tree/v0.2.0) |
| 工作台、项目管理、配置移交和平台管理界面 | [kaiwu-system-web](https://github.com/kaiwuzaidao/kaiwu-system-web/tree/v0.2.0) |
| 业务服务的 Java SDK、行级数据范围和 Excel 组件 | [kaiwu-system-starter](https://github.com/kaiwuzaidao/kaiwu-system-starter/tree/v0.2.0) |
| 可选的 GitOps 部署声明，执行 `./kaiwu deploy-init` 后检出 | [kaiwu-deploy](https://github.com/kaiwuzaidao/kaiwu-deploy/tree/v0.2.0) |

## 固定版本与 Fork

首次使用时检出入口仓最新稳定发行标签。要复现本页所述版本，请检出 `v0.2.0`。启动器会获取各产品仓的同名标签，发行安装默认拉取 GHCR 镜像。开发者可以用 `./kaiwu up --build` 从源码构建。

在 Fork 或自建 Git 服务上，把下面的地址换成实际托管上述仓库的组织地址，再预览来源：

```bash
export KAIWU_REPOSITORY_BASE_URL=https://github.com/example
export KAIWU_REPOSITORY_REF=v0.2.0
./kaiwu repositories
```

缺少同名标签时初始化会报错。已有工作区保留其检出状态，可通过 `workspace/.kaiwu/workspace.lock` 核对实际提交。项目工厂取回的业务仓默认在入口旁边的 `business/`，可独立提交、测试和发布。
