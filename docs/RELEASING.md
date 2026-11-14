# v0.2.0 发版手册（维护者草案）

公开发行版本从 v0.1.0 直接到 v0.2.0。GHCR 中的 0.1.1 镜像是手动补发的中间产物，保留原样。一次正式发行以入口和五个产品仓的同名不可变标签为准。

## 1. 固定候选提交

从内部主线确定六仓候选提交，记录提交号、版本和对应变更日志。逐仓生成公开导出树，核对内容与路径扫描均为零命中，检查导出后的许可证、构建与测试结果。记录实际对外发布的 GitHub 提交号，导出提交和内部提交可能不同。发布期间固定 Starter 候选内容，主库、数据范围和 Excel 三个 POM 的版本应同为 `0.2.0`。

## 2. 由维护者发布到 Maven Central

从已审核的 Starter 候选提交构建。核对三个组件的 POM 元数据、主 JAR、sources JAR、javadoc JAR 及签名。确认 release profile 的 `autoPublish=false`，Central Portal 中由维护者人工点击 **Publish**。发布凭据通过维护者已有的 Maven 配置提供。每次签名都显式传入 `-Dgpg.keyname`，值选用维护者的发布密钥。

在 Starter 仓根目录依次执行下列命令。先发布主库，data-scope 的生成与解析需要同版主库。Excel 在最后发布，便于按同一顺序检查三个坐标。每次上传后核对 Portal 中的坐标、版本、校验结果及签名，确认无误再人工 Publish。主库已能从 Central 解析后再处理 data-scope。

```sh
mvn -Prelease -Dgpg.keyname="维护者的发布密钥" deploy
mvn -f data-scope/pom.xml -Prelease -Dgpg.keyname="维护者的发布密钥" deploy
mvn -f excel/pom.xml -Prelease -Dgpg.keyname="维护者的发布密钥" deploy
```

在独立的空目录中，以全新的 Maven 本地仓库验证公开坐标。使用只访问 Maven Central 的 Maven 环境，避免私有镜像或已有的本地安装掩盖缺失制品。三个坐标全部能解析，再放行使用它们的脚手架。

```sh
cache=$(mktemp -d)
for artifact in kaiwu-system-starter kaiwu-data-scope kaiwu-excel; do
  mvn -B -U "-Dmaven.repo.local=$cache" dependency:get \
    "-Dartifact=com.kaiwuzaidao:$artifact:0.2.0" || exit 1
done
```

## 3. 确认公开主线，再按顺序打标签

将评审通过的产品仓 dev 候选提交依次合入 main，入口仓按自身流程合入 main。采用内部主线的导出流水线时，先配置覆盖本次发行标签的保护规则，限定维护者创建，并确认发布任务可使用其受保护凭据。在内部 main 的已核验提交上创建发行标签，由流水线完成导出扫描、更新 GitHub main 和创建同名公开标签。公开标签随后触发 GitHub Actions 构建 GHCR 镜像。每个产品仓完成这一流程后再处理下一个仓。核对各仓公开主线的导出结果和候选版本。用同一标签 `v0.2.0` 依次发布 Starter、System Service、Gateway Service、System Web、Deploy，最后标记入口。每次均在对应 GitHub 仓用 `git ls-remote --tags origin 'refs/tags/v0.2.0*'` 核对；若是附注标签，用剥离后的提交号与发布清单对照。入口标签一旦公开，启动器就会取其余五仓同名标签，因此须先确认这些标签和所需镜像均已就绪。System 的镜像工作流当前从 Starter 的公开默认分支取源码，因此发布 System 前还须确认 Starter 的 GitHub main 与本次标签指向同一提交，并将其保持到 System 镜像构建结束。

## 4. 核对 GHCR 与用户的启动路径

核对产品仓的 Release image 工作流和 GHCR 中的 System、Gateway、Web 镜像，使用达梦时也核对迁移器镜像。逐个检查完整版本标签 `0.2.0`、系列标签 `0.2` 和 `latest` 的镜像清单、架构与 digest。例如：

```sh
image=ghcr.io/kaiwuzaidao/kaiwu-system-service
for tag in 0.2.0 0.2 latest; do
  docker buildx imagetools inspect "$image:$tag" || exit 1
done
```

发行验收以完整版本标签为准。`0.2` 应指向本次系列版本。`latest` 受工作流的默认分支条件控制，须单独核对其实际指向；若旧标签残留或缺失，记录并按仓库的发布流程处理。将核验的版本标签与 digest 记入发布清单。

在全新目录检出入口发行标签，执行 `./kaiwu doctor` 和 `./kaiwu up`。核对实际运行镜像的版本和 digest，并检查完整启动日志。若拉取镜像后回退到本地构建，本轮预构建镜像验收失败。逐项核对 `workspace/.kaiwu/workspace.lock` 中 System 和三个运行时仓库的提交，再验证登录及就绪状态。Deploy 为可选仓；验收其检出时执行 `./kaiwu deploy-init`，再核对更新后的锁文件中 Deploy 的提交。另用 `./kaiwu up --build` 演练从源码构建。

在公开标签就绪前，可把扫描通过的六份导出树建成独立临时仓，分别标记本地 `v0.2.0`，通过只读 HTTPS 提供给启动器。仓库组地址通过 `KAIWU_REPOSITORY_BASE_URL` 指定。自签证书仅在演练进程中通过 `GIT_SSL_CAINFO` 信任。使用 Colima 时，在虚拟机可见的共享目录克隆入口，确保容器内的服务用户可以读取绑定挂载的公开配置文件。演练根目录可设为仅所有者可访问，源码按普通 Git 权限检出。用空目录复验：

```sh
export KAIWU_REPOSITORY_REF=v0.2.0
git clone --depth 1 --branch "$KAIWU_REPOSITORY_REF" "$KAIWU_REPOSITORY_BASE_URL/kaiwu.git" entry
cd entry
./kaiwu doctor
./kaiwu up --build
```

候选版项目工厂生成基础空脚手架，业务表在生成后开发，详见 System 仓的 `docs/PROJECT_FACTORY.md`。发行前分别记录两项实测结果：

- **首次安装与项目接入**。从空目录启动平台，登录并完成首次改密。创建基础脚手架，下载前后端 ZIP。后端使用独立空 Maven 仓库和公开源打包，前端从公开 npm 源安装并执行 `pnpm verify`。执行 `./kaiwu project-up`，从工作台打开生成的项目。v0.2.0 候选版已走通上述流程。四仓锁文件与演练标签一致；后端 15 项测试全部通过，前端通过 `pnpm verify`。浏览器从工作台进入订单中心后，业务页成功读取项目授权并显示空脚手架首页。使用 Colima 运行生成后端的测试时，将 `DOCKER_HOST` 指向当前实例的 Docker 套接字。
- **数据范围组件**。用独立消费项目从空 Maven 仓库解析 Central 三个同版组件，使用已发布的 JAR 和带归属列的示例表运行测试。v0.2.0 已在 MySQL 8.4 的客户、合同两张表上通过 22 项测试，包括可见行过滤、分页计数和越权更新拦截。

## 5. 更正错误与开启下一版开发

人工 Publish 前若暂存内容有误，撤销该暂存并重新核对。已公开的 GitHub 标签保持不变，Central 发布后无法撤回或覆盖。若发现版本内容错误，发布补丁版本，同步更新版本说明和镜像标签，保留原提交、标签与 digest 供追溯。

保存核验记录后，通过独立变更将各仓 POM、package.json 及适用的开发版本配置拨到下一开发版本。复核脚手架面向外部用户的正式依赖仍能在 Central 解析。
