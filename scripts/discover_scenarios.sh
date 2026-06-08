#!/bin/bash
# discover_scenarios.sh
# Discovers Cucumber scenarios by tag and writes a GitHub Actions matrix output.
#
# Usage: discover_scenarios.sh <TAG> <MAX_PER_JOB>
#   TAG          - Cucumber tag to filter (with or without leading '@')
#   MAX_PER_JOB  - maximum scenarios per matrix job

set -euo pipefail

RAW_TAG="${1:?Usage: discover_scenarios.sh <TAG> <MAX_PER_JOB>}"
MAX="${2:?Usage: discover_scenarios.sh <TAG> <MAX_PER_JOB>}"

# Normalize: strip leading '@' then always add exactly one '@'
TAG="@${RAW_TAG#@}"

cd test
echo "Discovering scenarios with tag: ${TAG}..."

# Run Cucumber dry-run with JSON plugin
mvn clean test -q \
  -Dcucumber.filter.tags="${TAG}" \
  -Dcucumber.execution.dry-run=true \
  -Dcucumber.plugin=json:target/cucumber.json || true

# Extract scenario line numbers — use the normalized tag so the selector
# matches regardless of whether the JSON stores '@smoke' or 'smoke'.
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

echo "matrix={\"include\":$MATRIX}" >> "$GITHUB_OUTPUT"
echo "Matrix: $MATRIX"
