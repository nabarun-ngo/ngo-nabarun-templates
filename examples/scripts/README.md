# Example Scripts

This directory contains example scripts that demonstrate how to add and update variables in the Setup-Env workflow.

## How Script Output Works

The Setup-Env workflow can execute a custom script and capture its output to merge with configuration variables. There are two methods to provide data from your script:

### Method 1: Environment Variables with SCRIPT_ Prefix

Set environment variables starting with `SCRIPT_` and they will be automatically captured:

```bash
export SCRIPT_BUILD_NUMBER="build-123"
export SCRIPT_RETRY_COUNT=3
export SCRIPT_ENABLE_FEATURE=true
```

**Type Detection:**
- Numbers: `123` → `123` (number)
- Booleans: `true`/`false` → `true`/`false` (boolean)  
- Strings: `"hello"` → `"hello"` (string)

### Method 2: JSON Output with Markers

Output JSON between special markers:

```bash
echo "### JSON_OUTPUT_START ###"
cat << EOF
{
  "deployment_config": {
    "replicas": 5,
    "enabled": true
  }
}
EOF
echo "### JSON_OUTPUT_END ###"
```

## Script Arguments Support

The Setup-Env workflow supports passing arguments to your scripts using the `script_args` parameter:

```yaml
jobs:
  setup:
    uses: ./.github/workflows/Setup-Env.yml
    with:
      script_path: "./scripts/my-script.sh"
      script_args: "--environment prod --action deploy --dry-run false"
```

**Multi-line arguments:**
```yaml
script_args: >-
  --environment ${{ github.event.inputs.environment }}
  --action ${{ github.event.inputs.action }}
  --timeout ${{ github.event.inputs.timeout }}
  ${{ github.event.inputs.verbose == 'true' && '--verbose' || '' }}
```

## Example Scripts

### 1. `example-set-variables.sh`
**Purpose:** Demonstrates setting individual variables using the SCRIPT_ prefix method.

**Features:**
- Sets string, numeric, and boolean values
- Computes Git-related information
- Sets dynamic values based on conditions
- Shows array-like values as JSON strings

**Usage in workflow:**
```yaml
jobs:
  setup:
    uses: ./.github/workflows/Setup-Env.yml
    with:
      script_path: "./examples/scripts/example-set-variables.sh"
```

**Output Example:**
```json
{
  "environment": "prod",
  "WORKFLOW_RUN_NAME": "Automated-20250115-143052",
  "BUILD_NUMBER": "build-1705327852",
  "RETRY_COUNT": 3,
  "ENABLE_NOTIFICATIONS": true,
  "GIT_BRANCH": "main",
  "IS_WEEKEND": false
}
```

### 2. `example-json-output.sh`
**Purpose:** Demonstrates outputting complex JSON directly using markers.

**Features:**
- Outputs nested JSON objects
- Includes calculated metrics
- Shows runtime information
- Demonstrates feature flags

**Usage in workflow:**
```yaml
jobs:
  setup:
    uses: ./.github/workflows/Setup-Env.yml
    with:
      script_path: "./examples/scripts/example-json-output.sh"
```

**Output Example:**
```json
{
  "environment": "prod",
  "deployment_metrics": {
    "estimated_size_mb": 456,
    "estimated_duration_minutes": 23,
    "calculated_at": "2025-01-15T14:30:52Z"
  },
  "feature_flags": {
    "enable_advanced_logging": true,
    "parallel_execution": true
  }
}
```

### 3. `example-modify-config.sh`
**Purpose:** Shows how to override/modify existing configuration values based on conditions.

**Features:**
- Reads existing environment variables
- Applies environment-specific overrides
- Detects execution context (scheduled vs manual)
- Combines both methods (SCRIPT_ vars + JSON)
- Shows conditional logic for different environments

**Usage in workflow:**
```yaml
jobs:
  setup:
    uses: ./.github/workflows/Setup-Env.yml
    with:
      script_path: "./examples/scripts/example-modify-config.sh"
```

**Output Example (Production):**
```json
{
  "environment": "prod",
  "DRY_RUN": false,
  "TIMEOUT_MINUTES": 60,
  "EXECUTION_TYPE": "scheduled",
  "deployment_config": {
    "strategy": "blue-green",
    "replicas": 5
  },
  "monitoring": {
    "enabled": true
  }
}
```

### 4. `example-with-arguments.sh`
**Purpose:** Demonstrates handling command-line arguments and setting configuration based on those arguments.

**Features:**
- Parses command-line arguments using standard options
- Validates argument values
- Sets different configurations based on arguments
- Supports help and usage display
- Combines argument processing with both output methods

**Usage in workflow:**
```yaml
jobs:
  setup:
    uses: ./.github/workflows/Setup-Env.yml
    with:
      script_path: "./examples/scripts/example-with-arguments.sh"
      script_args: "--environment prod --action deploy --timeout 300 --verbose"
```

**Output Example (with args):**
```json
{
  "environment": "prod",
  "ENVIRONMENT": "prod",
  "ACTION": "deploy",
  "DRY_RUN": false,
  "TIMEOUT_SECONDS": 300,
  "REPLICAS": 5,
  "CPU_LIMIT": "2000m",
  "deployment_strategy": {
    "type": "blue-green",
    "max_unavailable": "0"
  },
  "security_config": {
    "network_policies_enabled": true,
    "pod_security_standards": "restricted"
  }
}
```

## Merging Behavior

1. **Configuration First**: Base configuration comes from workflow inputs or schedule config
2. **Script Override**: Script output is merged on top (script values take precedence)
3. **Type Preservation**: JSON types (string, number, boolean) are preserved
4. **Deep Merge**: Complex objects are merged recursively

**Example Merge:**
```json
// Base Config
{
  "environment": "prod",
  "timeout": 30,
  "features": {"a": true}
}

// Script Output  
{
  "timeout": 60,
  "features": {"b": true},
  "new_field": "value"
}

// Final Result
{
  "environment": "prod",
  "timeout": 60,
  "features": {"a": true, "b": true},
  "new_field": "value"
}
```

## Best Practices

1. **Use Descriptive Names**: Choose clear variable names that indicate their purpose
2. **Consistent Prefixes**: Always use `SCRIPT_` for environment variables
3. **Type Consistency**: Be explicit about data types (numbers, booleans, strings)
4. **Error Handling**: Include error checking in your scripts
5. **Documentation**: Comment your scripts to explain the logic
6. **Validation**: Validate JSON output before setting complex objects

## Usage in Workflows

To use these scripts in your workflow:

1. **Copy to your repository**: Copy the desired script to your repo
2. **Make executable**: Ensure the script has execute permissions
3. **Reference in workflow**: Pass the script path to Setup-Env workflow
4. **Access variables**: Use the merged variables in subsequent steps

```yaml
jobs:
  setup:
    uses: ./.github/workflows/Setup-Env.yml  
    with:
      script_path: "./scripts/my-custom-script.sh"
      
  deploy:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Use Variables
        run: |
          variables='${{ needs.setup.outputs.variables }}'
          echo "Environment: $(echo "$variables" | jq -r '.environment')"
          echo "Timeout: $(echo "$variables" | jq -r '.TIMEOUT_MINUTES')"
```
