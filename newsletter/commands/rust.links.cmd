LINK=$(
    curl "https://rust.libhunt.com/newsletter" \
        | pup 'div:contains("Checkout") a:first-child attr{href}' \
)

curl "https://rust.libhunt.com$LINK" \
    | pup 'li.project div div json{}' \
    | jq 'map({"href": .children[0].children[0].children[1].href, "title": .children[1].text }) | map(select(.href != null and .title != null))' > "$LINKS_FILE"
