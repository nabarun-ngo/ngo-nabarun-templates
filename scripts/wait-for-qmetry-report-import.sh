#!/bin/bash

set -e

TRACKING_ID="$1"
API_KEY="$2"

if [[ -z "$TRACKING_ID" || -z "$API_KEY" ]]; then
  echo "❌ Usage: ./wait-for-qmetry-import.sh <trackingId> <apiKey>"
  exit 1
fi

URL="https://qtmcloud.qmetry.com/rest/api/automation/importresult/track?trackingId=$TRACKING_ID"
HEADER_APIKEY="apiKey: $API_KEY"
HEADER_CT="Content-Type: application/json"

echo "⏳ Tracking QMetry import progress for trackingId: $TRACKING_ID"
echo "📅 Timeout in 5 minutes (60 attempts, 5 seconds interval)"

attempt=0
max_attempts=60

while [ $attempt -lt $max_attempts ]; do
  attempt=$((attempt + 1))
  echo "🔄 Attempt $attempt..."

  RESPONSE=$(curl -s -H "$HEADER_CT" -H "$HEADER_APIKEY" -X GET "$URL")
  IMPORT_STATUS=$(echo "$RESPONSE" | jq -r '.importStatus')
  PROCESS_STATUS=$(echo "$RESPONSE" | jq -r '.processStatus')

  echo "   → Status: $IMPORT_STATUS ($PROCESS_STATUS)"

  if [[ "$IMPORT_STATUS" == "SUCCESS" ]]; then
    echo "✅ QMetry import completed successfully."
    exit 0
  elif [[ "$IMPORT_STATUS" == "FAILED" ]]; then
    echo "❌ QMetry import failed!"
    echo "$RESPONSE"
    exit 1
  fi

  sleep 5
done

echo "⏰ Timeout! QMetry import did not complete within 5 minutes."
exit 1
