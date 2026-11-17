# Kaiwu · 开物载道

[English](README.en.md) · [v0.3.0 发布说明](https://github.com/kaiwuzaidao/kaiwu/releases/tag/v0.3.0)

Kaiwu 是供多个业务系统共用的后台开发平台。团队可以用同一个工作台登录、分配项目成员、配置权限、接收待办；每个业务项目则有自己的前后端仓库、数据库和发布流程。

例如，开通一个「订单中心」后，项目工厂会交付两份源码 ZIP。你可以在自己的仓库里添加订单表、接口和页面，再把菜单、字典和权限声明同步到平台。下一次升级 Kaiwu，业务源码仍由你的团队维护。

![工作台展示订单中心、生成成功通知和当前成员需要处理的事项](docs/assets/workbench.png)

## 在本机启动 v0.3.0

准备 Git、Docker（含 Compose v2）、OpenSSL 和 curl。下面的命令选择本地 MySQL，从 GHCR 拉取发行版的预构建镜像，支持 amd64 和 arm64。

```bash
git clone --branch v0.3.0 --depth 1 https://github.com/kaiwuzaidao/kaiwu.git
cd kaiwu
./kaiwu doctor
KAIWU_DB_TYPE=mysql ./kaiwu up
```

就绪后打开 <http://127.0.0.1:8000>，使用 `admin` 和终端显示的随机密码，首次登录按提示改密。`./kaiwu credentials` 可再次查看初始凭据；`./kaiwu down` 停止本机平台并保留数据。基础项目生成可以直接体验，使用助手时再配置模型。

已有平台数据库的用户，先查看[升级说明](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/UPGRADING.md)。如需使用达梦 DM8，请先准备独立实例和 Schema。[数据库配置](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/DATABASES.md) · [MySQL / DM8 初始化 DDL 与 DML](https://github.com/kaiwuzaidao/kaiwu-system-service/releases/tag/v0.3.0)

## 生成第一个项目

在网页的「项目管理 → 开通项目」填写名称和编码，或在入口仓目录运行以下命令。命令行会提示打开浏览器确认设备授权。

```bash
./kaiwu login --client "kaiwu-demo"
./kaiwu project new order-center --name "订单中心"
./kaiwu project status order-center --wait
./kaiwu project pull order-center
./kaiwu project-up ../business/order-center-service ../business/order-center-web
```

`project pull` 会把两个独立 Git 仓库放在入口仓旁的 `business/` 目录。`project-up` 构建并接入本机平台，完成后从工作台打开业务后台。已有同名项目时，从查询状态那一步继续。[完整教程](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/QUICKSTART.md)

![订单中心的生成任务已成功，可分别下载后端和前端 ZIP](docs/assets/project-factory.png)

## 产品先做演示，再接入平台

先取得[产品前端起步仓](https://github.com/kaiwuzaidao/kaiwu-web-starter/tree/v0.3.0)，从仓库目录执行以下命令可创建一个独立的空白前端。要快速体验双人设备预约，在初始化命令末尾加 `--example booking`。产品验收和开发交接步骤见 [AI 协作开发指南](docs/AI-DEVELOPMENT.md)。

```sh
git clone --branch v0.3.0 --depth 1 https://github.com/kaiwuzaidao/kaiwu-web-starter.git
cd kaiwu-web-starter
node scripts/kaiwu-init.mjs --code equipment-booking --name 设备预约
cd ../equipment-booking-web
pnpm install --frozen-lockfile
pnpm dev
```

打开开发服务器打印的地址，进入 `/__mock/` 选择演示身份。页面定稿后，开发者使用含纳管功能的入口与 System，在入口仓登录并运行以下命令。这里假设业务前端和入口仓位于同一个父目录。

```sh
./kaiwu project adopt ../equipment-booking-web
./kaiwu project adopt ../equipment-booking-web --apply
```

配套后端会生成在 `../equipment-booking-service`。实现业务 API 后，在原前端运行 `pnpm dev:real` 即可联调。后续清单变更使用 `./kaiwu project sync ../equipment-booking-web`。已单独启用兼容 Workflow 服务并登记业务回调的项目，还可使用 `./kaiwu workflow sync ../equipment-booking-web` 预览流程导入。

## v0.3.0 可以做什么

| 场景 | 在哪里做 |
| --- | --- |
| 让不同团队只看自己的数据 | 在项目权限中心分配成员和角色，按资源设置本人、部门等数据范围。业务后端可接入 MyBatis-Plus 行级过滤。[数据范围](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/DATA_SCOPE.md) |
| 把项目配置随源码交付 | 在后端仓维护菜单、字典、参数和多语言资源。用 `project sync` 预览差异，再用 `--apply` 应用。管理端支持跨环境配置移交，导入角色授权时单独确认。[项目工厂](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/PROJECT_FACTORY.md) |
| 把业务待办送到工作台 | 业务服务按业务键投递或关闭待办，处理人在工作台查看分配给自己的事项。[统一待办](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/UNIFIED_TODO.md) |
| 接入文件和表格 | 为项目绑定对象存储账号，业务服务领取限定前缀的临时凭据。文件登记按需启用；Excel 导入导出也可单独引入。[Starter 与可选组件](https://github.com/kaiwuzaidao/kaiwu-system-starter/tree/v0.3.0) |
| 使用平台助手 | 在「大模型配置」分别选择任务识别和回答模型。助手可保留个人对话，接入已审核的项目能力；远程写操作需要使用者确认。[助手接入](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/adr/0030-agent-cross-project-capabilities.md) |

业务后端使用的三个 Maven Central 组件均为 `com.kaiwuzaidao` 下的 `0.2.0`：接入平台用 `kaiwu-system-starter`，行级数据过滤用 `kaiwu-data-scope`，表格导入导出用 `kaiwu-excel`。

## 继续使用

- [平台导览与界面截图](docs/HOW-IT-WORKS.md) · [仓库地图与版本选择](docs/REPOSITORIES.md)
- [部署到一台服务器](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/SERVER-DEPLOYMENT.md) · [部署到 Kubernetes](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/KUBERNETES.md)
- [开发工具入口](AGENTS.md) · [参与贡献](CONTRIBUTING.md) · [版本变更](CHANGELOG.md)

Kaiwu 采用 [Apache License 2.0](LICENSE)。名称与标识的使用见[商标政策](TRADEMARKS.md)。
