# Kaiwu · 开物载道

[Kaiwu website](http://kaiwu.shengzhiweilai.online/en/) · [Live demo](http://kaiwu.shengzhiweilai.online/try/index.html?lang=en) · [Quick start guide](http://kaiwu.shengzhiweilai.online/en/start) · [GitHub](https://github.com/kaiwuzaidao/kaiwu) · [Gitee](https://gitee.com/wujm12138/kaiwu) · [简体中文](README.md)

Kaiwu is a platform for developing and delivering enterprise applications with AI.

## Quick start

[Explore the workbench](http://kaiwu.shengzhiweilai.online/try/index.html?lang=en) without signing in. To build your own application, give this prompt to a coding agent with access to your local terminal.

```text
Get the latest stable Kaiwu release from https://github.com/kaiwuzaidao/kaiwu and follow AGENTS.md to start it locally. Ask what I want to build, then set up its backend and frontend.
```

## Run v0.2.0 locally

Install Git, Docker with Compose v2, OpenSSL and curl. This starts MySQL locally and uses the release images from GHCR on amd64 or arm64.

For a new installation, find the tag on the [latest release page](https://github.com/kaiwuzaidao/kaiwu/releases/latest). The example uses `v0.2.0` to reproduce the screenshots. Substitute your chosen release tag when installing another version.

```bash
git clone --branch v0.2.0 --depth 1 https://github.com/kaiwuzaidao/kaiwu.git
cd kaiwu
./kaiwu doctor
KAIWU_DB_TYPE=mysql ./kaiwu up
```

Open <http://127.0.0.1:8000>, sign in as `admin` with the randomly generated password printed in the terminal, and change it when prompted. Use `./kaiwu credentials` to show the initial credentials again. Run `./kaiwu down` to stop the stack and keep its data. Model configuration is optional for the project factory.

For an existing installation, read the [upgrade guide](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/UPGRADING.md). DM8 requires a prepared instance and schema. [Database setup](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/DATABASES.md) · [MySQL and DM8 initialization SQL](https://github.com/kaiwuzaidao/kaiwu-system-service/releases/tag/v0.2.0)

## How applications use the platform

Each project has its own Spring Boot backend, React frontend and business database. Your team owns the source and decides when to test and release it.

For example, a purchasing app and an inventory app can use the same employee accounts while granting access separately. Your coding agent can change a stock-count rule in the inventory repositories. The app can reuse managed dictionaries and translations, connect file storage for attachments or add Excel for bulk imports.

The project factory generates the initial repositories. Your agent implements features there, previews menu and permission changes and runs the repository checks. Review account access when prompted and use the Git diff and test results to review changes. [AI development guide](http://kaiwu.shengzhiweilai.online/en/ai-development) · [CLI reference](http://kaiwu.shengzhiweilai.online/en/commands)

![Kaiwu workbench showing project entries and tasks for the signed-in member](docs/assets/workbench.png)

## Generate an application

Open project management in the browser or run the commands below from the entry repository. Approve the CLI device request in your browser. Replace the example project name and code with your own.

```bash
./kaiwu login --client "kaiwu-demo"
./kaiwu project new order-center --name "Order Center"
./kaiwu project status order-center --wait
./kaiwu project pull order-center
./kaiwu project-up ../business/order-center-service ../business/order-center-web
```

The two independent Git repositories are created in the adjacent `business/` directory. Once the local build finishes, open the application from the workbench. For an existing project, start with the status command. [Full walkthrough](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/QUICKSTART.md)

In v0.2.0 a generated app can fail to start because its JAR lacks resources or Nginx cannot read its configuration. Verify it from the workbench. [Startup fix](https://github.com/kaiwuzaidao/kaiwu-system-service/pull/1)

![Successful project generation with separate backend and frontend ZIP downloads](docs/assets/project-factory.png)

## Platform capabilities

| Task | How it works |
| --- | --- |
| Control access to business data | Assign members and roles per project, configure resource-specific data scopes and apply row filters in a MyBatis-Plus backend. [Data scopes](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/DATA_SCOPE.md) |
| Deliver configuration with code | Keep menus, dictionaries, settings and translations in the backend repository. Preview changes with `project sync`, then apply them explicitly. Project administrators can also transfer configuration across environments. [Project factory](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/PROJECT_FACTORY.md) |
| Route work to a user | Business services open and close tasks by business key. Assignees see their tasks on the workbench. [Unified tasks](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/UNIFIED_TODO.md) |
| Add file and spreadsheet support | Bind storage to a project, issue prefix-scoped temporary credentials and opt in to file registration. Excel import and export is a separate dependency. [Starter repository](https://github.com/kaiwuzaidao/kaiwu-system-starter/tree/v0.2.0) |
| Connect a model and project actions | Select models for planning and answering, keep personal conversations and expose approved project actions. Remote writes require confirmation. [Assistant integration](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/adr/0030-agent-cross-project-capabilities.md) |

The Maven Central group is `com.kaiwuzaidao`. Use version `0.2.0` of `kaiwu-system-starter` for platform integration, `kaiwu-data-scope` for row filtering, or `kaiwu-excel` for spreadsheet support.

## Further reading

- [Illustrated platform guide (Chinese)](docs/HOW-IT-WORKS.md) · [Repository map (Chinese)](docs/REPOSITORIES.md)
- [Single-server deployment](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/SERVER-DEPLOYMENT.md) · [Kubernetes deployment](https://github.com/kaiwuzaidao/kaiwu-system-service/blob/v0.2.0/docs/KUBERNETES.md)
- [Coding agent guide](AGENTS.md) · [Contributing](CONTRIBUTING.md) · [Changelog](CHANGELOG.md)

[Apache License 2.0](LICENSE) · [Trademark policy](TRADEMARKS.md#trademark-policy-english)
