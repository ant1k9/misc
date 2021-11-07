set -l _kmap_commands get search

complete -f -c kmap \
    -n "not __fish_seen_subcommand_from $_kmap_commands" \
    -a get \
    -d "get knowledge-map info for github repo"

complete -f -c kmap \
    -n "not __fish_seen_subcommand_from $_kmap_commands" \
    -a search \
    -d "search throughout the knowledge-map for query"
