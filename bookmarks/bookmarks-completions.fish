set NOTES_DIR "$HOME/.local/share/bookmarks"

function _list_link_titles
    set -l BOOKMARK_NAME (commandline | awk '{ print $2 }')
    if test -f "$NOTES_DIR/$BOOKMARK_NAME.md"
        set -l counter 1
        for line in (grep -oP "\[\K(.*)]" "$NOTES_DIR/$BOOKMARK_NAME.md" | tr -d ']')
            echo "$counter. $line"
            set -l counter (math "$counter + 1")
        end
    end
end

function _bookmarks_notes
    /bin/ls "$NOTES_DIR" | egrep '.md$' | sed 's/.md//g'
end

function _bookmarks_commands
    echo -e "add\nget\nopen\nrm\nshow"
end

complete -f -c bookmarks \
    -n "not __fish_seen_subcommand_from (_bookmarks_notes); and not __fish_seen_subcommand_from (_bookmarks_commands)" \
    -a "help"

complete -f -c bookmarks \
    -n "not __fish_seen_subcommand_from (_bookmarks_notes)" \
    -a "(_bookmarks_notes)"

complete -f -c bookmarks \
    -n "__fish_seen_subcommand_from (_bookmarks_notes); and not __fish_seen_subcommand_from (_bookmarks_commands)" \
    -a "(_bookmarks_commands)"

complete -f -c bookmarks \
    -n "__fish_seen_subcommand_from get open" \
    -a "(_list_link_titles)"
