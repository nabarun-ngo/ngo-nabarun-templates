#!/usr/bin/env bash
# generate-release-notes.sh
#
# Builds a categorised, markdown-formatted release notes file for a GitHub Release.
#
# Usage:
#   bash generate-release-notes.sh <stable_tag> [output_file]
#
# Arguments:
#   stable_tag    The tag being released (e.g. v1.2.0)
#   output_file   Path to write the markdown (default: release_notes.md)
#
# Requirements:
#   - Must be run inside a git repo with full history + tags fetched
#   - git, printf, sed

set -euo pipefail

STABLE_TAG="${1:?Usage: generate-release-notes.sh <stable_tag> [output_file]}"
OUTPUT_FILE="${2:-release_notes.md}"

echo "📋 Building release notes for $STABLE_TAG..."

# ── Previous stable tag ──────────────────────────────────────────────────────
PREV_STABLE=$(git tag --list "v*.*.*" \
  --sort=-version:refname \
  | grep -v "beta" \
  | grep -v "^${STABLE_TAG}$" \
  | head -n 1 || true)

if [ -n "$PREV_STABLE" ]; then
  RANGE="${PREV_STABLE}..${STABLE_TAG}"
  echo "📊 Change range : $PREV_STABLE → $STABLE_TAG"
else
  RANGE="$STABLE_TAG"
  echo "📊 First release — including all commits up to $STABLE_TAG"
fi

# ── Collect beta tags that belong to this release cycle ──────────────────────
# A beta tag belongs when it is reachable from STABLE_TAG but NOT from PREV_STABLE.
BETA_TAGS=""
while IFS= read -r t; do
  [ -z "$t" ] && continue
  if git merge-base --is-ancestor "$t" "$STABLE_TAG" 2>/dev/null; then
    if [ -z "$PREV_STABLE" ] || ! git merge-base --is-ancestor "$t" "$PREV_STABLE" 2>/dev/null; then
      BETA_TAGS="${BETA_TAGS}${t}\n"
    fi
  fi
done < <(git tag --list "v*.*.*-beta.*" --sort=version:refname)

echo "🔖 Beta tags in this cycle:"
printf "%b" "${BETA_TAGS:-  (none)}\n"

# ── Categorise commits by conventional-commit prefix ─────────────────────────
BREAKING="" FEATURES="" FIXES="" PERF="" DOCS="" CHORES="" OTHERS=""

while IFS='|||' read -r subject hash author; do
  [ -z "$subject" ] && continue
  LINE="- ${subject} (\`${hash}\`) — *${author}*"
  case "$subject" in
    BREAKING*|*"!:"*)
      BREAKING="${BREAKING}${LINE}\n" ;;
    feat\(*|"feat!:"*|feat:*)
      FEATURES="${FEATURES}${LINE}\n" ;;
    fix\(*|"fix!:"*|fix:*)
      FIXES="${FIXES}${LINE}\n" ;;
    perf\(*|perf:*)
      PERF="${PERF}${LINE}\n" ;;
    docs\(*|docs:*)
      DOCS="${DOCS}${LINE}\n" ;;
    chore\(*|chore:*|ci\(*|ci:*|build\(*|build:*|refactor\(*|refactor:*|test\(*|test:*|style\(*|style:*)
      CHORES="${CHORES}${LINE}\n" ;;
    *)
      OTHERS="${OTHERS}${LINE}\n" ;;
  esac
done < <(git log --pretty=format:"%s|||%h|||%an" $RANGE 2>/dev/null || true)

COMMIT_COUNT=$(git rev-list --count $RANGE 2>/dev/null || echo "0")
echo "📝 Total commits in range: $COMMIT_COUNT"

# ── Assemble markdown ─────────────────────────────────────────────────────────
NOTES="## What's Changed\n\n"

[ -n "$BREAKING" ] && NOTES="${NOTES}### 💥 Breaking Changes\n${BREAKING}\n"
[ -n "$FEATURES" ] && NOTES="${NOTES}### ✨ New Features\n${FEATURES}\n"
[ -n "$FIXES"    ] && NOTES="${NOTES}### 🐛 Bug Fixes\n${FIXES}\n"
[ -n "$PERF"     ] && NOTES="${NOTES}### ⚡ Performance Improvements\n${PERF}\n"
[ -n "$DOCS"     ] && NOTES="${NOTES}### 📚 Documentation\n${DOCS}\n"
[ -n "$CHORES"   ] && NOTES="${NOTES}### 🔧 Maintenance\n${CHORES}\n"
[ -n "$OTHERS"   ] && NOTES="${NOTES}### 📦 Other Changes\n${OTHERS}\n"

if [ -z "${BREAKING}${FEATURES}${FIXES}${PERF}${DOCS}${CHORES}${OTHERS}" ]; then
  NOTES="${NOTES}*No conventional commits found in this release.*\n\n"
fi

# ── Pre-release history section ───────────────────────────────────────────────
if [ -n "$BETA_TAGS" ]; then
  NOTES="${NOTES}---\n### 🚀 Pre-release History\n"
  NOTES="${NOTES}The following pre-releases were included in **${STABLE_TAG}**:\n\n"
  NOTES="${NOTES}| Tag | Date | Trigger commit |\n"
  NOTES="${NOTES}|-----|------|----------------|\n"
  while IFS= read -r beta; do
    [ -z "$beta" ] && continue
    BETA_DATE=$(git log -1 --format="%ad" --date=short "$beta" 2>/dev/null || echo "unknown")
    BETA_MSG=$(git log -1 --format="%s" "$beta" 2>/dev/null || echo "")
    NOTES="${NOTES}| \`${beta}\` | ${BETA_DATE} | ${BETA_MSG} |\n"
  done < <(printf "%b" "$BETA_TAGS")
  NOTES="${NOTES}\n"
fi

# ── Footer ────────────────────────────────────────────────────────────────────
if [ -n "$PREV_STABLE" ]; then
  NOTES="${NOTES}---\n**Full diff:** [\`${PREV_STABLE}\` → \`${STABLE_TAG}\`](../../compare/${PREV_STABLE}...${STABLE_TAG})  \n"
fi
NOTES="${NOTES}**Commits in this release:** ${COMMIT_COUNT}\n"

# ── Write output file ─────────────────────────────────────────────────────────
printf "%b" "$NOTES" > "$OUTPUT_FILE"

echo "✅ Release notes written to $OUTPUT_FILE"
cat "$OUTPUT_FILE"
