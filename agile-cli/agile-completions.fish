set NOTES_DIR "$HOME/.local/share/agile-cli"

function _agile_notes
    echo -e "actualize\nadd\nclean\ndone\nundone\ntoday\ntomorrow\nweek\nmonth\nyear\nshow\nsync\nrm"
    /bin/ls "$NOTES_DIR" | egrep '.md$' | sed 's/.md//g'
end

complete -f -c agile \
    -a "(_agile_notes)"
