LINK=$(
    curl "https://sreweekly.com/" \
        | pup 'h2 a attr{href}' \
        | head -1
)

curl "$LINK" \
    | pup 'div.sreweekly-entry a json{}' \
    | jq 'map({"href": .href, "title": .text}) | map(select(.title != null))' > "$LINKS_FILE"
