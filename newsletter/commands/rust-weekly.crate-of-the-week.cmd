LINK=$(
    curl "https://this-week-in-rust.org/" \
        | pup 'div.post-title a attr{href}' \
        | head -1
)

curl "$LINK" \
    | pup 'h2:contains("Crate of the Week") + p a json{}' \
    | jq 'map({"href": .href, "title": .text})' > "$LINKS_FILE"
