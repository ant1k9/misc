#!/usr/bin/env fish

set LINKS_DB "links.sqlite3"

function _links_usage
    echo 'Newsletter usage:
    newsletter                      # gets 10 next links from newsletter db
    newsletter help                 # prints help command
    newsletter stats                # gets current progress
    newsletter 5 --filter postgres  # gets next 5 links with filter by title'
end

function _links_stats
    set -l finished (sqlite3 "$LINKS_DB" "SELECT COUNT(1) FROM links WHERE is_finished")
    set -l total (sqlite3 "$LINKS_DB" "SELECT COUNT(1) FROM links")
    printf "[%i/%i] %.3f%%\n" "$finished" "$total" (echo "$finished/$total*100" | bc -l)
end

function _generate_links
    set -l LIMIT "$argv[1]"

    set -l FILTER "1 = 1"
    if test (count $argv) = 2
        set FILTER "title LIKE '%$argv[2]%'"
    end

    for href in ( \
        sqlite3 "$LINKS_DB" \
        "SELECT href FROM links WHERE is_finished = 0 AND $FILTER ORDER BY RANDOM() LIMIT $LIMIT" \
    )
        open (echo $href | tr -d '"')
        sqlite3 "$LINKS_DB" \
            "UPDATE links SET is_finished = 1 WHERE href = '$href'" || true
    end
end

# print usage
if test "$argv" = "help"
    _links_usage
    exit 0
end

# print stats
if test "$argv" = "stats"
    _links_stats
    exit 0
end

# open links in browser
set -l LIMIT 10
if test (count $argv) -ge 1
    set LIMIT "$argv[1]"
end

argparse \
    'filter=' -- $argv

_generate_links "$LIMIT" "$_flag_filter"
