LINK=$(
    curl "https://www.cncf.io/kubeweekly/" \
        | pup 'div.kubeweekly-box a attr{href}' \
        | head -1
)

curl "$LINK" \
    | pup 'div#column-1-1 a json{}' \
    | jq 'map({"href": .href, "title": .text}) | map(select(.title != null))' > "$LINKS_FILE"
