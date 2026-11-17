# 从订单中心看 Kaiwu v0.3.0

如果你的团队要做一个订单后台，可以先在 Kaiwu 开通项目。平台管理谁能进入后台，项目工厂给出可运行的前后端起点；订单表、定价规则和履约流程由业务团队在自己的仓库中开发。下面的截图取自 MySQL 空库启动的公开版本，示例项目为 `order-center`。

## 从开通项目到接手源码

在工作台点「开通项目」，填写项目名称和编码。生成任务完成后，「项目工厂」提供后端 ZIP 和前端 ZIP。也可以用 CLI 生成并取回两个 Git 仓库，命令见[首页的完整示例](../README.md#生成第一个项目)。

![项目工厂中订单中心任务已成功，页面提供两个 ZIP 下载入口](assets/project-factory.png)

每个项目编码只生成一次。业务团队在独立仓库里维护表结构、菜单声明、接口和测试。生成的后端提供 Flyway 迁移、Starter 接入和权限检查；前端提供应用外壳、菜单、字典和权限组件。本机用 `project-up` 接入后，成员可从工作台打开业务后台。[项目工厂与交付方式](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/PROJECT_FACTORY.md)

## 成员能进哪个项目，能看哪些数据

「项目管理」同时列出平台内置项目 `system` 和订单中心。打开哪一行的「权限中心」，就在哪个项目内管理成员、角色和菜单。图中订单中心的代码已经生成，业务后台地址还没有配置。

![项目管理中的 Kaiwu System 与订单中心](assets/projects.png)

下图是内置项目的权限菜单，其中有工作台等菜单，也有具体操作的权限码。业务项目使用同一套模型，在自己的后端仓维护 `kaiwu/menus.yml`；前端按钮可见性和后端操作校验共用权限码。

![内置项目权限中心，展示平台菜单、按钮和权限码](assets/permissions.png)

浏览器通过 Web 访问 Gateway。Gateway 验证登录会话、确认项目访问权限，再签发绑定目标服务的短期 Context。业务服务用 Starter 本地验证 Context。需要限制记录范围时，管理员可按角色和资源选择「仅本人」「本部门」等范围，业务端声明要保护的表，再接入 `kaiwu-data-scope`。[项目接入](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/PROJECT_ACCESS.md) · [数据范围配置与接入](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/DATA_SCOPE.md)

## 让配置跟着项目走

项目字典可以继承全局默认项。图中左侧选中了「数据范围类型」，右侧列出标签和稳定的字典值。用户看到的中文或英文可以变化，代码通过字典值判断业务状态。

![字典管理中显示数据范围类型及其字典值](assets/dictionary.png)

开发时，先在业务后端仓维护菜单、字典、参数和多语言清单，再预览将要写入的内容：

```bash
./kaiwu project sync ../business/order-center-service
./kaiwu project sync ../business/order-center-service --apply
```

跨环境时，在项目权限中心打开「配置移交」。源环境导出移交包，目标环境先预览差异，再选择要应用的条目。角色授权和删除要单独勾选，成员和密钥留在各自环境。[配置移交规则](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/adr/0042-project-config-handover.md)

![订单中心的配置移交面板，提供导出、导入预览和移交记录](assets/handover.png)

## 让业务事件回到工作台

假设订单需要复核，业务服务可以按业务键向处理人投递待办。同一项目、业务键和处理人的重复投递会更新已有待办。复核完成或订单撤销时，由业务服务关闭或取消待办，工作台随之更新。成员从待办进入对应项目，业务状态仍由订单中心维护。[统一待办接入示例](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/UNIFIED_TODO.md)

有附件的项目还可绑定对象存储。业务服务按项目前缀申请临时凭据，文件记录由业务库保存。使用者可按需启用文件登记、附件挂载和孤儿清理。[项目对象存储](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/adr/0039-project-object-storage-via-sts.md)

## 助手如何选择模型

管理员在「大模型配置」添加兼容的提供方，再分配任务识别模型和回答模型。已有默认配置时，两种用途均可复用它。下图是新安装的实际状态，尚未接入模型。

![大模型配置中独立的任务识别模型和回答模型选择器](assets/model-routing.png)

助手支持个人对话和已审核的项目能力。查询按用户对目标项目的授权执行；涉及写入时，用户先确认操作。项目工厂生成基础脚手架可以独立运行。[模型用途分配](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/adr/0043-agent-multi-model-routing.md) · [跨项目能力](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.3.0/docs/adr/0030-agent-cross-project-capabilities.md)

[启动平台](../README.md#在本机启动-v020) · [查看五个产品仓](REPOSITORIES.md)
