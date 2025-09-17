# GCP Restart App Engine Action

A composite action to restart Google App Engine service by deleting all existing instances to force recreation.

## ⚠️ WARNING

**This action will DELETE ALL RUNNING INSTANCES** for the specified App Engine service. This will cause temporary service downtime until new instances are automatically created when traffic arrives.

**Use with extreme caution in production environments!**

## Overview

This action provides a controlled way to restart App Engine services by deleting all existing instances. This is useful for:
- Forcing a fresh restart of the application
- Clearing memory leaks or stuck processes
- Applying configuration changes that require a restart
- Troubleshooting service issues

## Features

- 🔥 **Instance Deletion**: Deletes all running instances for specified service/version
- 🛡️ **Safety Confirmation**: Requires explicit confirmation to prevent accidents
- 🔄 **Dry Run Mode**: Test the operation without making actual changes
- ⏱️ **Service Recovery**: Monitors service status after restart
- 📊 **Detailed Reporting**: Comprehensive metrics and status reporting
- 🎯 **Version Targeting**: Can target specific versions or all versions
- ⚡ **Auto-Recovery**: Instances are automatically recreated by App Engine

## Usage

### Basic Usage (with required confirmation)

```yaml
- name: Restart App Engine service
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-restart-app-engine@main
  with:
    project_id: 'my-gcp-project'
    service_name: 'default'
    confirm_restart: 'yes'  # Required for safety
```

### Dry Run (recommended first step)

```yaml
- name: Test App Engine restart (dry run)
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-restart-app-engine@main
  with:
    project_id: 'my-gcp-project'
    service_name: 'api-service'
    confirm_restart: 'yes'
    dry_run: 'true'  # No actual changes
```

### Advanced Usage (specific version)

```yaml
- name: Restart specific App Engine version
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-restart-app-engine@main
  with:
    project_id: 'my-gcp-project'
    service_name: 'api-service'
    version_id: 'v20240115-123456'
    confirm_restart: 'yes'
    wait_timeout: '600'  # Wait up to 10 minutes
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `project_id` | GCP Project ID where the service is deployed | ✅ Yes | - |
| `service_name` | Name of the App Engine service to restart | ❌ No | `default` |
| `version_id` | Specific version ID to restart (empty = all versions) | ❌ No | - |
| `confirm_restart` | **Must be "yes" to execute** | ✅ Yes | - |
| `dry_run` | Perform dry run without actual changes | ❌ No | `false` |
| `wait_timeout` | Wait timeout for instance recreation (seconds) | ❌ No | `300` |

## Outputs

| Output | Description |
|--------|-------------|
| `restart_result` | Result message of the restart operation |
| `instances_deleted` | Number of instances that were deleted |
| `instances_recreated` | Number of instances recreated after restart |
| `execution_time` | Total time taken for the operation |
| `service_status` | Final status of the service after restart |

## Safety Features

### 1. Confirmation Requirement
The action **will not proceed** unless `confirm_restart` is set to `"yes"`. This prevents accidental execution.

```yaml
# ❌ This will fail
confirm_restart: 'no'    # Default value

# ✅ This will proceed  
confirm_restart: 'yes'   # Required for execution
```

### 2. Dry Run Mode
Always test with dry run first to see what would be affected:

```yaml
dry_run: 'true'  # Shows what would be done without doing it
```

### 3. Input Validation
The action validates all inputs and provides clear error messages for issues.

## How It Works

1. **Validation**: Checks inputs, GCP authentication, and service existence
2. **Discovery**: Lists current instances for the specified service/version
3. **Deletion**: Deletes all found instances (if not dry run)
4. **Recovery Wait**: Waits for service stabilization
5. **Verification**: Checks final service status and new instances

## Behavior with Different Scenarios

### When Instances Exist
```
🔥 Found 3 instances - deleting all
✅ Deleted 3 instances successfully
⏳ Waiting for service recovery...
📊 0 instances now running (normal - will be created on demand)
```

### When No Instances Running
```
ℹ️ No instances currently running
🔄 Triggering service refresh instead...
✅ Service refresh completed
```

### Dry Run Mode
```
🔄 [DRY RUN] Would delete the following instances:
   - instance-1 (v20240115-123456)
   - instance-2 (v20240115-123456)
✅ [DRY RUN] Would have deleted 2 instances
```

## Prerequisites

- Google Cloud CLI (`gcloud`) must be installed and configured
- Proper GCP authentication (service account or user credentials)
- Required GCP permissions:
  - `appengine.instances.list`
  - `appengine.instances.delete`
  - `appengine.services.get`
  - `appengine.services.update`

## Use Cases

### 1. Memory Leak Resolution
```yaml
# When your service has memory leaks and needs a fresh start
- uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-restart-app-engine@main
  with:
    project_id: ${{ vars.GCP_PROJECT }}
    service_name: 'api-service'
    confirm_restart: 'yes'
```

### 2. Configuration Changes
```yaml
# After deploying config changes that require restart
- uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-restart-app-engine@main
  with:
    project_id: ${{ vars.GCP_PROJECT }}
    service_name: 'web-service'
    confirm_restart: 'yes'
```

### 3. Troubleshooting
```yaml
# When service is unresponsive and needs forced restart
- uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-restart-app-engine@main
  with:
    project_id: ${{ vars.GCP_PROJECT }}
    service_name: 'worker-service'
    confirm_restart: 'yes'
    wait_timeout: '600'  # Give more time for complex services
```

## Integration with Workflows

This action is designed to work with the GCP-Ops workflow:

```yaml
jobs:
  emergency-restart:
    name: 'Emergency Service Restart'
    runs-on: ubuntu-latest
    environment: production  # Requires environment approval
    steps:
      - name: Authenticate with GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - name: Setup gcloud
        uses: google-github-actions/setup-gcloud@v2
      
      - name: Restart service instances
        id: restart
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-restart-app-engine@main
        with:
          project_id: ${{ vars.GCP_PROJECT_ID }}
          service_name: ${{ inputs.service_name }}
          confirm_restart: 'yes'
      
      - name: Notify team
        if: always()
        run: |
          echo "Service restart completed: ${{ steps.restart.outputs.restart_result }}"
          # Add your notification logic here (Slack, email, etc.)
```

## Best Practices

1. **Always Use Dry Run First**: Test the operation before executing
2. **Monitor After Restart**: Watch service health and traffic handling
3. **Use Environment Protection**: Require approvals for production restarts
4. **Plan for Downtime**: Understand there will be temporary service unavailability
5. **Have Rollback Plan**: Know how to handle issues if they arise
6. **Document Restarts**: Log reasons and results for troubleshooting

## Error Handling

The action includes comprehensive error handling for:
- Missing confirmation
- Invalid service names or versions
- GCP authentication issues
- Instance deletion failures
- Service verification problems

## Troubleshooting

### Common Issues

1. **"Restart not confirmed" Error**
   ```
   ❌ Restart not confirmed. Set confirm_restart to 'yes' to proceed.
   ```
   **Solution**: Set `confirm_restart: 'yes'`

2. **Service Not Found**
   ```
   ❌ Service 'my-service' not found in project 'my-project'
   ```
   **Solution**: Verify service name and project ID

3. **Permission Denied**
   ```
   ❌ Failed to delete instances
   ```
   **Solution**: Check GCP service account permissions

4. **Instances Not Recreated**
   ```
   📊 Current instances after restart: 0
   ```
   **Note**: This is normal! Instances are created on-demand when traffic arrives.

## Related Actions

- `gcp-get-deployed-version` - Get current version information
- `gcp-health-check-deployment` - Health check services
- `gcp-promote-gae-traffic` - Traffic management
- `gcp-download-logs` - Download logs for troubleshooting

## Contributing

When contributing to this action:
1. Test thoroughly in non-production environments
2. Maintain all safety features and confirmations
3. Update documentation for any changes
4. Consider the impact on running services
5. Test edge cases (no instances, multiple versions, etc.)

---

**Remember**: This action deletes running instances and causes temporary downtime. Always use responsibly!
