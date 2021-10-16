curl -L "https://golangweekly.com/latest" \
    | pup 'td div a json{}' \
    | jq 'map(({"href": .href, "title": .text})) | map(select(.title != null))' > "$LINKS_FILE"
