#!/bin/bash
# wait-for-qmetry-report-import.sh
# Polls QMetry until an import job completes or times out.
#
# Usage: wait-for-qmetry-report-import.sh <trackingId> <apiKey> [qmetry_base_url]
#   trackingId      - QMetry import tracking ID
#   apiKey          - QMetry API key
#   qmetry_base_url - optional base URL (default: https://qtmcloud.qmetry.com)

set -e

TRACKING_ID="${1:?Usage: wait-for-qmetry-report-import.sh <trackingId> <apiKey> [qmetry_base_url]}"
API_KEY="${2:?Usage: wait-for-qmetry-report-import.sh <trackingId> <apiKey> [qmetry_base_url]}"
QMETRY_BASE_URL="${3:-https://qtmcloud.qmetry.com}"

URL="${QMETRY_BASE_URL}/rest/api/automation/importresult/track?trackingId=${TRACKING_ID}"
HEADER_APIKEY="apiKey: $API_KEY"
HEADER_CT="Content-Type: application/json"

echo "Tracking QMetry import progress for trackingId: $TRACKING_ID"
echo "QMetry base URL: $QMETRY_BASE_URL"
echo "Timeout in 5 minutes (60 attempts, 5 seconds interval)"

attempt=0
max_attempts=60

while [ $attempt -lt $max_attempts ]; do
  attempt=$((attempt + 1))
  echo "Attempt $attempt..."

  RESPONSE=$(curl -s -H "$HEADER_CT" -H "$HEADER_APIKEY" -X GET "$URL")
  IMPORT_STATUS=$(echo "$RESPONSE" | jq -r '.importStatus')
  PROCESS_STATUS=$(echo "$RESPONSE" | jq -r '.processStatus')

  echo "   Status: $IMPORT_STATUS ($PROCESS_STATUS)"

  if [[ "$IMPORT_STATUS" == "SUCCESS" ]]; then
    echo "QMetry import completed successfully."
    exit 0
  elif [[ "$IMPORT_STATUS" == "FAILED" ]]; then
    echo "QMetry import failed!"
    echo "$RESPONSE"
    exit 1
  fi

  sleep 5
done

echo "Timeout! QMetry import did not complete within 5 minutes."
exit 1
