#!/usr/bin/env fish

set -l GARBAGE_LINKS \
    '% engineer %' '%tech lead%' '%Vettery%' '%developer%remote%' \
    '%unsubscribe%' '"Read on the Web"' \
    '"1"' '"2"' '"3"' '"4"' '"5"' '"6"' '"7"' '"8"' '"9"' '"10"' \
    '"Postgres Weekly"' '%pgday%' '%pgconf%' '%PosttgresConf%' \
    '%conference%' '%podcast%' '%meetup%' '%talks%' '%summit%' '%meeting%' '%survey%' \
    '%KUBE% SIG %' '%agenda%' '"Agenda/Notes: here"' \
    '%youtube.com%' '%circleci.com%' \
    '%.net core%' '%spring%' '%php%' \
    'null'

for GARBAGE_LINK in $GARBAGE_LINKS
    sqlite3 "links.sqlite3" \
        "DELETE FROM links WHERE title LIKE '$GARBAGE_LINK'"
end
