#!/usr/bin/env fish
set NOTES_DIR "$HOME/.local/share/bookmarks"

function _bookmarks_usage
    echo 'Usage:
    bookmarks <project>
    bookmarks <project> add <name>
    bookmarks <project> add <name> <link>
    bookmarks <project> rm
    bookmarks <project> show'
end

function _bookmarks_adapt_filename
    echo "$filename.md"
end

function _add_bookmark
    set -l filename "$argv[1]"
    set -l title "$argv[2]"
    set -l link "$argv[3]"
    if test -z "$title"
        echo "provide bookmark title"
    else if test -z "$link"
        echo "- $title" >> $filename
    else
        echo "- [$title]($link)" >> $filename
    end
end

function _get_link
    set -l filename "$argv[1]"
    set -l title "$argv[2]"
    grep "$title" "$filename" | grep -oP '\(\K([^\)]+)'
end

# main
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
else if test "$argv[2]" = "add"
    _add_bookmark "$NOTES_DIR"/(_bookmarks_adapt_filename "$filename") "$argv[3]" "$argv[4]"
    exit
else if test "$argv[2]" = "get"
    if ! test -z "$argv[3]"
        _get_link "$NOTES_DIR"/(_bookmarks_adapt_filename "$filename") "$argv[3..]"
    end
    exit
else if test "$argv[2]" = "rm"
    alias run_command="rm"
else
    alias run_command="$EDITOR"
end

if test -z "$filename"
    _bookmarks_usage
    exit
end

set -l filename (_bookmarks_adapt_filename "$filename")
run_command "$NOTES_DIR/$filename"
