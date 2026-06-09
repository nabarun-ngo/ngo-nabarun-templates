#!/bin/bash
# run_cucumber_with_reruns.sh
#
# DEPRECATED — use the cucumber-run-tests composite action instead.
# The action uses Maven Surefire (-Dsurefire.rerunFailingTestsCount) which is
# the canonical rerun strategy for this template library. This script uses the
# Cucumber rerun plugin and is kept only for reference.
#
# Usage:
#   run_cucumber_with_reruns.sh <scenario_string> <job_index> <env>
#                               <doppler_project_name> <doppler_token>
#                               <max_reruns> [headless_mode]
#
#   headless_mode - Y or N (default: N); reads HEADLESS_MODE env var as fallback.

set -e

SCENARIO_STRING="${1:?arg 1 (scenario_string) required}"
JOB_INDEX="${2:?arg 2 (job_index) required}"
TEST_ENV="${3:?arg 3 (test environment) required}"
DOPPLER_PROJECT_NAME="${4:?arg 4 (doppler_project_name) required}"
DOPPLER_SERVICE_TOKEN="${5:?arg 5 (doppler_service_token) required}"
MAX_RETRIES="${6:?arg 6 (max_reruns) required}"
HEADLESS="${7:-${HEADLESS_MODE:-N}}"

ATTEMPT=0
TEST_FAILED=0
cd test
echo "Starting test run for job index: $JOB_INDEX"
echo "Max Rerun Attempts: $MAX_RETRIES"
echo "Scenarios: $SCENARIO_STRING"
echo "Headless: $HEADLESS"

while [ $ATTEMPT -le "$MAX_RETRIES" ]; do
  if [ $ATTEMPT -eq 0 ]; then
    echo "Initial Run..."
    mvn clean test -q \
      -Dcucumber.features="$SCENARIO_STRING" \
      -Dcucumber.plugin="pretty,html:target/cucumber-${JOB_INDEX}.html,json:target/cucumber-${JOB_INDEX}.json,rerun:target/rerun-${JOB_INDEX}.txt" \
      -DENVIRONMENT="$TEST_ENV" \
      -DCONFIG_SOURCE=doppler \
      -DDOPPLER_PROJECT_NAME="$DOPPLER_PROJECT_NAME" \
      -DDOPPLER_SERVICE_TOKEN="$DOPPLER_SERVICE_TOKEN" \
      -Dheadless="$HEADLESS" || TEST_FAILED=1
  else
    if [ -s "target/rerun-${JOB_INDEX}.txt" ]; then
      echo "Rerun Attempt $ATTEMPT..."
      mvn test -q \
        -Dcucumber.features="@target/rerun-${JOB_INDEX}.txt" \
        -Dcucumber.plugin="pretty,html:target/cucumber-rerun-${ATTEMPT}-${JOB_INDEX}.html,json:target/cucumber-rerun-${ATTEMPT}-${JOB_INDEX}.json,rerun:target/rerun-${JOB_INDEX}.txt" \
        -DENVIRONMENT="$TEST_ENV" \
        -DCONFIG_SOURCE=doppler \
        -DDOPPLER_PROJECT_NAME="$DOPPLER_PROJECT_NAME" \
        -DDOPPLER_SERVICE_TOKEN="$DOPPLER_SERVICE_TOKEN" \
        -Dheadless="$HEADLESS" || TEST_FAILED=1
      rm -f "target/rerun-${JOB_INDEX}.txt"
    else
      echo "No failed scenarios to rerun. Breaking early."
      break
    fi
  fi
  ATTEMPT=$((ATTEMPT + 1))
done

if [ $TEST_FAILED -eq 1 ]; then
  echo "TEST_STATUS=FAILED" >> "$GITHUB_ENV"
else
  echo "TEST_STATUS=SUCCESS" >> "$GITHUB_ENV"
fi
