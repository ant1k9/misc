set NOTES_DIR "$HOME/.local/share/agile-cli"

function _agile_notes_commands
    echo -e "add\npop\ndone\nundone\nshow\nsync\nrm"
end

function _agile_notes_lists
    echo -e "today\ntomorrow\nweek\nmonth\nyear"
    /bin/ls "$NOTES_DIR" | egrep '.md$' | sed 's/.md//g'
end

function _list_tasks
    set -l AGILE_LIST_NAME (commandline | awk '{ print $2 }')
    if test "$AGILE_LIST_NAME" = "today"
        set AGILE_LIST_NAME (date '+%Y-%m-%d')
    end

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
    -a "(_agile_notes_lists) actualize clean"

complete -f -c agile \
    -n "__fish_seen_subcommand_from (_agile_notes_lists); and not __fish_seen_subcommand_from (_agile_notes_commands)" \
    -a "(_agile_notes_commands)"

complete -f -c agile \
    -n "__fish_seen_subcommand_from pop done undone" \
    -a "(_list_tasks)"
