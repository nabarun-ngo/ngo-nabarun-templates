#!/bin/bash

# Usage:
# ./run_cucumber_tests.sh "<scenario_string>" <job_index> <env> <doppler_project_name> <doppler_token> <max_reruns>

set -e

SCENARIO_STRING="$1"
JOB_INDEX="$2"
TEST_ENV="$3"
DOPPLER_PROJECT_NAME="$4"
DOPPLER_SERVICE_TOKEN="$5"
MAX_RETRIES="$6"

TEST_FAILED=0
cd test
echo "🏁 Starting test run for job index: $JOB_INDEX"
echo "🔢 Max Rerun Attempts: $MAX_RETRIES"
echo "🔢 Scenario: $SCENARIO_STRING"

mvn -Dsurefire.rerunFailingTestsCount=$MAX_RETRIES clean test -q \
      -Dcucumber.features=$SCENARIO_STRING \
      -Dcucumber.plugin="pretty,html:target/cucumber-${JOB_INDEX}.html,json:target/cucumber-${JOB_INDEX}.json,junit:target/cucumber-${JOB_INDEX}.xml" \
      -DENVIRONMENT=$TEST_ENV \
      -DCONFIG_SOURCE=doppler \
      -DDOPPLER_PROJECT_NAME=$DOPPLER_PROJECT_NAME \
      -DDOPPLER_SERVICE_TOKEN=$DOPPLER_SERVICE_TOKEN \
      -Dheadless=Y || TEST_FAILED=1

if [ $TEST_FAILED -eq 1 ]; then
  echo "TEST_STATUS=FAILED" >> $GITHUB_ENV
else
  echo "TEST_STATUS=SUCCESS" >> $GITHUB_ENV
fi
