# GCP Get Deployed Version

A GitHub composite action to retrieve the most recently deployed version of a Google App Engine service.

## Description

This action uses the Google Cloud CLI to query App Engine versions and retrieve information about deployed versions. It provides flexible filtering and sorting options to find specific versions based on your requirements.

## Features

- 🚀 **Simple Version Retrieval**: Get the most recent deployed version with minimal configuration
- 🔧 **Flexible Filtering**: Support for custom filters and sorting criteria
- 📊 **Detailed Information**: Returns both version ID and detailed version metadata
- 🛠️ **Debug Support**: Comprehensive error messages and debugging information
- ✅ **Validation**: Basic sanity checks on returned version data

## Prerequisites

- Google Cloud CLI (`gcloud`) must be installed and authenticated
- Proper IAM permissions to list App Engine versions in the specified project

## Usage

### Basic Usage

```yaml
- name: Get deployed version
  id: get_version
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-get-deployed-version@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    service_name: 'default'
```

### Advanced Usage

```yaml
- name: Get latest serving version
  id: get_version
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-get-deployed-version@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    service_name: 'api'
    limit: 3
    sort_by: '~version.createTime'
    additional_filters: '--filter="serving.status=SERVING"'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `project_id` | GCP Project ID where the service is deployed | ✅ Yes | - |
| `service_name` | Name of the App Engine service | ❌ No | `default` |
| `sort_by` | Field to sort versions by | ❌ No | `~version.createTime` |
| `limit` | Maximum number of versions to retrieve | ❌ No | `1` |
| `format` | Format for the gcloud output | ❌ No | `value(version.id)` |
| `additional_filters` | Additional filters for gcloud command | ❌ No | `''` |

### Input Details

- **`sort_by`**: Use `~` prefix for descending order (e.g., `~version.createTime` for newest first)
- **`additional_filters`**: Any valid gcloud filter expressions (e.g., `--filter="serving.status=SERVING"`)

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `version` | The ID of the deployed version | `20231215t120000` |
| `version_info` | Detailed version information in JSON format | `{"id": "...", "createTime": "..."}` |
| `created_time` | Creation time of the version | `2023-12-15T12:00:00Z` |

## Example Workflows

### Simple Version Check

```yaml
jobs:
  check-version:
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          
      - name: Get current version
        id: version
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-get-deployed-version@main
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          service_name: 'web'
          
      - name: Display version
        run: |
          echo "Current version: ${{ steps.version.outputs.version }}"
          echo "Created: ${{ steps.version.outputs.created_time }}"
```

### Version Comparison

```yaml
jobs:
  compare-versions:
    runs-on: ubuntu-latest
    steps:
      - uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT }}
          
      - name: Get latest version
        id: latest
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-get-deployed-version@main
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          service_name: 'api'
          
      - name: Get serving version
        id: serving
        uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/gcp-get-deployed-version@main
        with:
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          service_name: 'api'
          additional_filters: '--filter="serving.status=SERVING"'
          
      - name: Compare versions
        run: |
          if [[ "${{ steps.latest.outputs.version }}" != "${{ steps.serving.outputs.version }}" ]]; then
            echo "Latest version is not serving traffic"
            echo "Latest: ${{ steps.latest.outputs.version }}"
            echo "Serving: ${{ steps.serving.outputs.version }}"
          else
            echo "Latest version is actively serving traffic"
          fi
```

## Error Handling

The action provides comprehensive error handling:

- **Missing gcloud CLI**: Clear error message if gcloud is not available
- **No versions found**: Debugging information including available services and versions
- **Invalid project/service**: Helpful error messages with context
- **Permission issues**: Clear indication of authentication/authorization problems

## Common Issues

### Authentication Error
```
ERROR: (gcloud.app.versions.list) User [email] does not have permission to access app [project-id]
```
**Solution**: Ensure the service account has `App Engine Viewer` role or higher.

### Service Not Found
```
❌ Could not determine deployed version
📋 Available services: (empty)
```
**Solution**: Verify the App Engine service exists and the project ID is correct.

### Version Format Warning
```
⚠️ Warning: Version ID 'unusual-version-123!' has unusual format
```
**Note**: This is just a warning; the action will still work with non-standard version IDs.

## Development

To modify or extend this action:

1. Edit the `action.yml` file in this directory
2. Test changes using a workflow in a test repository
3. Update documentation and examples as needed

## Related Actions

- [gcp-promote-gae-traffic](../gcp-promote-gae-traffic/README.md) - Promote traffic to a specific version
- [gcp-clean-gae-versions](../gcp-clean-gae-versions/README.md) - Clean up old App Engine versions
- [gcp-health-check-deployment](../gcp-health-check-deployment/README.md) - Health check deployed services
