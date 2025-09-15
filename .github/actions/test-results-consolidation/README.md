# Test Results Consolidation Action

A composite action that downloads parallel test artifacts, merges Cucumber JSON results, and prepares a consolidated report for QMetry upload.

## Description

This action handles the first phase of test result processing by:
- Downloading all artifacts from parallel test jobs
- Merging individual Cucumber JSON files into a single consolidated report
- Validating merged results and providing detailed logging
- Uploading the consolidated report as an artifact

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `templates_repository` | Templates repository containing merge scripts | No | `nabarun-ngo/ngo-nabarun-templates` |
| `artifact_download_path` | Path to download all artifacts | No | `all-results` |
| `merged_output_path` | Path for merged output files | No | `merged` |
| `merged_artifact_name` | Name for merged artifact upload | No | `merged-cucumber-json` |

## Outputs

| Output | Description |
|--------|-------------|
| `merged_file_path` | Path to the merged cucumber.json file |
| `artifact_count` | Number of artifacts processed |
| `total_scenarios` | Total number of scenarios in merged results |
| `consolidation_status` | Status of consolidation process |

## Usage

```yaml
- name: Consolidate Test Results
  id: consolidate
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-results-consolidation@main
  
- name: Use consolidated results
  run: |
    echo "Merged file: ${{ steps.consolidate.outputs.merged_file_path }}"
    echo "Total artifacts: ${{ steps.consolidate.outputs.artifact_count }}"
    echo "Total scenarios: ${{ steps.consolidate.outputs.total_scenarios }}"
```

## Features

- ✅ **Comprehensive Logging**: Detailed logs for debugging and monitoring
- ✅ **Input Validation**: Validates all prerequisites before processing
- ✅ **JSON Validation**: Ensures merged file contains valid JSON
- ✅ **Error Handling**: Graceful handling of missing files or failed merges
- ✅ **Artifact Analysis**: Provides detailed information about processed artifacts
- ✅ **Scenario Counting**: Counts total scenarios using jq when available

## Example Output Logs

```
🚀 Starting test results consolidation process...
📊 Configuration:
  Templates Repository: nabarun-ngo/ngo-nabarun-templates
  Download Path: all-results
  Output Path: merged
  
📥 Analyzing downloaded artifacts...
📊 Total JSON artifacts found: 5
📄 Found: all-results/cucumber-json-0/cucumber-0.json (1234 bytes)

🔄 Starting test results consolidation...
✅ Merge script found: templates/scripts/merge-cucumber-jsons.sh
📁 Created output directory: merged

📊 Merged file created successfully:
  📄 File: merged/cucumber.json
  📏 Size: 5678 bytes
  🎯 Total scenarios: 25

✅ Consolidation completed successfully!
```

## Error Handling

The action includes comprehensive error handling for:
- Missing download directory
- Missing merge script
- Failed merge operations
- Invalid JSON output
- Empty or corrupt result files

## Requirements

- Templates repository must contain `scripts/merge-cucumber-jsons.sh`
- Input artifacts must be in JSON format
- `jq` tool for JSON validation (optional but recommended)
