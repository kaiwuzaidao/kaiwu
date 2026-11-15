# Kaiwu 开源入口 · Agent 指引

你现在在 **入口仓**。它不含产品源码，只负责三件事：把五个产品仓取到
`workspace/`、用一条命令把平台跑起来、告诉你接下来该读哪份文档。

## 先做这一步

```bash
./kaiwu doctor   # 检查 Git、Docker Compose v2、OpenSSL 和 curl
KAIWU_DB_TYPE=mysql ./kaiwu up  # 取仓、初始化并启动，完成后访问 http://127.0.0.1:8000
./kaiwu credentials   # 初始管理员账号与随机初始密码
```

检出发行标签后，`./kaiwu up` 默认拉取同版 GHCR 预构建镜像，拉取失败时会尝试本机构建。
开发态或显式指定 `--build` 时会从源码构建，首次构建需要拉取 Maven 与 npm 依赖。

失败时先看 `./kaiwu doctor` 的输出，再看 `./kaiwu logs`（默认打印最近 200 行后退出；
要持续跟随才加 `-f`）；不要绕过脚本直接敲 `docker compose`——端口、密钥与 Compose
文件的组合由脚本负责生成。

同一台机器上已经跑着另一份 Kaiwu 时，**项目名和对外端口都要错开**，两者缺一不可：

```bash
COMPOSE_PROJECT_NAME=kaiwu-demo KAIWU_WEB_PORT=8100 KAIWU_GATEWAY_PORT=8188 ./kaiwu up
```

只改端口会共用同一批数据卷——新生成的随机口令对不上旧卷里的库，MySQL 起不来；
只改项目名不改端口，则卡在 `Bind for 127.0.0.1:8088 failed: port is already allocated`。

## 生成并取回一个业务项目

平台跑起来之后，生成业务项目不需要操作网页，按下面的顺序在命令行完成（ADR 0035）：

```bash
./kaiwu login --client "<你的工具名>" --local   # 本机平台：免点击；--local 不可用或失败时会打印 /device 链接，由用户核对后点「允许」
./kaiwu project new order-center --name "订单中心"   # 生成前后端基础脚手架
./kaiwu project status order-center --wait
./kaiwu project pull order-center       # 解压到工作目录旁的 business/，两个仓各自完成 git 初始提交
./kaiwu project-up ../business/order-center-service ../business/order-center-web
```

开发过程中需要平台配合的动作，都用命令完成，不要让用户去网页上点：

```bash
./kaiwu project sync ../business/order-center-service          # 先看计划：仓库里 kaiwu/*.yml 的菜单、字典、配置与平台的差异
./kaiwu project sync ../business/order-center-service --apply  # 确认后写入（只新增、不删除）
./kaiwu access permissions order-center                        # 项目里可授予的权限码
./kaiwu access roles order-center                              # 角色
./kaiwu access role-create order-center auditor --name "审计员"
./kaiwu access role-grant order-center auditor --permissions order:order:list   # 整体替换，上级菜单自动补齐
./kaiwu access members order-center                            # 成员
./kaiwu access member-set order-center alice --roles auditor   # 添加或更新成员（--disabled 停用）
```

- 远程平台上的授权必须由用户本人在浏览器里确认；CLI 会话最长 7 天，可在安全运营中心强制下线。
  会话的平台权限被收窄到「生成并取回项目、同步清单」，成员与角色授权则按用户在该项目里的权限判定。
- `kaiwu/menus.yml`、`dicts.yml`、`configs.yml` 在业务后端仓里；新增接口权限码时同批补 `menus.yml`，再 `project sync`。
  提交前运行业务仓里的 `bash scripts/verify.sh`。
- `project new` 根据项目配置生成基础脚手架；取回后在业务仓中开发数据模型和业务功能。项目编码一经生成不可重复生成。
- 取回的两个仓库自带各自的 `AGENTS.md`，后续开发在那两个仓里进行。推送到用户自己的 Git 服务前，
  先确认远端仓库为空，不做 force push。
- 修改 Docker、代理或系统配置，重启任何服务，或清理磁盘之前，先向用户说明影响并取得同意；
  清理只限缓存和构建产物，不删除会话记录等用户数据。

## 仓库长什么样

`./kaiwu up` 之后：

```text
workspace/
├── kaiwu-system-service    # 控制面后端、项目工厂、统一启动器、Helm Chart
├── kaiwu-gateway-service   # 唯一外部 API 入口：认证、会话、显式路由
├── kaiwu-system-web        # 平台管理前端
├── kaiwu-system-starter    # 业务服务接入 SDK
└── kaiwu-deploy            # 可选，执行 ./kaiwu deploy-init 后才出现
```

五个仓各自独立提交、独立发布。**改产品代码要进对应的仓改，不要在入口仓里改。**
每个产品仓根目录都有自己的 `AGENTS.md` 和 `CLAUDE.md`，进去先读那两份。

`workspace/` 已被本仓 `.gitignore` 忽略，不会形成嵌套提交。

## 接下来读哪份

| 你要做什么 | 读哪里 |
| --- | --- |
| 十分钟搞懂它怎么运作 | `docs/HOW-IT-WORKS.md` |
| 搞清楚五个仓各管什么 | `docs/REPOSITORIES.md` |
| 第一次完整走一遍 | `workspace/kaiwu-system-service/docs/QUICKSTART.md` |
| 本地起停、登录与取回项目 | `workspace/kaiwu-system-service/docs/QUICKSTART.md` |
| 部署到一台服务器 | `workspace/kaiwu-system-service/docs/SERVER-DEPLOYMENT.md` |
| 部署到 Kubernetes | `workspace/kaiwu-system-service/docs/KUBERNETES.md` |
| 接自己已有的 MySQL / Redis | `workspace/kaiwu-system-service/docs/SERVER-DEPLOYMENT.md`（Compose）或 `docs/KUBERNETES.md`（Helm） |
| 用 Nacos 管理运行配置 | `workspace/kaiwu-system-service/docs/NACOS.md`，配置模板在同仓 `deploy/nacos/` |
| 理解架构与历史决策 | `workspace/kaiwu-system-service/docs/ARCHITECTURE.md` 与 `docs/adr/` |
| 在平台上生成一个业务项目 | `workspace/kaiwu-system-service/docs/PROJECT_FACTORY.md` |

还没执行 `./kaiwu up` 时，上表中 `workspace/` 开头的路径尚不存在；可以直接到
对应的产品仓浏览同名路径。

## 这个仓里的硬约束

- **不要把任何组织专有信息写进来**：主机名、内网 IP、镜像仓库地址、Git 组织地址、
  邮箱域名。组织地址由 `./kaiwu` 从 git origin 自动推导，或由
  `KAIWU_REPOSITORY_BASE_URL` 显式覆盖。
- 提交前跑 `bash scripts/check.sh`。它会验证入口脚本的行为，并扫描组织内地址与
  私网 IP；命中即失败。
- 入口只认识 `kaiwu-system-service`。其余仓的清单由 System 仓的
  `kaiwu-workspace.env` 维护，避免出现第二份事实源——**不要在入口仓里另列一份仓库表。**
- 不引入 submodule。版本一致性由同名 tag 与 `workspace/.kaiwu/workspace.lock` 保证。
- 不要直接在受保护分支上实现；需要时创建描述性的 feature/fix 分支。

## 版本与 Fork

```bash
KAIWU_REPOSITORY_BASE_URL=https://github.com/kaiwuzaidao ./kaiwu repositories
KAIWU_REPOSITORY_REF=v0.2.0 ./kaiwu up
```

正式发行时入口与五个产品仓使用**同名不可变 tag**。初始化时发现同名 tag 缺失必须
失败，不允许回退到默认分支。
