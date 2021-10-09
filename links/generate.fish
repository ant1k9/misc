#!/usr/bin/env fish

set -l LIMIT 10
if test (count $argv) -eq 1
    set LIMIT "$argv[1]"
end

for href in ( \
    sqlite3 links.sqlite3 \
    "SELECT href FROM links WHERE is_finished = 0 ORDER BY RANDOM() LIMIT $LIMIT" \
)
    open (echo $href | tr -d '"')
    sqlite3 "links.sqlite3" \
        "UPDATE links SET is_finished = 1 WHERE href = '$href'" || true
end
