LINK=$(
    curl "https://go.libhunt.com/newsletter" \
        | pup 'div:contains("Checkout") a:first-child attr{href}' \
)

curl "https://go.libhunt.com$LINK" \
    | pup 'li.story :first-child :first-child json{}' \
    | jq 'map(({"href": .href, "title": .title})) | map(select(.title != null))' > "$LINKS_FILE"
