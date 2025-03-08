#!/bin/bash

set -e  # Exit if any command fails

SRC_ENV=$1
DEST_ENV=$2
FILE=$3

if [[ ! -f "$SRC_ENV" || ! -f "$DEST_ENV" || ! -f "$FILE" ]]; then
    echo "Error: One or more required files do not exist."
    exit 1
fi

# Read JSON values
SRC_MAPPINGS=$(jq -r '.AUTH0_KEYWORD_REPLACE_MAPPINGS' "$SRC_ENV")
DEST_MAPPINGS=$(jq -r '.AUTH0_KEYWORD_REPLACE_MAPPINGS' "$DEST_ENV")

# Extract keys and values
SRC_KEYS=$(echo "$SRC_MAPPINGS" | jq -r 'keys[]')

for KEY in $SRC_KEYS; do
    FROM=$(echo "$SRC_MAPPINGS" | jq -r --arg key "$KEY" '.[$key]')
    TO=$(echo "$DEST_MAPPINGS" | jq -r --arg key "$KEY" '.[$key]')

    if [[ -z "$FROM" || -z "$TO" || "$FROM" == "null" || "$TO" == "null" ]]; then
        echo "Skipping: Missing mapping for $KEY"
    else
        echo "Replacing: $FROM → $TO"
        sed -i "s|$FROM|$TO|g" "$FILE"
    fi
done

echo "Processing completed."
