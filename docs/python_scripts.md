# Python Script Documentation

This document describes the main Python scripts in the repository.

---

## auth0/process_auth0.py

**Purpose:**
Replaces keywords in files using source and destination Auth0 JSON mappings.

**Usage:**
```
python process_auth0.py <source_json> <dest_json> <file>
```
- `<source_json>`: Source environment JSON file
- `<dest_json>`: Destination environment JSON file
- `<file>`: Target file to process

**Details:**
- Loads mappings from both JSON files
- Replaces values in the target file according to mappings
- Prints progress and errors

---

## auth0/process_auth0_v2.py

**Purpose:**
Replaces values with keys in files using Auth0 JSON mappings, with dry-run and backup support.

**Usage:**
```
python process_auth0_v2.py <env_json> <file> [--dry-run]
```
- `<env_json>`: Environment JSON file
- `<file>`: Target file to process
- `--dry-run`: Optional, shows changes without saving

**Details:**
- Backs up the file before modifying
- Replaces values with keys in the format `##KEY##`
- Supports dry-run mode

---

## common/set_env.py

**Purpose:**
Sets environment variables for GitHub Actions workflows based on event payloads and inputs.

**Usage:**
Used in GitHub Actions workflows. No direct CLI usage.

**Details:**
- Loads event data and workflow inputs
- Writes variables to GitHub Outputs
- Prints final variables for debugging

---

For more details, see comments in each script.
