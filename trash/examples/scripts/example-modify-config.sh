#!/bin/bash

# Example script that demonstrates how to modify/override existing configuration values
# This script combines both methods and shows how to update configuration based on conditions

echo "🚀 Example script: Modifying configuration based on conditions..."

# Read current environment (if available from previous steps)
current_env="${environment:-dev}"
echo "📊 Current environment: $current_env"

# Method 1: Set individual variables that will override config values
export SCRIPT_MODIFIED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Override environment-specific settings
if [[ "$current_env" == "prod" ]]; then
    echo "🔧 Applying production overrides..."
    export SCRIPT_DRY_RUN=false
    export SCRIPT_TIMEOUT_MINUTES=60
    export SCRIPT_MAX_RETRIES=5
    export SCRIPT_ENABLE_MONITORING=true
    export SCRIPT_LOG_LEVEL="INFO"
elif [[ "$current_env" == "staging" ]]; then
    echo "🧪 Applying staging overrides..."
    export SCRIPT_DRY_RUN=false
    export SCRIPT_TIMEOUT_MINUTES=30
    export SCRIPT_MAX_RETRIES=3
    export SCRIPT_ENABLE_MONITORING=true
    export SCRIPT_LOG_LEVEL="DEBUG"
else
    echo "👨‍💻 Applying development overrides..."
    export SCRIPT_DRY_RUN=true
    export SCRIPT_TIMEOUT_MINUTES=15
    export SCRIPT_MAX_RETRIES=2
    export SCRIPT_ENABLE_MONITORING=false
    export SCRIPT_LOG_LEVEL="DEBUG"
fi

# Check if it's a scheduled run vs manual trigger
if [[ "${GITHUB_EVENT_NAME:-}" == "schedule" ]]; then
    echo "⏰ Detected scheduled execution"
    export SCRIPT_EXECUTION_TYPE="scheduled"
    export SCRIPT_NOTIFICATIONS_ENABLED=true
    export SCRIPT_AUTO_APPROVE=true
else
    echo "👤 Detected manual execution"
    export SCRIPT_EXECUTION_TYPE="manual"
    export SCRIPT_NOTIFICATIONS_ENABLED=false
    export SCRIPT_AUTO_APPROVE=false
fi

# Check git status and set related flags
if git diff --quiet HEAD 2>/dev/null; then
    export SCRIPT_HAS_UNCOMMITTED_CHANGES=false
    export SCRIPT_DEPLOYMENT_ALLOWED=true
else
    export SCRIPT_HAS_UNCOMMITTED_CHANGES=true
    export SCRIPT_DEPLOYMENT_ALLOWED=false
fi

# Method 2: Output complex JSON for nested configuration updates
echo "### JSON_OUTPUT_START ###"
cat << EOF
{
  "deployment_config": {
    "strategy": "${current_env}" == "prod" ? "blue-green" : "rolling",
    "replicas": $([ "$current_env" == "prod" ] && echo 5 || echo 2),
    "resources": {
      "cpu_limit": "$([ "$current_env" == "prod" ] && echo "2000m" || echo "500m")",
      "memory_limit": "$([ "$current_env" == "prod" ] && echo "4Gi" || echo "1Gi")"
    }
  },
  "monitoring": {
    "enabled": $([ "$current_env" != "dev" ] && echo true || echo false),
    "alert_thresholds": {
      "cpu_percent": $([ "$current_env" == "prod" ] && echo 80 || echo 90),
      "memory_percent": $([ "$current_env" == "prod" ] && echo 85 || echo 95)
    }
  },
  "backup": {
    "enabled": $([ "$current_env" == "prod" ] && echo true || echo false),
    "retention_days": $([ "$current_env" == "prod" ] && echo 30 || echo 7),
    "schedule": "$([ "$current_env" == "prod" ] && echo "0 2 * * *" || echo "0 3 * * 0")"
  }
}
EOF
echo "### JSON_OUTPUT_END ###"

echo "✅ Configuration modifications applied!"
echo "📋 Summary:"
echo "  - Environment: $current_env"
echo "  - Execution type: ${SCRIPT_EXECUTION_TYPE}"
echo "  - Deployment allowed: ${SCRIPT_DEPLOYMENT_ALLOWED}"
echo "  - Auto approve: ${SCRIPT_AUTO_APPROVE}"

echo ""
echo "🎯 These values will override the original configuration and be available in all subsequent steps."
