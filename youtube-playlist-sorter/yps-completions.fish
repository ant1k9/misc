#!/usr/bin/env fish
set -l _yps_commands ( \
    sqlite3 -csv "$HOME/.config/yps/playlists.sqlite3" \
    "SELECT DISTINCT playlist_id FROM playlists" \
)

function _yps_order_by 
    echo -e "views\nlikes"
end

if ! test -z (echo $_yps_commands)
    for cmd in $_yps_commands
        complete -f -c yps \
            -n "not __fish_seen_subcommand_from $_yps_commands" \
            -a "$cmd"
    end
end

complete -f -c yps \
    -l limit \
    -d "limit output to n records"

complete -f -c yps \
    -l order-by \
    -a "(_yps_order_by)" \
    -d "order the output by field"
