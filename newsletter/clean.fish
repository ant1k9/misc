#!/usr/bin/env fish

set -l SKIP_TITLES \
    '% engineer %' '%tech lead%' '%Vettery%' '%developer%remote%' '%engineer"' '%engineer,%' \
    '%unsubscribe%' '"Read on the Web"' '"Web Version"' \
    '"0"' '"1"' '"2"' '"3"' '"4"' '"5"' '"6"' '"7"' '"8"' '"9"' '"10"' \
    '"Postgres Weekly"' '%pgday%' '%pgcon%' '%PostgresConf%' '%Postgres Vision%' \
    '%conference%' '%podcast%' '%meetup%' '%talks%' '%summit%' '%meeting%' '%survey%' '% talk %' \
    '%KUBE% SIG %' '%agenda%' '"Agenda/Notes: here"' '%announcing%' \
    '%youtube.com%' '%circleci.com%' \
    '%.net core%' '%spring%' '%php%' '%gui %' '%rails%' '% 2d%' '% 3d%' '%oracle%' '%django%' \
    'null' '%released%' '%release note%' '%this week%' \
    '%Goland%' '%IntelliJ%' '%JetBrains%' \
    '%enterprise%'

set -l SKIP_HREFS \
    '%youtube.com%' '%youtu.be%'

for SKIP_TITLE in $SKIP_TITLES
    sqlite3 "links.sqlite3" \
        "DELETE FROM links WHERE title LIKE '$SKIP_TITLE'"
end

for SKIP_HREF in $SKIP_HREFS
    sqlite3 "links.sqlite3" \
        "DELETE FROM links WHERE href LIKE '$SKIP_HREF'"
end
