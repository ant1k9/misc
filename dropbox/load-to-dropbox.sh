#!/usr/bin/env bash
set -euo pipefail

DB_BACKUP_ARCHIVE="$1"
DROPBOX_PATH=${DB_BACKUP_ARCHIVE/\/tmp/$DROPBOX_DIRECTORY}

curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $DB_BACKUP_TOKEN" \
    --header "Content-Type: application/octet-stream" \
    --header "Dropbox-API-Arg: {\"path\": \"$DROPBOX_PATH\",\"mode\": \"add\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
    --data-binary @"$DB_BACKUP_ARCHIVE"

rm "$DB_BACKUP_ARCHIVE"
