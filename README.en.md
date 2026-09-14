# Kaiwu

*[中文](README.md) · English*

> Take a back-office project from "can be generated" to "can be understood, verified, and
> maintained for years."

Kaiwu is a general-purpose back-office development platform for delivering many projects.
Users, projects, permissions, menus, dictionaries, configuration, i18n, auditing, a single
entry point, and a deterministic project scaffold all live in one governance plane — while
every business project is delivered as its own frontend and backend repositories, its own
database, and its own deployment boundary.

AI is not a prerequisite. You can generate an empty scaffold, or let a model draft a
constrained first blueprint. After delivery, keep using whatever your team already uses —
an IDE, Codex, Claude Code, Cursor, Trae, or anything else.

## Five minutes to a running platform

You need Git, Docker Compose v2, and OpenSSL — nothing else:

```bash
git clone <this repository> kaiwu
cd kaiwu
./kaiwu doctor
./kaiwu up
```

When the readiness message appears, open [http://127.0.0.1:8000](http://127.0.0.1:8000).
The randomly generated initial password is printed in the terminal, and you can print it
again with:

```bash
./kaiwu credentials
```

The first run needs no AI provider, no Nacos, no Kubernetes, no ArgoCD, and no external
MySQL or Redis. Images are built from source; every base image comes from a public
registry, so no private credentials are involved.

## Pick your route

| I want to | Go to |
| --- | --- |
| Try the platform | `./kaiwu up`, then follow the workbench to create a basic project |
| Build my first business project | Download the standalone backend and frontend from the project factory, continue in your own tools |
| Deploy to one server | `docs/SERVER-DEPLOYMENT.md` in the `kaiwu-system-service` repository |
| Deploy to Kubernetes (Helm) | `docs/KUBERNETES.md` in `kaiwu-system-service`; the chart is at `deploy/helm/kaiwu` |
| Deploy to Kubernetes (GitOps) | Run `./kaiwu deploy-init` to fetch `kaiwu-deploy`, then follow the guide above |
| Understand how it works | [How Kaiwu works](docs/HOW-IT-WORKS.md) — ten minutes |
| Hand this to an AI coding tool | [AGENTS.md](AGENTS.md) — the entry point for Codex, Claude Code, Cursor, Trae |
| Contribute | [CONTRIBUTING.md](CONTRIBUTING.md) and the [repository map](docs/REPOSITORIES.md) |

> Documents listed under `kaiwu-system-service` appear in
> `workspace/kaiwu-system-service/docs/` after `./kaiwu up` or `./kaiwu init`. Before that,
> browse the same paths in that repository directly.

## What it actually solves

- **Full platforms are too heavy.** One business project drags in a pile of unrelated
  modules and historical conventions.
- **Low-code boundaries are unclear.** Fast at first; extension, debugging, and migration
  get expensive once real complexity arrives.
- **Copied scaffolds drift.** The first and the fifth project in the same organisation stop
  looking like the same engineering.
- **AI context windows are finite.** When platform and business facts share one giant repo,
  the search surface is too large and edits miss things.
- **AI output runs but cannot ship.** Permissions, migrations, logging, security, CI, and
  deployment contracts are missing.
- **Platform and business code get entangled.** Upgrading the platform risks overwriting
  business code; business change drags the platform.

Kaiwu answers these with a thin platform, independent business repositories, constrained
blueprints, deterministic templates, and executable engineering gates.

The project factory generates each project **once**. After you have the two repositories,
Kaiwu never overwrites your business source again.

## Repositories

This entry repository holds no product source. After the first run, `workspace/` contains
four runtime repositories; a fifth is added when you choose Kubernetes/GitOps:

```text
workspace/
├── kaiwu-system-service       # Control plane, unified launcher, Helm chart
├── kaiwu-gateway-service      # The only external API entry
├── kaiwu-system-web           # Platform admin frontend
├── kaiwu-system-starter       # SDK for business services
└── kaiwu-deploy               # Optional, added by ./kaiwu deploy-init
```

They stay separate Git repositories. `workspace/` is ignored here, so no nested commits.
No submodules: ordinary users get a matching workspace from one command, while maintainers
keep committing, testing, and releasing in their own repositories.

## Forks, self-hosted Git, and versions

Releases use the **same immutable tag** across the entry and all product repositories.
Override the organisation or the version explicitly:

```bash
export KAIWU_REPOSITORY_BASE_URL='https://github.com/kaiwuzaidao'
export KAIWU_REPOSITORY_REF='v0.1.0'
./kaiwu repositories
./kaiwu up
```

The entry never overwrites an existing repository and never switches your branch. Actual
product commits are recorded in `workspace/.kaiwu/workspace.lock` so a problem can be
reproduced.

## Project philosophy

1. A business project must be able to leave the platform and still be developed and deployed.
2. AI may participate in design, but is never required to create or continue a project.
3. Models produce validated blueprints; source and engineering files are rendered
   deterministically from versioned templates.
4. Permissions, migrations, logging, security, CI, and deployment are not attachments added
   after generation.
5. User-facing text may change; permission codes, status codes, and service protocols must
   stay stable.
6. Only ship capabilities a developer can understand, verify, and maintain.

## License

[Apache License 2.0](LICENSE).
