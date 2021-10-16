LINK=$(
    curl "https://go.libhunt.com/newsletter" \
        | pup 'div:contains("Checkout") a:first-child attr{href}' \
)

curl "https://go.libhunt.com$LINK" \
    | pup 'li.project div div json{}' \
    | jq 'map({"link": .children[0].children[0].children[1].href, "description": .children[1].text }) | map(select(.link != null))' > "$LINKS_FILE"
