# Kaiwu 开源入口 · Agent 指引

你现在在 **入口仓**。它不含产品源码，只负责三件事：把五个产品仓取到
`workspace/`、用一条命令把平台跑起来、告诉你接下来该读哪份文档。

## 先做这一步

```bash
./kaiwu doctor   # 检查 Git / Docker Compose v2 / OpenSSL 是否就绪
./kaiwu up       # 取仓 + 构建 + 启动，完成后访问 http://127.0.0.1:8000
./kaiwu credentials   # 初始管理员账号与随机初始密码
```

`./kaiwu up` 会从源码构建镜像，基础镜像全部来自公共仓库，不需要任何私有凭据。
第一次构建需要拉 Maven 与 npm 依赖，耗时取决于网络。

失败时先看 `./kaiwu doctor` 的输出，再看 `./kaiwu logs`；不要绕过脚本直接敲
`docker compose`——端口、密钥与 Compose 文件的组合由脚本负责生成。

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
| 本地开发与调试 | `workspace/kaiwu-system-service/docs/QUICKSTART.md` |
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
KAIWU_REPOSITORY_REF=v0.1.0 ./kaiwu up
```

正式发行时入口与五个产品仓使用**同名不可变 tag**。初始化时发现同名 tag 缺失必须
失败，不允许回退到默认分支。
