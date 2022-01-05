set NOTES_DIR "$HOME/.config/agile-cli"

function _agile_notes
    echo -e "actualize\ndone\nundone\ntoday\nweek\nmonth\nyear\nshow"
    /bin/ls "$NOTES_DIR" | sed 's/.md//g'
end

complete -f -c agile \
    -a "(_agile_notes)"