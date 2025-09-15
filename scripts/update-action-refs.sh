#!/bin/bash

# =============================================================================
# UPDATE ACTION REFERENCES SCRIPT
# =============================================================================
# This script updates all composite action references in GitHub workflows
# Usage: ./update-action-refs.sh [NEW_REPO] [NEW_REF]
# Example: ./update-action-refs.sh "my-org/my-templates" "v1.0.0"

set -euo pipefail

# Configuration
WORKFLOW_FILE=".github/workflows/Deploy-GCP-v2.yml"
CURRENT_REPO="nabarun-ngo/ngo-nabarun-templates"
CURRENT_REF="main"

# Get new values from command line or use current values as default
NEW_REPO="${1:-$CURRENT_REPO}"
NEW_REF="${2:-$CURRENT_REF}"

echo "🔄 Updating composite action references..."
echo "📂 Workflow file: $WORKFLOW_FILE"
echo "🔄 From: $CURRENT_REPO/.github/actions/gcp-*@$CURRENT_REF"
echo "✅ To:   $NEW_REPO/.github/actions/gcp-*@$NEW_REF"
echo ""

# Check if workflow file exists
if [[ ! -f "$WORKFLOW_FILE" ]]; then
  echo "❌ Workflow file not found: $WORKFLOW_FILE"
  exit 1
fi

# Create backup
BACKUP_FILE="${WORKFLOW_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$WORKFLOW_FILE" "$BACKUP_FILE"
echo "💾 Backup created: $BACKUP_FILE"

# Update repository references
echo "🔄 Updating repository references..."
sed -i.tmp "s|${CURRENT_REPO}/\.github/actions/gcp-|${NEW_REPO}/.github/actions/gcp-|g" "$WORKFLOW_FILE"

# Update ref/branch references  
echo "🔄 Updating branch/tag references..."
sed -i.tmp "s|@${CURRENT_REF}|@${NEW_REF}|g" "$WORKFLOW_FILE"

# Update the configuration comment block
echo "🔄 Updating configuration documentation..."
sed -i.tmp "s|ACTION_REPO: '${CURRENT_REPO}'|ACTION_REPO: '${NEW_REPO}'|g" "$WORKFLOW_FILE"
sed -i.tmp "s|ACTION_REF: '${CURRENT_REF}'|ACTION_REF: '${NEW_REF}'|g" "$WORKFLOW_FILE"
sed -i.tmp "s|# Example: ${CURRENT_REPO}/.github/actions/gcp-promote-gae-traffic@${CURRENT_REF}|# Example: ${NEW_REPO}/.github/actions/gcp-promote-gae-traffic@${NEW_REF}|g" "$WORKFLOW_FILE"

# Clean up temporary file
rm -f "${WORKFLOW_FILE}.tmp"

echo "✅ Action references updated successfully!"
echo ""
echo "📋 Summary of changes:"
echo "  Repository: $CURRENT_REPO → $NEW_REPO"
echo "  Branch/Tag: $CURRENT_REF → $NEW_REF"
echo ""
echo "🔍 Updated action references:"
grep -n "uses.*${NEW_REPO}.*gcp-.*@${NEW_REF}" "$WORKFLOW_FILE" | head -10 || echo "  (No references found - this might indicate an issue)"
echo ""
echo "⚡ To revert changes, use: cp $BACKUP_FILE $WORKFLOW_FILE"
