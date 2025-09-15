# Test Environment Setup Action

A reusable composite action that sets up the complete test environment including Java, Maven caching, and repository checkouts.

## Description

This action handles the common setup steps required for test execution:
- Checks out template and test repositories
- Sets up Java with specified version
- Configures Maven dependency caching
- Installs system dependencies (jq)

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `java_version` | Java version to use | No | `22` |
| `templates_repository` | Templates repository | No | `nabarun-ngo/ngo-nabarun-templates` |
| `test_repository` | Test repository | Yes | - |
| `test_branch` | Test repository branch | No | `master` |
| `templates_path` | Path to checkout templates repository | No | `actions` |
| `test_path` | Path to checkout test repository | No | `test` |
| `enable_maven_cache` | Whether to enable Maven dependency caching | No | `true` |

## Outputs

| Output | Description |
|--------|-------------|
| `java_version` | Java version that was set up |
| `cache_hit` | Whether Maven cache was hit |

## Usage

```yaml
- name: Setup test environment
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-setup@main
  with:
    java_version: '17'
    test_repository: 'my-org/my-test-repo'
    test_branch: 'develop'
```

## Features

- ✅ Cross-platform Maven caching (Linux/Windows)
- ✅ Automatic system dependency installation
- ✅ Flexible repository checkout paths
- ✅ Configurable Java versions
- ✅ Optional Maven caching control

## Requirements

- Repositories must be accessible to the workflow
- Maven projects should have valid pom.xml files
- Java projects should use standard Maven directory structure
