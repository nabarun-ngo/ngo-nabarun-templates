#!/usr/bin/env bash
# update-action-refs.sh
#
# DEPRECATED — use scripts/setup-for-org.sh instead.
# setup-for-org.sh replaces all internal org/repo references across the
# entire templates library in one shot, rather than only Deploy-GCP-v2.yml.
#
# This wrapper is kept for backwards compatibility.
# Usage: ./update-action-refs.sh [NEW_REPO] [NEW_REF]
# Example: ./update-action-refs.sh "my-org/my-templates" "v1.0.0"

set -euo pipefail

NEW_REPO="${1:-}"
NEW_REF="${2:-main}"

if [[ -z "$NEW_REPO" ]]; then
  echo "Usage: update-action-refs.sh <ORG/REPO> [REF]"
  echo ""
  echo "Consider using scripts/setup-for-org.sh instead — it updates ALL files,"
  echo "not just Deploy-GCP-v2.yml."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORG="${NEW_REPO%%/*}"
REPO="${NEW_REPO##*/}"

echo "Delegating to setup-for-org.sh ..."
bash "$SCRIPT_DIR/setup-for-org.sh" "$ORG" "$REPO" "$NEW_REF"
