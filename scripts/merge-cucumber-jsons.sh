#!/bin/bash
# merge-cucumber-jsons.sh
# Merges all cucumber-*.json files from INPUT_DIR into a single JSON array
# in OUTPUT_DIR/cucumber.json.
#
# Usage: merge-cucumber-jsons.sh [INPUT_DIR] [OUTPUT_DIR]
#   INPUT_DIR   - directory containing cucumber-*.json artifacts (default: all-results)
#   OUTPUT_DIR  - directory to write the merged file into        (default: merged)

set -euo pipefail

INPUT_DIR="${1:-all-results}"
OUTPUT_DIR="${2:-merged}"
OUTPUT_FILE="$OUTPUT_DIR/cucumber.json"

mkdir -p "$OUTPUT_DIR"

# Collect files into a bash array to avoid subshell variable-scope issues
# with the pipe-into-while pattern.
mapfile -t FILES < <(find "$INPUT_DIR" -type f -name 'cucumber-*.json' | sort)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "WARNING: No cucumber-*.json files found in '$INPUT_DIR'. Writing empty array."
  echo "[]" > "$OUTPUT_FILE"
  echo "Merged 0 files into $OUTPUT_FILE"
  exit 0
fi

# Build merged JSON array without spawning subshells for the separator flag.
echo "[" > "$OUTPUT_FILE"
first=true

for file in "${FILES[@]}"; do
  # Strip the outer [ ] from each individual file.
  content=$(sed -e '1s/^\[//' -e '$s/\]$//' "$file")

  if [[ "$first" == "true" ]]; then
    printf '%s\n' "$content" >> "$OUTPUT_FILE"
    first="false"
  else
    printf ',\n%s\n' "$content" >> "$OUTPUT_FILE"
  fi
done

echo "]" >> "$OUTPUT_FILE"

echo "Merged ${#FILES[@]} file(s) into $OUTPUT_FILE"
