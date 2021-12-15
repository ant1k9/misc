#!/usr/bin/env fish

set -l _newsletter_commands help send serve stats

complete -f -c newsletter \
    -n "not __fish_seen_subcommand_from $_newsletter_commands" \
    -a help \
    -d "prints help command"

complete -f -c newsletter \
    -n "not __fish_seen_subcommand_from $_newsletter_commands" \
    -a send \
    -d "send one link to telegram channel"

complete -f -c newsletter \
    -n "not __fish_seen_subcommand_from $_newsletter_commands" \
    -a serve \
    -d "serve links app as a web page"

complete -f -c newsletter \
    -n "not __fish_seen_subcommand_from $_newsletter_commands" \
    -a stats \
    -d "gets current progress"

complete -f -c newsletter
    -n "not __fish_seen_subcommand_from $_newsletter_commands" \
    -l "filter" \
    -d "gets next 10 links with filter by title"
