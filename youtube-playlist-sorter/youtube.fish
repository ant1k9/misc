#!/usr/bin/env fish

function usage
    echo "Usage:
    yps SREcon21 --playlist-id=PLbRoZ5Rrl5lcjhxsp-V3-xJnHQpWLllRS  # download playlist
    yps SREcon21 --limit=20 --order-by=likes                       # get playlist videos"
end

if test (count $argv) -eq 0
    usage
    exit 0
end

source "$HOME/.config/yps/config.env"
set BATCH_SIZE 50
set TMP_FILE "/tmp/playlist.results"
set STATS_FILE "/tmp/playlist.stats"
set DB "$HOME/.config/yps/playlists.sqlite3"

function get-playlist-results
    set PLAYLIST_ID "$argv[1]"
    set PLAYLIST_NAME "$argv[2]"
    if test (count $argv) -eq 3
        set EXTRA_QUERY_PARAMS "&pageToken=$argv[3]"
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
        | PLAYLIST_ID=$PLAYLIST_ID PLAYLIST_NAME=$PLAYLIST_NAME jq '.items[] |
            env.PLAYLIST_ID
            + "," + "https://www.youtube.com/watch?v=" + .id
            + "," + .statistics.viewCount
            + "," + .statistics.likeCount
            + "," + .statistics.dislikeCount
            + "," + env.PLAYLIST_NAME' \
        | tr -d '"' > "$STATS_FILE"

    sqlite3 -csv "$DB" ".import $STATS_FILE playlists"

    set NEXT_PAGE_TOKEN ( \
        grep nextPageToken "$TMP_FILE" \
        | tr -d '",:' | awk '{ print $2 }' | tr -d ' ' \
    )
    echo "NEXT_PAGE_TOKEN = $NEXT_PAGE_TOKEN"
    if test -n "$NEXT_PAGE_TOKEN"
        get-playlist-results "$PLAYLIST_ID" "$PLAYLIST_NAME" "$NEXT_PAGE_TOKEN"
    end
end

function get-playlist-sorted
    set -l _bad_args (string match -r -- "-.*" "$argv[1]")
    if test -n "$_bad_args"
        usage
        return
    end

    set PLAYLIST_NAME "$argv[1]"

    argparse 'order-by=' 'limit=' 'playlist-id=' -- $argv
    if test -z $_flag_order_by
        set _flag_order_by views
    end
    if test -z $_flag_limit
        set _flag_limit 10
    end

    if test -z (sqlite3 "$DB" "SELECT 1 FROM playlists WHERE name = '$PLAYLIST_NAME' LIMIT 1")
        get-playlist-results "$_flag_playlist_id" "$PLAYLIST_NAME"
    end

    sqlite3 -csv "$DB" \
        "SELECT video_id, views, likes, dislikes FROM playlists
            WHERE name = '$PLAYLIST_NAME'
            ORDER BY CAST($_flag_order_by AS INTEGER) DESC
            LIMIT $_flag_limit" \
        | tr ',' ' '
end

argparse 'order-by=' 'limit=' 'playlist-id=' 'remove' -- $argv

if set -q _flag_remove
    sqlite3 "$DB" "DELETE FROM playlists WHERE name = '$argv[1]'"
    exit $status
end

get-playlist-sorted "$argv[1]" \
    --playlist-id=$_flag_playlist_id \
    --limit=$_flag_limit \
    --order-by=$_flag_order_by
