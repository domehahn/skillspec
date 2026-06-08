# skillspec

`skillspec` is the vendor-neutral specification package for AI Agent Skills. It defines the common schemas, package layout rules, lockfile format, registry API contract, and compatibility conventions shared by the `skcr`, `skpm`, SkillForge, and `skforge` toolchain.

This repository contains no implementation code. It is specification-first.

---

## Why skillspec exists

Four tools share the same data formats:

| Tool | Role |
| --- | --- |
| `skcr` | Creates skill skeletons and renders project/platform structures |
| `skpm` | Generic skill package manager and lifecycle manager |
| SkillForge | Concrete skill registry server |
| `skforge` | SkillForge-native CLI and admin tool |

Without a shared specification, these tools drift apart. `skillspec` is the single source of truth for every format each tool reads or writes.

---

## What this repository contains

```text
skillspec/
├── README.md                              <- this file
├── schemas/
│   ├── skill.schema.json                  <- validates skill.yaml
│   ├── agent-skills.schema.json           <- validates agent-skills.yaml
│   ├── agent-skills-lock.schema.json      <- validates agent-skills.lock
│   └── package-manifest.schema.json       <- validates manifest.json in artifacts
├── openapi/
│   └── registry-api-v1.openapi.yaml      <- registry HTTP API contract
├── docs/
│   └── package-layout.md                  <- canonical source and package layout rules
└── examples/
    ├── skill.yaml
    ├── agent-skills.yaml
    ├── agent-skills.lock.yaml
    └── package/
        ├── SKILL.md
        ├── VERSION
        ├── skill.yaml
        ├── CHANGELOG.md
        └── README.md
```

---

## Four-level versioning model

Skills participate in four distinct versioning layers:

```text
1. Source versioning      -> Git
                             The skill source tree is committed and tracked in version
                             control. Git provides history, authorship, and branching.

2. Skill versioning       -> SemVer per skill
                             Each skill carries its own version in skill.yaml and VERSION.
                             Skills follow Semantic Versioning (MAJOR.MINOR.PATCH).

3. Package versioning     -> Immutable artifact
                             A packaged skill (ZIP or TGZ) is an immutable artifact
                             identified by name, version, and SHA256 digest. Once
                             published, a version cannot be mutated.

4. Consumption versioning -> Pinned lockfile
                             Projects declare desired constraints in agent-skills.yaml.
                             skpm resolves and pins exact versions and checksums into
                             agent-skills.lock. The lockfile is committed to the consuming
                             repository.
```

---

## Canonical skill source layout

```text
skills/<name>/
├── SKILL.md        <- agent-readable entrypoint (required)
├── VERSION         <- plain-text version matching skill.yaml (required)
├── skill.yaml      <- machine-readable metadata (required)
├── CHANGELOG.md    <- version history (required)
├── README.md       <- human-readable documentation (recommended)
├── LICENSE         <- license file (recommended)
├── examples/       <- example invocations or inputs (optional)
└── tests/          <- test fixtures or validation scripts (optional)
```

`skills/<name>/` is the canonical source location. Subdirectory names must match the `name` field in `skill.yaml`.

---

## Source skills vs generated platform output

A skill source directory is not the same as generated platform output.

`skcr` renders platform-specific output from the canonical skill source. Platform output typically contains only `SKILL.md` — the agent-readable entrypoint — placed in a location the target agent platform reads from.

```text
skills/my-skill/            <- canonical source (committed, packaged, published)

.agents/skills/my-skill/    <- generated platform output for generic agents
.claude/skills/my-skill/    <- generated platform output for Claude Code
.github/skills/my-skill/    <- generated platform output for GitHub Copilot
```

Platform output should not be confused with the skill package. Platform output is generated. The package artifact is the canonical distributable.

---

## Tool responsibilities

### skcr

- Creates `agentic.bake.yaml` (project bake configuration)
- Creates canonical skill source directories (`skills/<name>/`)
- Renders platform and project structures from skill sources
- Generates platform output (e.g. `.agents/skills/<name>/SKILL.md`)

`skcr` does not manage package versions, publish to registries, or manage lockfiles.

### skpm

- Validates skill sources against `skill.schema.json`
- Manages `VERSION` and `skill.yaml` version consistency
- Packages skills into immutable ZIP or TGZ artifacts
- Publishes packages to configured registries
- Manages `agent-skills.yaml` (the project manifest)
- Resolves version constraints and generates `agent-skills.lock`
- Installs and verifies locked skill artifacts against expected SHA256 digests
- Updates skills within constraint bounds

`skpm` is the generic package manager. It is not SkillForge-specific.

### SkillForge

- Stores immutable skill package artifacts
- Exposes the registry API defined in `openapi/registry-api-v1.openapi.yaml`
- Provides search, info, resolve, download, and publish operations
- Manages registry metadata, authentication, audit logs
- Supports deprecate and yank operations for governance

SkillForge is one registry implementation. `skpm` can work with other registry types.

### skforge

- Native CLI for SkillForge-specific administrative operations
- Complements `skpm` for SkillForge-specific features not in the generic manager
- Not a substitute for `skpm` as the general lifecycle tool

---

## Schemas

All schemas use JSON Schema Draft 2020-12.

| Schema | File | Validates |
| --- | --- | --- |
| Skill metadata | `schemas/skill.schema.json` | `skill.yaml` in each skill source |
| Project manifest | `schemas/agent-skills.schema.json` | `agent-skills.yaml` in consuming projects |
| Resolved lockfile | `schemas/agent-skills-lock.schema.json` | `agent-skills.lock` generated by `skpm` |
| Package manifest | `schemas/package-manifest.schema.json` | `manifest.json` inside packaged artifacts |

Schema `$id` base: `https://skillspec.dev/schemas/`

---

## Registry API contract

`openapi/registry-api-v1.openapi.yaml` defines the HTTP API that all compatible skill registries must implement.

Key endpoints:

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/api/v1/capabilities` | Declare supported features |
| GET | `/api/v1/skills` | List/search skills |
| GET | `/api/v1/skills/{namespace}/{name}` | Skill info |
| GET | `/api/v1/skills/{namespace}/{name}/versions` | List versions |
| GET | `/api/v1/skills/{namespace}/{name}/resolve` | Resolve a version constraint |
| GET | `/api/v1/skills/{namespace}/{name}/versions/{version}` | Version metadata |
| GET | `/api/v1/skills/{namespace}/{name}/versions/{version}/download` | Download artifact |
| PUT | `/api/v1/skills/{namespace}/{name}/versions/{version}` | Publish artifact |
| POST | `/api/v1/skills/{namespace}/{name}/versions/{version}/deprecate` | Deprecate version |
| POST | `/api/v1/skills/{namespace}/{name}/versions/{version}/yank` | Yank version |
| POST | `/api/v1/skills/{namespace}/{name}/versions/{version}/unyank` | Unyank version |

Clients must call `/capabilities` first and adapt behavior based on the features reported.

---

## Platform compatibility

Canonical platform identifiers used throughout this specification:

```text
codex
claude-code
gitlab-duo
github-copilot
cursor
windsurf
openhands
opencode
ollama
generic
all
```

`all` means the skill is compatible with every platform.
`generic` means the skill targets platforms not otherwise named.

---

## Production recommendations

- **Always use pinned versions in production.** Declare exact version constraints or exact versions in `agent-skills.yaml`.
- **Commit `agent-skills.lock`.** The lockfile captures exact versions and checksums. Treat it like `package-lock.json` or `Cargo.lock`.
- **Never use `latest` in production.** `latest` is permitted for local experiments only. It must not appear in committed lockfiles.
- **Verify checksums on install.** `skpm` verifies SHA256 digests against locked values on every install.
- **Pin by digest when possible.** Registries may support digest pinning in addition to version pinning.

---

## Specification versioning

This specification is at version `v1`. The OpenAPI contract path prefix is `/api/v1`. Schema `$id` values use `/v1/` in the path.

Breaking changes to schemas or the API contract will increment the version. Additive changes may be made within a version using forward-compatible extension fields.
