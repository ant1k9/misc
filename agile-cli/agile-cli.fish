#!/usr/bin/env fish
set NOTES_DIR "$HOME/.local/share/agile-cli"
set FILESERVER_BASE_URL "http://$PERSONAL_SERVER_HOST/agile/"

function _agile_usage
    echo 'Usage:
    agile <project>
    agile today                   # current date
    agile tomorrow                # next day
    agile week                    # current week
    agile month                   # current month
    agile year                    # current year
    agile <any> show              # show the progress
    agile <any> add               # add a task to the list
    agile <any> rm                # remove file with progress
    agile actualize               # move undone tasks to current date
    agile <any> sync              # sync data with server
    agile <any> done   <pattern>  # mark the task matched by pattern as done
    agile <any> undone <pattern>  # mark the task matched by pattern as not done'
end

set _today_pattern '+%Y-%m-%d.md'
set _week_pattern  '+%Y-w%V.md'
set _month_pattern '+%Y-m%m.md'
set _year_pattern  '+%Y.md'

function _agile_adapt_filename
    set -l filename "$argv[1]"
    if test "$filename" = "today"
        date "$_today_pattern"
    else if test "$filename" = "tomorrow"
        date --date tomorrow "$_today_pattern"
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

function _agile_clean
    for file in (/bin/ls "$NOTES_DIR/" | egrep "*.md")
        grep '\[ \]' "$NOTES_DIR/$file" >/dev/null
        if test $status -ne 0
            echo remove "$file"
            rm "$NOTES_DIR/$file"
        end
    end
end

function _sync_with_server
    set -l filename "$argv[1]"

    echo "provide user:password pair"
    read -s pass
    set -l credentials (echo -n "$pass" | base64)

    curl -I "$FILESERVER_BASE_URL/$filename" \
        -H "Authorization: Basic $credentials" 2>/dev/null \
        | head -1 | grep 'File not found' > /dev/null
    if test $status -ne 0
        curl "$FILESERVER_BASE_URL/$filename" \
            -H "Authorization: Basic $credentials" \
            -o "/tmp/$filename" 2>/dev/null
        for line in (cat "/tmp/$filename")
            set line (string split ']' "$line" -m1 -f2)
            grep -F "$line" "$NOTES_DIR/$filename" >/dev/null
            if test $status -ne 0
                echo "$line" >> "$NOTES_DIR/$filename"
            end
        end
    end

    $EDITOR "$NOTES_DIR/$filename"

    curl -XPOST "$FILESERVER_BASE_URL/upload" \
        -H "Authorization: Basic $credentials" \
        -F "files=@$NOTES_DIR/$filename" 2>/dev/null
end

# main
set _make_sort 1
set filename "$argv[1]"

if test "$argv[2]" = "show"
    set -e _make_sort
    set markdown_viewer (which glow 2>/dev/null)" -s auto "
    if test -z "$markdown_viewer"
        set markdown_viewer (which bat 2>/dev/null)
    end
    if test -z "$markdown_viewer"
        set markdown_viewer "cat"
    end
    alias run_command="$markdown_viewer"
else if test "$argv[2]" = "done" -o "$argv[2]" = "undone"
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
else if test "$argv[1]" = "clean"
    _agile_clean
    exit
else if test "$argv[2]" = "sync"
    _sync_with_server (_agile_adapt_filename "$filename")
    exit
else if test "$argv[2]" = "add"
    echo "1. [ ] $argv[3..]" >> "$NOTES_DIR"/(_agile_adapt_filename "$filename")
    exit
else if test "$argv[2]" = "rm"
    alias run_command="rm"
else
    alias run_command="$EDITOR"
end

if test -z "$filename"
    _agile_usage
    exit
end

set -l filename (_agile_adapt_filename "$filename")
run_command "$NOTES_DIR/$filename"

if test -f "$NOTES_DIR/$filename" -a -n "$_make_sort"
    sort -srk2 "$NOTES_DIR/$filename" > "$NOTES_DIR/$filename.bak"
    mv "$NOTES_DIR/$filename.bak" "$NOTES_DIR/$filename"
end
