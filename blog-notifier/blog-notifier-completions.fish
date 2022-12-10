set -l _subcommands "-remove -explore -list -h"

complete -f -c blog-notifier \
    -n "not __fish_seen_subcommand_from $_subcommands" \
    -a "-remove" \
    -d "remove blog from the watch list"

complete -f -c blog-notifier \
    -n "not __fish_seen_subcommand_from $_subcommands" \
    -a "-explore" \
    -d "explore new blog"

complete -f -c blog-notifier \
    -n "not __fish_seen_subcommand_from $_subcommands" \
    -a "-list" \
    -d "list blogs from the watchlist"

complete -f -c blog-notifier \
    -n "not __fish_seen_subcommand_from $_subcommands" \
    -a "-h" \
    -d "help"
