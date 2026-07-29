# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] — 2026-07-29

### Added
- `dist/AGENTS.md` and `dist/mucho-texto.mdc` — pre-built adapters for installing by copying a
  file instead of running the script. Generated from `SKILL.md` by `./install.sh --build`.
- CI: manifest validation, SKILL.md frontmatter checks, shellcheck, an install/uninstall
  round-trip across every target, and a gate that fails if `dist/` drifts from `SKILL.md`.

### Fixed
- Uninstalling from an `AGENTS.md` left a stray blank line where the managed block had been.
  Insertion and removal now share one strip helper, so removal restores the file byte-for-byte.

### Notes
- Nothing an agent auto-loads lives at the repo root — no `AGENTS.md`, `CLAUDE.md`, or
  `SKILL.md`. The distributable copies live in `dist/`, inert until you move them.

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

[1.1.0]: https://github.com/troopdegen/mucho-texto/releases/tag/v1.1.0
[1.0.0]: https://github.com/troopdegen/mucho-texto/releases/tag/v1.0.0
