set NOTES_DIR "$HOME/.local/share/agile-cli"

function _agile_notes_commands
    echo -e "actualize\nadd\npop\nclean\ndone\nundone\nshow\nsync\nrm"
end

function _agile_notes_lists
    echo -e "today\ntomorrow\nweek\nmonth\nyear"
    /bin/ls "$NOTES_DIR" | egrep '.md$' | sed 's/.md//g'
end

function _list_tasks
    set -l AGILE_LIST_NAME (commandline | awk '{ print $2 }')
    if test -f "$NOTES_DIR/$AGILE_LIST_NAME.md"
        for line in (grep -oP "\[.\] \K(.*)" "$NOTES_DIR/$AGILE_LIST_NAME.md")
            echo "$line"
        end
    end
end

complete -f -c agile \
    -n "not __fish_seen_subcommand_from (_agile_notes_commands); and not __fish_seen_subcommand_from (_agile_notes_lists)" \
    -a "help"

complete -f -c agile \
    -n "not __fish_seen_subcommand_from (_agile_notes_lists)" \
    -a "(_agile_notes_lists)"

complete -f -c agile \
    -n "__fish_seen_subcommand_from (_agile_notes_lists); and not __fish_seen_subcommand_from (_agile_notes_commands)" \
    -a "(_agile_notes_commands)"

complete -f -c agile \
    -n "__fish_seen_subcommand_from pop" \
    -a "(_list_tasks)"
