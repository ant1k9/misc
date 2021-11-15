#!/usr/bin/env fish

function usage
    echo "Usage:
    yps <playlist_id>"
end

if test (count $argv) -eq 0
    usage
    exit 0
end

source config.env
set PLAYLIST_ID "$argv[1]"
set BATCH_SIZE 50
set TMP_FILE "/tmp/playlist.results"
set STATS_FILE "/tmp/playlist.stats"

function get-playlist-results
    if test (count $argv) -eq 2
        set EXTRA_QUERY_PARAMS "&pageToken=$argv[2]"
    end

    curl "https://content-youtube.googleapis.com/youtube/v3/playlistItems?part=contentDetails&maxResults=200&playlistId=$PLAYLIST_ID&key=$YOUTUBE_API_KEY$EXTRA_QUERY_PARAMS" \
        -H 'x-origin: https://explorer.apis.google.com' \
        -H "authorization: Bearer $YOUTUBE_API_TOKEN" > "$TMP_FILE"

    set IDS_REQUEST (string trim --right --chars='&' ( \
        jq  '.items[] | .contentDetails.videoId' "$TMP_FILE" \
            | tr -d '"' | awk '{ printf "id=%s&", $1 }' \
    ))

    curl "https://content-youtube.googleapis.com/youtube/v3/videos?part=statistics&$IDS_REQUEST&key=$YOUTUBE_API_KEY" \
        -H 'x-origin: https://explorer.apis.google.com' \
        -H "authorization: Bearer $YOUTUBE_API_TOKEN" \
        > /tmp/stats

    cat /tmp/stats \
        | jq '.items[] | "https://www.youtube.com/watch?v=" + .id + " " + .statistics.viewCount + " " + .statistics.likeCount + " " + .statistics.dislikeCount' | tr -d '"' >> "$STATS_FILE"

    set NEXT_PAGE_TOKEN ( \
        grep nextPageToken "$TMP_FILE" \
        | tr -d '",:' | awk '{ print $2 }' | tr -d ' ' \
    )
    echo "NEXT_PAGE_TOKEN = $NEXT_PAGE_TOKEN"
    if ! test -z "$NEXT_PAGE_TOKEN"
        get-playlist-results "$argv[1]" "$NEXT_PAGE_TOKEN"
    end
end

get-playlist-results "$PLAYLIST_ID"
echo "$STATS_FILE"
