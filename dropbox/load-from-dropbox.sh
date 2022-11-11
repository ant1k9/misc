#!/usr/bin/env bash
set -euo pipefail

PAYLOAD_FILE="$1"
DROPBOX_PATH=$DROPBOX_DIRECTORY/$(basename "$PAYLOAD_FILE")
: ${DROPBOX_TOKEN:=$DB_BACKUP_TOKEN}

curl -X POST https://content.dropboxapi.com/2/files/download \
    -H "Authorization: Bearer ${DROPBOX_TOKEN}" \
    -H "Dropbox-API-Arg: {\"path\": \"$DROPBOX_PATH\"}" \
    -o "$PAYLOAD_FILE"
