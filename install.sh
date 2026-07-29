#!/usr/bin/env bash
# Install the mucho-texto skill into whichever agent harness you use.
#
# One canonical file — skills/mucho-texto/SKILL.md — is the source of truth.
# Each target below is a thin adapter that puts that same body where a
# particular harness looks for it. Nothing is rewritten but the frontmatter.
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$SOURCE_DIR/skills/mucho-texto/SKILL.md"
MARKER_BEGIN="<!-- BEGIN mucho-texto (managed by install.sh — edits here are overwritten) -->"
MARKER_END="<!-- END mucho-texto -->"

TARGET="claude"
ASSUME_YES=0
UNINSTALL=0
BUILD=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [--target <harness>] [--yes] [--uninstall]
       ./install.sh --build

Targets:
  claude     ~/.claude/skills/mucho-texto/SKILL.md          (default)
  cursor     ./.cursor/rules/mucho-texto.mdc                (project-scoped)
  codex      ~/.codex/AGENTS.md, in a managed block
  agents     ./AGENTS.md, in a managed block  — read by Codex, Gemini CLI,
             Copilot, Cursor, Zed, Aider, Windsurf, Jules and others
  print      write the harness-agnostic body to stdout, install nothing

Flags:
  --yes, -y    do not prompt before overwriting an unmanaged file
  --uninstall  remove what this script installed for the chosen target
  --build      regenerate dist/ from skills/mucho-texto/SKILL.md — for
               maintainers of this repo, not for installing

Claude Code users can skip this script entirely:
  /plugin marketplace add troopdegen/mucho-texto
  /plugin install mucho-texto@mucho-texto
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="${2:?--target needs a value}"; shift 2 ;;
    --target=*) TARGET="${1#*=}"; shift ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --build) BUILD=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "unknown flag: $1" >&2; usage >&2; exit 1 ;;
  esac
done

case "$TARGET" in
  claude|cursor|codex|agents|print) ;;
  *) echo "error: unknown target '$TARGET'" >&2; usage >&2; exit 1 ;;
esac

# Fail up front on a partial clone rather than halfway through a write.
if [ ! -f "$SKILL_SRC" ]; then
  echo "error: missing $SKILL_SRC — is this clone complete?" >&2
  exit 1
fi

# --- helpers -----------------------------------------------------------------

# Everything after the closing --- of the YAML frontmatter, with the blank
# lines that follow it dropped so callers control their own spacing.
skill_body() {
  awk '
    BEGIN { n = 0; started = 0 }
    /^---[[:space:]]*$/ { n++; if (n <= 2) next }
    n < 2 { next }
    !started && /^[[:space:]]*$/ { next }
    { started = 1; print }
  ' "$SKILL_SRC"
}

# The description: line from the frontmatter, unwrapped onto one line.
skill_description() {
  awk '
    /^description:[[:space:]]/ { sub(/^description:[[:space:]]*/, ""); d=$0; grab=1; next }
    grab && /^[a-zA-Z_]+:/ { grab=0 }
    grab && /^---[[:space:]]*$/ { grab=0 }
    grab { sub(/^[[:space:]]+/, " "); d=d $0 }
    END { print d }
  ' "$SKILL_SRC"
}

confirm_overwrite() {
  local path="$1"
  [ "$ASSUME_YES" = "1" ] && return 0
  echo "warning: $path already exists and was not installed by this script."
  read -r -p "  Overwrite it? [y/N] " reply
  case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

# Drop the managed block wherever it appears, and trim the trailing blank
# lines left behind. Write and remove both go through this, so removing a
# block restores the file byte-for-byte to what it was before it was added.
strip_managed_block() {
  awk -v b="$MARKER_BEGIN" -v e="$MARKER_END" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip
  ' "$1" | awk '
    # Buffer blank lines and emit them only once a non-blank follows, so any
    # run of blanks at end of file is dropped rather than printed.
    /^[[:space:]]*$/ { blank++; next }
    { for (i = 0; i < blank; i++) print ""; blank = 0; print }
  '
}

# Replace (or append) the managed block inside a file the user also curates
# by hand. Idempotent: running twice leaves one block, not two.
write_managed_block() {
  local file="$1" tmp
  tmp="$(mktemp)"
  mkdir -p "$(dirname "$file")"
  touch "$file"

  strip_managed_block "$file" > "$tmp"

  [ -s "$tmp" ] && printf '\n' >> "$tmp"
  {
    echo "$MARKER_BEGIN"
    echo
    skill_body
    echo
    echo "$MARKER_END"
  } >> "$tmp"

  mv "$tmp" "$file"
}

remove_managed_block() {
  local file="$1" tmp
  [ -f "$file" ] || { echo "Nothing to remove: $file does not exist."; return 0; }
  if ! grep -qF "$MARKER_BEGIN" "$file"; then
    echo "Skipped $file: no managed mucho-texto block found."
    return 0
  fi
  tmp="$(mktemp)"
  strip_managed_block "$file" > "$tmp"
  mv "$tmp" "$file"
  echo "Removed the mucho-texto block from: $file"
}

# --- targets -----------------------------------------------------------------

install_claude() {
  local skills_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
  local dest="$skills_dir/mucho-texto"

  if [ "$UNINSTALL" = "1" ]; then
    if [ -f "$dest/.mucho-texto-managed" ]; then
      rm -rf "$dest"; echo "Removed: $dest"
    elif [ -e "$dest" ]; then
      echo "Skipped $dest: exists but was not installed by this script."
    else
      echo "Nothing to remove at $dest."
    fi
    return 0
  fi

  if [ -e "$dest" ] && [ ! -f "$dest/.mucho-texto-managed" ]; then
    confirm_overwrite "$dest" || { echo "  Skipped."; return 0; }
  fi

  # Back up rather than delete-then-copy: a failed cp leaves the previous
  # working version recoverable instead of gone.
  local backup=""
  if [ -e "$dest" ]; then backup="${dest}.bak.$$"; mv "$dest" "$backup"; fi

  if mkdir -p "$dest" && cp "$SKILL_SRC" "$dest/SKILL.md"; then
    touch "$dest/.mucho-texto-managed"
    [ -n "$backup" ] && rm -rf "$backup"
    echo "Installed: $dest/SKILL.md"
    echo
    echo "If Claude Code is already running, start a new session to pick it up."
    echo "Smoke test: type /mucho-texto and confirm it appears before relying on it."
  else
    echo "error: install failed, restoring the previous version." >&2
    rm -rf "$dest"
    [ -n "$backup" ] && mv "$backup" "$dest"
    exit 1
  fi
}

install_cursor() {
  local dest="./.cursor/rules/mucho-texto.mdc"

  if [ "$UNINSTALL" = "1" ]; then
    if [ -f "$dest" ]; then rm -f "$dest"; echo "Removed: $dest"
    else echo "Nothing to remove at $dest."; fi
    return 0
  fi

  if [ -f "$dest" ] && ! grep -qF "mucho-texto" "$dest"; then
    confirm_overwrite "$dest" || { echo "  Skipped."; return 0; }
  fi

  mkdir -p "$(dirname "$dest")"
  {
    echo "---"
    # Agent-requested activation: Cursor reads the description and pulls the
    # rule in when it is relevant, rather than on every turn.
    echo "description: $(skill_description)"
    echo "alwaysApply: false"
    echo "---"
    echo
    skill_body
  } > "$dest"

  echo "Installed: $dest"
  echo "Cursor loads this on request — reference it with @mucho-texto, or let the"
  echo "agent pull it in from the description."
}

# Regenerate the checked-in adapters under dist/. These exist so someone can
# copy a ready-made file instead of running this script at all; CI fails if
# they drift from SKILL.md.
build_dist() {
  local dist="$SOURCE_DIR/dist"
  mkdir -p "$dist"

  {
    echo "$MARKER_BEGIN"
    echo
    skill_body
    echo
    echo "$MARKER_END"
  } > "$dist/AGENTS.md"

  {
    echo "---"
    echo "description: $(skill_description)"
    echo "alwaysApply: false"
    echo "---"
    echo
    skill_body
  } > "$dist/mucho-texto.mdc"

  echo "Built: dist/AGENTS.md"
  echo "Built: dist/mucho-texto.mdc"
}

install_agents_file() {
  local dest="$1" label="$2"
  if [ "$UNINSTALL" = "1" ]; then remove_managed_block "$dest"; return 0; fi
  write_managed_block "$dest"
  echo "Installed into: $dest ($label)"
  echo "The block is delimited by HTML comments — re-running updates it in place,"
  echo "and --uninstall removes exactly that block and nothing else."
}

if [ "$BUILD" = "1" ]; then
  build_dist
  exit 0
fi

case "$TARGET" in
  claude) install_claude ;;
  cursor) install_cursor ;;
  codex)  install_agents_file "$HOME/.codex/AGENTS.md" "Codex CLI, global" ;;
  agents) install_agents_file "./AGENTS.md" "AGENTS.md, project root" ;;
  print)  skill_body ;;
esac
