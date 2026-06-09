#!/bin/bash

# Example script that demonstrates handling command line arguments
# Usage: ./example-with-arguments.sh --environment prod --action deploy --dry-run false --timeout 300

echo "🚀 Example script: Processing command line arguments..."

# Default values
ENVIRONMENT="dev"
ACTION="validate"
DRY_RUN=true
TIMEOUT=60
VERBOSE=false
CONFIG_FILE=""

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --environment ENV    Target environment (dev/staging/prod) [default: dev]"
    echo "  --action ACTION      Action to perform (validate/deploy/rollback) [default: validate]"
    echo "  --dry-run BOOL       Enable dry-run mode (true/false) [default: true]"
    echo "  --timeout SECONDS    Timeout in seconds [default: 60]"
    echo "  --config FILE        Path to config file"
    echo "  --verbose            Enable verbose output"
    echo "  --help               Show this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --action)
            ACTION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "❌ Unknown argument: $1"
            show_usage
            exit 1
            ;;
    esac
done

echo "📊 Parsed arguments:"
echo "  Environment: $ENVIRONMENT"
echo "  Action: $ACTION"
echo "  Dry Run: $DRY_RUN"
echo "  Timeout: $TIMEOUT seconds"
echo "  Verbose: $VERBOSE"
if [[ -n "$CONFIG_FILE" ]]; then
    echo "  Config File: $CONFIG_FILE"
fi

# Validate arguments
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo "❌ Invalid environment: $ENVIRONMENT. Must be dev, staging, or prod."
    exit 1
fi

if [[ ! "$ACTION" =~ ^(validate|deploy|rollback)$ ]]; then
    echo "❌ Invalid action: $ACTION. Must be validate, deploy, or rollback."
    exit 1
fi

if [[ ! "$DRY_RUN" =~ ^(true|false)$ ]]; then
    echo "❌ Invalid dry-run value: $DRY_RUN. Must be true or false."
    exit 1
fi

if [[ ! "$TIMEOUT" =~ ^[0-9]+$ ]]; then
    echo "❌ Invalid timeout: $TIMEOUT. Must be a number."
    exit 1
fi

# Set script outputs based on arguments
export SCRIPT_ENVIRONMENT="$ENVIRONMENT"
export SCRIPT_ACTION="$ACTION"
export SCRIPT_DRY_RUN="$DRY_RUN"
export SCRIPT_TIMEOUT_SECONDS="$TIMEOUT"
export SCRIPT_VERBOSE_ENABLED="$VERBOSE"
export SCRIPT_EXECUTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Set environment-specific configurations
case "$ENVIRONMENT" in
    "prod")
        export SCRIPT_REPLICAS=5
        export SCRIPT_CPU_LIMIT="2000m"
        export SCRIPT_MEMORY_LIMIT="4Gi"
        export SCRIPT_ENABLE_MONITORING=true
        ;;
    "staging")
        export SCRIPT_REPLICAS=3
        export SCRIPT_CPU_LIMIT="1000m"
        export SCRIPT_MEMORY_LIMIT="2Gi"
        export SCRIPT_ENABLE_MONITORING=true
        ;;
    "dev")
        export SCRIPT_REPLICAS=1
        export SCRIPT_CPU_LIMIT="500m"
        export SCRIPT_MEMORY_LIMIT="1Gi"
        export SCRIPT_ENABLE_MONITORING=false
        ;;
esac

# Set action-specific configurations
case "$ACTION" in
    "deploy")
        export SCRIPT_HEALTH_CHECK_ENABLED=true
        export SCRIPT_ROLLBACK_ENABLED=true
        export SCRIPT_MAX_DEPLOYMENT_TIME=1800
        ;;
    "rollback")
        export SCRIPT_HEALTH_CHECK_ENABLED=false
        export SCRIPT_ROLLBACK_ENABLED=false
        export SCRIPT_MAX_DEPLOYMENT_TIME=600
        ;;
    "validate")
        export SCRIPT_HEALTH_CHECK_ENABLED=false
        export SCRIPT_ROLLBACK_ENABLED=false
        export SCRIPT_MAX_DEPLOYMENT_TIME=300
        ;;
esac

# Output additional JSON configuration
echo "### JSON_OUTPUT_START ###"
cat << EOF
{
  "deployment_strategy": {
    "type": "$([ "$ENVIRONMENT" == "prod" ] && echo "blue-green" || echo "rolling")",
    "max_unavailable": "$([ "$ENVIRONMENT" == "prod" ] && echo "0" || echo "1")",
    "max_surge": "$([ "$ENVIRONMENT" == "prod" ] && echo "1" || echo "2")"
  },
  "security_config": {
    "network_policies_enabled": $([ "$ENVIRONMENT" != "dev" ] && echo true || echo false),
    "pod_security_standards": "$([ "$ENVIRONMENT" == "prod" ] && echo "restricted" || echo "baseline")",
    "image_scanning_required": $([ "$ENVIRONMENT" == "prod" ] && echo true || echo false)
  },
  "backup_config": {
    "enabled": $([ "$ACTION" == "deploy" ] && [ "$ENVIRONMENT" == "prod" ] && echo true || echo false),
    "retention_days": $([ "$ENVIRONMENT" == "prod" ] && echo 30 || echo 7),
    "compression": true
  },
  "notification_config": {
    "channels": $([ "$VERBOSE" == "true" ] && echo '["slack", "email", "webhook"]' || echo '["slack"]'),
    "on_success": $([ "$ACTION" == "deploy" ] && echo true || echo false),
    "on_failure": true
  }
}
EOF
echo "### JSON_OUTPUT_END ###"

if [[ "$VERBOSE" == "true" ]]; then
    echo ""
    echo "📈 Verbose output enabled - Additional details:"
    echo "  Current directory: $(pwd)"
    echo "  Script arguments received: $*"
    echo "  Process ID: $$"
    echo "  User: $(whoami 2>/dev/null || echo "unknown")"
fi

echo "✅ Script completed successfully with all arguments processed!"
