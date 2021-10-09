#!/usr/bin/env fish

for i in (seq (jq ". | length" < "$argv[1]"))
    set -l href (jq ".[$i].href" < "$argv[1]")
    set -l title (jq ".[$i].title" < "$argv[1]")
    sqlite3 "links.sqlite3" \
        "INSERT INTO links (href, title, is_finished) VALUES ('$href', '$title', 0)" || true
end
