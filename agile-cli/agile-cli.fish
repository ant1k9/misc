#!/usr/bin/env fish
set NOTES_DIR "$HOME/.local/share/agile-cli"

function _agile_usage
    echo 'Usage:
    agile <project>
    agile show <any> # show the progress
    agile today      # current date
    agile week       # current week
    agile month      # current month
    agile year       # current year'
end

set _today_pattern '+%Y-%m-%d.md'
set _week_pattern  '+%Y-w%V.md'
set _month_pattern '+%Y-m%m.md'
set _year_pattern  '+%Y.md'

function _agile_adapt_filename
    set -l filename "$argv[1]"
    if test "$filename" = "today"
        date "$_today_pattern"
    else if test "$filename" = "week"
        date "$_week_pattern"
    else if test "$filename" = "month"
        date "$_month_pattern"
    else if test "$filename" = "year"
        date "$_year_pattern"
    else
        echo "$filename.md"
    end
end

function _agile_actualize
    set -l date_pattern "$argv[1]"
    set -l file_pattern "$argv[2]"
    set today (date "$date_pattern")

    for file in (/bin/ls "$NOTES_DIR/" | egrep "$file_pattern")
        if test (sh -c "[[ '$file' < '$today' ]] && echo 1")
            grep '\[ \]' "$NOTES_DIR/$file" >> "$NOTES_DIR/$today"; \
                and sed -i'.bak' '/\[ \]/d' "$NOTES_DIR/$file"
        end
    end
end

# main
if test "$argv[2]" = "show"
    set filename "$argv[1]"
    set markdown_viewer (which glow 2>/dev/null)
    if test -z "$markdown_viewer"
        set markdown_viewer (which bat 2>/dev/null)
    end
    if test -z "$markdown_viewer"
        set markdown_viewer "cat"
    end
    alias run_command="$markdown_viewer"
else if test "$argv[2]" = "done" -o "$argv[2]" = "undone"
    set filename "$argv[1]"
    if test (count $argv) -ne 3
        _agile_usage
        exit
    end
    if test "$argv[2]" = "done"
        alias run_command="sed -i'.bak' '/$argv[3]/s/\[ \]/\[x\]/g'"
    else
        alias run_command="sed -i'.bak' '/$argv[3]/s/\[x\]/\[ \]/g'"
    end
else if test "$argv[1]" = "actualize"
    # cleaning .bak files to prevent double accounting
    find "$NOTES_DIR" -name '*.bak' -exec rm '{}' \;
    _agile_actualize "$_today_pattern" "[0-9]{4}-[0-9]{2}-[0-9]{2}.md"
    _agile_actualize "$_week_pattern"  "[0-9]{4}-w[0-9]{2}.md"
    _agile_actualize "$_month_pattern" "[0-9]{4}-m[0-9]{2}.md"
    _agile_actualize "$_year_pattern"  "[0-9]{4}.md"
    # cleaning .bak files after finish changing files
    find "$NOTES_DIR" -name '*.bak' -exec rm '{}' \;
    exit
else
    set filename "$argv[1]"
    alias run_command="$EDITOR"
end

if test -z "$filename"
    _agile_usage
    exit
end

set -l filename (_agile_adapt_filename "$filename")
run_command "$NOTES_DIR/$filename"
