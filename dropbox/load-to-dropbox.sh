#!/usr/bin/env bash
set -euo pipefail

PAYLOAD_FILE="$1"
DROPBOX_PATH=${PAYLOAD_FILE/\/tmp/$DROPBOX_DIRECTORY}
: ${DROPBOX_TOKEN:=$DB_BACKUP_TOKEN}

curl -X POST https://api.dropboxapi.com/2/files/delete_v2 \
    --header "Authorization: Bearer $DROPBOX_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{\"path\": \"$DROPBOX_PATH\"}" || true

curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $DROPBOX_TOKEN" \
    --header "Content-Type: application/octet-stream" \
    --header "Dropbox-API-Arg: {\"path\": \"$DROPBOX_PATH\",\"mode\": \"add\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
    --data-binary @"$PAYLOAD_FILE"

rm "$PAYLOAD_FILE"
