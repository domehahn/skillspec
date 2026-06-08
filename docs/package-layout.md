# Skill Package Layout

This document defines the canonical layout for skill source directories and packaged artifacts.

---

## Canonical source layout

The authoritative location for a skill's source files is:

```text
skills/<name>/
├── SKILL.md        <- agent-readable entrypoint (required)
├── VERSION         <- plain-text version string (required)
├── skill.yaml      <- machine-readable skill metadata (required)
├── CHANGELOG.md    <- version history (required)
├── README.md       <- human documentation (recommended)
├── LICENSE         <- license file (recommended)
├── examples/       <- example invocations or inputs (optional)
└── tests/          <- test fixtures or validation scripts (optional)
```

The directory name under `skills/` must match the `name` field in `skill.yaml`.

---

## File responsibilities

### SKILL.md

The agent-readable entrypoint. This file is what the AI agent reads at runtime when the skill is invoked. It should contain:

- Clear instructions for the agent
- Input/output expectations
- Constraints and prerequisites
- Examples where helpful

`SKILL.md` is the only file agents read at runtime. Platform output usually contains only this file.

### VERSION

A plain-text file containing exactly the SemVer version string and a trailing newline. No other content.

```text
1.5.0
```

The version in `VERSION` must match the `version` field in `skill.yaml` exactly. `skpm` enforces this constraint during validation and packaging.

### skill.yaml

Machine-readable metadata for the skill. Validated against `schemas/skill.schema.json`.

Required fields: `name`, `version`, `description`, `compatible_with`, `entrypoint`.

See [schemas/skill.schema.json](../schemas/skill.schema.json) for the full schema.

### CHANGELOG.md

Version history following [Keep a Changelog](https://keepachangelog.com/) conventions. Must contain an entry for the current version before a package can be published.

### README.md

Human-readable documentation. Not read by agents at runtime. Aimed at skill authors, consumers, and contributors.

### LICENSE

License file. Required for public or shared skill packages.

### examples/

Optional directory containing example inputs, invocations, or test cases that demonstrate skill usage.

### tests/

Optional directory containing test fixtures, expected outputs, or validation scripts.

---

## Minimum package contents

A publishable skill package must contain at minimum:

```text
<name>/
├── SKILL.md
├── VERSION
├── skill.yaml
└── CHANGELOG.md
```

A package missing any of these four files will be rejected by `skpm` during packaging and by compliant registries during publish.

---

## Recommended package contents

```text
<name>/
├── SKILL.md
├── VERSION
├── skill.yaml
├── CHANGELOG.md
├── README.md
├── LICENSE
├── examples/
└── tests/
```

---

## Generated package artifact

When `skpm package` runs, it produces an archive (ZIP or TGZ) containing the skill source files plus two generated files:

### manifest.json

Generated during packaging. Contains a snapshot of the skill metadata and packaging context. Validated against [`schemas/package-manifest.schema.json`](../schemas/package-manifest.schema.json).

```json
{
  "name": "gitlab-policy-reviewer",
  "namespace": "default",
  "version": "1.5.2",
  "package_type": "zip",
  "packaged_at": "2024-03-15T14:30:00Z",
  "packaged_by": "skpm/1.2.0",
  "files": ["SKILL.md", "VERSION", "skill.yaml", "CHANGELOG.md", "README.md", "LICENSE"]
}
```

### checksums.txt

Generated during packaging. Contains SHA256 digests for every file in the package.

Format: `<sha256-hex>  <relative-path>` — two spaces between digest and path, compatible with `sha256sum -c`.

```text
b875cc1f70dfe77f7626fddda0cc7315643d851169cdf09a104d6233e0888ff5  SKILL.md
a3f9c2e1d4b8f7a6c5e2d9b1f4a7c3e8d6b2f5a9c1e4d7b3f6a2c8e5d1b7f4  VERSION
d1c2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1  skill.yaml
e2d3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2  CHANGELOG.md
f3e4d5c6b7a8f9e0d1c2b3a4f5e6d7c8b9a0f1e2d3c4b5a6f7e8d9c0b1a2f3  README.md
a4f5e6d7c8b9a0f1e2d3c4b5a6f7e8d9c0b1a2f3e4d5c6b7a8f9e0d1c2b3a4  LICENSE
b5a6f7e8d9c0b1a2f3e4d5c6b7a8f9e0d1c2b3a4f5e6d7c8b9a0f1e2d3c4b5  manifest.json
```

Files are listed in lexicographic order. Tooling must verify each entry using this format.

---

## Example packaged artifact

```text
gitlab-policy-reviewer-1.5.2.zip
├── SKILL.md
├── VERSION
├── skill.yaml
├── CHANGELOG.md
├── README.md
├── LICENSE
├── manifest.json
└── checksums.txt
```

The archive root directory is the skill name (i.e., the archive extracts into `gitlab-policy-reviewer/`, not directly into `.`).

---

## What must not be packaged

The following must never appear in a published artifact:

- `.git/` directories or any git internals
- `.env` files or any file containing secrets or credentials
- `node_modules/`, `.venv/`, or other dependency caches
- Build artifacts, compiled output, or intermediate files
- Temporary files (`.DS_Store`, `*.tmp`, `*.bak`, etc.)
- IDE configuration directories (`.idea/`, `.vscode/`, etc.)

`skpm` applies a default exclusion list during packaging. Projects may extend it via `.skpmignore`.

---

## Reproducible packages

Packages should be reproducible: two runs of `skpm package` on the same source at the same version should produce byte-identical archives (or at minimum, identical checksums for all included files).

To achieve reproducibility:

- **Stable file ordering**: files are sorted lexicographically before archiving
- **Normalized timestamps**: archive entry timestamps are set to a fixed epoch (1970-01-01T00:00:00Z) or the git commit timestamp
- **Normalized file modes**: archive entry permissions are normalized (0644 for files, 0755 for directories)
- **No metadata drift**: `manifest.json` includes `packaged_at` only when reproducibility is not required; omit or stabilize it for reproducible builds

Deterministic checksums enable consumers to verify integrity without trusting the registry.

---

## Source layout vs generated platform output

A skill source directory is **not** the same as generated platform output.

```text
skills/my-skill/              <- canonical source (committed, packaged, published)

.agents/skills/my-skill/      <- generated platform output for generic agents
.claude/skills/my-skill/      <- generated platform output for Claude Code
.github/skills/my-skill/      <- generated platform output for GitHub Copilot
.cursor/skills/my-skill/      <- generated platform output for Cursor
```

Platform output is generated by `skcr` from the canonical skill source. It typically contains only `SKILL.md` placed at the path the target agent platform reads from. It does not include `VERSION`, `CHANGELOG.md`, `manifest.json`, or other package metadata files.

Platform output should be committed to the consuming project repository if the target platform requires it (e.g., `.claude/` for Claude Code). Platform output is not what gets packaged and published to a registry.

---

## Tool responsibilities

| Operation | Tool |
| --- | --- |
| Create skill source directory | `skcr` |
| Render platform output (e.g. `.agents/skills/<name>/SKILL.md`) | `skcr` |
| Validate skill source against `skill.schema.json` | `skpm` |
| Enforce `VERSION` matches `skill.yaml.version` | `skpm` |
| Package skill into ZIP or TGZ artifact | `skpm` |
| Publish artifact to a registry | `skpm` |
| Install skills from lockfile | `skpm` |
| Verify installed artifacts against SHA256 | `skpm` |
| Store and serve package artifacts | SkillForge |
| SkillForge-specific admin operations | `skforge` |

---

## Versioning rules

1. `VERSION` and `skill.yaml.version` must always match.
2. A version increment (however small) requires a `CHANGELOG.md` entry.
3. Published versions are immutable. A published `1.5.2` cannot be changed.
4. To fix a published version, publish `1.5.3`.
5. Pre-release versions (e.g. `1.5.3-beta.1`) may be used during development but must not be the default resolved version for production consumers.

---

## Package naming convention

Package artifacts follow this naming pattern:

```text
<name>-<version>.<package_type>
```

Examples:

```text
gitlab-policy-reviewer-1.5.2.zip
audit-helper-2.0.0-beta.1.tgz
```

The package type (`zip` or `tgz`) is determined by `skpm` configuration or registry requirements.
