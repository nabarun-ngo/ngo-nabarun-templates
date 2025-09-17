# GCP Download Logs Action

A composite action to download logs from Google Cloud Logging with textPayload filter and multiple output format support.

## Overview

This action provides a robust way to download logs from Google Cloud Logging with various filtering options and output formats. It follows the GCP composite action standards used throughout the ngo-nabarun-templates repository.

## Features

- ✅ **Multiple Output Formats**: TXT, CSV, HTML, JSON
- 🔍 **Flexible Filtering**: Support for complex log queries
- ⏰ **Time Range Support**: Filter logs by timestamp
- 📊 **Metadata Options**: Include/exclude log metadata
- 🎨 **Rich HTML Output**: Beautiful, styled HTML reports
- 🔧 **Comprehensive Validation**: Input validation and error handling
- 📁 **Custom Naming**: Support for custom output filenames

## Usage

### Basic Usage

```yaml
- name: Download logs
  uses: ./.github/actions/gcp-download-logs
  with:
    project_id: 'my-gcp-project'
    filter: 'textPayload:"error-uuid-12345"'
```

### Advanced Usage

```yaml
- name: Download logs with full configuration
  uses: ./.github/actions/gcp-download-logs
  with:
    project_id: 'my-gcp-project'
    filter: 'textPayload:"error-uuid-12345" AND severity>=ERROR'
    output_format: 'html'
    output_filename: 'error-logs-investigation'
    time_range: 'timestamp>="2024-01-01T00:00:00Z" AND timestamp<="2024-01-02T00:00:00Z"'
    order_by: 'timestamp desc'
    limit: '500'
    include_metadata: 'true'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `project_id` | GCP Project ID to query logs from | ✅ Yes | - |
| `filter` | Log filter query (e.g., textPayload:"uuid-value") | ✅ Yes | - |
| `output_format` | Output format (txt, csv, html, json) | ❌ No | `txt` |
| `output_filename` | Custom filename for output (without extension) | ❌ No | Auto-generated |
| `time_range` | Time range for log query | ❌ No | - |
| `order_by` | Field to order results by | ❌ No | `timestamp desc` |
| `limit` | Maximum number of log entries to retrieve | ❌ No | `1000` |
| `include_metadata` | Include log metadata in output | ❌ No | `true` |

## Outputs

| Output | Description |
|--------|-------------|
| `output_path` | Path to the generated log file |
| `log_count` | Number of log entries retrieved |
| `query_summary` | Summary of the executed query |
| `execution_time` | Time taken to execute the query |

## Output Formats

### TXT Format
Plain text format with optional metadata:
```
2024-01-15T10:30:00Z [ERROR] Application error: Database connection failed
2024-01-15T10:29:45Z [INFO] Starting application initialization
```

### CSV Format
Comma-separated values with headers:
```csv
Timestamp,Severity,Message,Resource,Labels
2024-01-15T10:30:00Z,ERROR,"Application error: Database connection failed",gce_instance,"{\"env\":\"prod\"}"
```

### HTML Format
Rich, styled HTML report with:
- Professional styling and layout
- Color-coded severity levels
- Searchable content
- Statistics summary
- Responsive design

### JSON Format
Structured JSON output with full or filtered metadata:
```json
[
  {
    "timestamp": "2024-01-15T10:30:00Z",
    "severity": "ERROR",
    "textPayload": "Application error: Database connection failed",
    "resource": {"type": "gce_instance"},
    "labels": {"env": "prod"}
  }
]
```

## Filter Examples

### Basic Text Search
```yaml
filter: 'textPayload:"error"'
```

### UUID-based Search
```yaml
filter: 'textPayload:"550e8400-e29b-41d4-a716-446655440000"'
```

### Severity Filtering
```yaml
filter: 'severity>=ERROR'
```

### Combined Filters
```yaml
filter: 'textPayload:"database" AND severity>=WARNING AND resource.type="gce_instance"'
```

### Resource-based Filtering
```yaml
filter: 'resource.type="k8s_container" AND textPayload:"my-service"'
```

## Time Range Examples

### Specific Date Range
```yaml
time_range: 'timestamp>="2024-01-15T00:00:00Z" AND timestamp<="2024-01-15T23:59:59Z"'
```

### Last 24 Hours
```yaml
time_range: 'timestamp>="2024-01-14T10:00:00Z"'
```

### Specific Time Window
```yaml
time_range: 'timestamp>="2024-01-15T10:00:00Z" AND timestamp<="2024-01-15T12:00:00Z"'
```

## Prerequisites

- Google Cloud CLI (`gcloud`) must be installed and configured
- `jq` must be available for JSON processing
- Proper GCP authentication (service account or user credentials)
- Required GCP permissions:
  - `logging.logEntries.list`
  - `logging.logs.list`

## Error Handling

The action includes comprehensive error handling for:
- Missing dependencies (gcloud, jq)
- Invalid input formats
- GCP authentication issues
- Query syntax errors
- File creation failures

## Integration with Workflows

This action is designed to work seamlessly with the GCP-Ops workflow:

```yaml
jobs:
  download-logs:
    name: 'Download Application Logs'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Authenticate with GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - name: Setup gcloud
        uses: google-github-actions/setup-gcloud@v2
      
      - name: Download logs
        id: download
        uses: ./.github/actions/gcp-download-logs
        with:
          project_id: ${{ vars.GCP_PROJECT_ID }}
          filter: 'textPayload:"${{ inputs.search_term }}"'
          output_format: 'html'
      
      - name: Upload logs as artifact
        uses: actions/upload-artifact@v4
        with:
          name: application-logs
          path: ${{ steps.download.outputs.output_path }}
```

## Best Practices

1. **Use Specific Filters**: Avoid overly broad filters that return too many results
2. **Set Appropriate Limits**: Use the `limit` parameter to control output size
3. **Include Time Ranges**: Always specify time ranges for better performance
4. **Choose Right Format**: Use HTML for manual review, JSON for programmatic processing
5. **Monitor Costs**: Be aware that log queries consume GCP resources
6. **Use Metadata Wisely**: Disable metadata for large datasets to reduce file size

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure GCP service account has proper permissions
   - Verify the service account key is correctly configured

2. **No Logs Found**
   - Check filter syntax using GCP Console
   - Verify time ranges are correct
   - Ensure logs exist in the specified project

3. **Query Timeout**
   - Reduce the time range
   - Make filters more specific
   - Decrease the limit parameter

4. **File Size Issues**
   - Set `include_metadata: 'false'` for large datasets
   - Use smaller time ranges
   - Consider pagination for very large results

### Debug Mode

Enable verbose logging by checking the action's step outputs and GitHub Actions logs for detailed execution information.

## Contributing

When contributing to this action:
1. Follow the existing code style and patterns
2. Update tests for new features
3. Maintain backward compatibility
4. Update documentation for any changes
5. Test with different GCP projects and log types

## Related Actions

- `gcp-get-deployed-version` - Get GAE version information
- `gcp-health-check-deployment` - Health check deployments
- `gcp-promote-gae-traffic` - Traffic management
- `gcp-clean-gae-versions` - Version cleanup
