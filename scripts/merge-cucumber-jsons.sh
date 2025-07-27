#!/bin/bash

# Exit on error
set -e

# Directory where cucumber-*.json files are located
INPUT_DIR=${1:-"all-results"}

# Output file path
OUTPUT_DIR=${2:-"merged"}
OUTPUT_FILE="$OUTPUT_DIR/cucumber.json"

# Create output directory if not exists
mkdir -p "$OUTPUT_DIR"

# Start JSON array
echo "[" > "$OUTPUT_FILE"
first=true

# Find all cucumber-*.json files recursively
find "$INPUT_DIR" -type f -name 'cucumber-*.json' | while read -r file; do
  # Read and clean content (remove outer [ ])
  content=$(cat "$file" | sed -e '1s/^\[//' -e '$s/\]$//')

  if [ "$first" = true ]; then
    echo "$content" >> "$OUTPUT_FILE"
    first=false
  else
    echo "," >> "$OUTPUT_FILE"
    echo "$content" >> "$OUTPUT_FILE"
  fi
done

# Close JSON array
echo "]" >> "$OUTPUT_FILE"

echo "✅ Merged all cucumber-*.json into $OUTPUT_FILE"
