set NOTES_DIR "$HOME/.local/share/agile-cli"

function _agile_notes
    echo -e "actualize\nclean\ndone\nundone\ntoday\ntomorrow\nweek\nmonth\nyear\nshow\nsync\rm"
    /bin/ls "$NOTES_DIR" | egrep '.md$' | sed 's/.md//g'
end

complete -f -c agile \
    -a "(_agile_notes)"
