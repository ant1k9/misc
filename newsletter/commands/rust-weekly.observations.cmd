LINK=$(
    curl "https://this-week-in-rust.org/" \
        | pup 'div.post-title a attr{href}' \
        | head -1
)

curl "$LINK" \
    | pup 'h3:contains("Observations") + ul li json{}' \
    | jq 'map({"href": .children[0].href, "title": .children[0].text})' > "$LINKS_FILE"
