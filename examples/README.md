# Examples

This directory contains examples of how to use the automation scripts and configuration system.

## Directory Structure

```
examples/
├── workflows/          # Example workflow files
├── configs/           # Example configuration files  
└── README.md         # This file
```

## Example Workflows

### 1. Direct Workflow Usage (`workflows/Example-Direct-Schedule.yml`)

Shows how to use the configuration system directly in a workflow without reusable workflows.

**Features:**
- Direct usage of `determine-schedule-config` action
- Multiple schedule triggers with different configurations
- Configuration detection based on workflow filename

**To use:**
1. Copy to `.github/workflows/` directory
2. Create corresponding config file: `config/config-Example-Direct-Schedule.json`
3. Customize the cron schedules and configuration as needed

### 2. Reusable Workflow Usage (`workflows/Example-Reusable-Schedule.yml`)

Shows how to use the `Setup-Env.yml` reusable workflow for configuration management.

**Features:**
- Uses the `Setup-Env.yml` reusable workflow
- Automatic configuration detection
- Clean separation of setup and execution logic

**To use:**
1. Copy to `.github/workflows/` directory  
2. Create corresponding config file: `config/config-Example-Reusable-Schedule.json`
3. Customize the schedules and add your workflow logic

## Example Configurations

### Configuration File Naming

Configuration files follow the pattern: `config/config-{WORKFLOW_FILENAME}.json`

Examples:
- `Daily-Auth0-Sync.yml` → `config/config-Daily-Auth0-Sync.json`
- `Test-Suite.yml` → `config/config-Test-Suite.json`

### Configuration Structure

```json
{
  "CRON_EXPRESSION": {
    "environment": "prod",
    "service_name": "my-service",
    "custom_setting": "value"
  },
  "ANOTHER_CRON": {
    "environment": "dev", 
    "service_name": "dev-service",
    "custom_setting": "other_value"
  }
}
```

### Available Example Configs

1. **`config-Daily-Auth0-Sync.json`**
   - Auth0 synchronization configurations
   - Daily and weekly schedules
   - Production and DR site configs

2. **`config-Test-Suite.json`**
   - Test execution configurations
   - Nightly, integration, and performance test setups
   - Different environments and test parameters

3. **`config-Example-Direct-Schedule.json`**
   - Simple direct workflow configuration
   - Daily maintenance and weekly reporting

4. **`config-Example-Reusable-Schedule.json`**
   - Reusable workflow configuration
   - Development sync and production backup setups

## Getting Started

1. **Choose your approach:**
   - Direct workflow: Copy `workflows/Example-Direct-Schedule.yml`
   - Reusable workflow: Copy `workflows/Example-Reusable-Schedule.yml`

2. **Create configuration:**
   - Copy one of the example configs from `configs/`
   - Rename to match your workflow filename
   - Customize the cron expressions and settings

3. **Deploy:**
   - Move workflow to `.github/workflows/`
   - Move config to `config/`
   - Test with workflow dispatch first

## Tips

- Always test with `workflow_dispatch` trigger first before relying on schedules
- Use descriptive cron expressions as JSON keys for clarity
- Keep configuration files in version control
- Use environment-specific settings within each cron configuration
- Check workflow logs to see which configuration was detected and loaded
