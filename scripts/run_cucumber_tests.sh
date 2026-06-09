#!/bin/bash
# run_cucumber_tests.sh
# Runs a Cucumber test suite via Maven Surefire rerun.
#
# Usage:
#   run_cucumber_tests.sh <scenario_string> <job_index> <env>
#                         <doppler_project_name> <doppler_token> <max_reruns>
#                         [headless_mode]
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

TEST_FAILED=0
cd test
echo "Starting test run for job index: $JOB_INDEX"
echo "Max Rerun Attempts: $MAX_RETRIES"
echo "Scenario: $SCENARIO_STRING"
echo "Headless: $HEADLESS"

mvn -Dsurefire.rerunFailingTestsCount="$MAX_RETRIES" clean test -q \
      -Dcucumber.features="$SCENARIO_STRING" \
      -Dcucumber.plugin="pretty,html:target/cucumber-${JOB_INDEX}.html,json:target/cucumber-${JOB_INDEX}.json,junit:target/cucumber-${JOB_INDEX}.xml" \
      -DENVIRONMENT="$TEST_ENV" \
      -DCONFIG_SOURCE=doppler \
      -DDOPPLER_PROJECT_NAME="$DOPPLER_PROJECT_NAME" \
      -DDOPPLER_SERVICE_TOKEN="$DOPPLER_SERVICE_TOKEN" \
      -Dheadless="$HEADLESS" || TEST_FAILED=1

if [ $TEST_FAILED -eq 1 ]; then
  echo "TEST_STATUS=FAILED" >> "$GITHUB_ENV"
else
  echo "TEST_STATUS=SUCCESS" >> "$GITHUB_ENV"
fi
