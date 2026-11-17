# Kaiwu · 开物载道

[Kaiwu 官网](http://kaiwu.shengzhiweilai.online/) · [在线体验](http://kaiwu.shengzhiweilai.online/try/index.html) · [快速开始指南](http://kaiwu.shengzhiweilai.online/start) · [Gitee](https://gitee.com/wujm12138/kaiwu) · [GitHub](https://github.com/kaiwuzaidao/kaiwu) · [English](README.en.md)

Kaiwu 是面向 AI 时代的企业应用开发与交付平台。

## 快速开始

想先看效果？[打开在线工作台](http://kaiwu.shengzhiweilai.online/try/index.html)即可免登录体验。要开发自己的项目，把这句话复制给能使用本机终端的 AI 编码工具。

```text
从 https://gitee.com/wujm12138/kaiwu 获取 Kaiwu 最新稳定版，按 AGENTS.md 在本机启动。问我想开发什么项目，再按我的回答准备前后端。
```

## 在本机启动 v0.2.0

准备 Git、Docker（含 Compose v2）、OpenSSL 和 curl。下面的命令选择本地 MySQL，从 GHCR 拉取发行版的预构建镜像，支持 amd64 和 arm64。

首次安装可在[发行页](https://github.com/kaiwuzaidao/kaiwu/releases/latest)查看最新稳定标签。下面用 `v0.2.0` 复现本页截图；安装其他版本时，将命令中的标签换成选定版本。

```bash
git clone --branch v0.2.0 --depth 1 https://github.com/kaiwuzaidao/kaiwu.git
cd kaiwu
./kaiwu doctor
KAIWU_DB_TYPE=mysql ./kaiwu up
```

就绪后打开 <http://127.0.0.1:8000>，使用 `admin` 和终端显示的随机密码，首次登录按提示改密。`./kaiwu credentials` 可再次查看初始凭据；`./kaiwu down` 停止本机平台并保留数据。基础项目生成可以直接体验，使用助手时再配置模型。

已有平台数据库的用户，先查看[升级说明](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/UPGRADING.md)。如需使用达梦 DM8，请先准备独立实例和 Schema。[数据库配置](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/DATABASES.md) · [MySQL / DM8 初始化 DDL 与 DML](https://github.com/kaiwuzaidao/kaiwu-system-service/releases/tag/v0.2.0)

## 平台与业务项目如何配合

每个项目都有自己的 Spring Boot 后端、React 前端和业务数据库，由团队管理源码，独立测试和发布。

比如采购和库存可以沿用同一批员工账号，分别授予采购员和仓管员权限。盘点规则变了，AI 只需在库存项目的业务仓里改代码。业务字典、多语言文案、附件存储可以按需接入，需要批量导入时再加 Excel 组件。

项目工厂交付前后端基础工程，Agent 在业务仓里实现需求、预览菜单和权限变更、运行随仓校验。需要账号授权时由你确认。交接时可以查看 Git 差异和测试结果。[AI 开发指南](http://kaiwu.shengzhiweilai.online/ai-development) · [CLI 命令索引](http://kaiwu.shengzhiweilai.online/commands)

![Kaiwu 工作台展示当前成员的项目入口和待办事项](docs/assets/workbench.png)

## 生成第一个项目

在网页的「项目管理 → 开通项目」填写名称和编码，或在入口仓目录运行以下命令。命令行会提示打开浏览器确认设备授权。下文的订单中心仅为示例，运行前替换为自己的名称和编码。

```bash
./kaiwu login --client "kaiwu-demo"
./kaiwu project new order-center --name "订单中心"
./kaiwu project status order-center --wait
./kaiwu project pull order-center
./kaiwu project-up ../business/order-center-service ../business/order-center-web
```

`project pull` 会把两个独立 Git 仓库放在入口仓旁的 `business/` 目录。`project-up` 构建并接入本机平台，完成后从工作台打开业务后台。已有同名项目时，从查询状态那一步继续。[完整教程](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/QUICKSTART.md)

v0.2.0 中，生成项目可能因 JAR 缺少资源或 Nginx 配置读取权限而启动失败。请从工作台打开业务页面验证。[故障与修复进展](https://github.com/kaiwuzaidao/kaiwu-system-service/pull/1)

![订单中心的生成任务已成功，可分别下载后端和前端 ZIP](docs/assets/project-factory.png)

## v0.2.0 可以做什么

| 场景 | 在哪里做 |
| --- | --- |
| 让不同团队只看自己的数据 | 在项目权限中心分配成员和角色，按资源设置本人、部门等数据范围。业务后端可接入 MyBatis-Plus 行级过滤。[数据范围](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/DATA_SCOPE.md) |
| 把项目配置随源码交付 | 在后端仓维护菜单、字典、参数和多语言资源。用 `project sync` 预览差异，再用 `--apply` 应用。管理端支持跨环境配置移交，导入角色授权时单独确认。[项目工厂](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/PROJECT_FACTORY.md) |
| 把业务待办送到工作台 | 业务服务按业务键投递或关闭待办，处理人在工作台查看分配给自己的事项。[统一待办](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/UNIFIED_TODO.md) |
| 接入文件和表格 | 为项目绑定对象存储账号，业务服务领取限定前缀的临时凭据。文件登记按需启用；Excel 导入导出也可单独引入。[Starter 与可选组件](https://github.com/kaiwuzaidao/kaiwu-system-starter/tree/v0.2.0) |
| 使用平台助手 | 在「大模型配置」分别选择任务识别和回答模型。助手可保留个人对话，接入已审核的项目能力；远程写操作需要使用者确认。[助手接入](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/adr/0030-agent-cross-project-capabilities.md) |

业务后端使用的三个 Maven Central 组件均为 `com.kaiwuzaidao` 下的 `0.2.0`：接入平台用 `kaiwu-system-starter`，行级数据过滤用 `kaiwu-data-scope`，表格导入导出用 `kaiwu-excel`。

## 继续使用

- [平台导览与界面截图](docs/HOW-IT-WORKS.md) · [仓库地图与版本选择](docs/REPOSITORIES.md)
- [部署到一台服务器](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/SERVER-DEPLOYMENT.md) · [部署到 Kubernetes](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/KUBERNETES.md)
- [开发工具入口](AGENTS.md) · [参与贡献](CONTRIBUTING.md) · [版本变更](CHANGELOG.md)

Kaiwu 采用 [Apache License 2.0](LICENSE)。名称与标识的使用见[商标政策](TRADEMARKS.md)。
