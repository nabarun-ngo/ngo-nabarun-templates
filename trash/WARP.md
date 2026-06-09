# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This repository contains automation scripts and GitHub Actions workflow templates for Nabarun NGO projects. It serves as a centralized collection of CI/CD utilities, focusing on:
- Cucumber test orchestration and parallel execution
- Auth0 environment synchronization and data processing
- Firebase configuration management
- QMetry test reporting integration

## Key Architecture Patterns

### Test Orchestration Pipeline
The repository implements a sophisticated parallel test execution system:
1. **Discovery Phase**: `discover_scenarios.sh` uses Cucumber dry-run mode to extract scenarios by tags and creates GitHub Actions matrices for parallel execution
2. **Execution Phase**: `run_cucumber_tests.sh` and `run_cucumber_with_reruns.sh` handle test execution with configurable retry logic
3. **Aggregation Phase**: `merge-cucumber-jsons.sh` consolidates results from parallel jobs into a single report

### Environment Processing System
Auth0 and Firebase configurations follow a template-based replacement pattern:
- JSON mapping files define keyword-to-value relationships
- Python scripts (`process_auth0.py`, `process_auth0_v2.py`) perform bidirectional transformations
- Backup and dry-run capabilities ensure safe configuration updates

### Dynamic GitHub Actions Integration
Scripts are designed to work seamlessly with GitHub Actions:
- Environment variables are set via `$GITHUB_OUTPUT` and `$GITHUB_ENV`
- `set_env.py` bridges repository_dispatch and workflow_dispatch inputs
- Doppler integration for secure configuration management

## Common Commands

### Test Discovery and Execution
```bash
# Discover scenarios by tag and prepare matrix
./scripts/discover_scenarios.sh @smoke 10

# Run specific scenarios with reruns
./scripts/run_cucumber_with_reruns.sh "src/test/resources/features/example.feature:10" 1 dev project-name token 3

# Merge test results
./scripts/merge-cucumber-jsons.sh all-results merged
```

### Auth0 Configuration Processing
```bash
# Replace values with template keys (reverse processing)
python scripts/auth0/process_auth0_v2.py env.json config.json --dry-run

# Process configuration between environments
python scripts/auth0/process_auth0.py source_env.json dest_env.json target_file.json
```

### Environment Setup for GitHub Actions
```bash
# Set environment variables from inputs/payload
python scripts/common/set_env.py
```

## Testing Scripts Locally

Most scripts require specific directory structure and dependencies:
- Scripts expect to run from the repository root
- Cucumber scripts require a `test/` directory with Maven setup
- Auth0 scripts need JSON configuration files with `AUTH0_KEYWORD_REPLACE_MAPPINGS` structure
- QMetry integration requires valid API keys and tracking IDs

## Workflow Templates Structure

The `trash/` directory contains GitHub Actions workflow templates:
- **Auth0 workflows**: Handle tenant synchronization and configuration updates
- **Firebase workflows**: Manage environment configuration files
- **Test workflows**: Orchestrate parallel Cucumber test execution
- Templates use reusable workflow patterns with parameterized inputs

## Configuration Patterns

### JSON Mapping Files
Auth0 and Firebase configurations use standardized JSON structure:
```json
{
  "AUTH0_KEYWORD_REPLACE_MAPPINGS": {
    "KEY_NAME": "actual_value",
    "ANOTHER_KEY": "another_value"
  }
}
```

### Script Parameter Conventions
- Environment names: `dev`, `staging`, `prod`
- Doppler integration: project names and service tokens
- Test tags: Cucumber-style `@tagname` format
- Job indexing: Zero-based for parallel execution

## Dependencies

### Required Tools
- `jq` for JSON processing in bash scripts
- Maven for Java/Cucumber test execution
- Python 3.x for configuration processing scripts

### External Integrations
- **Doppler**: Secure configuration management
- **QMetry**: Test result reporting and tracking
- **GitHub Actions**: CI/CD pipeline execution
- **Auth0**: Identity provider configuration management
