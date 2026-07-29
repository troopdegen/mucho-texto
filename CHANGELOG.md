# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-07-29

First public release.

### Added
- `mucho-texto` skill: four-block output (DECIDE / KNOW / RUNNING / PARKED), enforced caps,
  and the hard precondition that the uncompressed version must survive in a durable artifact.
- Claude Code plugin manifest and a one-plugin marketplace, so the repo installs via
  `/plugin marketplace add troopdegen/mucho-texto`.
- `install.sh` with four targets — `claude`, `cursor`, `codex`, `agents` — plus `print` for
  every other harness. AGENTS.md targets write into a delimited block that updates in place
  and uninstalls cleanly.
- CI: JSON manifest validation, SKILL.md frontmatter checks, and shellcheck.

[1.0.0]: https://github.com/troopdegen/mucho-texto/releases/tag/v1.0.0
