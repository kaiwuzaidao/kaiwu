# Kaiwu 是怎么运作的

十分钟读完，用来判断 Kaiwu 是否适合你的团队。

这是**导览**，不是规范。每一节末尾都指向真正的事实源；出现分歧时以产品仓文档为准。

## 五个仓，各自独立

Kaiwu 不是一个大仓库。你现在看到的入口只有主页、初始化脚本和导航，产品源码在五个
独立仓库里，各自有自己的 Git 历史、CI、版本和发布节奏。

```mermaid
flowchart TB
    subgraph 运行件
        GW["kaiwu-gateway-service<br/>唯一外部入口 · 8088"]
        SYS["kaiwu-system-service<br/>控制面后端 · 8080"]
        WEB["kaiwu-system-web<br/>管理前端 · 8000"]
    end
    SDK["kaiwu-system-starter<br/>业务服务接入 SDK · 发到 Maven 仓"]
    DEPLOY["kaiwu-deploy<br/>GitOps 部署声明 · 可选"]

    WEB -->|"/api"| GW
    GW --> SYS
    SDK -.被生成的业务服务依赖.-> GW
    DEPLOY -.声明环境值.-> SYS
```

前三个是进程，`kaiwu-system-starter` 是给业务服务用的 SDK（不是运行进程），
`kaiwu-deploy` 只在你走 Kubernetes/GitOps 时才需要。

> 详见 [仓库地图](REPOSITORIES.md)

## 一个请求怎么走

理解 Kaiwu 的最快方式是跟着一个请求走一遍：

1. 浏览器请求 `/api/projects`，打到 **Web** 的 nginx
2. nginx 把 `/api` 反代给 **Gateway**（前端不直连后端，这条是硬约束）
3. Gateway 验证 Access JWT 与 Redis 里的在线会话
4. Gateway 按 Route 声明的访问模式决定策略；若是业务项目接口，还要向 System 确认
   调用者确实是该项目的有效成员
5. Gateway 签发一枚 **60 秒、绑定目标服务 audience** 的内部 Context，转发请求
6. **System** 或业务服务用 Starter **本地验证**这枚 Context，不再回头询问平台

第 6 步是关键：正常业务请求**不会**产生"业务服务 → 平台"的同步调用。平台不会成为
每个业务请求的性能瓶颈和故障点。

## 三条边界

Kaiwu 的多数设计可以归结为三条边界，它们解释了为什么架构长这样。

**① Gateway 不持有权限事实**

Gateway 只做身份、会话、项目成员三件事，没有数据库连接，不执行业务规则。
权限的唯一事实源是 System。这样做的代价是 Gateway 需要向 System 查项目授权（带缓存），
换来的是不会出现两套会漂移的权限数据。

**② Kaiwu 自己也是一个项目**

平台的成员、角色、菜单、登录权限，全部存在一个 `project_code=system` 的内置项目下，
和业务项目走完全相同的表和相同的授权路径。没有"平台专用"的特权旁路。

![项目管理](assets/projects.png)

上图里 `Kaiwu System` 和两个业务项目在同一张列表、同一套操作入口下。区别只有一处：
它标着"内置"，停用与归档是灰的——平台自身不能被自己停用，其余一视同仁。

**③ 生成的项目必须能离开平台**

项目工厂对每个项目**只生成一次**，产出独立的前后端仓库、独立数据库、独立部署边界。
生成完成后 Kaiwu 不再碰业务源码——你用自己的 IDE、自己的 AI 工具、自己的 CI 继续开发。
平台升级不会覆盖你的业务代码，你的业务变化也不会反向拖住平台。

![项目权限中心](assets/permissions.png)

上图是业务项目 `reimburse` 的权限菜单：菜单树、按钮和 `mod:res:act` 权限码在同一处维护，
后端注解、前端按钮与菜单 SQL 使用同一个权限码，由 CI 校验三处一致。

> 详见各产品仓的 `docs/ARCHITECTURE.md` 与 ADR 目录

## AI 在哪一步

AI 是**可选的**，且被限制在一个很窄的位置：

```
你的业务描述（可选：现有库的 DDL）
        ↓
   AI 产出受校验的 ProjectBlueprint      ← AI 只走到这里
        ↓
   确定性模板渲染出源码与工程文件        ← 这一步没有 AI
        ↓
   独立前后端仓库
```

模型产出的是**受约束的结构化蓝图**，不是源码。源码由版本化模板确定性渲染——
同样的蓝图永远渲染出同样的代码。不配置 AI 也可以用基础脚手架开通项目。

这样做是因为：大模型能写出能跑的代码，但难以稳定产出带权限、迁移、日志、安全、CI
和部署契约的**可交付**代码。把 AI 放在设计环节、把确定性留给生成环节，两边都发挥了长处。

> 详见 `kaiwu-system-service/docs/PROJECT_FACTORY.md`

## 生成出来的项目长什么样

不是一个空壳。每个生成的后端仓库自带：

- 三模块结构、分页边界、统一异常与响应
- Flyway 迁移脚本与权限菜单 SQL
- 接入 Starter 的鉴权、字典、配置、站内信、定时任务
- 约定测试（架构依赖、分页上限、敏感日志、API 兼容基线）
- `CLAUDE.md` 与 `AGENTS.md`，写明路径、构建命令、权限/字典/Context 契约和常见坑

最后一条是给 AI Coding 工具准备的：你的团队接手后继续用 Claude Code、Codex 或 Cursor
开发时，这些文件让工具知道该守什么规矩。

## 工程约束是可执行的

Kaiwu 把权限三端同码、字典使用、迁移前向性、分页上限、敏感日志、服务寻址等约束
写成了 CI 门禁，而不是文档里的建议。约束目录在
`kaiwu-system-service/docs/kaiwu-constraints.json`，每条都标注了强度、理由和执行方式。

这意味着违反约定的代码**会让构建变红**，而不是等到 code review 或线上事故。


![字典管理](assets/dictionary.png)

字典是其中一例：需要翻译或运营配置的业务状态统一走字典组件，新增受管字典必须
后端 seed 与前端 fallback 同批提交，由 `pnpm check:dict` 校验。

> 详见 ADR 0020「风险分级的工程约束」

## 国际化怎样保持一致

Kaiwu 不把国际化理解成前端里多放几份 JSON。用户语言偏好保存在 System，换浏览器登录可以恢复；
固定界面、跨服务错误、动态菜单和全局字典沿同一语言目录工作。Gateway、System 和 Starter 返回
稳定的 `messageKey/messageArgs`，翻译不会改变状态码、权限码、字典值、19 位 ID 或 Context。

初始完整语言是 `zh-CN` 和 `en-US`。新语言只有在必需资源、内置菜单和全局字典全部覆盖后才会
出现在选择器中，避免把“能够选择”误当成“已经可用”。资源加载失败时保留上一份完整快照，不因
翻译服务异常清除会话或写入不完整偏好。

国际化也遵守业务所有权边界：平台不会把语言资源回写到已经生成成功的业务仓。业务项目需要支持
哪些语言、字段和内容，由业务团队在自己的前后端仓库中持续维护。

> 详见 `kaiwu-system-service/docs/REQUIREMENTS.md` 4.9 与 ADR 0011

## 接下来

| 你想 | 去哪 |
|---|---|
| 跑起来看看 | 回到 [主页](../README.md) 的「5 分钟开始」 |
| 了解仓库怎么分工 | [仓库地图](REPOSITORIES.md) |
| 读完整架构设计 | `kaiwu-system-service/docs/ARCHITECTURE.md` |
| 看每个决策的来龙去脉 | `kaiwu-system-service/docs/adr/` |
| 参与开发 | [CONTRIBUTING.md](../CONTRIBUTING.md) |
