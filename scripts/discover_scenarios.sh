#!/bin/bash

TAG=$1
MAX=$2

cd test
echo "Discovering scenarios with tag: ${TAG}..."

# Run Cucumber dry-run with JSON plugin
mvn test -Dcucumber.filter.tags="${TAG}" -Dcucumber.execution.dry-run=true \
  -Dcucumber.plugin=json:target/cucumber-dry-run.json || true

# Extract scenario line numbers by tag
SCENARIOS=$(jq -r \
  '[.[] | .elements[] |
    select(.tags[]?.name == "'"$TAG"'") |
    "\(.uri):\(.line)"]' target/cucumber-dry-run.json)

COUNT=$(echo "$SCENARIOS" | jq 'length')

echo "Total scenarios found: $COUNT"
PER_JOB=$MAX
MATRIX="["

for ((i=0; i<COUNT; i+=PER_JOB)); do
  BATCH=$(echo "$SCENARIOS" | jq -c ".[$i:${i}+${PER_JOB}]")
  MATRIX+="{\"scenarios\":$BATCH},"
done

MATRIX="${MATRIX%,}]"

# Output for GitHub Actions
echo "matrix={\"include\":$MATRIX}" >> $GITHUB_OUTPUT
echo "Matrix: $MATRIX"
