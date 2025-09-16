# NGO Nabarun Templates - Comprehensive Usage Guide

This guide provides step-by-step instructions for using every component in the ngo-nabarun-templates repository. The repository contains reusable GitHub Actions workflows, composite actions, and utility scripts for automating testing, building, deployment, and environment management.

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Workflows](#workflows)
3. [Composite Actions](#composite-actions)
4. [Utility Scripts](#utility-scripts)
5. [Configuration System](#configuration-system)
6. [Examples and Templates](#examples-and-templates)
7. [Best Practices](#best-practices)

---

## Repository Overview

### Structure
```
ngo-nabarun-templates/
├── .github/
│   ├── workflows/          # Reusable workflows
│   └── actions/           # Composite actions
├── scripts/               # Utility scripts
├── examples/             # Example configurations and workflows
├── docs/                 # Documentation
└── config/              # Configuration files
```

### Key Concepts
- **Reusable Workflows**: Complete workflows that can be called from other repositories
- **Composite Actions**: Reusable action components for specific tasks
- **Configuration System**: Dynamic configuration based on schedules and environments
- **Templates**: Pre-built examples for common use cases

---

## Workflows

### 1. Setup-Env.yml - Environment Configuration

**Purpose**: Dynamic environment setup and variable resolution for scheduled and triggered workflows.

**Usage**:
```yaml
jobs:
  setup:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Setup-Env.yml@main
    with:
      inputs: ${{ toJson(inputs) }}
      script_path: "scripts/custom-setup.sh"  # Optional
      script_args: "--env prod --region us-east"  # Optional
      resolve_variables: "API_URL,DB_HOST"  # Optional
    
  use_variables:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Use resolved variables
        run: |
          echo "Variables: ${{ needs.setup.outputs.variables }}"
```

**Features**:
- ✅ Automatic schedule-based configuration detection
- ✅ Support for workflow_dispatch and repository_dispatch inputs
- ✅ Optional custom script execution
- ✅ Environment variable resolution and merging

**When to Use**:
- Scheduled workflows with different configurations
- Complex environment setups requiring dynamic variables
- Workflows needing script-based preprocessing

---

### 2. Build-Test.yml - Application Building and Testing

**Purpose**: Universal build and test workflow supporting Java and Node.js applications.

**Usage**:
```yaml
jobs:
  build:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: "java"  # or "node"
      repo: "my-org/my-app"
      branch: "main"
      command: "clean test"  # Maven command
      java_version: "17"
      working_directory: "."
      maven_options: "-Dmaven.test.skip=false"
```

**Platform-Specific Examples**:

**Java Application**:
```yaml
with:
  platform: "java"
  command: "clean package"
  java_version: "17"
  maven_options: "-DskipTests=false -Dspring.profiles.active=test"
```

**Node.js Application**:
```yaml
with:
  platform: "node"
  command: "npm run test"
  node_version: "18"
```

**When to Use**:
- CI/CD pipelines requiring build and test
- Multi-platform applications (Java/Node.js)
- Standard build processes with caching

---

### 3. Run-Tests.yml - Sequential Test Execution

**Purpose**: Execute Cucumber tests sequentially with QMetry integration.

**Usage**:
```yaml
jobs:
  test:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Tests.yml@main
    with:
      test_env: "staging"
      test_doppler_project_name: "my-project"
      test_cucumber_tags: "@smoke"
      test_type: "smoke_tests"
      repository_name: "my-org/test-repo"
      branch_name: "main"
      test_cycle_folder: "1234567"
      test_case_folder: "7654321"
      qmetry_project_id: "10004"
      jira_url: "https://myorg.atlassian.net"
      upload_result: true
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
      qmetry_open_api_key: ${{ secrets.QMETRY_OPEN_API_KEY }}
```

**Output Usage**:
```yaml
- name: Use test results
  run: |
    echo "Test Execution URL: ${{ needs.test.outputs.test_execution_url }}"
    echo "Test Cycle: ${{ needs.test.outputs.test_cycle }}"
    echo "Upload Success: ${{ needs.test.outputs.test_results_uploaded }}"
```

**When to Use**:
- Single-threaded test execution
- Simple test suites with basic requirements
- Legacy test frameworks

---

### 4. Run-Parallel-Tests.yml - Parallel Test Execution

**Purpose**: Execute Cucumber tests in parallel with smart re-run capabilities and QMetry integration.

**Usage**:
```yaml
jobs:
  parallel_test:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Parallel-Tests.yml@main
    with:
      test_env: "staging"
      test_doppler_project_name: "my-project"
      test_cucumber_tags: "@regression"
      test_type: "regression_tests"
      max_tests_per_matrix: 5
      max_rerun_attempt: 2
      repository_name: "my-org/test-repo"
      branch_name: "main"
      test_cycle_folder: "1234567"
      test_case_folder: "7654321"
      qmetry_project_id: "10004"
      jira_url: "https://myorg.atlassian.net"
      rerun_mode: "failed-only"  # "all", "failed-only", "selective"
      enable_smart_rerun: true
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
      qmetry_open_api_key: ${{ secrets.QMETRY_OPEN_API_KEY }}
```

**Smart Re-run Configuration**:
```yaml
# First run - discovers and runs all scenarios
rerun_mode: "all"
enable_smart_rerun: true

# Re-run - only runs previously failed scenarios
rerun_mode: "failed-only"
enable_smart_rerun: true
```

**When to Use**:
- Large test suites requiring parallelization
- Flaky test environments benefiting from smart re-runs
- Performance-critical test execution

---

### 5. Deploy-GCP-v2.yml - Google Cloud Deployment

**Purpose**: Deploy applications to Google Cloud Platform with health checks and traffic management.

**Usage**:
```yaml
jobs:
  deploy:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Deploy-GCP-v2.yml@main
    with:
      app_name: "my-app"
      environment: "staging"
      gcp_project: "my-gcp-project"
      gae_service: "default"
      version_prefix: "v"
      enable_traffic_promotion: true
      health_check_url: "/health"
      max_health_check_attempts: 10
    secrets:
      gcp_service_account_key: ${{ secrets.GCP_SA_KEY }}
```

**When to Use**:
- Google App Engine deployments
- Applications requiring zero-downtime deployments
- Multi-environment deployment pipelines

---

## Composite Actions

### Testing Actions

#### 1. test-setup - Environment Setup

**Purpose**: Complete test environment setup including Java, Maven caching, and repository checkout.

**Usage**:
```yaml
- name: Setup test environment
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-setup@main
  with:
    java_version: "17"
    test_repository: "my-org/test-repo"
    test_branch: "develop"
    enable_maven_cache: true
```

**Advanced Usage**:
```yaml
- name: Setup with custom paths
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-setup@main
  with:
    java_version: "11"
    templates_repository: "my-org/custom-templates"
    test_repository: "my-org/integration-tests"
    test_branch: "feature/new-tests"
    templates_path: "custom-actions"
    test_path: "integration"
    enable_maven_cache: false
```

#### 2. cucumber-discover-scenarios - Scenario Discovery

**Purpose**: Discover Cucumber scenarios by tag and create parallel execution matrix.

**Usage**:
```yaml
- name: Discover scenarios
  id: discover
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/cucumber-discover-scenarios@main
  with:
    cucumber_tags: "@smoke and not @slow"
    max_scenarios_per_job: 3
    test_directory: "tests"

- name: Use discovered scenarios
  run: |
    echo "Found ${{ steps.discover.outputs.scenario_count }} scenarios"
    echo "Matrix: ${{ steps.discover.outputs.matrix }}"
```

**Tag Expression Examples**:
```yaml
# Single tag
cucumber_tags: "@smoke"

# Multiple tags (AND)
cucumber_tags: "@smoke and @login"

# Multiple tags (OR)
cucumber_tags: "@smoke or @critical"

# Exclude scenarios
cucumber_tags: "@regression and not @slow"

# Complex expressions
cucumber_tags: "(@smoke or @critical) and not (@slow or @manual)"
```

#### 3. cucumber-run-tests - Test Execution

**Purpose**: Execute Cucumber tests with retry mechanisms and multiple output formats.

**Usage**:
```yaml
- name: Run tests
  id: run_tests
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/cucumber-run-tests@main
  with:
    scenarios: "features/login.feature:10,features/checkout.feature:25"
    job_index: ${{ strategy.job-index }}
    test_environment: "staging"
    doppler_project_name: "my-project"
    doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
    max_rerun_attempts: 2
    headless_mode: "Y"
  continue-on-error: true

- name: Check results
  run: |
    echo "Status: ${{ steps.run_tests.outputs.test_status }}"
    echo "Exit Code: ${{ steps.run_tests.outputs.exit_code }}"
```

#### 4. test-results-consolidation - Results Processing

**Purpose**: Download and merge parallel test results into consolidated report.

**Usage**:
```yaml
- name: Consolidate results
  id: consolidate
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-results-consolidation@main
  with:
    templates_repository: "my-org/custom-templates"
    artifact_download_path: "test-artifacts"
    merged_output_path: "consolidated"
    merged_artifact_name: "final-results"

- name: Use consolidated results
  run: |
    echo "Merged file: ${{ steps.consolidate.outputs.merged_file_path }}"
    echo "Total scenarios: ${{ steps.consolidate.outputs.total_scenarios }}"
```

#### 5. test-cycle-cache-manager - Test Cycle Management

**Purpose**: Manage test cycle caching for workflow re-runs and QMetry integration.

**Usage**:
```yaml
- name: Manage cache
  id: cache_manager
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-cycle-cache-manager@main
  with:
    workflow_name: ${{ github.workflow }}
    run_id: ${{ github.run_id }}
    run_attempt: ${{ github.run_attempt }}
    test_type: "integration"
    cache_file_path: "test-variables.env"

- name: Use cache info
  run: |
    echo "Is re-run: ${{ steps.cache_manager.outputs.is_rerun }}"
    echo "Cached cycle: ${{ steps.cache_manager.outputs.cached_test_cycle }}"
```

### QMetry Integration Actions

#### 6. qmetry-upload-manager - Test Results Upload

**Purpose**: Upload test results to QMetry with automatic retry and validation.

**Usage**:
```yaml
- name: Upload to QMetry
  id: upload
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/qmetry-upload-manager@main
  with:
    qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
    test_environment: "staging"
    test_cycle_summary: "Automated Tests - Build 123"
    test_cycle_folder: "1234567"
    test_case_folder: "7654321"
    app_server_version: "v1.2.3"
    app_ui_version: "v2.1.0"
    test_type: "regression"
    run_id: ${{ github.run_id }}
    run_attempt: ${{ github.run_attempt }}
    results_file_path: "merged/cucumber.json"
    cached_test_cycle: ""  # For re-runs

- name: Check upload status
  run: |
    echo "Upload Status: ${{ steps.upload.outputs.upload_status }}"
    echo "Import Status: ${{ steps.upload.outputs.import_status }}"
```

#### 7. qmetry-result-linker - Result URL Generation

**Purpose**: Generate QMetry execution URLs and manage result caching.

**Usage**:
```yaml
- name: Generate links
  id: linker
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/qmetry-result-linker@main
  with:
    qmetry_open_api_key: ${{ secrets.QMETRY_OPEN_API_KEY }}
    qmetry_project_id: "10004"
    jira_url: "https://myorg.atlassian.net"
    test_cycle_summary: "Automated Tests - Build 123"
    workflow_name: ${{ github.workflow }}
    run_id: ${{ github.run_id }}
    cache_file_path: "variables.env"

- name: Use generated links
  run: |
    echo "Execution URL: ${{ steps.linker.outputs.execution_url }}"
    echo "Test Cycle: ${{ steps.linker.outputs.test_cycle }}"
```

### Build Actions

#### 8. build-java - Java Application Build

**Purpose**: Build and test Java applications with Maven.

**Usage**:
```yaml
- name: Build Java app
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-java@main
  with:
    java_version: "17"
    maven_command: "clean package"
    maven_options: "-DskipTests=false -Dspring.profiles.active=test"
    working_directory: "backend"
    enable_cache: true
    upload_test_results: true
```

#### 9. build-node - Node.js Application Build

**Purpose**: Build and test Node.js applications.

**Usage**:
```yaml
- name: Build Node.js app
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-node@main
  with:
    node_version: "18"
    command: "npm run build && npm test"
    working_directory: "frontend"
```

### GCP Actions

#### 10. gcp-health-check-deployment - Health Validation

**Purpose**: Validate deployed applications with health checks.

**Usage**:
```yaml
- name: Health check
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-health-check-deployment@main
  with:
    health_check_url: "https://my-app-staging.appspot.com/health"
    max_attempts: 15
    wait_interval: 30
    expected_status: "200"
```

#### 11. gcp-promote-gae-traffic - Traffic Management

**Purpose**: Promote traffic to new App Engine versions.

**Usage**:
```yaml
- name: Promote traffic
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-promote-gae-traffic@main
  with:
    gcp_project: "my-project"
    gae_service: "api"
    version_id: "v20250115-123456"
    traffic_percentage: 100
```

### Utility Actions

#### 12. notify-system - Notifications

**Purpose**: Send notifications to various systems (Slack, email, etc.).

**Usage**:
```yaml
- name: Send notification
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/notify-system@main
  with:
    notification_type: "slack"
    message: "Deployment completed successfully"
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    channel: "#deployments"
```

#### 13. resolve-inputs - Input Resolution

**Purpose**: Resolve and merge inputs from various GitHub event sources.

**Usage**:
```yaml
- name: Resolve inputs
  id: resolve
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/resolve-inputs@main
  with:
    inputs: ${{ toJson(inputs) }}
    client_payload: ${{ toJson(github.event.client_payload) }}
    schedule_config_file: "config/schedule-config.json"

- name: Use resolved inputs
  run: echo "Variables: ${{ steps.resolve.outputs.variables }}"
```

---

## Utility Scripts

### Testing Scripts

#### 1. discover_scenarios.sh - Scenario Discovery

**Purpose**: Legacy script for discovering Cucumber scenarios (replaced by composite action).

**Usage**:
```bash
./scripts/discover_scenarios.sh \
  --tags "@smoke" \
  --max-per-job 5 \
  --output-dir "discovered"
```

#### 2. run_cucumber_tests.sh - Test Execution

**Purpose**: Execute Cucumber tests with environment configuration.

**Usage**:
```bash
./scripts/run_cucumber_tests.sh \
  --scenarios "features/login.feature:10,features/signup.feature:15" \
  --environment "staging" \
  --job-index 1
```

#### 3. run_cucumber_with_reruns.sh - Test Execution with Retries

**Purpose**: Execute tests with automatic retry mechanisms.

**Usage**:
```bash
./scripts/run_cucumber_with_reruns.sh \
  --scenarios "features/flaky.feature:20" \
  --max-reruns 3 \
  --environment "staging"
```

#### 4. merge-cucumber-jsons.sh - Result Merging

**Purpose**: Merge multiple Cucumber JSON files into consolidated report.

**Usage**:
```bash
./scripts/merge-cucumber-jsons.sh \
  --input-dir "test-results" \
  --output-file "merged/cucumber.json" \
  --validate
```

### Integration Scripts

#### 5. process-auth0.sh - Auth0 Processing

**Purpose**: Process Auth0 configuration files with environment-specific replacements.

**Usage**:
```bash
./scripts/process-auth0.sh \
  --source-env "dev" \
  --target-env "staging" \
  --config-dir "auth0-configs" \
  --output-dir "processed"
```

#### 6. wait-for-qmetry-report-import.sh - QMetry Import Polling

**Purpose**: Poll QMetry API for import completion status.

**Usage**:
```bash
./scripts/wait-for-qmetry-report-import.sh \
  "tracking-id-12345" \
  "$QMETRY_API_KEY" \
  --timeout 300 \
  --interval 10
```

### Python Scripts

#### 7. auth0/process_auth0.py - Auth0 Configuration Processing

**Purpose**: Advanced Auth0 configuration processing with Python.

**Usage**:
```bash
python scripts/auth0/process_auth0.py \
  --source-file auth0-dev.json \
  --target-file auth0-staging.json \
  --template-dir templates/ \
  --output-dir processed/ \
  --dry-run
```

#### 8. common/set_env.py - Environment Variable Management

**Purpose**: Set GitHub Actions environment variables dynamically.

**Usage**:
```bash
python scripts/common/set_env.py \
  --event-type "workflow_dispatch" \
  --inputs '{"environment":"staging","version":"v1.2.3"}' \
  --output-env
```

---

## Configuration System

### Schedule-Based Configuration

#### 1. Configuration File Structure

Create configuration files in `config/config-{WORKFLOW_NAME}.json`:

```json
{
  "0 2 * * *": {
    "environment": "production",
    "test_type": "smoke_tests",
    "notification_channel": "#prod-alerts",
    "max_retries": 3
  },
  "0 */6 * * *": {
    "environment": "staging", 
    "test_type": "regression_tests",
    "notification_channel": "#dev-alerts",
    "max_retries": 1
  }
}
```

#### 2. Using Configuration in Workflows

```yaml
name: Scheduled Tests
on:
  schedule:
    - cron: "0 2 * * *"      # Daily production smoke tests
    - cron: "0 */6 * * *"    # Every 6 hours staging regression
  workflow_dispatch:

jobs:
  setup:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Setup-Env.yml@main
    
  test:
    needs: setup
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Parallel-Tests.yml@main
    with:
      test_env: ${{ fromJson(needs.setup.outputs.variables).environment }}
      test_type: ${{ fromJson(needs.setup.outputs.variables).test_type }}
      # ... other parameters from configuration
```

### Dynamic Input Resolution

#### 1. Workflow Dispatch Inputs

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Target environment"
        required: true
        type: choice
        options: ["dev", "staging", "prod"]
      test_suite:
        description: "Test suite to run"
        required: true
        type: choice
        options: ["smoke", "regression", "performance"]

jobs:
  setup:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Setup-Env.yml@main
    with:
      inputs: ${{ toJson(inputs) }}
```

#### 2. Repository Dispatch Inputs

```yaml
on:
  repository_dispatch:
    types: [run-tests]

jobs:
  setup:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Setup-Env.yml@main
    with:
      client_payload: ${{ toJson(github.event.client_payload) }}
```

**Trigger via API**:
```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/owner/repo/dispatches \
  -d '{
    "event_type": "run-tests",
    "client_payload": {
      "environment": "staging",
      "test_type": "smoke",
      "branch": "feature/new-tests"
    }
  }'
```

---

## Examples and Templates

### 1. Complete Test Pipeline

```yaml
name: Complete Test Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: "0 2 * * *"  # Daily at 2 AM
  workflow_dispatch:

jobs:
  # Environment setup and variable resolution
  setup:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Setup-Env.yml@main
    with:
      inputs: ${{ toJson(inputs) }}
      script_path: "scripts/set-test-variables.sh"
      resolve_variables: "TEST_ENV,MAX_PARALLEL,NOTIFICATION_CHANNEL"

  # Build and unit test the application
  build:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: "java"
      repo: "my-org/my-app"
      branch: ${{ github.ref_name }}
      command: "clean test"
      java_version: "17"

  # Run parallel integration tests
  integration_tests:
    needs: [setup, build]
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Parallel-Tests.yml@main
    with:
      test_env: ${{ fromJson(needs.setup.outputs.variables).TEST_ENV }}
      test_cucumber_tags: "@integration"
      test_type: "integration"
      max_tests_per_matrix: ${{ fromJson(needs.setup.outputs.variables).MAX_PARALLEL }}
      enable_smart_rerun: true
      rerun_mode: "failed-only"
      repository_name: "my-org/integration-tests"
      branch_name: "main"
      test_cycle_folder: "1234567"
      test_case_folder: "7654321"
      qmetry_project_id: "10004"
      jira_url: "https://myorg.atlassian.net"
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
      qmetry_open_api_key: ${{ secrets.QMETRY_OPEN_API_KEY }}

  # Deploy to staging (if tests pass)
  deploy_staging:
    if: needs.integration_tests.result == 'success' && github.ref == 'refs/heads/main'
    needs: [setup, integration_tests]
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Deploy-GCP-v2.yml@main
    with:
      app_name: "my-app"
      environment: "staging"
      gcp_project: "my-project-staging"
      enable_traffic_promotion: true
    secrets:
      gcp_service_account_key: ${{ secrets.GCP_SA_KEY_STAGING }}

  # Run smoke tests on staging
  smoke_tests:
    if: needs.deploy_staging.result == 'success'
    needs: [setup, deploy_staging]
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Tests.yml@main
    with:
      test_env: "staging"
      test_cucumber_tags: "@smoke"
      test_type: "smoke"
      repository_name: "my-org/smoke-tests"
      upload_result: false  # Skip QMetry for quick smoke tests
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}

  # Notify results
  notify:
    if: always()
    needs: [integration_tests, smoke_tests]
    runs-on: ubuntu-latest
    steps:
      - name: Notify team
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/notify-system@main
        with:
          notification_type: "slack"
          message: |
            Pipeline Results:
            - Integration Tests: ${{ needs.integration_tests.result }}
            - Smoke Tests: ${{ needs.smoke_tests.result }}
            - Test Results: ${{ needs.integration_tests.outputs.test_execution_url }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
          channel: ${{ fromJson(needs.setup.outputs.variables).NOTIFICATION_CHANNEL }}
```

### 2. Custom Test Discovery and Execution

```yaml
name: Custom Test Flow
on:
  workflow_dispatch:
    inputs:
      test_tags:
        description: "Cucumber tags to run"
        required: true
        default: "@smoke"
      environment:
        description: "Test environment"
        required: true
        type: choice
        options: ["dev", "staging", "prod"]

jobs:
  custom_discovery:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.discover.outputs.matrix }}
      scenario_count: ${{ steps.discover.outputs.scenario_count }}
    steps:
      - name: Setup environment
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-setup@main
        with:
          test_repository: "my-org/custom-tests"
          java_version: "11"

      - name: Discover scenarios
        id: discover
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/cucumber-discover-scenarios@main
        with:
          cucumber_tags: ${{ inputs.test_tags }}
          max_scenarios_per_job: 4
          test_directory: "custom-tests"

  custom_execution:
    needs: custom_discovery
    if: needs.custom_discovery.outputs.scenario_count > 0
    runs-on: windows-latest
    strategy:
      fail-fast: false
      matrix: ${{ fromJson(needs.custom_discovery.outputs.matrix) }}
    steps:
      - name: Setup environment
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-setup@main
        with:
          test_repository: "my-org/custom-tests"
          java_version: "11"

      - name: Execute tests
        id: run_tests
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/cucumber-run-tests@main
        with:
          scenarios: ${{ join(matrix.scenarios, ',') }}
          job_index: ${{ strategy.job-index }}
          test_environment: ${{ inputs.environment }}
          doppler_project_name: "custom-project"
          doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
          max_rerun_attempts: 1
          headless_mode: "N"  # Run with UI for debugging
        continue-on-error: true

      - name: Upload custom results
        uses: actions/upload-artifact@v4
        with:
          name: custom-results-${{ strategy.job-index }}
          path: test/target/cucumber-${{ strategy.job-index }}.json

  custom_reporting:
    needs: custom_execution
    if: always()
    runs-on: ubuntu-latest
    steps:
      - name: Consolidate results
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-results-consolidation@main

      - name: Custom result processing
        run: |
          echo "Processing ${{ needs.custom_discovery.outputs.scenario_count }} scenarios"
          # Add custom result processing logic here
```

### 3. Multi-Environment Deployment Pipeline

```yaml
name: Multi-Environment Deploy
on:
  workflow_dispatch:
    inputs:
      version:
        description: "Version to deploy"
        required: true
      target_environments:
        description: "Comma-separated environments (dev,staging,prod)"
        required: true
        default: "dev,staging"

jobs:
  setup:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Setup-Env.yml@main
    with:
      inputs: ${{ toJson(inputs) }}
      script_path: "scripts/prepare-deployment.sh"
      script_args: "--version ${{ inputs.version }} --environments '${{ inputs.target_environments }}'"

  deploy:
    needs: setup
    strategy:
      matrix:
        environment: ${{ fromJson(needs.setup.outputs.variables).environments }}
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Deploy-GCP-v2.yml@main
    with:
      app_name: "my-app"
      environment: ${{ matrix.environment }}
      gcp_project: "my-project-${{ matrix.environment }}"
      version_prefix: ${{ inputs.version }}
    secrets:
      gcp_service_account_key: ${{ secrets[format('GCP_SA_KEY_{0}', upper(matrix.environment))] }}

  validate:
    needs: deploy
    strategy:
      matrix:
        environment: ${{ fromJson(needs.setup.outputs.variables).environments }}
    runs-on: ubuntu-latest
    steps:
      - name: Health check
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-health-check-deployment@main
        with:
          health_check_url: "https://my-app-${{ matrix.environment }}.appspot.com/health"
          max_attempts: 10

      - name: Run environment tests
        uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Tests.yml@main
        with:
          test_env: ${{ matrix.environment }}
          test_cucumber_tags: "@smoke"
          test_type: "deployment_validation"
          upload_result: false
        secrets:
          test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
```

---

## Best Practices

### 1. Security Best Practices

**Secrets Management**:
```yaml
# ✅ Good: Use GitHub secrets
doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}

# ❌ Bad: Hard-coded secrets
doppler_service_token: "dp.st.xxx.yyy.zzz"
```

**Dynamic Secret References**:
```yaml
# ✅ Good: Dynamic secret references
secrets:
  gcp_key: ${{ secrets[format('GCP_SA_KEY_{0}', upper(inputs.environment))] }}
```

### 2. Error Handling Best Practices

**Continue on Error for Tests**:
```yaml
- name: Run tests
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/cucumber-run-tests@main
  continue-on-error: true  # ✅ Allow workflow to continue

- name: Process results
  if: always()  # ✅ Run regardless of test outcome
```

**Conditional Job Execution**:
```yaml
deploy:
  if: needs.test.result == 'success'  # ✅ Only deploy if tests pass
  needs: test
```

### 3. Performance Best Practices

**Parallel Test Execution**:
```yaml
# ✅ Good: Use parallel workflow for large test suites
uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Parallel-Tests.yml@main
with:
  max_tests_per_matrix: 5  # Optimize based on test execution time
```

**Smart Re-runs**:
```yaml
# ✅ Good: Enable smart re-runs for flaky tests
enable_smart_rerun: true
rerun_mode: "failed-only"
```

### 4. Configuration Best Practices

**Environment-Specific Settings**:
```json
{
  "0 2 * * *": {
    "environment": "production",
    "test_type": "smoke_tests",
    "max_retries": 3,
    "timeout_minutes": 30
  },
  "0 */2 * * *": {
    "environment": "staging",
    "test_type": "regression_tests", 
    "max_retries": 1,
    "timeout_minutes": 60
  }
}
```

**Variable Resolution**:
```yaml
# ✅ Good: Use resolve_variables for dynamic configs
resolve_variables: "API_URL,DB_HOST,MAX_RETRIES"
```

### 5. Monitoring and Observability

**Comprehensive Logging**:
```yaml
- name: Log execution details
  run: |
    echo "Test Status: ${{ steps.tests.outputs.test_status }}"
    echo "Scenario Count: ${{ steps.discovery.outputs.scenario_count }}"
    echo "Execution URL: ${{ steps.results.outputs.execution_url }}"
```

**Notifications**:
```yaml
- name: Notify on failure
  if: failure()
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/notify-system@main
  with:
    notification_type: "slack"
    message: "❌ Pipeline failed: ${{ github.run_id }}"
```

### 6. Maintenance Best Practices

**Version Pinning**:
```yaml
# ✅ Good: Pin to specific branch/tag for stability
uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Tests.yml@v1.2.0

# ⚠️ Acceptable: Use main for latest features (test thoroughly)
uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Tests.yml@main
```

**Documentation**:
```yaml
name: Well Documented Pipeline
# Purpose: Runs integration tests on every push to main
# Maintainer: Platform Team
# Last Updated: 2025-01-15
on:
  push:
    branches: [main]
```

**Regular Updates**:
- Monitor repository releases for new features and bug fixes
- Test template updates in non-production environments first
- Keep configuration files and secrets up to date

---

## Troubleshooting Guide

### Common Issues

1. **QMetry Upload Failures**
   - Check folder ID formatting (remove commas)
   - Verify API keys are valid
   - Ensure test results are in valid JSON format

2. **Test Discovery Issues**
   - Verify Cucumber tags exist in feature files
   - Check feature file paths and directory structure
   - Ensure Maven configuration supports dry-run execution

3. **Parallel Execution Problems**
   - Verify matrix configuration is valid JSON
   - Check job limits in GitHub Actions
   - Monitor resource usage and timeouts

4. **Configuration Resolution**
   - Verify configuration file naming matches workflow file
   - Check JSON syntax in configuration files
   - Ensure schedule expressions match cron format

---

This comprehensive guide covers all components in the ngo-nabarun-templates repository. Each section includes practical examples, best practices, and troubleshooting information to help users effectively implement automation workflows.
