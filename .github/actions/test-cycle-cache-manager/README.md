# Test Cycle Cache Manager Action

A composite action that manages test cycle caching and state restoration for workflow re-runs, enabling automatic test cycle reuse.

## Description

This action handles test cycle state management by:
- Restoring cached test cycle information from previous runs
- Loading environment variables for test cycle reuse
- Generating test cycle summaries for QMetry
- Determining whether this is a first run or re-run

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `workflow_name` | Name of the current workflow | Yes | - |
| `run_id` | GitHub workflow run ID | Yes | - |
| `run_attempt` | GitHub workflow run attempt number | Yes | - |
| `test_type` | Type of test being executed | Yes | - |
| `cache_file_path` | Path to cache file | No | `variables.env` |

## Outputs

| Output | Description |
|--------|-------------|
| `test_cycle_summary` | Generated test cycle summary |
| `is_rerun` | Whether this is a re-run (true/false) |
| `cached_test_cycle` | Test cycle ID from cache (if available) |
| `cache_status` | Status of cache operation |
| `cache_key` | Cache key used for this run |

## Usage

```yaml
- name: Manage Test Cycle Cache
  id: cache_manager
  uses: nabarun-ngo/ngo-nabarun-templates/.github/actions/test-cycle-cache-manager@main
  with:
    workflow_name: ${{ github.workflow }}
    run_id: ${{ github.run_id }}
    run_attempt: ${{ github.run_attempt }}
    test_type: 'smoke_tests'

- name: Use cache information
  run: |
    echo "Is rerun: ${{ steps.cache_manager.outputs.is_rerun }}"
    echo "Test cycle: ${{ steps.cache_manager.outputs.cached_test_cycle }}"
```

## Features

- ✅ **Automatic Re-run Detection**: Identifies first runs vs re-runs
- ✅ **State Persistence**: Maintains test cycle information across attempts
- ✅ **Environment Loading**: Loads cached variables into workflow environment
- ✅ **Detailed Logging**: Comprehensive logging for debugging
- ✅ **Cache Validation**: Validates cached data before loading

## Cache File Format

The cache file (`variables.env`) contains:
```
execution_id=12345
test_cycle=TCY-789
run_id=123456
created_at=2025-01-15T16:43:14Z
workflow=Run-Parallel-Tests
jira_url=https://example.atlassian.net
```

## Use Cases

### First Run
- No cache found
- Creates new test cycle summary
- Prepares for new QMetry test cycle creation

### Re-run (Same Run ID)
- Cache found from previous attempt
- Loads existing test cycle information
- Enables reuse of same QMetry test cycle

## Requirements

- GitHub Actions environment with caching enabled
- Proper workflow permissions for cache operations
