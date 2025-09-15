# Java Build and Test

A comprehensive GitHub composite action for building and testing Java Maven projects with advanced caching, error handling, and flexible configuration options.

## Description

This action provides a complete solution for building Java Maven projects in GitHub Actions workflows. It handles Java setup, Maven dependency caching, build execution, and test result collection with robust error handling and detailed logging.

## Features

- ☕ **Java Setup**: Automatic Java environment setup with configurable versions
- 🔧 **Smart Caching**: Intelligent Maven dependency caching with customizable keys
- 🚀 **Flexible Commands**: Support for any Maven command (package, test, install, etc.)
- ⏱️ **Timeout Control**: Configurable build timeouts to prevent hanging builds
- 📊 **Test Results**: Optional upload of test results as artifacts
- 🛠️ **Error Handling**: Comprehensive error reporting and debugging information
- 📈 **Build Metrics**: Build duration tracking and status reporting
- 🔍 **Validation**: Automatic project validation and environment checks

## Prerequisites

- Maven project with `pom.xml` file
- Compatible with Ubuntu, macOS, and Windows runners
- Requires `actions/setup-java@v4` compatibility

## Usage

### Basic Usage

```yaml
- name: Build Java project
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-java@main
  with:
    java_version: '17'
```

### Advanced Usage

```yaml
- name: Build and test Java project
  id: java_build
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-java@main
  with:
    java_version: '11'
    maven_command: 'clean test package'
    maven_options: '-Dspring.profiles.active=test -DskipITs=false'
    build_timeout_minutes: '20'
    upload_test_results: 'true'
    test_results_artifact_name: 'junit-results'
    enable_cache: 'true'
    cache_key_prefix: 'maven-cache'
```

### Deploy-GCP-v2.yml Integration

```yaml
- name: Build with Maven
  id: maven_build
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-java@main
  with:
    java_version: ${{ inputs.java_version }}
    maven_command: 'clean package'
    maven_options: ${{ inputs.maven_options }}
    build_timeout_minutes: '15'
    upload_test_results: 'false'
    enable_cache: 'true'
    cache_key_prefix: 'maven'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `java_version` | Java version to use (e.g., 17, 11, 8) | ❌ No | `17` |
| `working_directory` | Directory where the Maven project resides | ❌ No | `.` |
| `maven_command` | Maven command to run | ❌ No | `clean package` |
| `maven_options` | Additional Maven options/flags | ❌ No | `-Dmaven.test.skip=true -Dmaven.javadoc.skip=true` |
| `build_timeout_minutes` | Timeout for the build step in minutes | ❌ No | `15` |
| `upload_test_results` | Whether to upload test results as artifacts | ❌ No | `true` |
| `test_results_artifact_name` | Name for the test results artifact | ❌ No | `java-test-results` |
| `enable_cache` | Whether to enable Maven dependency caching | ❌ No | `true` |
| `cache_key_prefix` | Prefix for Maven cache key | ❌ No | `maven` |

### Input Details

- **`maven_command`**: Any valid Maven command (e.g., `clean test`, `clean package`, `clean install`)
- **`maven_options`**: Maven flags and properties (e.g., `-DskipTests`, `-Dmaven.compiler.source=11`)
- **`build_timeout_minutes`**: Prevents builds from hanging indefinitely
- **`cache_key_prefix`**: Useful for distinguishing different cache contexts

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `build_status` | Status of the build (success/failure) | `success` |
| `build_time` | Build duration in seconds | `45` |
| `maven_version` | Maven version used for the build | `3.9.4` |

## Example Workflows

### Simple Package Build

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build JAR
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-java@main
        with:
          maven_command: 'clean package'
          upload_test_results: 'false'
```

### Full Test Suite with Results

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run tests
        id: test
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-java@main
        with:
          maven_command: 'clean test'
          maven_options: '-Dtest.profile=ci'
          upload_test_results: 'true'
          test_results_artifact_name: 'test-results-${{ github.run_number }}'
      
      - name: Check build status
        run: |
          echo "Build took: ${{ steps.test.outputs.build_time }} seconds"
          echo "Maven version: ${{ steps.test.outputs.maven_version }}"
```

### Multi-Module Project

```yaml
jobs:
  build-modules:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        module: [core, api, web]
    steps:
      - uses: actions/checkout@v4
      
      - name: Build ${{ matrix.module }}
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-java@main
        with:
          working_directory: './${{ matrix.module }}'
          maven_command: 'clean package'
          cache_key_prefix: 'maven-${{ matrix.module }}'
```

### Custom Java Version and Options

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build with Java 21
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/build-java@main
        with:
          java_version: '21'
          maven_command: 'clean compile test-compile package'
          maven_options: '-Dmaven.compiler.release=21 -Dproject.build.sourceEncoding=UTF-8'
          build_timeout_minutes: '25'
```

## Error Handling

The action provides comprehensive error handling and debugging:

### Build Failures
- Detailed error messages with context
- Maven version and Java version information
- Working directory and command details
- Target directory contents (if available)
- Maven log excerpts (when available)

### Environment Issues
- Maven installation verification and auto-installation on Linux
- Java version compatibility checks
- Project structure validation (pom.xml presence)
- Working directory validation

### Timeout Handling
- Configurable timeouts prevent infinite builds
- Clear timeout messages with duration information

## Caching Strategy

The action implements intelligent caching:

```yaml
# Cache structure
~/.m2/repository/
# Key format: {prefix}-{OS}-java{version}-{pom-hash}
# Example: maven-Linux-java17-a1b2c3d4e5f6
```

### Cache Benefits
- **Faster Builds**: Dependencies downloaded only when changed
- **Bandwidth Savings**: Reduces network usage in CI/CD
- **Reliability**: Less dependency on external repositories

### Cache Configuration
- **Enable/Disable**: Use `enable_cache: 'false'` to disable caching
- **Custom Keys**: Use `cache_key_prefix` for different contexts
- **Automatic Invalidation**: Cache updates when `pom.xml` changes

## Performance Tips

1. **Use Specific Maven Commands**: Instead of `clean install`, use `clean package` if you don't need local installation
2. **Enable Parallel Builds**: Add `-T 1C` to `maven_options` for parallel compilation
3. **Skip Unnecessary Steps**: Use `-DskipTests` for build-only scenarios
4. **Optimize Test Execution**: Use `-Dmaven.test.failure.ignore=true` to continue on test failures

## Common Issues

### Build Timeout
```
Error: The operation was canceled.
```
**Solution**: Increase `build_timeout_minutes` or optimize build performance.

### Maven Not Found
```
❌ Maven installation not supported for Windows
```
**Solution**: Use `ubuntu-latest` runner or pre-install Maven in your workflow.

### Cache Issues
```
Warning: Failed to restore cache
```
**Solution**: This is usually harmless. The build will continue without cache acceleration.

### Java Version Mismatch
```
[ERROR] Failed to execute goal ... requires Java version
```
**Solution**: Ensure `java_version` matches your project's requirements.

## Comparison with Previous Implementation

| Feature | Before (Inline) | After (Composite Action) |
|---------|----------------|-------------------------|
| **Lines of Code** | ~30 lines inline | ~6 lines to call action |
| **Error Handling** | Basic | Comprehensive with debugging |
| **Caching** | Manual setup | Automatic with smart keys |
| **Reusability** | None | Across all workflows |
| **Customization** | Limited | 9 configurable inputs |
| **Maintainability** | Workflow-specific | Centralized |
| **Build Metrics** | None | Duration and status tracking |

## Development

To modify or extend this action:

1. Edit the `action.yml` file in this directory
2. Test changes using a test workflow
3. Update documentation and examples
4. Consider backward compatibility for existing users

## Related Actions

- [validate-and-find-file](../validate-and-find-file/README.md) - Find and validate built JAR files
- [gcp-get-deployed-version](../gcp-get-deployed-version/README.md) - Get deployed application versions
- [build-node](../build-node/README.md) - Build Node.js projects
