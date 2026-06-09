#!/bin/bash

# Example script that demonstrates how to output JSON that will be merged with configuration
# Method 2: Output JSON directly using special markers

echo "🚀 Example script: Outputting JSON directly..."

# Do some processing
echo "📊 Calculating deployment metrics..."

# Simulate some calculations
deployment_size=$(( RANDOM % 1000 + 100 ))
estimated_duration=$(( RANDOM % 60 + 5 ))
success_rate=$(echo "scale=2; $(( RANDOM % 30 + 70 ))" | bc -l 2>/dev/null || echo "95.5")

# Get current timestamp
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Build JSON object with computed values
echo "### JSON_OUTPUT_START ###"
cat << EOF
{
  "deployment_metrics": {
    "estimated_size_mb": $deployment_size,
    "estimated_duration_minutes": $estimated_duration,
    "success_rate_percentage": $success_rate,
    "calculated_at": "$timestamp"
  },
  "runtime_info": {
    "script_version": "1.0.0",
    "execution_environment": "github-actions",
    "runner_os": "${RUNNER_OS:-linux}",
    "execution_id": "exec-$(date +%s)"
  },
  "feature_flags": {
    "enable_advanced_logging": true,
    "use_experimental_features": false,
    "parallel_execution": true
  },
  "updated_settings": {
    "max_retries": 5,
    "health_check_interval": 30,
    "backup_enabled": true
  }
}
EOF
echo "### JSON_OUTPUT_END ###"

echo "✅ JSON output generated successfully!"
echo "🎯 The JSON block above will be parsed and merged with configuration variables."
