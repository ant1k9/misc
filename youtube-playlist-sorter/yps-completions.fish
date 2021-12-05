#!/usr/bin/env fish
function _yps_commands
    sqlite3 -csv "$HOME/.config/yps/playlists.sqlite3" \
        "SELECT DISTINCT name FROM playlists"
end

function _yps_order_by
    echo -e "views\nlikes"
end

complete -f -c yps \
    -n "not __fish_seen_subcommand_from (_yps_commands)" \
    -a "(_yps_commands)"

complete -f -c yps \
    -l limit \
    -d "limit output to n records"

complete -f -c yps \
    -l playlist-id \
    -d "pass playlist-id to download data for it"

complete -f -c yps \
    -l order-by \
    -a "(_yps_order_by)" \
    -d "order the output by field"
