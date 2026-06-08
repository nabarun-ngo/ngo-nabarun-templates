#!/usr/bin/env bash
# setup-for-org.sh
# One-time setup script that makes this template library fully generic for
# any organization by replacing all internal self-references with your own
# org/repo values.
#
# Run once after forking:
#   bash scripts/setup-for-org.sh MY-ORG MY-TEMPLATES-REPO [REF]
#
# Arguments:
#   ORG_NAME          - Your GitHub organization or user name  (e.g. acme-corp)
#   REPO_NAME         - Your fork's repository name            (e.g. ci-templates)
#   REF               - Default ref to pin to                  (default: main)
#
# What it does:
#   1. Replaces every occurrence of the upstream org/repo reference
#      (nabarun-ngo/ngo-nabarun-templates) with YOUR_ORG/YOUR_REPO in:
#         .github/workflows/*.yml
#         .github/actions/**/action.yml
#         examples/**/*.yml
#         *.yml  (root-level example callers)
#   2. Replaces the internal @main ref with @REF so you get pinned stability.
#   3. Reports every file changed.
#
# The script is safe to re-run: it only changes lines that still match the
# original upstream reference.

set -euo pipefail

UPSTREAM_ORG="nabarun-ngo"
UPSTREAM_REPO="ngo-nabarun-templates"
UPSTREAM="${UPSTREAM_ORG}/${UPSTREAM_REPO}"

TARGET_ORG="${1:?Usage: setup-for-org.sh <ORG_NAME> <REPO_NAME> [REF]}"
TARGET_REPO="${2:?Usage: setup-for-org.sh <ORG_NAME> <REPO_NAME> [REF]}"
TARGET_REF="${3:-main}"
TARGET="${TARGET_ORG}/${TARGET_REPO}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "============================================================"
echo "  Templates repo setup"
echo "  Upstream : ${UPSTREAM}@main"
echo "  Target   : ${TARGET}@${TARGET_REF}"
echo "  Root     : ${REPO_ROOT}"
echo "============================================================"
echo ""

# Collect target files
mapfile -t FILES < <(find "$REPO_ROOT" \
  -not -path "*/.git/*" \
  -not -path "*/trash/*" \
  -not -path "*/node_modules/*" \
  \( -name "*.yml" -o -name "*.yaml" -o -name "*.sh" \) \
  | sort)

CHANGED=0

for file in "${FILES[@]}"; do
  if grep -q "${UPSTREAM}" "$file" 2>/dev/null; then
    # Replace org/repo reference
    sed -i "s|${UPSTREAM}|${TARGET}|g" "$file"
    # Replace internal @main refs (only for the target repo lines)
    sed -i "s|${TARGET}@main|${TARGET}@${TARGET_REF}|g" "$file"
    echo "  Updated: ${file#$REPO_ROOT/}"
    CHANGED=$((CHANGED + 1))
  fi
done

echo ""
echo "Done. $CHANGED file(s) updated."
echo ""
echo "Next steps:"
echo "  1. Review the changes with: git diff"
echo "  2. Commit: git add -A && git commit -m 'chore: configure for ${TARGET}'"
echo "  3. Push and tag a release: git tag v1.0.0 && git push origin v1.0.0"
echo "  4. In your consumer repos, call workflows with:"
echo "       uses: ${TARGET}/.github/workflows/Run-Parallel-Tests.yml@${TARGET_REF}"
