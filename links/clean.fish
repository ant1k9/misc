#!/usr/bin/env fish

set -l GARBAGE_LINKS \
    '"Agenda/Notes: here"' \
    '"Find A Job Through Vettery"' \
    '%agenda%' \
    '%meeting%' \
    '% engineer %' \
    '%unsubscribe%' \
    '"1"' \
    '"2"' \
    '"3"' \
    '"4"' \
    '"5"' \
    '"6"' \
    '"7"' \
    '"8"' \
    '"9"' \
    '"10"' \
    '"Read on the Web"' \
    '"Postgres Weekly"' \
    '%KUBE% SIG %' \
    '%pgday%'

for GARBAGE_LINK in $GARBAGE_LINKS
    sqlite3 "links.sqlite3" \
        "DELETE FROM links WHERE title LIKE '$GARBAGE_LINK'"
end
