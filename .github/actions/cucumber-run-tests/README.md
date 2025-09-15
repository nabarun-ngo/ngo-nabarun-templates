# Cucumber Test Execution Action

A composite action that executes Cucumber tests with configurable environment settings and retry mechanisms.

## Description

This action replaces the `run_cucumber_tests.sh` script and provides:
- Cucumber test execution with Maven
- Configurable test environments via Doppler
- Test retry mechanisms for flaky tests
- Multiple output formats (HTML, JSON, JUnit XML)
- Comprehensive error handling and validation

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `scenarios` | Comma-separated list of scenarios to run | Yes | - |
| `job_index` | Job index for file naming and identification | Yes | - |
| `test_environment` | Test environment (dev, staging, prod, etc.) | Yes | - |
| `doppler_project_name` | Doppler project name for configuration | Yes | - |
| `doppler_service_token` | Doppler service token for authentication | Yes | - |
| `max_rerun_attempts` | Maximum number of test rerun attempts on failure | No | `0` |
| `test_directory` | Directory containing the test project | No | `test` |
| `headless_mode` | Run tests in headless mode (Y/N) | No | `N` |

## Outputs

| Output | Description |
|--------|-------------|
| `test_status` | Test execution status (PASSED or FAILED) |
| `exit_code` | Test execution exit code |
| `results_path` | Path to test results files |

## Usage

```yaml
- name: Run Cucumber Tests
  id: run_tests
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/cucumber-run-tests@main
  with:
    scenarios: 'features/login.feature:10,features/checkout.feature:25'
    job_index: ${{ strategy.job-index }}
    test_environment: 'staging'
    doppler_project_name: 'my-project'
    doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
    max_rerun_attempts: 2
    headless_mode: 'Y'
  continue-on-error: true

- name: Check test results
  run: |
    echo "Test Status: ${{ steps.run_tests.outputs.test_status }}"
    echo "Exit Code: ${{ steps.run_tests.outputs.exit_code }}"
```

## Features

- ✅ **Multiple output formats**: HTML, JSON, and JUnit XML reports
- ✅ **Test retry mechanism**: Configurable rerun attempts for flaky tests
- ✅ **Environment configuration**: Integration with Doppler for secure config
- ✅ **Headless mode**: Support for both headed and headless test execution
- ✅ **Comprehensive validation**: Input validation and artifact verification
- ✅ **Detailed logging**: Clear feedback throughout execution
- ✅ **Error handling**: Proper exit codes and status reporting

## Generated Artifacts

For each test execution, the following files are generated:
- `target/cucumber-{job_index}.html` - HTML test report
- `target/cucumber-{job_index}.json` - JSON test results
- `target/cucumber-{job_index}.xml` - JUnit XML for test reporting

## Environment Variables

The action configures the following environment variables for test execution:
- `ENVIRONMENT` - Test environment name
- `CONFIG_SOURCE` - Set to 'doppler'
- `DOPPLER_PROJECT_NAME` - Doppler project name
- `DOPPLER_SERVICE_TOKEN` - Doppler authentication token

## Error Handling

The action provides robust error handling:
- Validates all inputs before execution
- Checks for required files (pom.xml, test directory)
- Verifies test artifacts after execution  
- Captures and reports exit codes properly
- Continues workflow execution even on test failures (when configured)

## Requirements

- Maven project with Cucumber framework
- Valid pom.xml in test directory
- Doppler configuration for environment management
- Surefire plugin configured for test reruns
