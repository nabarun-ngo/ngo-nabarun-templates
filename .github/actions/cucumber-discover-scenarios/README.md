# Cucumber Scenario Discovery Action

A composite action that discovers Cucumber scenarios by tag and creates a matrix for parallel test execution.

## Description

This action replaces the `discover_scenarios.sh` script and provides:
- Cucumber scenario discovery using dry-run execution
- Matrix creation for GitHub Actions parallel execution
- Tag-based scenario filtering
- Configurable batch sizes for optimal parallelization

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `cucumber_tags` | Cucumber tags to filter scenarios (e.g., @smoke, @regression) | Yes | - |
| `max_scenarios_per_job` | Maximum number of scenarios per matrix job | No | `5` |
| `test_directory` | Directory containing the test project | No | `test` |

## Outputs

| Output | Description |
|--------|-------------|
| `matrix` | JSON matrix for GitHub Actions strategy |
| `scenario_count` | Total number of scenarios found |

## Usage

```yaml
- name: Discover test scenarios
  id: discover
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/cucumber-discover-scenarios@main
  with:
    cucumber_tags: '@smoke'
    max_scenarios_per_job: 3

- name: Use matrix in strategy
  strategy:
    matrix: ${{ fromJson(steps.discover.outputs.matrix) }}
```

## Features

- ✅ **Tag-based filtering**: Supports all Cucumber tag expressions
- ✅ **Parallel execution**: Creates optimal job distribution
- ✅ **Error handling**: Validates inputs and handles edge cases
- ✅ **Detailed logging**: Provides clear feedback on scenario discovery
- ✅ **Zero scenarios handling**: Gracefully handles empty results

## Matrix Output Format

The action creates a matrix in the following format:

```json
{
  "include": [
    {
      "scenarios": [
        "features/login.feature:10",
        "features/login.feature:25"
      ]
    },
    {
      "scenarios": [
        "features/checkout.feature:15",
        "features/checkout.feature:30"
      ]
    }
  ]
}
```

## Tag Examples

```yaml
# Single tag
cucumber_tags: '@smoke'

# Multiple tags (AND)
cucumber_tags: '@smoke and @login'

# Multiple tags (OR) 
cucumber_tags: '@smoke or @regression'

# Exclude tags
cucumber_tags: '@smoke and not @slow'
```

## Requirements

- Maven project with valid pom.xml
- Cucumber test framework configured
- jq installed (handled by test-setup action)
- Test directory must contain feature files with specified tags
