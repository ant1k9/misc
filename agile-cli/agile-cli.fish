#!/usr/bin/env fish
set NOTES_DIR "$HOME/.config/agile-cli"

function _agile_usage
    echo 'Usage:
    agile <project>
    agile show <any> # show the progress
    agile today      # current date
    agile week       # current week
    agile month      # current month
    agile year       # current year'
end

function _agile_adapt_filename
    set -l filename "$argv[1]"
    if test "$filename" = "today"
        date '+%Y-%m-%d.md'
    else if test "$filename" = "week"
        date '+%Y-w%V.md'
    else if test "$filename" = "month"
        date '+%Y-m%m.md'
    else if test "$filename" = "year"
        date '+%Y.md'
    else
        echo "$filename.md"
    end
end

# main
if test "$argv[1]" = "show"
    set filename "$argv[2]"
    set markdown_viewer (which glow 2>/dev/null)
    if test -z "$markdown_viewer"
        set markdown_viewer (which bat 2>/dev/null)
    end
    if test -z "$markdown_viewer"
        set markdown_viewer "cat"
    end
    set run_command "$markdown_viewer"
else
    set filename "$argv[1]"
    set run_command "$EDITOR"
end

if test -z "$filename"
    _agile_usage
    exit
end

set -l filename (_agile_adapt_filename "$filename")
$run_command "$NOTES_DIR/$filename"
