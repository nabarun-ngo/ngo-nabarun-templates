# ngo-nabarun-templates

This repository contains scripts and templates for automating workflows, testing, and environment management for Nabarun NGO projects. It includes Bash and Python scripts for CI/CD, test orchestration, Auth0 and Firebase sync, and more.

## Folder Structure

- `scripts/` - Main automation scripts
  - `auth0/` - Auth0 processing Python scripts
  - `common/` - Common utility scripts
  - Various Bash scripts for test and environment management
- `trash/` - Collection of workflow YAMLs and templates
  - `auth0/` - Auth0 workflow YAMLs
  - `firebase/` - Firebase workflow YAMLs
  - `templates/` - Build and other templates

## Key Scripts

### Bash Scripts
- `discover_scenarios.sh` - Discovers Cucumber scenarios by tag and prepares a matrix for GitHub Actions.
- `merge-cucumber-jsons.sh` - Merges multiple Cucumber JSON result files into a single file.
- `process-auth0.sh` - Replaces keywords in files based on Auth0 environment mappings.
- `run_cucumber_tests.sh` - Runs Cucumber tests for specified scenarios with rerun support.
- `run_cucumber_with_reruns.sh` - Runs Cucumber tests with multiple rerun attempts for failed scenarios.
- `wait-for-qmetry-report-import.sh` - Polls QMetry API for import status and reports success/failure.

### Python Scripts
- `auth0/process_auth0.py` - Replaces keywords in files using source and destination Auth0 JSON mappings.
- `auth0/process_auth0_v2.py` - Replaces values with keys in files using Auth0 JSON mappings, with dry-run and backup support.
- `common/set_env.py` - Sets environment variables for GitHub Actions workflows based on event payloads and inputs.

## Usage

Most scripts are designed to be run in CI/CD pipelines or locally for automation. See individual script documentation for usage details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with a clear description

## License

MIT License

---

For more details, see the documentation for each script in the `docs/` folder (to be created).
