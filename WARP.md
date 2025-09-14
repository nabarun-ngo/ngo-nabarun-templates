# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Purpose

This repository serves as a centralized collection of reusable GitHub Actions workflows and utility scripts for the NGO Nabarun project ecosystem. It acts as a template library that other repositories can reference to standardize CI/CD operations, testing procedures, and deployment workflows.

## Architecture Overview

### Workflow Structure
The repository is organized into two main components:

**`.github/workflows/`** - Contains reusable GitHub Actions workflows that can be called from other repositories using `workflow_call`. These workflows are designed for:
- **Testing**: Automated test execution (sequential and parallel)
- **Building**: Multi-platform build processes (Node.js, Java/Maven)
- **Deployment**: Automated deployment to GCP App Engine and Firebase Hosting
- **Data Synchronization**: Auth0 tenant sync and Firebase Remote Config sync
- **Release Management**: Automated tagging, versioning, and GitHub releases

**`.github/actions/`** - Contains reusable composite actions to reduce code duplication:
- **checkout-and-setup**: Repository checkout with environment setup (Java/Node.js)
- **github-deployment**: GitHub deployment creation and management
- **gcp-setup**: Google Cloud Platform authentication and CLI setup
- **maven-build**: Maven build process with JAR extraction
- **deployment-status**: GitHub deployment status updates
- **firebase-remote-config-sync**: Firebase Remote Config synchronization
- **resolve-inputs**: Input resolution for workflow dispatch events
- **update-run-name**: Dynamic workflow run name updates

**`scripts/`** - Contains utility scripts that support the workflows:
- **Test Discovery**: Dynamic test scenario detection for parallel execution
- **Data Processing**: Auth0 configuration processing with environment-specific replacements
- **Report Management**: Test result aggregation and QMetry integration
- **Utility Functions**: Environment variable handling and common operations

**`trash/`** - Contains unused workflows that have been moved out of active use

### Key Workflow Patterns

1. **Multi-Platform Build Support**: `Build-Test.yml` dynamically handles both Node.js and Java projects based on input parameters
2. **Parallel Test Execution**: `Run-Parallel-Tests.yml` uses dynamic matrix generation to distribute Cucumber tests across multiple runners
3. **Environment-Agnostic Deployments**: Deployment workflows use Doppler for secret management and support multiple environments
4. **Data Sync Workflows**: Automated synchronization between Auth0 tenants and Firebase projects with backup and rollback capabilities

## Common Development Commands

### Testing Workflows Locally
Since these are reusable workflows, they cannot be executed directly. To test workflow logic:

```bash
# Validate workflow syntax
git --no-pager diff HEAD~1 .github/workflows/

# Check script syntax
bash -n scripts/discover_scenarios.sh
bash -n scripts/run_cucumber_tests.sh
```

### Script Development
```bash
# Make scripts executable
find scripts/ -name "*.sh" -exec chmod +x {} \;

# Test script functionality
bash scripts/discover_scenarios.sh "@smoke" 5
bash scripts/merge-cucumber-jsons.sh test-results merged-output
```

### Python Script Testing
```bash
# Test Auth0 processing script
python scripts/auth0/process_auth0_v2.py auth0-config.json tenant.yaml --dry-run

# Test environment variable processing
python scripts/common/set_env.py
```

## Workflow Integration Patterns

### Calling Workflows from Other Repositories
```yaml
jobs:
  test:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Run-Tests.yml@main
    with:
      test_env: "staging"
      test_doppler_project_name: "my-project"
      test_cucumber_tags: "@smoke"
      test_type: "smoke"
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
```

### Using Composite Actions
Composite actions can be used directly in workflows to reduce duplication:

```yaml
steps:
  - name: Checkout and Setup Environment
    uses: ./.github/actions/checkout-and-setup
    with:
      tag_name: ${{ inputs.tag_name }}
      repo_name: ${{ inputs.repo_name }}
      repo_owner_name: ${{ inputs.repo_owner_name }}
      setup_java: 'true'
      java_version: '17'

  - name: Setup GCP
    uses: ./.github/actions/gcp-setup
    with:
      gcp_project_id: ${{ inputs.gcp_project_id }}
      gcp_service_account: ${{ secrets.gcp_service_account }}
```

### Required Secret Configuration
When integrating these workflows, consuming repositories need:
- `DOPPLER_SERVICE_TOKEN` for configuration management
- `QMETRY_API_KEY` and `QMETRY_OPEN_API_KEY` for test reporting
- `GCP_SERVICE_ACCOUNT` for GCP deployments
- `FIREBASE_SERVICE_ACCOUNT_*` for Firebase operations
- `AUTH0_*_CONFIG` for Auth0 synchronization

## Script Functionality

### Test Discovery and Execution
- `discover_scenarios.sh` - Uses Maven and jq to extract Cucumber scenarios by tags and create test matrices
- `run_cucumber_tests.sh` - Executes Cucumber tests with retry logic and proper reporting
- `merge-cucumber-jsons.sh` - Combines multiple test result files for unified reporting

### Auth0 Data Processing
- `process_auth0_v2.py` - Processes Auth0 tenant exports with environment-specific variable replacement using placeholder patterns (`##VARIABLE##`)

### Integration Monitoring
- `wait-for-qmetry-report-import.sh` - Monitors QMetry test result import status with timeout handling

## Repository Optimization

### Composite Actions Benefits
1. **Reduced Duplication**: Common patterns are extracted into reusable components
2. **Centralized Maintenance**: Updates to common operations only need to be made in one place
3. **Improved Readability**: Workflows are cleaner and easier to understand
4. **Consistent Behavior**: Standardized implementations across all workflows

### Unused Workflow Management
- Unused workflows have been moved to the `trash/` folder
- Only actively used workflows remain in the main `.github/workflows/` directory
- This improves maintainability and reduces confusion

## Development Guidelines

### Adding New Workflows
1. Use `workflow_call` trigger for all reusable workflows
2. Define clear input parameters with descriptions and defaults
3. Include proper error handling and status reporting
4. Upload artifacts for debugging and result tracking
5. Use consistent naming patterns for jobs and steps
6. Consider creating composite actions for common patterns

### Adding New Composite Actions
1. Place in `.github/actions/` with descriptive folder names
2. Include comprehensive input validation and error handling
3. Use appropriate shell types (bash for Linux operations)
4. Document all inputs and outputs clearly
5. Test across different runner environments

### Script Development
1. Include proper error handling with `set -e` for bash scripts
2. Validate input parameters and provide usage information
3. Use structured logging with clear status indicators (✅, ❌, ⏳)
4. Support dry-run modes for testing and validation

### Secret Management
- Use Doppler for application configuration
- Store sensitive data as GitHub repository secrets
- Never hardcode credentials in workflows or scripts
- Use environment-specific placeholders for Auth0 processing

## Maintenance Considerations

### Version Management
- The repository uses semantic versioning with automated tagging
- Pre-release versions use `-beta` suffix for staging branches
- Stable releases are promoted from pre-release versions

### Dependency Updates
- Monitor GitHub Actions versions in workflows
- Keep Maven and Node.js versions updated in build workflows
- Update Python package dependencies in processing scripts

### Performance Optimization
- Parallel test execution is configurable via `max_tests_per_matrix`
- Use caching for Maven dependencies and npm packages
- Configure appropriate timeouts for external API calls
