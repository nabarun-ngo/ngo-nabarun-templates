#!/bin/bash

# Example script that demonstrates how to set variables that will be merged with configuration
# Variables starting with SCRIPT_ will be automatically captured and added to the final JSON

echo "🚀 Example script: Setting and updating variables..."

# Method 1: Set individual variables using SCRIPT_ prefix
# These will be automatically detected and converted to JSON

# String values
export SCRIPT_WORKFLOW_RUN_NAME="Automated-$(date +%Y%m%d-%H%M%S)"
export SCRIPT_BUILD_NUMBER="build-$(date +%s)"
export SCRIPT_DEPLOYMENT_TARGET="production"

# Numeric values (will be preserved as numbers in JSON)
export SCRIPT_RETRY_COUNT=3
export SCRIPT_TIMEOUT_SECONDS=300
export SCRIPT_VERSION_CODE=42

# Boolean values (will be preserved as booleans in JSON)
export SCRIPT_DRY_RUN=false
export SCRIPT_ENABLE_NOTIFICATIONS=true
export SCRIPT_DEBUG_MODE=false

# Computed values
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
export SCRIPT_GIT_BRANCH="$current_branch"

commit_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
export SCRIPT_GIT_COMMIT="$commit_sha"

# Dynamic values based on conditions
if [[ "$(date +%u)" -eq 6 ]] || [[ "$(date +%u)" -eq 7 ]]; then
    export SCRIPT_IS_WEEKEND=true
    export SCRIPT_SCHEDULE_TYPE="weekend"
else
    export SCRIPT_IS_WEEKEND=false
    export SCRIPT_SCHEDULE_TYPE="weekday"
fi

# Array-like values (as JSON strings)
export SCRIPT_ENVIRONMENTS='["dev", "staging", "prod"]'
export SCRIPT_NOTIFICATION_CHANNELS='["slack", "email"]'

echo "✅ Variables set successfully!"
echo "📊 Summary of variables set:"
env | grep '^SCRIPT_' | sort

echo ""
echo "🎯 These variables will be merged with the configuration JSON and available in subsequent steps."
