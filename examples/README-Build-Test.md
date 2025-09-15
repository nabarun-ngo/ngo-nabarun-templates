# Build and Test Workflow

A versatile reusable workflow for building and testing applications across different platforms (Node.js, Java) with comprehensive configuration options.

## Description

This workflow provides a unified interface for building and testing applications written in different languages/frameworks. It automatically detects the platform type and uses the appropriate composite action with optimized settings.

## Features

- 🚀 **Multi-Platform Support**: Node.js and Java/Maven projects
- ⚡ **Smart Caching**: Automatic dependency caching for faster builds
- 🧪 **Test Integration**: Built-in test execution and result collection
- 🔧 **Flexible Configuration**: Customizable build commands and options
- ⏱️ **Timeout Protection**: Prevents hanging builds with configurable timeouts

## Usage

### Basic Java Build and Test

```yaml
jobs:
  test:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'java'
      repo: 'my-org/my-java-app'
      branch: 'main'
      command: 'clean test'
      java_version: '17'
```

### Advanced Java Build with Custom Options

```yaml
jobs:
  build:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'java'
      repo: 'my-org/my-spring-app'
      branch: 'develop'
      command: 'clean package'
      java_version: '11'
      maven_options: '-Dspring.profiles.active=test -DskipITs=false'
      working_directory: './backend'
```

### Node.js Build and Test

```yaml
jobs:
  test-node:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'node'
      repo: 'my-org/my-react-app'
      branch: 'main'
      command: 'npm run test'
      node_version: '18'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `platform` | Platform type (`node`, `java`) | ✅ Yes | - |
| `repo` | Repository to clone | ❌ No | Current repository |
| `branch` | Branch to checkout | ❌ No | Current branch |
| `command` | Build command to run | ✅ Yes | - |
| `node_version` | Node.js version (for Node apps) | ❌ No | `20` |
| `java_version` | Java version (for Java apps) | ❌ No | `17` |
| `working_directory` | Directory where code resides | ❌ No | `.` |
| `maven_options` | Additional Maven options (for Java apps) | ❌ No | `-Dmaven.test.skip=false` |

## Platform-Specific Behavior

### Java Platform
When `platform: 'java'` is specified:

- **Composite Action Used**: `build-java@main`
- **Automatic Features**: 
  - Maven dependency caching with smart cache keys
  - Test result collection and artifact upload
  - Build timeout protection (20 minutes)
  - Comprehensive error handling and diagnostics
- **Command Format**: Maven commands without 'mvn' prefix
  - ✅ Good: `clean test`, `clean package`, `clean install`
  - ❌ Avoid: `mvn clean test` (mvn prefix is added automatically)

### Node.js Platform
When `platform: 'node'` is specified:

- **Composite Action Used**: `build-node@main`
- **Features**: Standard Node.js build and test execution
- **Command Format**: Full npm/yarn commands
  - ✅ Examples: `npm run test`, `yarn build`, `npm run lint`

## Example Scenarios

### CI/CD Pipeline Integration

```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  # Test stage
  test:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'java'
      command: 'clean test'
      java_version: '17'
      maven_options: '-Dmaven.test.failure.ignore=false'

  # Build stage (depends on test)
  build:
    needs: test
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'java'
      command: 'clean package'
      java_version: '17'
      maven_options: '-Dmaven.test.skip=true'
```

### Multi-Module Java Project

```yaml
jobs:
  test-modules:
    strategy:
      matrix:
        module: [core, api, web]
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'java'
      command: 'clean test'
      working_directory: './${{ matrix.module }}'
      java_version: '17'
```

### Cross-Platform Testing

```yaml
jobs:
  test-backend:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'java'
      command: 'clean test'
      working_directory: './backend'
      
  test-frontend:
    uses: nabarun-ngo/ngo-nabarun-templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'node'
      command: 'npm run test'
      working_directory: './frontend'
      node_version: '18'
```

## Changes from Previous Version

| Aspect | Before | After |
|--------|--------|--------|
| **Java Interface** | `command: 'mvn clean test'` | `maven_command: 'clean test'` |
| **Maven Options** | ❌ Not supported | ✅ `maven_options` input |
| **Test Results** | ❌ Manual setup | ✅ Automatic upload |
| **Caching** | ❌ No caching | ✅ Smart Maven caching |
| **Error Handling** | ⚠️ Basic | ✅ Comprehensive diagnostics |
| **Build Metrics** | ❌ None | ✅ Duration and status tracking |

## Migration Guide

### For Existing Java Workflows

**Before**:
```yaml
with:
  platform: 'java'
  command: 'mvn clean test'
```

**After**:
```yaml
with:
  platform: 'java'
  command: 'clean test'  # Remove 'mvn' prefix
  maven_options: '-Dmaven.test.skip=false'  # Optional: add Maven flags
```

### Benefits of Migration
- ⚡ **Faster Builds**: Intelligent caching reduces build times
- 🧪 **Better Testing**: Automatic test result collection
- 🛠️ **Enhanced Debugging**: Comprehensive error reporting
- 🔧 **More Flexibility**: Fine-grained Maven option control

## Troubleshooting

### Java Build Issues

**Command Format Error**:
```yaml
# ❌ Wrong
command: 'mvn clean test'

# ✅ Correct  
command: 'clean test'
```

**Missing Test Results**: Ensure your Maven project has proper test configuration in `pom.xml`.

**Build Timeout**: Increase timeout if needed by customizing the composite action call.

### Node.js Build Issues

**Version Compatibility**: Ensure `node_version` is compatible with your project's requirements.

## Related Documentation

- [build-java Composite Action](../actions/build-java/README.md)
- [build-node Composite Action](../actions/build-node/README.md)
- [Deploy-GCP-v2 Workflow](./Deploy-GCP-v2.yml)
