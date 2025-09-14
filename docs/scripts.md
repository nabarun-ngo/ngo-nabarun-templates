# Script Documentation

This folder contains detailed documentation for each major script in the repository.

---

## discover_scenarios.sh

**Purpose:**
Discovers Cucumber scenarios by tag and prepares a matrix for parallel test execution in CI/CD (GitHub Actions).

**Usage:**
```
./discover_scenarios.sh <tag> <max_per_job>
```
- `<tag>`: Cucumber tag to filter scenarios
- `<max_per_job>`: Maximum scenarios per job

**Details:**
- Runs Cucumber in dry-run mode to list scenarios
- Uses `jq` to extract scenario line numbers
- Outputs a matrix for GitHub Actions

---

## merge-cucumber-jsons.sh

**Purpose:**
Merges multiple Cucumber JSON result files into a single file for reporting.

**Usage:**
```
./merge-cucumber-jsons.sh [input_dir] [output_dir]
```
- `input_dir`: Directory containing `cucumber-*.json` files (default: `all-results`)
- `output_dir`: Directory for merged output (default: `merged`)

**Details:**
- Recursively finds all Cucumber JSON files
- Merges them into one JSON array

---

## process-auth0.sh

**Purpose:**
Replaces keywords in files based on Auth0 environment mappings.

**Usage:**
```
./process-auth0.sh <src_env.json> <dest_env.json> <target_file>
```
- `src_env.json`: Source environment JSON
- `dest_env.json`: Destination environment JSON
- `target_file`: File to process

**Details:**
- Uses `jq` to extract mappings
- Replaces values in the target file

---

## run_cucumber_tests.sh

**Purpose:**
Runs Cucumber tests for specified scenarios, supports reruns for failed tests.

**Usage:**
```
./run_cucumber_tests.sh "<scenario_string>" <job_index> <env> <doppler_project_name> <doppler_token> <max_reruns>
```

**Details:**
- Runs tests with Maven
- Sets environment variables for CI status

---

## run_cucumber_with_reruns.sh

**Purpose:**
Runs Cucumber tests with multiple rerun attempts for failed scenarios.

**Usage:**
```
./run_cucumber_with_reruns.sh "<scenario_string>" <job_index> <env> <doppler_project_name> <doppler_token> <max_reruns>
```

**Details:**
- Initial run and reruns for failed scenarios
- Breaks early if no failed scenarios

---

## wait-for-qmetry-report-import.sh

**Purpose:**
Polls QMetry API for import status and reports success/failure.

**Usage:**
```
./wait-for-qmetry-report-import.sh <trackingId> <apiKey>
```

**Details:**
- Polls QMetry API every 5 seconds for up to 5 minutes
- Reports success or failure

---

See Python script documentation in `docs/python_scripts.md`.
