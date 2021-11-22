curl -L "https://dbweekly.com/issues/" \
    | pup 'td p span a json{}' \
    | jq 'map(({"href": .href, "title": .text})) | map(select(.title != null))' > "$LINKS_FILE"
