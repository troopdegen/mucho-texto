# mucho-texto

*Mucho texto* is what you say when a wall of words hides the point.

This is a skill that makes an AI agent stop delivering 650-word reports. It compresses finished
work into four blocks — **DECIDE**, **KNOW**, **RUNNING**, **PARKED** — under a hard word cap,
and ends every summary with a path to the artifact holding the full detail.

The sorting is the actual work. Most walls are walls because everything got flattened into one
urgency. This skill forces every item into exactly one bucket: *needs you*, *changes your model
of the world*, *already handled*, or *deliberately not now*.

**It has one precondition, and it is the whole safety story:** compression is only allowed when
the uncompressed version survives somewhere durable. If there is no artifact, the skill says so
and offers to write one. A summary is never permitted to become the only surviving record —
that is not compression, it is deletion.

## What it looks like

A ~650-word orchestrator report across 8 headers, compressed to ~180 words:

> **pokta-care / Epic 2: stopped at gate 7.1.** Wave 0 only, nothing built, 154k tokens
> (~17% of estimate). The spike proved arm 3 as specified is impossible — cheap catch.
>
> **DECIDE — 1**
> 1. **What does arm 3 retrieve with?** Study-design call, not engineering. All of Epic 2 is
>    stalled behind it.
>    - **A:** purpose-built persona-free retrieval — buildable now, but arms 2 and 3 then
>      differ by more than the persona, and the manuscript has to say so.
>    - **B:** keep RheumaAI's tools, inject their persistence — preserves the clean
>      comparison, touches arm 2's code.
>
> **KNOW — 3**
> - A structured call failing on OpenAI silently returns Gemini prose, 200, credited to the
>   wrong model. Benchmark data corruption. `llm/resilient.ts:84`
> - `STRUCTURED_LLM_MODEL=gpt-4o` is interpolated into a *Gemini* URL — the structured path
>   was never wired. `lab-interpretation/index.ts:63`
> - `USE_RERANKING` defaults ON when unset. `embeddings/config.ts:10`
>
> **PARKED** — uncommitted `.gitignore` fix in the fork.
>
> Full detail: `docs/ultraplan-grader/EPIC-REPORT.md`

Same decision, same evidence, nothing that needed the thread to understand.

## Install

The skill is one file — [`skills/mucho-texto/SKILL.md`](skills/mucho-texto/SKILL.md) — written as
plain Markdown with no harness-specific syntax in the body. Every install path below puts that
same body somewhere your agent reads, rewriting nothing but the frontmatter. Pick the one that
matches your tool.

### Claude Code

```
/plugin marketplace add troopdegen/mucho-texto
/plugin install mucho-texto@mucho-texto
```

`/plugin update mucho-texto` picks up later releases.

Or install it as a plain skill, without the plugin system:

```bash
git clone https://github.com/troopdegen/mucho-texto.git
cd mucho-texto
./install.sh
```

That writes `~/.claude/skills/mucho-texto/SKILL.md`. Start a new session afterwards — Claude Code
does not pick up newly installed skills mid-session.

### Codex, Gemini CLI, Copilot, Zed, Aider, Windsurf, Jules

These read [AGENTS.md](https://agents.md). Run from your project root:

```bash
./install.sh --target agents      # ./AGENTS.md
./install.sh --target codex       # ~/.codex/AGENTS.md, global for Codex CLI
```

Both write into a block delimited by HTML comments, so the rest of your `AGENTS.md` is left
alone. Re-running updates that block in place instead of appending a second copy, and
`--uninstall` removes exactly that block.

### Cursor

```bash
./install.sh --target cursor      # ./.cursor/rules/mucho-texto.mdc
```

Installed with `alwaysApply: false` and the skill's description in the frontmatter, so Cursor
pulls it in when it's relevant rather than on every turn. Reference it directly with
`@mucho-texto`.

### Without running anything

[`dist/`](dist) holds the same adapters pre-built, for copying by hand:

- [`dist/AGENTS.md`](dist/AGENTS.md) — paste into your project's `AGENTS.md`, or use it as one
  if you don't have it yet. It keeps the same comment delimiters `install.sh` uses, so you can
  hand it over to the script later and `--uninstall` will still find it.
- [`dist/mucho-texto.mdc`](dist/mucho-texto.mdc) — drop into `.cursor/rules/`.

These are generated from `SKILL.md`, byte-identical to what `install.sh` writes, and CI fails if
they drift. Regenerate with `./install.sh --build`.

For anything else — a system prompt, a custom GPT, a rules file with its own format:

```bash
./install.sh --target print
```

Writes the harness-agnostic body to stdout, no frontmatter, no markers.

### Uninstall

`./install.sh --target <same-target> --uninstall`. It only removes what it installed: each
target leaves a marker (a `.mucho-texto-managed` file, or the comment delimiters) and refuses to
touch anything it did not write.

## Layout

```
skills/mucho-texto/SKILL.md    the skill — the only copy of the content
dist/AGENTS.md                 generated adapter, for AGENTS.md-family harnesses
dist/mucho-texto.mdc           generated adapter, for Cursor
.claude-plugin/                plugin + marketplace manifests
install.sh                     adapters over SKILL.md, and --build for dist/
```

Nothing that an agent auto-loads lives at the repo root — no `AGENTS.md`, no `CLAUDE.md`, no
`SKILL.md`. Those paths belong to *your* project, not to a repo you cloned to install something.
A root `AGENTS.md` here would be picked up by any agent you pointed at this clone, and would
collide with `./install.sh --target agents` if you ran it from the wrong directory. The
distributable copy lives in `dist/` instead, where it is inert until you move it.

## Using it

Say **"mucho texto"** — or "too long", "tl;dr this", "give me the bites" — at any wall of text.
In Claude Code, `/mucho-texto` invokes it directly.

It also fires on its own when finished work is about to be delivered as more than ~300 words:
a review, an agent result, a long investigation, a session wrap. The order matters and the skill
enforces it — **write the artifact to disk first, then deliver only the bites.** Writing the wall
and then compressing it delivers both and costs you more, not less.

**It deliberately stays out of the way when the reasoning IS the deliverable:** design
discussions, plans under review, architecture trade-offs, anything you asked to see in detail.
Compression is for reports of completed work, not for thinking together.

## Provenance

Written after a real session in which a complete `EPIC-REPORT.md` was written to disk *and* a
650-word chat message was delivered on top of it. The report was right; the message was the
wall. Everything in it already existed one path away. That failure is quoted in the skill
itself, because it is the one it most needs to avoid.

Used daily in a multi-project Claude Code setup. The non-Claude targets are adapters over the
same file — mechanically verified to install, update and uninstall cleanly, but not battle-tested
in each harness the way the Claude Code path is.

## License

MIT — see [LICENSE](LICENSE).
