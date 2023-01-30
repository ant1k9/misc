set NOTES_DIR "$HOME/.local/share/bookmarks"

function _bookmarks_notes
    echo -e "add\nrm\nshow\n"
    /bin/ls "$NOTES_DIR" | egrep '.md$' | sed 's/.md//g'
end

complete -f -c bookmarks \
    -a "(_bookmarks_notes)"
