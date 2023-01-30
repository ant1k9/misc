set NOTES_DIR "$HOME/.local/share/bookmarks"

function _list_link_titles
    set -l BOOKMARK_NAME (commandline | awk '{ print $2 }')
    if test -f "$NOTES_DIR/$BOOKMARK_NAME.md"
        for line in (grep -oP "\[\K(.*)]" "$NOTES_DIR/$BOOKMARK_NAME.md" | tr -d ']')
            echo "$line"
        end
    end
end

function _bookmarks_notes
    echo -e "add\nget\nrm\nshow\n"
    /bin/ls "$NOTES_DIR" | egrep '.md$' | sed 's/.md//g'
end

complete -f -c bookmarks \
    -n "not __fish_seen_subcommand_from add get rm show" \
    -a "(_bookmarks_notes)"

complete -f -c bookmarks \
    -n "__fish_seen_subcommand_from get" \
    -a "(_list_link_titles)"
