#!/bin/bash

TAG=$1
MAX=$2

cd test
echo "Discovering scenarios with tag: ${TAG}..."

# Run Cucumber dry-run with JSON plugin
mvn clean test -q -Dcucumber.filter.tags="${TAG}" -Dcucumber.execution.dry-run=true \
  -Dcucumber.plugin=json:target/cucumber.json || true

# echo "Listing all files in workspace:"
# find . -type f | sort

# Extract scenario line numbers by tag
SCENARIOS=$(jq -r \
  --arg tag "$TAG" '
  [ .[] as $feature
    | $feature.elements[]
    | select(.tags[]?.name == $tag)
    | "\($feature.uri):\(.line)"
  ]' target/cucumber.json)

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
