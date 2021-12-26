#!/usr/bin/env fish

set LINKS_DB "links.sqlite3"

function _links_usage
    echo 'Newsletter usage:
    newsletter                      # gets 10 next links from newsletter db
    newsletter help                 # prints help command
    newsletter send                 # send one link to telegram channel
    newsletter serve                # serve links app as a web page
    newsletter stats                # gets current progress
    newsletter 5 --filter postgres  # gets next 5 links with filter by title'
end

function _links_send
    if test -z "$TELEGRAM_BOT_TOKEN"
        echo "Export telegram bot token to env"; and exit 1
    end
    if test -z "$TELEGRAM_CHANNEL"
        echo "Export telegram channel to env"; and exit 1
    end

    set -l MESSAGE_TEXT ( \
        sqlite3 "$LINKS_DB" \
        "SELECT title, href FROM links WHERE is_finished = 0 ORDER BY RANDOM() LIMIT 1" \
        | tr -d '"' \
    )
    set -l TITLE (echo "$MESSAGE_TEXT" | awk -F '|' '{ print $1 }')
    set -l LINK (echo "$MESSAGE_TEXT" | awk -F '|' '{ print $2 }')

    curl -i "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage?chat_id=$TELEGRAM_CHANNEL&text=$TITLE%0A$LINK" \
        | head -1 | grep 200; or exit 1
    sqlite3 "$LINKS_DB" "UPDATE links SET is_finished = 1 WHERE href = '\"$LINK\"'"
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

# send a link to telegram channel
if test "$argv" = "send"
    _links_send
    exit 0
end

# server the app by HTTP
if test "$argv" = "serve"
    newsletter-app
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
