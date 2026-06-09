#!/bin/bash

# Example script that sets environment variables 
# These will be picked up by resolve_variables parameter

echo "🚀 Setting environment variables for resolve_variables demo..."

# Get current environment from inputs
current_env="${environment:-dev}"
echo "Current environment: $current_env"

# Set some example variables that will be resolved into JSON

# Tag names (these would typically be fetched from APIs or computed)
export fe_tag_name="v2.1.3"
export be_tag_name="v1.8.5"

# Deployment metadata
export deployment_id="deploy-$(date +%s)"
export build_number="build-$(( RANDOM % 1000 + 1 ))"

# Boolean based on environment
if [[ "$current_env" == "prod" ]]; then
    export is_production="true"
else
    export is_production="false"
fi

# Additional computed values
export deployment_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
export git_commit="abc123def456"

echo "✅ Environment variables set:"
echo "  fe_tag_name=$fe_tag_name"
echo "  be_tag_name=$be_tag_name" 
echo "  deployment_id=$deployment_id"
echo "  build_number=$build_number"
echo "  is_production=$is_production"
echo "  deployment_timestamp=$deployment_timestamp"
echo "  git_commit=$git_commit"

echo ""
echo "💡 Note: Only variables listed in resolve_variables will be added to final JSON"
