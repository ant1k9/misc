#!/usr/bin/env fish

set -l PROGRAM
if test (count $argv) -eq 1
    set PROGRAM $argv[1]
end

if test "$PROGRAM" = "newsletter"
    cp links/generate.fish "$HOME/bin/newsletter"
    sed -i "s:links.sqlite3:$PWD/links/links.sqlite3:g" "$HOME/bin/newsletter"
end
