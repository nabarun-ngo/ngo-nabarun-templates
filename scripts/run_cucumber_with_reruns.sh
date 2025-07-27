#!/bin/bash

# Usage:
# ./run_cucumber_with_reruns.sh "<scenario_string>" <job_index> <env> <doppler_project_name> <doppler_token> <max_reruns>

set -e

SCENARIO_STRING="$1"
JOB_INDEX="$2"
TEST_ENV="$3"
DOPPLER_PROJECT_NAME="$4"
DOPPLER_SERVICE_TOKEN="$5"
MAX_RETRIES="$6"

ATTEMPT=0
TEST_FAILED=0
cd test
echo "🏁 Starting test run for job index: $JOB_INDEX"
echo "🔢 Max Rerun Attempts: $MAX_RETRIES"
echo "📋 Scenarios: $SCENARIO_STRING"

while [ $ATTEMPT -le $MAX_RETRIES ]; do
  if [ $ATTEMPT -eq 0 ]; then
    echo "🧪 Initial Run..."
    mvn clean test -q \
      -Dcucumber.features="$SCENARIO_STRING" \
      -Dcucumber.plugin="pretty,html:target/cucumber-${JOB_INDEX}.html,json:target/cucumber-${JOB_INDEX}.json,rerun:target/rerun-${JOB_INDEX}.txt" \
      -DENVIRONMENT=$TEST_ENV \
      -DCONFIG_SOURCE=doppler \
      -DDOPPLER_PROJECT_NAME=$DOPPLER_PROJECT_NAME \
      -DDOPPLER_SERVICE_TOKEN=$DOPPLER_SERVICE_TOKEN || TEST_FAILED=1
  else
    if [ -s "target/rerun-${JOB_INDEX}.txt" ]; then
      echo "🔁 Rerun Attempt $ATTEMPT..."
      mvn test -q \
        -Dcucumber.features="@target/rerun-${JOB_INDEX}.txt" \
        -Dcucumber.plugin="pretty,html:target/cucumber-rerun-${ATTEMPT}-${JOB_INDEX}.html,json:target/cucumber-rerun-${ATTEMPT}-${JOB_INDEX}.json,rerun:target/rerun-${JOB_INDEX}.txt" \
        -DENVIRONMENT=$TEST_ENV \
        -DCONFIG_SOURCE=doppler \
        -DDOPPLER_PROJECT_NAME=$DOPPLER_PROJECT_NAME \
        -DDOPPLER_SERVICE_TOKEN=$DOPPLER_SERVICE_TOKEN || TEST_FAILED=1
      rm -f "target/rerun-${JOB_INDEX}.txt"
    else
      echo "✅ No failed scenarios to rerun. Breaking early."
      break
    fi
  fi
  ATTEMPT=$((ATTEMPT + 1))
done

if [ $TEST_FAILED -eq 1 ]; then
  echo "TEST_STATUS=FAILED" >> $GITHUB_ENV
else
  echo "TEST_STATUS=SUCCESS" >> $GITHUB_ENV
fi
