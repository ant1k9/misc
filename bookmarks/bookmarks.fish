#!/usr/bin/env fish
set NOTES_DIR "$HOME/.local/share/bookmarks"
if set -q BOOKMARKS_NOTES_DIR
    set NOTES_DIR "$BOOKMARKS_NOTES_DIR"
end

function _bookmarks_usage
    echo 'Usage:
    bookmarks <project>
    bookmarks <project> add     <name>          # add a new bookmark without link
    bookmarks <project> add     <name> <link>   # add a new bookmark with a link
    bookmarks <project> explain <name>          # get a link for item in a list
    bookmarks <project> get     <name>          # get a link for item in a list
    bookmarks <project> open    <name>          # open a link for item in a list in a browser
    bookmarks <project> rm                      # remove bookmark list
    bookmarks <project> show                    # list bookmarks'
end

function _bookmarks_adapt_filename
    echo "$argv[1].md"
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
    set -l title (echo "$argv[2]" | cut -d' ' -f2-)
    grep "$title" "$filename" | grep -oP '\(\K([^\)]+)'
end

function _get_definition
    set -l filename "$argv[1]"
    set -l term (echo "$argv[2]" | cut -d' ' -f2-)
    echo -ne '\t'; and grep "$term - " "$filename" | cut -d'-' -f3-
end

# main
if test "$argv[1]" = "help"
    _bookmarks_usage
    exit
end

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
else if test "$argv[2]" = "explain"
    if ! test -z "$argv[3]"
        echo "$argv[3]" | cut -d' ' -f2-
        _get_definition "$NOTES_DIR"/(_bookmarks_adapt_filename "$filename") "$argv[3]"
    end
    exit
else if test "$argv[2]" = "get" -o "$argv[2]" = "open"
    if ! test -z "$argv[3]"
        set -l LINK (_get_link "$NOTES_DIR"/(_bookmarks_adapt_filename "$filename") "$argv[3..]")
        echo "$LINK"
        if test "$argv[2]" = "open"
            open "$LINK"
        end
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
