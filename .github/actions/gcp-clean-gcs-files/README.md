# GCP Clean GCS Files

A GitHub composite action to clean old files from Google Cloud Storage buckets based on age criteria with comprehensive configuration options and safety features.

## Description

This action provides automated cleanup of old files in Google Cloud Storage buckets. It's designed to help manage storage costs by removing files that are older than a specified retention period, with support for custom bucket patterns, dry-run mode, and detailed reporting.

## Features

- 🧹 **Automated Cleanup**: Remove files older than specified days
- 🎯 **Flexible Targeting**: Support for multiple bucket patterns and custom bucket lists
- 🔍 **Dry Run Mode**: Preview what would be deleted without actually deleting files
- 📊 **Detailed Reporting**: Comprehensive cleanup summaries and statistics
- 🛡️ **Safety Features**: Input validation, error handling, and continue-on-error support
- 📁 **Pattern Matching**: Support for file patterns and subdirectory inclusion
- ⏱️ **Timeout Control**: Configurable operation timeouts
- 🚀 **GAE Integration**: Built-in patterns for Google App Engine projects

## Prerequisites

- Google Cloud CLI (`gcloud`) must be installed and authenticated
- Proper IAM permissions to list and delete objects in the specified buckets
- Required permissions: `Storage Object Viewer`, `Storage Object Admin`

## Usage

### Basic Usage (GAE Projects)

```yaml
- name: Clean old GCS files
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    keep_days: '7'
```

### Advanced Usage with Custom Configuration

```yaml
- name: Clean old GCS files
  id: cleanup
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    keep_days: '30'
    bucket_patterns: 'my-project-logs,my-project-temp,my-project-cache'
    file_pattern: '*.log'
    dry_run: 'false'
    timeout_minutes: '15'
    include_subdirectories: 'true'

- name: Display cleanup results
  run: |
    echo "Files deleted: ${{ steps.cleanup.outputs.files_deleted }}"
    echo "Buckets processed: ${{ steps.cleanup.outputs.buckets_processed }}"
    echo "Errors: ${{ steps.cleanup.outputs.errors_encountered }}"
```

### Dry Run Mode

```yaml
- name: Preview GCS cleanup
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    keep_days: '7'
    dry_run: 'true'  # Preview only, no actual deletions
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `project_id` | GCP Project ID where buckets are located | ✅ Yes | - |
| `keep_days` | Number of days to keep files (delete older files) | ❌ No | `5` |
| `bucket_patterns` | Comma-separated bucket patterns to clean | ❌ No | `auto` |
| `dry_run` | Run in dry-run mode (preview only) | ❌ No | `false` |
| `timeout_minutes` | Timeout for cleanup operation in minutes | ❌ No | `10` |
| `include_subdirectories` | Include files in subdirectories (recursive) | ❌ No | `true` |
| `custom_bucket_names` | Specific bucket names (overrides patterns) | ❌ No | `''` |
| `file_pattern` | File pattern to match | ❌ No | `**` |

### Input Details

- **`bucket_patterns`**: When set to `auto`, uses GAE-specific patterns. Otherwise, provide comma-separated patterns.
- **`custom_bucket_names`**: Takes precedence over `bucket_patterns` when specified.
- **`file_pattern`**: Supports glob patterns like `*.log`, `temp/*`, `**` (all files).
- **`dry_run`**: When `true`, shows what would be deleted without performing deletions.

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `files_deleted` | Total number of files deleted | `42` |
| `buckets_processed` | Number of buckets processed | `3` |
| `cleanup_summary` | Detailed summary of cleanup operation | Multiline summary |
| `errors_encountered` | Number of errors during cleanup | `0` |

## Automatic Bucket Patterns

When `bucket_patterns: 'auto'` is used, the action automatically targets common GAE-related buckets:

```
staging.{PROJECT_ID}.appspot.com
{PROJECT_ID}.appspot.com
artifacts.{PROJECT_ID}.appspot.com
{PROJECT_ID}-staging
{PROJECT_ID}-artifacts
{PROJECT_ID}-gcf-artifacts
{PROJECT_ID}-gcf-staging
{PROJECT_ID}-build-cache
```

## Example Workflows

### Scheduled Cleanup

```yaml
name: Weekly GCS Cleanup
on:
  schedule:
    - cron: '0 2 * * SUN'  # Every Sunday at 2 AM

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          
      - name: Clean old GCS files
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          keep_days: '30'
```

### Post-Deployment Cleanup

```yaml
jobs:
  deploy:
    # ... deployment steps ...
    
  cleanup:
    needs: deploy
    if: success()
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          
      - name: Clean old build artifacts
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
        continue-on-error: true
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          keep_days: '7'
          custom_bucket_names: '${{ secrets.GCP_PROJECT_ID }}-build-artifacts'
          file_pattern: 'builds/*'
```

### Multi-Environment Cleanup

```yaml
jobs:
  cleanup:
    strategy:
      matrix:
        environment: [staging, production]
        include:
          - environment: staging
            keep_days: '7'
          - environment: production
            keep_days: '30'
    
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          
      - name: Clean ${{ matrix.environment }} files
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          keep_days: ${{ matrix.keep_days }}
          custom_bucket_names: 'my-project-${{ matrix.environment }}'
```

### Conditional Cleanup with Dry Run

```yaml
jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT }}
      
      # First, preview what would be deleted
      - name: Preview cleanup
        id: preview
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          keep_days: '7'
          dry_run: 'true'
      
      # Only proceed if files would be deleted
      - name: Actual cleanup
        if: steps.preview.outputs.files_deleted > 0
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          keep_days: '7'
          dry_run: 'false'
```

## Error Handling

The action provides comprehensive error handling:

### Authentication Errors
```
❌ gcloud CLI not found. Please ensure Google Cloud CLI is installed and authenticated.
```
**Solution**: Ensure `google-github-actions/auth@v2` is run before this action.

### Permission Errors
```
ERROR: (gcloud.storage.buckets.describe) User does not have permission to access bucket
```
**Solution**: Ensure the service account has `Storage Object Viewer` and `Storage Object Admin` roles.

### Invalid Input Errors
```
❌ Invalid keep_days value: -1. Must be a positive integer.
```
**Solution**: Ensure `keep_days` is a positive integer.

## Safety Features

1. **Input Validation**: Validates all inputs before processing
2. **Bucket Verification**: Checks bucket existence before attempting operations
3. **Dry Run Mode**: Preview deletions without actually deleting files
4. **Continue on Error**: Designed to work with `continue-on-error: true`
5. **Detailed Logging**: Comprehensive logging for troubleshooting
6. **Timeout Protection**: Configurable timeouts prevent hanging operations

## Performance Considerations

- **Large Buckets**: Use `file_pattern` to target specific files in large buckets
- **Timeout Settings**: Increase `timeout_minutes` for buckets with many files
- **Parallel Processing**: The action processes buckets sequentially, but files within buckets in parallel streams
- **Network Efficiency**: Uses `gcloud storage ls -l` for efficient file listing

## Comparison with Previous Implementation

| Feature | Before (Inline Script) | After (Composite Action) |
|---------|----------------------|--------------------------|
| **Lines of Code** | ~75+ lines inline | ~8 lines to call action |
| **Error Handling** | Basic | Comprehensive with validation |
| **Bucket Patterns** | Fixed 5 patterns | 8+ patterns + custom support |
| **Dry Run Mode** | ❌ Not supported | ✅ Full dry-run capability |
| **File Patterns** | All files only | ✅ Custom patterns supported |
| **Reporting** | Basic counts | ✅ Detailed summaries and metrics |
| **Reusability** | None | ✅ Across all workflows |
| **Safety Features** | Limited | ✅ Input validation, timeout control |

## Migration from Deploy-GCP-v2.yml

**Before**:
```yaml
- name: Clean old GCS files
  shell: bash
  run: |
    # 75+ lines of bash script...
```

**After**:
```yaml
- name: Clean old GCS files
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-clean-gcs-files@main
  with:
    project_id: ${{ secrets.gcp_project_id }}
    keep_days: ${{ inputs.gcs_keep_days }}
```

## Troubleshooting

### No Files Deleted
Check if:
- Files exist and are older than `keep_days`
- Bucket permissions are correct
- File patterns match your files

### Timeout Issues
- Increase `timeout_minutes`
- Use more specific `file_pattern` to reduce scope
- Process buckets separately in different steps

### Permission Issues
Ensure service account has these roles:
- `Storage Object Viewer` (to list files)
- `Storage Object Admin` (to delete files)

## Development

To modify or extend this action:

1. Edit the `action.yml` file in this directory
2. Test changes using the dry-run mode first
3. Update documentation and examples as needed

## Related Actions

- [gcp-clean-gae-versions](../gcp-clean-gae-versions/README.md) - Clean up old App Engine versions
- [gcp-clean-artifact-registry](../gcp-clean-artifact-registry/README.md) - Clean up Artifact Registry repositories
- [gcp-get-deployed-version](../gcp-get-deployed-version/README.md) - Get deployed application versions
