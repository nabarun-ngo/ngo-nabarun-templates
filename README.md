# CI/CD Templates Repository

[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-blue?logo=github-actions)](https://github.com/features/actions)
[![Bash](https://img.shields.io/badge/Scripting-Bash-4EAA25?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A centralized repository of **reusable GitHub Actions workflows, composite actions, and scripts** for CI/CD, testing, deployment, and environment management. Any project can use these templates by forking or referencing them directly.

---

## Table of Contents

1. [Repository Structure](#1-repository-structure)
2. [First-time Setup (Forking)](#2-first-time-setup-forking)
3. [Reusable Workflows](#3-reusable-workflows)
   - [Setup-Env](#31-setup-env)
   - [Build-Test](#32-build-test)
   - [Run-Tests](#33-run-tests-sequential)
   - [Run-Parallel-Tests](#34-run-parallel-tests)
   - [Deploy-GCP-v2](#35-deploy-gcp-app-engine)
   - [Deploy-GCP-CloudRun](#36-deploy-gcp-cloud-run)
   - [Deploy-Firebase](#37-deploy-firebase)
   - [Create-Tag-Release](#38-create-tag--release)
   - [Sync-Data](#39-sync-data)
   - [Run-MongoDB-Migration](#310-run-mongodb-migration)
   - [Run-Parallel-Tests-Allure](#311-run-parallel-tests-allure)
   - [GCP-Ops](#312-gcp-ops)
   - [JMeter-Load-Test](#313-jmeter-load-test)
   - [mongo-cloud (MongoDB → PostgreSQL)](#314-mongo-cloud-mongodb--postgresql)
   - [Publish-Package](#315-publish-package)
   - [Redis-Ops](#316-redis-ops)
   - [Trigger-Workflow](#317-trigger-workflow)
4. [Composite Actions](#4-composite-actions)
   - [Build Actions](#41-build-actions)
   - [Testing Actions](#42-testing-actions)
   - [QMetry Integration](#43-qmetry-integration-actions)
   - [GCP Operations](#44-gcp-operations-actions)
   - [Utility Actions](#45-utility-actions)
   - [Allure Reporting](#46-allure-reporting-actions)
5. [Scripts Reference](#5-scripts-reference)
6. [Configuration System](#6-configuration-system)
7. [Full Examples](#7-full-examples)
8. [Caller Migration Guide](#8-caller-migration-guide)
9. [Best Practices](#9-best-practices)

---

## 1. Repository Structure

```
templates/
├── .github/
│   ├── workflows/               # Reusable workflows (workflow_call)
│   │   ├── Setup-Env.yml
│   │   ├── Build-Test.yml
│   │   ├── Run-Tests.yml
│   │   ├── Run-Parallel-Tests.yml
│   │   ├── Run-Parallel-Tests-Allure.yml
│   │   ├── Deploy-GCP-v2.yml
│   │   ├── Deploy-GCP-CloudRun.yml
│   │   ├── Deploy-Firebase.yml
│   │   ├── Create-Tag-Release.yml
│   │   ├── Sync-Data.yml
│   │   ├── Run-MongoDB-Migration.yml
│   │   ├── GCP-Ops.yml
│   │   ├── jmeter-load-test.yml
│   │   ├── mongo-cloud.yml
│   │   ├── Publish-Package.yml
│   │   ├── Redis-Ops.yml
│   │   └── Trigger-Workflow.yml
│   └── actions/                 # Composite actions
│       ├── build-java/
│       ├── build-node/
│       ├── prepare-node-artifact/
│       ├── cucumber-discover-scenarios/
│       ├── cucumber-run-tests/
│       ├── test-setup/
│       ├── test-results-consolidation/
│       ├── test-cycle-cache-manager/
│       ├── allure-publish/
│       ├── qmetry-upload-manager/
│       ├── qmetry-result-linker/
│       ├── resolve-deploy-tag/
│       ├── resolve-inputs/
│       ├── notify-system/
│       ├── update-pr-description/
│       ├── update-json-from-env/
│       ├── validate-and-find-file/
│       ├── determine-schedule-config/
│       └── gcp-*/               # GCP operation actions
├── scripts/                     # Bash and Python utility scripts
├── examples/                    # Example caller workflows and configs
└── README.md                    # This file
```

---

## 2. First-time Setup (Forking)

If you are **forking** this repository for your own organization, run the setup script once after forking to replace all internal `org/repo` references with your own:

```bash
bash scripts/setup-for-org.sh YOUR_ORG/YOUR_REPO main
```

This rewrites every `uses:` and script reference across all `.yml` and `.sh` files so they point to your fork. You only need to do this once.

If you are **referencing the repo directly** (not forking), no setup is needed — use `nabarun-ngo/ngo-nabarun-templates` as the org/repo in all examples below.

---

## 3. Reusable Workflows

All workflows are called via `workflow_call`. Replace `your-org/templates` with your fork, or use `nabarun-ngo/ngo-nabarun-templates` directly.

---

### 3.1 Setup-Env

**File:** `.github/workflows/Setup-Env.yml`  
**Purpose:** Resolves inputs from any trigger type (workflow_dispatch, repository_dispatch, schedule) into a unified JSON output. Optionally runs a custom setup script.

```yaml
jobs:
  setup:
    uses: your-org/templates/.github/workflows/Setup-Env.yml@main
    with:
      inputs: ${{ toJson(inputs) }}                        # optional
      client_payload: ${{ toJson(github.event.client_payload) }} # optional
      schedule_config_file: 'config/config-MyWorkflow.json'      # optional
      script_path: 'scripts/my-setup.sh'                        # optional
      script_args: '--env prod'                                   # optional
      resolve_variables: 'API_URL,DB_HOST'                       # optional

  next_job:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - run: echo "Env is ${{ fromJson(needs.setup.outputs.variables).environment }}"
```

**Outputs:** `variables` (JSON string), `trigger_type`

---

### 3.2 Build-Test

**File:** `.github/workflows/Build-Test.yml`  
**Purpose:** Builds and tests Java or Node.js applications.

```yaml
jobs:
  build:
    uses: your-org/templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'java'           # 'java' or 'node'
      repo: 'my-org/my-app'
      branch: 'main'
      command: 'clean package'   # Maven command for Java; npm command for Node
      java_version: '17'         # Java only
      node_version: '20'         # Node only
      working_directory: '.'
      maven_options: '-DskipTests=false'
```

---

### 3.3 Run-Tests (Sequential)

**File:** `.github/workflows/Run-Tests.yml`  
**Purpose:** Executes Cucumber tests sequentially with optional QMetry upload.

```yaml
jobs:
  test:
    uses: your-org/templates/.github/workflows/Run-Tests.yml@main
    with:
      test_env: 'staging'
      test_doppler_project_name: 'my-project'
      test_cucumber_tags: '@smoke'
      test_type: 'smoke'
      repository_name: 'my-org/test-repo'
      branch_name: 'main'
      test_cycle_folder: '1234567'
      test_case_folder: '7654321'
      qmetry_project_id: '10004'
      jira_url: 'https://myorg.atlassian.net'
      upload_result: true
      templates_repository: 'your-org/templates'    # if forked
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
      qmetry_open_api_key: ${{ secrets.QMETRY_OPEN_API_KEY }}
      repo_token: ${{ secrets.GITHUB_TOKEN }}
```

**Outputs:** `test_execution_url`, `test_cycle`, `test_results_uploaded`

---

### 3.4 Run-Parallel-Tests

**File:** `.github/workflows/Run-Parallel-Tests.yml`  
**Purpose:** Discovers scenarios, runs them in parallel across a matrix, consolidates results, and uploads to QMetry.

```yaml
jobs:
  parallel_test:
    uses: your-org/templates/.github/workflows/Run-Parallel-Tests.yml@main
    with:
      test_env: 'staging'
      test_doppler_project_name: 'my-project'
      test_cucumber_tags: '@regression'
      test_type: 'regression'
      max_tests_per_matrix: 5
      max_rerun_attempt: 2
      repository_name: 'my-org/test-repo'
      branch_name: 'main'
      test_cycle_folder: '1234567'
      test_case_folder: '7654321'
      qmetry_project_id: '10004'
      jira_url: 'https://myorg.atlassian.net'
      templates_repository: 'your-org/templates'    # if forked
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
      qmetry_open_api_key: ${{ secrets.QMETRY_OPEN_API_KEY }}
      repo_token: ${{ secrets.GITHUB_TOKEN }}
```

---

### 3.5 Deploy GCP App Engine

**File:** `.github/workflows/Deploy-GCP-v2.yml`  
**Purpose:** Builds a Java or Node app and deploys it to Google App Engine with health checks and optional cleanup.

```yaml
jobs:
  deploy:
    uses: your-org/templates/.github/workflows/Deploy-GCP-v2.yml@main
    with:
      app_type: 'java'                  # 'java' or 'node'
      repo_name: 'my-app'
      repo_owner_name: 'my-org'
      environment_name: 'staging'
      # --- Tag resolution (choose one) ---
      source_branch: 'main'             # auto-resolve latest tag on this branch
      # tag_name: 'v1.4.2'             # OR pin an explicit tag
      # ---
      app_doppler_project_name: 'my-project'
      app_doppler_config: 'stg'
      gae_service_name: 'default'
      enable_health_check: true
    secrets:
      gcp_project_id: ${{ secrets.GCP_PROJECT_ID }}
      gcp_service_account: ${{ secrets.GCP_SA_KEY }}
      app_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      repo_token: ${{ secrets.GITHUB_TOKEN }}
```

**Key inputs:**

| Input | Default | Description |
|-------|---------|-------------|
| `tag_name` | `'latest'` | Tag to deploy. Leave empty to auto-resolve from `source_branch`. |
| `source_branch` | `'main'` | Branch used for tag auto-resolution (only tags reachable from this branch). |
| `app_type` | — | `'java'` or `'node'` |
| `enable_db_migration` | `false` | Run DB migration before deploy |
| `enable_cleanup` | `false` | Clean old GAE versions / GCS files after deploy |

---

### 3.6 Deploy GCP Cloud Run

**File:** `.github/workflows/Deploy-GCP-CloudRun.yml`  
**Purpose:** Builds a Docker image and deploys to Google Cloud Run.

```yaml
jobs:
  deploy:
    uses: your-org/templates/.github/workflows/Deploy-GCP-CloudRun.yml@main
    with:
      repo_name: 'my-app'
      repo_owner_name: 'my-org'
      image_name: 'my-org/my-app'
      service_name: 'my-service'
      environment_name: 'production'
      source_branch: 'main'            # auto-resolve latest tag
      doppler_project: 'my-project'
      doppler_config: 'prd'
      region: 'us-central1'
    secrets:
      GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
      GCP_SA_KEY: ${{ secrets.GCP_SA_KEY }}
      DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
      REPO_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      DOCKER_USER: ${{ secrets.DOCKER_USER }}
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
```

---

### 3.7 Deploy Firebase

**File:** `.github/workflows/Deploy-Firebase.yml`  
**Purpose:** Builds a Node.js app and deploys it to Firebase Hosting.

```yaml
jobs:
  deploy:
    uses: your-org/templates/.github/workflows/Deploy-Firebase.yml@main
    with:
      repo_name: 'my-frontend'
      repo_owner_name: 'my-org'
      environment_name: 'production'
      npm_run_command: 'npm run build:prod'
      target_site: 'my-site'
      source_branch: 'main'            # auto-resolve latest tag
      use_doppler: true
      doppler_project: 'my-project'
      doppler_config: 'prd'
    secrets:
      firebase_project_id: ${{ secrets.FIREBASE_PROJECT_ID }}
      firebase_service_account: ${{ secrets.FIREBASE_SA }}
      repo_token: ${{ secrets.GITHUB_TOKEN }}
      doppler_token: ${{ secrets.DOPPLER_TOKEN }}
```

---

### 3.8 Create Tag & Release

**File:** `.github/workflows/Create-Tag-Release.yml`  
**Purpose:** Auto-bumps a semver tag (beta on pre-release branches, stable on release branches) and publishes a full GitHub Release with categorised release notes and pre-release history.

**Release notes include:**
- Commits categorised by type (💥 Breaking, ✨ Features, 🐛 Fixes, ⚡ Perf, 📚 Docs, 🔧 Maintenance)
- A table of every beta tag (`v1.2.0-beta.1`, `beta.2`, …) that was part of this release
- Full diff link between previous and current stable

```yaml
jobs:
  release:
    uses: your-org/templates/.github/workflows/Create-Tag-Release.yml@main
    with:
      source_branch: ${{ github.ref_name }}
      pre_release_branches: 'staging,stage'   # these get beta tags
      release_branches: 'master,main'          # these get stable tags + GitHub Release
      templates_repository: 'your-org/templates'  # required if you forked
```

**Outputs:** `tag_name` (created tag), `stable_tag` (promoted stable tag)

**Commit message format** (for categorised notes):
```
feat: add new login flow
fix(auth): resolve token expiry
chore: upgrade dependencies
BREAKING CHANGE: removed legacy API
```

**Testing the release notes script locally:**
```bash
cd your-app-repo
git fetch --tags
bash path/to/templates/scripts/generate-release-notes.sh v1.2.0
cat release_notes.md
```

---

### 3.9 Sync Data

**File:** `.github/workflows/Sync-Data.yml`  
**Purpose:** Syncs Auth0 tenant configuration or Firebase environment data between environments.

```yaml
jobs:
  sync:
    uses: your-org/templates/.github/workflows/Sync-Data.yml@main
    with:
      sync_type: 'auth0'           # 'auth0' or 'firebase'
      source_env: 'dev'
      target_env: 'staging'
      templates_repository: 'your-org/templates'
    secrets:
      repo_token: ${{ secrets.GITHUB_TOKEN }}
```

---

### 3.10 Run-MongoDB-Migration

**File:** `.github/workflows/Run-MongoDB-Migration.yml`  
**Purpose:** Runs a `mongosh` migration script against a MongoDB instance. Checks out the target repository, installs MongoDB Shell 6.0, and executes the specified script file with source and destination database names injected as environment variables.

```yaml
jobs:
  migrate:
    uses: your-org/templates/.github/workflows/Run-MongoDB-Migration.yml@main
    with:
      script_file: 'migrate-users.js'        # path relative to working_directory
      source_db: 'users_db_v1'
      dest_db: 'users_db_v2'
      environment_name: 'staging'            # GitHub environment to deploy into
      working_directory: 'migrations'        # default: 'migrations'
      repository_name: 'my-org/my-app'       # optional; defaults to caller repo
      branch_name: 'main'                    # optional; defaults to default branch
    secrets:
      MONGO_URI: ${{ secrets.MONGO_URI }}
```

**Inputs:**

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `script_file` | yes | — | Migration script filename (resolved inside `working_directory`) |
| `source_db` | yes | — | Source database name (available as `$SOURCE_DB` in the script) |
| `dest_db` | yes | — | Destination database name (available as `$DEST_DB` in the script) |
| `environment_name` | yes | — | GitHub environment for the job (gates approvals and environment secrets) |
| `working_directory` | no | `'migrations'` | Directory containing migration scripts |
| `repository_name` | no | — | Repository to checkout (`org/repo`). Omit to use the caller repo |
| `branch_name` | no | — | Branch or ref to checkout |

**Secrets:**

| Secret | Required | Description |
|--------|----------|-------------|
| `MONGO_URI` | yes | Full MongoDB connection URI (e.g. `mongodb+srv://user:pass@cluster/`) |

**How the script receives context:**

The migration script is executed via:
```bash
mongosh "$MONGO_URI" migrations/migrate-users.js
```

Inside the script, `SOURCE_DB` and `DEST_DB` are available as environment variables:
```js
const srcDb = db.getSiblingDB(process.env.SOURCE_DB);
const dstDb = db.getSiblingDB(process.env.DEST_DB);
```

---

### 3.11 Run-Parallel-Tests-Allure

**File:** `.github/workflows/Run-Parallel-Tests-Allure.yml`  
**Purpose:** Drop-in replacement for `Run-Parallel-Tests.yml` with QMetry removed and Allure reporting added. Discovers scenarios, runs them in parallel across a matrix, uploads per-job Allure results, then generates a full Allure report (with rolling trend history capped at `keep_history_days` days) and deploys it to GitHub Pages.

```yaml
jobs:
  parallel_test:
    uses: your-org/templates/.github/workflows/Run-Parallel-Tests-Allure.yml@main
    with:
      test_env: 'staging'
      test_doppler_project_name: 'my-project'
      test_cucumber_tags: '@regression'
      test_type: 'regression'
      max_tests_per_matrix: 5
      max_rerun_attempt: 2
      app_ui_version: 'v2.1.0'
      app_server_version: 'v1.4.0'
      repository_name: 'my-org/test-repo'
      branch_name: 'main'
      runner_os: 'ubuntu-latest'        # default; use windows-latest if tests require Windows
      templates_repository: ''          # default (uses the repo this workflow lives in)
      enable_allure: true               # default true
      allure_results_dir: 'test/allure-results'   # default
      gh_pages_branch: 'gh-pages'       # default
      allure_report_name: 'Regression Report'
      keep_history_days: 30             # default; 0 = unlimited
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      repo_token: ${{ secrets.GITHUB_TOKEN }}
```

**All inputs:**

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `test_env` | **Yes** | — | Target test environment |
| `test_doppler_project_name` | **Yes** | — | Doppler project for config injection |
| `test_cucumber_tags` | **Yes** | — | Cucumber tag expression |
| `test_type` | **Yes** | — | Test type label (e.g. `regression`, `smoke`) |
| `app_ui_version` | **Yes** | — | UI version being tested |
| `app_server_version` | **Yes** | — | Server version being tested |
| `repository_name` | **Yes** | — | Test repo in `org/repo` format |
| `max_tests_per_matrix` | No | `5` | Max scenarios per parallel job |
| `max_rerun_attempt` | No | `1` | Rerun count for flaky tests |
| `java_version` | No | `22` | Java version for test runner |
| `branch_name` | No | `main` | Branch of the test repository to checkout |
| `runner_os` | No | `ubuntu-latest` | OS for test execution jobs |
| `templates_repository` | No | `''` | Override templates repo ref for forked setups |
| `additional_plugins` | No | `''` | Extra Cucumber plugins (comma-separated) |
| `enable_allure` | No | `true` | Toggle Allure plugin injection and report publishing |
| `allure_results_dir` | No | `test/allure-results` | Per-job Allure results path |
| `gh_pages_branch` | No | `gh-pages` | Branch for GitHub Pages deployment |
| `allure_report_name` | No | `Allure Report` | Title shown in the report |
| `keep_history_days` | No | `30` | Days of trend history to retain; `0` = unlimited |

**Outputs:** `discovery_status`, `scenario_count`, `test_execution_status`, `overall_status`, `test_summary`, `allure_report_url`

**Pre-requisites:**

1. **Maven dependency** — add `allure-cucumber7-jvm` to your test project's `pom.xml`:
   ```xml
   <dependency>
     <groupId>io.qameta.allure</groupId>
     <artifactId>allure-cucumber7-jvm</artifactId>
     <version>2.27.0</version>  <!-- match your Allure CLI version -->
     <scope>test</scope>
   </dependency>
   ```
2. **GitHub Pages** — enable Pages on the test-results repo: Settings → Pages → Source → Deploy from branch → `gh-pages`.
3. **Token permissions** — the workflow grants `contents: write` to the publish job automatically via `GITHUB_TOKEN`. Ensure Actions have write permission in the repo (Settings → Actions → General → Workflow permissions → Read and write).

**Migration guide from `Run-Parallel-Tests.yml`:**

| Change | Action |
|--------|--------|
| Remove `test_cycle_folder`, `test_case_folder`, `qmetry_execution_url`, `qmetry_project_id`, `jira_url`, `upload_result` inputs | Delete from caller workflow |
| Remove `qmetry_api_key`, `qmetry_open_api_key` secrets | Delete from caller secrets block |
| Remove outputs `upload_status`, `test_execution_url`, `test_cycle`, `test_results_uploaded` | Update any downstream job that reads these |
| Add `allure-cucumber7-jvm` Maven dependency | See pre-requisite above |
| Enable GitHub Pages on the repo | See pre-requisite above |
| Switch `uses:` to `Run-Parallel-Tests-Allure.yml` | Rename the `uses:` line |

---

### 3.12 GCP-Ops

**File:** `.github/workflows/GCP-Ops.yml`  
**Purpose:** A single-entry-point workflow for common GCP maintenance tasks. The `operation` input selects which job runs; all other inputs are operation-specific and ignored by other jobs.

**Supported operations:**

| `operation` value | What it does |
|-------------------|-------------|
| `download-logs` | Downloads Cloud Logging entries matching a filter to an artifact |
| `restart-app-engine` | Restarts an App Engine service by deleting all instances |
| `restart-gcr` | Forces a new Cloud Run revision (updates env var timestamp) and re-routes traffic |
| `cleanup-gcp-resources` | Cleans Artifact Registry repositories, old GAE versions, and old GCS files |

```yaml
# Example: download logs
jobs:
  ops:
    uses: your-org/templates/.github/workflows/GCP-Ops.yml@main
    with:
      operation: 'download-logs'
      environment: 'staging'
      log_filter: 'textPayload:"my-request-id-123"'
      output_format: 'txt'       # txt | csv | html | json
      limit: '5000'
    secrets:
      project_id: ${{ secrets.GCP_PROJECT_ID }}
      gcp_sa_key: ${{ secrets.GCP_SA_KEY }}

# Example: restart App Engine
jobs:
  ops:
    uses: your-org/templates/.github/workflows/GCP-Ops.yml@main
    with:
      operation: 'restart-app-engine'
      environment: 'staging'
      service_name: 'default'
      confirm_restart: 'yes'
    secrets:
      project_id: ${{ secrets.GCP_PROJECT_ID }}
      gcp_sa_key: ${{ secrets.GCP_SA_KEY }}

# Example: cleanup GCP resources
jobs:
  ops:
    uses: your-org/templates/.github/workflows/GCP-Ops.yml@main
    with:
      operation: 'cleanup-gcp-resources'
      environment: 'staging'
      service_name: 'default'
      keep_gae_versions: '2'
      gcs_keep_days: '7'
    secrets:
      project_id: ${{ secrets.GCP_PROJECT_ID }}
      gcp_sa_key: ${{ secrets.GCP_SA_KEY }}
```

**Outputs:** `operation_result`, `output_path`, `log_count`, `execution_time`, `instances_deleted`, `instances_recreated`, `service_status`, `cleanup_result`, `resources_cleaned`

---

### 3.13 JMeter Load Test

**File:** `.github/workflows/jmeter-load-test.yml`  
**Purpose:** Runs a JMeter load test against a target URL, generates an HTML report, uploads it as an artifact, deploys it to GitHub Pages (under `reports/{run_number}/`), and posts a performance summary to the job summary and (if triggered by PR) as a PR comment. Fails the job if the success rate drops below 95% or average response time exceeds 2000 ms.

```yaml
jobs:
  load_test:
    uses: your-org/templates/.github/workflows/jmeter-load-test.yml@main
    with:
      script: 'tests/load/my-test.jmx'
      users: '50'
      rampup: '30'
      loops: '10'
      lifetime: '300'
      target_url: 'api.myapp.com'    # without protocol
    secrets:
      JWT_TOKEN: ${{ secrets.JWT_TOKEN }}     # optional, injected as -JJWT_TOKEN
      API_KEY: ${{ secrets.API_KEY }}         # optional, injected as -JAPI_KEY
```

**Inputs:**

| Input | Required | Description |
|-------|----------|-------------|
| `script` | yes | Path to `.jmx` file relative to the repo root |
| `users` | yes | Number of concurrent virtual users |
| `rampup` | yes | Ramp-up time in seconds |
| `loops` | yes | Loop count per user thread |
| `lifetime` | yes | Thread lifetime |
| `target_url` | yes | Base host without protocol (e.g. `api.myapp.com`) |

**Report URL pattern:** `https://{owner}.github.io/{repo}/reports/{run_number}/index.html`

---

### 3.14 mongo-cloud (MongoDB → PostgreSQL)

**File:** `.github/workflows/mongo-cloud.yml`  
**Purpose:** Three independent, conditionally executed jobs for MongoDB Atlas operations. Each job only runs when its corresponding input is provided; you can trigger one, two, or all three in the same call.

| Job | Triggered when | What it does |
|-----|----------------|-------------|
| `run-mongo-script` | `script-path` is set | Runs a `.js` file against MongoDB Atlas via `mongosh` |
| `import-mongo-data` | `import-file` and `import-collection` are both set | Bulk-imports a JSON file into a collection via `mongoimport` |
| `migrate-mongo-to-postgres` | `migration-script-path` is set | Runs a Node.js migration script with both `MONGO_URI` and `POSTGRES_URI` injected |

```yaml
# Example: run a maintenance script
jobs:
  db_ops:
    uses: your-org/templates/.github/workflows/mongo-cloud.yml@main
    with:
      target-env: 'staging'
      script-path: 'scripts/fix-orphaned-docs.js'
    secrets:
      mongo-uri: ${{ secrets.MONGO_URI }}

# Example: import seed data
jobs:
  db_ops:
    uses: your-org/templates/.github/workflows/mongo-cloud.yml@main
    with:
      target-env: 'staging'
      import-file: 'data/seed-users.json'
      import-collection: 'users'
    secrets:
      mongo-uri: ${{ secrets.MONGO_URI }}

# Example: migrate to PostgreSQL
jobs:
  db_ops:
    uses: your-org/templates/.github/workflows/mongo-cloud.yml@main
    with:
      target-env: 'staging'
      migration-script-path: 'migrations/users-to-pg.js'
    secrets:
      mongo-uri: ${{ secrets.MONGO_URI }}
      postgres-uri: ${{ secrets.POSTGRES_URI }}
```

**Outputs:** `script-logs`, `import-logs`, `migration-logs`

---

### 3.15 Publish-Package

**File:** `.github/workflows/Publish-Package.yml`  
**Purpose:** Publishes a Maven package to GitHub Packages at a specific tag. Sets the POM version to match the tag (stripping the leading `v`), builds all modules, then runs `mvn deploy`.

```yaml
jobs:
  publish:
    uses: your-org/templates/.github/workflows/Publish-Package.yml@main
    with:
      source_tag: 'v1.4.2'        # tag to checkout and publish
      package_manager: 'mvn'      # only 'mvn' is supported today
      java_version: '17'          # default: '17'
      server_id: 'github'         # default: 'github'
    permissions:
      contents: read
      packages: write
```

> The workflow uses `GITHUB_TOKEN` implicitly via `actions/setup-java` — no additional secrets are required.

---

### 3.16 Redis-Ops

**File:** `.github/workflows/Redis-Ops.yml`  
**Purpose:** Provides `view-keys` and `delete-keys` operations against a Redis instance. Always runs a connectivity ping first; the operation job only runs if the ping succeeds.

| `operation` | Behaviour |
|-------------|-----------|
| `view-keys` | Lists all keys matching `*` and reports the count |
| `delete-keys` (with `key`) | Deletes a specific key via `DEL` |
| `delete-keys` (without `key`) | Flushes all keys via `FLUSHALL` |

```yaml
# View all keys
jobs:
  redis_ops:
    uses: your-org/templates/.github/workflows/Redis-Ops.yml@main
    with:
      operation: 'view-keys'
      environment: 'staging'
    secrets:
      redis_uri: ${{ secrets.REDIS_URI }}

# Delete a specific key
jobs:
  redis_ops:
    uses: your-org/templates/.github/workflows/Redis-Ops.yml@main
    with:
      operation: 'delete-keys'
      environment: 'staging'
      key: 'session:user:12345'
    secrets:
      redis_uri: ${{ secrets.REDIS_URI }}

# Flush all keys (omit key input)
jobs:
  redis_ops:
    uses: your-org/templates/.github/workflows/Redis-Ops.yml@main
    with:
      operation: 'delete-keys'
      environment: 'staging'
    secrets:
      redis_uri: ${{ secrets.REDIS_URI }}
```

**Outputs:** `ping_result`, `operation_result`, `keys_count`

---

### 3.17 Trigger-Workflow

**File:** `.github/workflows/Trigger-Workflow.yml`  
**Purpose:** Sends a `repository_dispatch` event to any GitHub repository, allowing cross-repo workflow triggering. Wraps `peter-evans/repository-dispatch`.

```yaml
jobs:
  trigger:
    uses: your-org/templates/.github/workflows/Trigger-Workflow.yml@main
    with:
      repository: 'my-org/my-other-repo'
      event_type: 'run-regression-tests'
      input_json: '{"environment": "staging", "test_type": "regression"}'
    secrets:
      token: ${{ secrets.PAT_TOKEN }}   # must have repo scope on the target repo
```

> The receiving repo must have a workflow with `on: repository_dispatch` and a matching `types:` filter for `event_type`.

---

## 4. Composite Actions

### 4.1 Build Actions

#### `build-java`

Builds a Java/Maven project with caching, validation, and test result upload.

```yaml
- uses: your-org/templates/.github/actions/build-java@main
  with:
    java_version: '17'
    maven_command: 'clean package'
    maven_options: '-DskipTests=false'
    working_directory: '.'
    enable_cache: 'true'
    upload_test_results: 'true'
```

| Input | Default | Description |
|-------|---------|-------------|
| `java_version` | `'17'` | Java version |
| `maven_command` | `'clean package'` | Maven lifecycle/goals |
| `maven_options` | `'-Dmaven.test.skip=true ...'` | Additional Maven flags |
| `enable_cache` | `'true'` | Cache `~/.m2/repository` |
| `upload_test_results` | `'true'` | Upload surefire/failsafe reports |

**Outputs:** `build_status`, `build_time`, `maven_version`

---

#### `build-node`

Builds a Node.js project, optionally injecting secrets from Doppler.

```yaml
- uses: your-org/templates/.github/actions/build-node@main
  with:
    node_version: '20'
    command: 'npm run build'
    working_directory: '.'
    package_manager: 'npm'           # 'npm', 'yarn', 'pnpm'
    use_doppler: 'true'
    doppler_token: ${{ secrets.DOPPLER_TOKEN }}
    doppler_project: 'my-project'
    doppler_config: 'stg'
```

**Outputs:** `build_status`

---

#### `prepare-node-artifact`

Creates a production-only deployment artifact (no dev dependencies, with optional Doppler CLI and Prisma schema).

```yaml
- uses: your-org/templates/.github/actions/prepare-node-artifact@main
  with:
    artifact_pattern: 'dist'
    package_manager: 'npm'
    include_node_modules: 'true'
    install_doppler_cli: 'true'
    include_prisma_schema: 'true'
```

---

### 4.2 Testing Actions

#### `test-setup`

Checks out the templates repo and the test repo, sets up Java, and installs `jq`.

```yaml
- uses: your-org/templates/.github/actions/test-setup@main
  with:
    java_version: '22'
    templates_repository: 'your-org/templates'   # optional, defaults to action repo
    test_repository: 'my-org/test-repo'
    test_branch: 'main'
    templates_path: 'actions'
    test_path: 'test'
    enable_maven_cache: 'true'
```

**Outputs:** `java_version`, `cache_hit`

---

#### `cucumber-discover-scenarios`

Runs a Cucumber dry-run to find all scenarios matching a tag, and outputs a GitHub Actions matrix for parallel execution.

```yaml
- id: discover
  uses: your-org/templates/.github/actions/cucumber-discover-scenarios@main
  with:
    cucumber_tags: '@smoke'
    max_scenarios_per_job: '5'
    test_directory: 'test'

- run: echo "Found ${{ steps.discover.outputs.scenario_count }} scenarios"
```

**Outputs:** `matrix`, `scenario_count`

---

#### `cucumber-run-tests`

Executes Cucumber tests via Maven for a specific set of scenario lines.

```yaml
- id: run
  uses: your-org/templates/.github/actions/cucumber-run-tests@main
  with:
    scenarios: 'features/login.feature:10,features/checkout.feature:25'
    job_index: ${{ strategy.job-index }}
    test_environment: 'staging'
    doppler_project_name: 'my-project'
    doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
    max_rerun_attempts: '2'
    headless_mode: 'Y'
  continue-on-error: true
```

**Outputs:** `test_status` (`PASSED`/`FAILED`), `exit_code`, `results_path`

---

#### `test-results-consolidation`

Downloads all parallel test artifacts, merges the Cucumber JSON files, and uploads the consolidated result.

```yaml
- id: consolidate
  uses: your-org/templates/.github/actions/test-results-consolidation@main
  with:
    templates_repository: 'your-org/templates'
    artifact_download_path: 'all-results'
    merged_output_path: 'merged'
    merged_artifact_name: 'merged-cucumber-json'
```

**Outputs:** `merged_file_path`, `artifact_count`, `total_scenarios`, `consolidation_status`

---

#### `test-cycle-cache-manager`

Restores or initialises the QMetry test cycle state for re-run support.

```yaml
- id: cache
  uses: your-org/templates/.github/actions/test-cycle-cache-manager@main
  with:
    workflow_name: ${{ github.workflow }}
    run_id: ${{ github.run_id }}
    run_attempt: ${{ github.run_attempt }}
    test_type: 'regression'
```

**Outputs:** `test_cycle_summary`, `is_rerun`, `cached_test_cycle`, `cache_status`, `cache_key`

---

### 4.3 QMetry Integration Actions

#### `qmetry-upload-manager`

Generates a QMetry upload URL, uploads the Cucumber JSON, and waits for the import to complete.

```yaml
- id: upload
  uses: your-org/templates/.github/actions/qmetry-upload-manager@main
  with:
    qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
    test_environment: 'staging'
    test_cycle_summary: 'Smoke Tests - Build ${{ github.run_number }}'
    test_cycle_folder: '1234567'
    test_case_folder: '7654321'
    app_server_version: 'v1.2.3'
    app_ui_version: 'v2.0.0'
    test_type: 'smoke'
    run_id: ${{ github.run_id }}
    run_attempt: ${{ github.run_attempt }}
    results_file_path: 'merged/cucumber.json'
    cached_test_cycle: ${{ steps.cache.outputs.cached_test_cycle }}
    qmetry_base_url: 'https://qtmcloud.qmetry.com'         # optional
    templates_repository: 'your-org/templates'              # optional
```

**Outputs:** `upload_url`, `tracking_id`, `upload_status`, `import_status`

---

#### `qmetry-result-linker`

Retrieves the QMetry test cycle ID and builds the execution URL for the run summary.

```yaml
- id: link
  uses: your-org/templates/.github/actions/qmetry-result-linker@main
  with:
    qmetry_open_api_key: ${{ secrets.QMETRY_OPEN_API_KEY }}
    qmetry_project_id: '10004'
    qmetry_base_url: 'https://qtmcloud.qmetry.com'
    test_cycle_summary: 'Smoke Tests - Build ${{ github.run_number }}'
    app_execution_url: 'https://qtmcloud.qmetry.com/testExecution/{executionId}'
    jira_url: 'https://myorg.atlassian.net'
    workflow_name: ${{ github.workflow }}
    run_id: ${{ github.run_id }}

- run: echo "Results at ${{ steps.link.outputs.execution_url }}"
```

**Outputs:** `execution_url`, `test_cycle`, `execution_id`, `cache_key`

---

#### `resolve-deploy-tag` ✨ New

Resolves the tag to deploy. If `tag_name` is empty or `'latest'`, finds the most recent git tag reachable from `source_branch` (branch-scoped — tags from other branches are excluded).

```yaml
- id: tag
  uses: your-org/templates/.github/actions/resolve-deploy-tag@main
  with:
    repository: 'my-org/my-app'
    source_branch: 'main'          # only tags on this branch are candidates
    # tag_name: 'v1.4.2'          # OR pin an explicit tag
    token: ${{ secrets.GITHUB_TOKEN }}

- run: echo "Deploying ${{ steps.tag.outputs.resolved_tag }}"
```

**Inputs:**

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `tag_name` | No | `'latest'` | Explicit tag, or empty/`'latest'` to auto-resolve |
| `repository` | **Yes** | — | `org/repo` to resolve the tag from |
| `source_branch` | No | `'main'` | Branch to scope the tag search to |
| `token` | No | `''` | GitHub token for private repos |

**Outputs:** `resolved_tag`, `was_auto_resolved`

---

### 4.4 GCP Operations Actions

#### `gcp-promote-gae-traffic`

Promotes a deployed App Engine version to receive 100% of traffic.

```yaml
- uses: your-org/templates/.github/actions/gcp-promote-gae-traffic@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    service_name: 'default'
    version: ${{ steps.deploy.outputs.version }}
```

---

#### `gcp-health-check-deployment`

Polls the deployment URL until it returns HTTP 200 or max attempts are reached.

```yaml
- uses: your-org/templates/.github/actions/gcp-health-check-deployment@main
  with:
    environment_url: 'https://my-app.appspot.com'
    max_attempts: '10'
    retry_delay: '15'
    timeout: '30'
```

---

#### `gcp-get-deployed-version`

Returns the most recently deployed App Engine version ID.

```yaml
- id: ver
  uses: your-org/templates/.github/actions/gcp-get-deployed-version@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    service_name: 'default'
- run: echo "Deployed version: ${{ steps.ver.outputs.version }}"
```

---

#### `gcp-clean-gae-versions`

Deletes old App Engine versions, keeping only the most recent N.

```yaml
- uses: your-org/templates/.github/actions/gcp-clean-gae-versions@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    service_name: 'default'
    keep_versions: '2'
```

---

#### `gcp-clean-gcr-versions`

Deletes old Cloud Run revisions, keeping only the most recent N.

```yaml
- uses: your-org/templates/.github/actions/gcp-clean-gcr-versions@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    service_name: 'my-service'
    region: 'us-central1'
    keep_revisions: '3'
```

---

#### `gcp-clean-gcs-files`

Deletes files older than N days from GCS buckets.

```yaml
- uses: your-org/templates/.github/actions/gcp-clean-gcs-files@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    keep_days: '5'
    bucket_patterns: 'auto'    # auto = GAE staging/artifact buckets
    dry_run: 'false'
```

---

#### `gcp-clean-artifact-registry`

Deletes all Artifact Registry repositories used by App Engine deployments.

```yaml
- uses: your-org/templates/.github/actions/gcp-clean-artifact-registry@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
```

---

#### `gcp-restart-app-engine`

Restarts an App Engine service by deleting all instances (which forces recreation).

```yaml
- uses: your-org/templates/.github/actions/gcp-restart-app-engine@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    service_name: 'default'
    confirm_restart: 'yes'
    dry_run: 'false'
```

---

#### `gcp-download-logs`

Downloads GCP Cloud Logging entries matching a filter to a file (txt, csv, html, or json).

```yaml
- uses: your-org/templates/.github/actions/gcp-download-logs@main
  with:
    project_id: ${{ secrets.GCP_PROJECT_ID }}
    filter: 'textPayload:"my-request-id"'
    output_format: 'txt'
    limit: '1000'
```

---

### 4.5 Utility Actions

#### `resolve-inputs`

Merges inputs from any GitHub trigger (workflow_dispatch, repository_dispatch, schedule) into a single JSON output and exports all keys to `GITHUB_ENV`.

```yaml
- id: resolve
  uses: your-org/templates/.github/actions/resolve-inputs@main
  with:
    inputs: ${{ toJson(inputs) }}
    client_payload: ${{ toJson(github.event.client_payload) }}
    schedule_config_file: 'config/config-MyWorkflow.json'

- run: echo "Env = ${{ fromJson(steps.resolve.outputs.variables).environment }}"
```

---

#### `determine-schedule-config`

Finds the config file for a scheduled workflow and returns the matching cron configuration.

```yaml
- id: cfg
  uses: your-org/templates/.github/actions/determine-schedule-config@main
  with:
    config_base_path: 'config'

- run: echo "Config file: ${{ steps.cfg.outputs.config_file }}"
```

---

#### `notify-system`

Posts a JSON message to any webhook (Slack, Teams, Jira, etc.).  
> ⚠️ `message` **must be valid JSON**.

```yaml
- uses: your-org/templates/.github/actions/notify-system@main
  with:
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    message: '{"text": "Deployment complete", "status": "success"}'
```

---

#### `update-pr-description`

Fetches all commit messages from a PR and rewrites its description body with them.

```yaml
- uses: your-org/templates/.github/actions/update-pr-description@main
  with:
    pr_number: ${{ github.event.pull_request.number }}
    repository: ${{ github.repository }}
    token: ${{ secrets.GITHUB_TOKEN }}
```

> Requires `pull-requests: write` permission on the token.

---

#### `update-json-from-env`

Merges environment variable values into a JSON object with automatic type detection (string, integer, float, boolean).

```yaml
- id: json
  uses: your-org/templates/.github/actions/update-json-from-env@main
  with:
    base_json: '{"env": "staging"}'
    resolve_variables: 'VERSION,FEATURE_FLAG'

- run: echo "${{ steps.json.outputs.updated_json }}"
```

---

#### `validate-and-find-file`

Finds a file matching a pattern in a directory, with exclusion support and multiple selection strategies.

```yaml
- id: jar
  uses: your-org/templates/.github/actions/validate-and-find-file@main
  with:
    search_directory: 'target'
    file_pattern: '*.jar'
    exclude_patterns: 'sources,javadoc,test'
    selection_strategy: 'first'    # 'first', 'last', 'largest', 'newest'
    validate_file: 'true'

- run: echo "JAR: ${{ steps.jar.outputs.file_path }}"
```

---

### 4.6 Allure Reporting Actions

#### `allure-publish`

Downloads all `allure-results-*` artifacts from a parallel test run, restores trend history from the `gh-pages` branch (pruning entries older than `keep_history_days`), generates a full Allure report, and deploys it to GitHub Pages. Used internally by `Run-Parallel-Tests-Allure.yml` but can also be called standalone.

```yaml
- uses: your-org/templates/.github/actions/allure-publish@main
  with:
    allure_results_artifact_pattern: 'allure-results-*'  # default
    gh_pages_branch: 'gh-pages'                          # default
    report_name: 'My Regression Report'
    keep_history_days: '30'    # default; '0' = unlimited
    github_token: ${{ secrets.GITHUB_TOKEN }}
    allure_version: '2.27.0'   # default; pin to a specific release
```

**How history pruning works:**  
Allure trend files (`*-trend.json`) contain no timestamps. A sidecar file `history-dates.json` is maintained on the `gh-pages` branch with one ISO-8601 timestamp per build. On each publish run the current timestamp is appended and entries older than `keep_history_days` days are counted out; both the sidecar and all trend arrays are sliced to keep only the in-window builds. Set `keep_history_days: '0'` to disable pruning entirely.

**Inputs:**

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `allure_results_artifact_pattern` | No | `allure-results-*` | Glob pattern for artifact download |
| `gh_pages_branch` | No | `gh-pages` | Target branch for deployment |
| `report_name` | No | `Allure Report` | Title shown inside the report (requires Allure CLI ≥ 2.10) |
| `keep_history_days` | No | `30` | Days of trend history to keep; `0` = unlimited |
| `github_token` | **Yes** | — | Token with `contents: write` for gh-pages push |
| `allure_version` | No | `2.27.0` | Allure CLI version to install (must be ≥ 2.10 for `--name` to work) |

**Outputs:**

| Output | Description |
|--------|-------------|
| `report_url` | Deployed GitHub Pages URL (`https://<owner>.github.io/<repo>/`) |

---

## 5. Scripts Reference

All scripts live in `scripts/`. They can be run locally or called from composite actions.

### Bash scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `generate-release-notes.sh` | Builds categorised release notes markdown for a GitHub Release | `bash generate-release-notes.sh <tag> [output.md]` |
| `merge-cucumber-jsons.sh` | Merges multiple Cucumber JSON files into one | `bash merge-cucumber-jsons.sh [input_dir] [output_dir]` |
| `discover_scenarios.sh` | Cucumber dry-run scenario discovery (legacy; use composite action) | `bash discover_scenarios.sh <@tag> <max_per_job>` |
| `run_cucumber_tests.sh` | Runs Cucumber tests via Maven | `bash run_cucumber_tests.sh <scenarios> <idx> <env> <project> <token> <reruns> [headless]` |
| `wait-for-qmetry-report-import.sh` | Polls QMetry until an import completes | `bash wait-for-qmetry-report-import.sh <trackingId> <apiKey> [base_url]` |
| `process-auth0.sh` | Replaces Auth0 keyword mappings in a file | `bash process-auth0.sh <src.json> <dest.json> <target_file>` |
| `set_latest_tag_fixed.sh` | Fetches latest FE/BE tags (set `FE_REPO`, `BE_REPO` env vars) | Sourced in CI steps |
| `setup-for-org.sh` | One-time fork setup: replaces all internal org/repo references | `bash setup-for-org.sh YOUR_ORG/YOUR_REPO [ref]` |

### Python scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/auth0/process_auth0.py` | Replaces values between two Auth0 environment JSON files | `python process_auth0.py <src.json> <dest.json> <file>` |
| `scripts/auth0/process_auth0_v2.py` | Reverse-replaces values with `##KEY##` tokens (with `--dry-run`) | `python process_auth0_v2.py <env.json> <file> [--dry-run]` |
| `scripts/common/set_env.py` | Sets `GITHUB_OUTPUT` / `GITHUB_ENV` from dispatch payloads | Called from workflow steps |

---

## 6. Configuration System

For **scheduled workflows** that run multiple crons with different parameters, put a JSON config file in the caller repo:

**File naming:** `config/config-{WorkflowFilename}.json`  
Example: `Daily-Tests.yml` → `config/config-Daily-Tests.json`

**Structure:**
```json
{
  "0 2 * * *": {
    "environment": "production",
    "test_type": "smoke",
    "cucumber_tags": "@smoke"
  },
  "0 */6 * * *": {
    "environment": "staging",
    "test_type": "regression",
    "cucumber_tags": "@regression"
  }
}
```

**Reading config in a workflow:**
```yaml
on:
  schedule:
    - cron: '0 2 * * *'
    - cron: '0 */6 * * *'

jobs:
  setup:
    uses: your-org/templates/.github/workflows/Setup-Env.yml@main
    with:
      schedule_config_file: 'config/config-Daily-Tests.json'

  test:
    needs: setup
    uses: your-org/templates/.github/workflows/Run-Parallel-Tests.yml@main
    with:
      test_env: ${{ fromJson(needs.setup.outputs.variables).environment }}
      test_cucumber_tags: ${{ fromJson(needs.setup.outputs.variables).cucumber_tags }}
```

---

## 7. Full Examples

### Complete Test → Deploy Pipeline

```yaml
name: Test and Deploy
on:
  push:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'

jobs:
  setup:
    uses: your-org/templates/.github/workflows/Setup-Env.yml@main
    with:
      inputs: ${{ toJson(inputs) }}
      schedule_config_file: 'config/config-Test-and-Deploy.json'

  build:
    uses: your-org/templates/.github/workflows/Build-Test.yml@main
    with:
      platform: 'java'
      repo: 'my-org/my-app'
      branch: ${{ github.ref_name }}
      command: 'clean test'
      java_version: '17'

  integration_tests:
    needs: [setup, build]
    uses: your-org/templates/.github/workflows/Run-Parallel-Tests.yml@main
    with:
      test_env: ${{ fromJson(needs.setup.outputs.variables).environment }}
      test_cucumber_tags: '@integration'
      test_type: 'integration'
      repository_name: 'my-org/tests'
      branch_name: 'main'
      test_cycle_folder: '1234567'
      test_case_folder: '7654321'
      qmetry_project_id: '10004'
      jira_url: 'https://myorg.atlassian.net'
    secrets:
      test_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      qmetry_api_key: ${{ secrets.QMETRY_API_KEY }}
      qmetry_open_api_key: ${{ secrets.QMETRY_OPEN_API_KEY }}
      repo_token: ${{ secrets.GITHUB_TOKEN }}

  deploy:
    needs: integration_tests
    if: needs.integration_tests.result == 'success' && github.ref == 'refs/heads/main'
    uses: your-org/templates/.github/workflows/Deploy-GCP-v2.yml@main
    with:
      app_type: 'java'
      repo_name: 'my-app'
      repo_owner_name: 'my-org'
      environment_name: 'staging'
      source_branch: 'main'
      app_doppler_project_name: 'my-project'
      app_doppler_config: 'stg'
    secrets:
      gcp_project_id: ${{ secrets.GCP_PROJECT_ID }}
      gcp_service_account: ${{ secrets.GCP_SA_KEY }}
      app_doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}
      repo_token: ${{ secrets.GITHUB_TOKEN }}

  notify:
    if: always()
    needs: [integration_tests, deploy]
    runs-on: ubuntu-latest
    steps:
      - uses: your-org/templates/.github/actions/notify-system@main
        with:
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
          message: >-
            {"text": "Pipeline: tests=${{ needs.integration_tests.result }},
            deploy=${{ needs.deploy.result }}"}
```

### Release Workflow

```yaml
name: Release
on:
  push:
    branches: [main, staging]

jobs:
  tag_and_release:
    uses: your-org/templates/.github/workflows/Create-Tag-Release.yml@main
    with:
      source_branch: ${{ github.ref_name }}
      pre_release_branches: 'staging'
      release_branches: 'main'
      templates_repository: 'your-org/templates'

  deploy_after_release:
    needs: tag_and_release
    if: needs.tag_and_release.outputs.stable_tag != ''
    uses: your-org/templates/.github/workflows/Deploy-Firebase.yml@main
    with:
      repo_name: 'my-frontend'
      repo_owner_name: 'my-org'
      environment_name: 'production'
      npm_run_command: 'npm run build:prod'
      target_site: 'my-site'
      tag_name: ${{ needs.tag_and_release.outputs.stable_tag }}
    secrets:
      firebase_project_id: ${{ secrets.FIREBASE_PROJECT_ID }}
      firebase_service_account: ${{ secrets.FIREBASE_SA }}
      repo_token: ${{ secrets.GITHUB_TOKEN }}
```

---

## 8. Caller Migration Guide

This section documents **breaking and notable changes** so you know exactly what to update in your caller repo.

### Impact legend

| Symbol | Meaning |
|--------|---------|
| 🔴 | **Potentially breaking** — review and update |
| 🟡 | **Action recommended** — opt in to benefit |
| 🟢 | **Non-breaking** — no changes needed |

---

### Deploy workflows — `tag_name` now optional 🟢🟡

`tag_name` was `required: true`. It is now **optional** (default `'latest'`). Existing callers that pass an explicit `tag_name` continue to work unchanged.

**New behaviour:** omit `tag_name` and provide `source_branch` to auto-resolve the latest tag whose commit is reachable from that branch:

```yaml
# Old — caller had to know and pass the tag
with:
  tag_name: v1.4.2
  repo_name: my-app

# New — tag resolved automatically from the branch
with:
  source_branch: main      # only tags reachable from 'main' are considered
  repo_name: my-app
```

---

### Create-Tag-Release — comprehensive release notes 🟡

If you **forked** this repo, you must:
1. Copy `scripts/generate-release-notes.sh` into your fork
2. Add `templates_repository: your-org/your-fork` to your caller

If you use the repo directly, no change needed.

For best categorised release notes, use [Conventional Commits](https://www.conventionalcommits.org/):
`feat:`, `fix:`, `chore:`, `docs:`, `perf:`, `refactor:`, `BREAKING CHANGE:`

---

### `notify-system` — `message` must be valid JSON 🔴

The action now validates that `message` is valid JSON before sending. Callers passing plain-text strings will now fail.

```yaml
# Invalid — will fail
message: "Deployment complete"

# Valid
message: '{"text": "Deployment complete"}'
```

---

### `update-pr-description` — was silently broken, now works 🟡

The action previously had no `shell:` declarations and silently did nothing. It now actually updates PR descriptions. Verify your `pr_number`, `repository`, and `token` inputs are correct before the next run.

---

### `build-node` — Doppler secret names no longer logged 🟢

`doppler secrets --only-names` was removed. Secret names no longer appear in job logs. Use the CLI locally for debugging.

---

### `build-java` — debug artifact removed 🟢

The `maven-settings` artifact is no longer uploaded. Remove any step in your workflow that downloads it.

---

### Migration checklist

- [ ] **Deploy workflows**: remove hardcoded `tag_name`, add `source_branch` (optional)
- [ ] **Create-Tag-Release** (fork users): copy `scripts/generate-release-notes.sh`, add `templates_repository` input
- [ ] **notify-system**: ensure all `message` values are valid JSON
- [ ] **update-pr-description**: verify inputs — it now actually runs
- [ ] **build-java**: remove any step downloading `maven-settings` artifact

---

## 9. Best Practices

### Secrets

```yaml
# ✅ Use GitHub encrypted secrets
doppler_service_token: ${{ secrets.DOPPLER_TOKEN }}

# ❌ Never hardcode
doppler_service_token: "dp.st.xxx"
```

### Error handling

```yaml
# ✅ Allow tests to continue even on failure, process results anyway
- uses: .../cucumber-run-tests@main
  continue-on-error: true

- uses: .../test-results-consolidation@main
  if: always()
```

### Performance

```yaml
# ✅ Use parallel tests for large suites
uses: .../Run-Parallel-Tests.yml@main
with:
  max_tests_per_matrix: 5   # tune to balance job count vs parallelism
```

### Version pinning

```yaml
# ✅ Pin to a tag for stability
uses: your-org/templates/.github/workflows/Run-Tests.yml@v1.2.0

# ⚠️ @main gives latest features but less stability
uses: your-org/templates/.github/workflows/Run-Tests.yml@main
```

### Conventional commits (for release notes)

Use these prefixes so `Create-Tag-Release` produces categorised release notes:

| Prefix | Section in release notes |
|--------|--------------------------|
| `feat:` | ✨ New Features |
| `fix:` | 🐛 Bug Fixes |
| `perf:` | ⚡ Performance |
| `docs:` | 📚 Documentation |
| `chore:` / `ci:` / `build:` / `refactor:` / `test:` | 🔧 Maintenance |
| `BREAKING CHANGE:` or `feat!:` | 💥 Breaking Changes |

---

*Last updated: 2026-06-09*
