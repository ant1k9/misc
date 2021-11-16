set -l _misc_commands install update list

complete -f -c misc \
    -n "not __fish_seen_subcommand_from $_misc_commands" \
    -a list \
    -d "list available programs"

complete -f -c misc \
    -n "not __fish_seen_subcommand_from $_misc_commands" \
    -a update \
    -d "update misc repo"

complete -f -c misc \
    -n "not __fish_seen_subcommand_from $_misc_commands" \
    -a install \
    -d "install scripts"

complete -f -c misc \
    -n "__fish_seen_subcommand_from install" \
    -a "(misc list)"
