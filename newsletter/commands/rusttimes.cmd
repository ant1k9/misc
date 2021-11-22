curl -L "https://www.rusttimes.com/" \
    -H 'authority: www.rusttimes.com' \
    -H 'accept-language: en-US,en;q=0.9' \
    --compressed \
    | pup 'div#articles div.articles-content json{}' \
    | jq 'map({"title": .children[0].text, "href": .children[3].children[0].children[0].children[0].children[0].href})' > "$LINKS_FILE"
