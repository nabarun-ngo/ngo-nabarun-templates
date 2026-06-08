#!/usr/bin/env bash
# set_latest_tag_fixed.sh
# Fetches the latest git tags for configurable repositories.
#
# All configuration is via environment variables (no hardcoded org/repo values):
#
#   FE_REPO          - Frontend repository (e.g. my-org/my-frontend-repo)   REQUIRED if fe_tag_name is empty/latest
#   BE_REPO          - Backend  repository (e.g. my-org/my-backend-repo)    REQUIRED if be_tag_name is empty/latest
#   target_env       - Target environment name (e.g. prod, staging, dev)    default: dev
#   BRANCH_PROD      - Branch name used for the production environment       default: main
#   BRANCH_DEFAULT   - Branch name used for all other environments          default: main
#   fe_tag_name      - Skip FE fetch when set to a specific tag value        optional
#   be_tag_name      - Skip BE fetch when set to a specific tag value        optional
#
# Example caller (in a GitHub Actions workflow):
#   env:
#     FE_REPO: my-org/my-frontend
#     BE_REPO: my-org/my-backend
#     BRANCH_PROD: main
#     BRANCH_DEFAULT: develop
#     target_env: ${{ inputs.environment }}

set -euo pipefail

echo "Fetching latest repository tags..."

# Repository configurations — must be supplied via environment variables.
FE_REPO="${FE_REPO:-${fe_repo:-}}"
BE_REPO="${BE_REPO:-${be_repo:-}}"

if [[ -z "$FE_REPO" && -z "${fe_tag_name:-}" ]]; then
  echo "ERROR: FE_REPO environment variable is required when fe_tag_name is not provided." >&2
  exit 1
fi
if [[ -z "$BE_REPO" && -z "${be_tag_name:-}" ]]; then
  echo "ERROR: BE_REPO environment variable is required when be_tag_name is not provided." >&2
  exit 1
fi

# Resolve branch from environment — fully configurable, no hardcoded conventions.
TARGET_ENV="${target_env:-${environment:-dev}}"
BRANCH_PROD="${BRANCH_PROD:-main}"
BRANCH_DEFAULT="${BRANCH_DEFAULT:-main}"

echo "Target environment: $TARGET_ENV"

if [[ "$TARGET_ENV" == "prod" || "$TARGET_ENV" == "production" ]]; then
  BRANCH="$BRANCH_PROD"
else
  BRANCH="$BRANCH_DEFAULT"
fi

echo "Using branch: $BRANCH for environment: $TARGET_ENV"

export SCRIPT_TARGET_BRANCH="$BRANCH"
export SCRIPT_ENVIRONMENT_RESOLVED="$TARGET_ENV"

# Function: get_latest_tag <repo> <branch>
get_latest_tag() {
  local repo="$1"
  local branch="$2"

  echo "Fetching latest tag for $repo on branch $branch..." >&2

  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' RETURN

  cd "$tmp_dir"
  git init -q
  git remote add origin "https://github.com/${repo}.git"

  if ! git fetch --tags --depth=1 origin "$branch" 2>/dev/null; then
    echo "ERROR: Failed to fetch from $repo branch $branch" >&2
    return 1
  fi

  local latest_tag
  latest_tag=$(git tag --sort=-creatordate --merged "origin/$branch" | head -n1)

  if [[ -z "$latest_tag" ]]; then
    echo "ERROR: No tag found on branch $branch in $repo" >&2
    return 1
  fi

  echo "$latest_tag"
}

FE_TAG=""
BE_TAG=""

# Fetch FE tag if needed
FE_TAG_INPUT="${fe_tag_name:-}"
if [[ -z "$FE_TAG_INPUT" || "$FE_TAG_INPUT" == "latest" ]]; then
  echo "Fetching latest FE tag..."
  if FE_TAG=$(get_latest_tag "$FE_REPO" "$BRANCH"); then
    echo "Frontend tag: $FE_TAG"
    export SCRIPT_FE_TAG_NAME="$FE_TAG"
    export SCRIPT_FE_TAG_FETCHED=true
    if [[ -n "${GITHUB_ENV:-}" ]]; then
      { echo "fe_tag_name<<EOF"; echo "$FE_TAG"; echo "EOF"; } >> "$GITHUB_ENV"
    fi
  else
    echo "ERROR: Failed to fetch FE tag"
    export SCRIPT_FE_TAG_FETCHED=false
    export SCRIPT_FE_TAG_ERROR="Failed to fetch latest tag"
  fi
else
  echo "Using provided FE tag: $FE_TAG_INPUT"
  export SCRIPT_FE_TAG_NAME="$FE_TAG_INPUT"
  export SCRIPT_FE_TAG_FETCHED=false
  FE_TAG="$FE_TAG_INPUT"
fi

# Fetch BE tag if needed
BE_TAG_INPUT="${be_tag_name:-}"
if [[ -z "$BE_TAG_INPUT" || "$BE_TAG_INPUT" == "latest" ]]; then
  echo "Fetching latest BE tag..."
  if BE_TAG=$(get_latest_tag "$BE_REPO" "$BRANCH"); then
    echo "Backend tag: $BE_TAG"
    export SCRIPT_BE_TAG_NAME="$BE_TAG"
    export SCRIPT_BE_TAG_FETCHED=true
    if [[ -n "${GITHUB_ENV:-}" ]]; then
      { echo "be_tag_name<<EOF"; echo "$BE_TAG"; echo "EOF"; } >> "$GITHUB_ENV"
    fi
  else
    echo "ERROR: Failed to fetch BE tag"
    export SCRIPT_BE_TAG_FETCHED=false
    export SCRIPT_BE_TAG_ERROR="Failed to fetch latest tag"
  fi
else
  echo "Using provided BE tag: $BE_TAG_INPUT"
  export SCRIPT_BE_TAG_NAME="$BE_TAG_INPUT"
  export SCRIPT_BE_TAG_FETCHED=false
  BE_TAG="$BE_TAG_INPUT"
fi

export SCRIPT_SCRIPT_EXECUTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
export SCRIPT_REPOSITORIES_PROCESSED=2

echo "### JSON_OUTPUT_START ###"
cat << EOF
{
  "deployment_info": {
    "frontend": {
      "repository": "${FE_REPO:-n/a}",
      "tag": "${FE_TAG:-unknown}",
      "branch_used": "$BRANCH",
      "tag_fetched": $([ "${SCRIPT_FE_TAG_FETCHED:-false}" = "true" ] && echo true || echo false)
    },
    "backend": {
      "repository": "${BE_REPO:-n/a}",
      "tag": "${BE_TAG:-unknown}",
      "branch_used": "$BRANCH",
      "tag_fetched": $([ "${SCRIPT_BE_TAG_FETCHED:-false}" = "true" ] && echo true || echo false)
    }
  },
  "deployment_metadata": {
    "target_environment": "$TARGET_ENV",
    "source_branch": "$BRANCH",
    "deployment_ready": $([ -n "$FE_TAG" ] && [ -n "$BE_TAG" ] && echo true || echo false),
    "execution_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  }
}
EOF
echo "### JSON_OUTPUT_END ###"

echo ""
echo "Tag Resolution Summary:"
echo "  Environment: $TARGET_ENV"
echo "  Branch: $BRANCH"
echo "  Frontend Tag: ${FE_TAG:-not-resolved}"
echo "  Backend Tag: ${BE_TAG:-not-resolved}"

if [[ -n "${FE_TAG:-}" && -n "${BE_TAG:-}" ]]; then
  echo "All tags resolved successfully!"
  exit 0
else
  echo "WARNING: Some tags could not be resolved"
  exit 0
fi
