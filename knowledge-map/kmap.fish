#!/usr/bin/env fish
set MY_KNOWLEDGE_MAP_HOST "http://$PERSONAL_SERVER_HOST"

function _kmap_usage
    echo 'Usage:
    kmap get    <repo-url>
    kmap search <query>'
end

function _kmap_get_repo
    set -l REPO (string replace "https://github.com/" "" "$argv[1]")
    set -g TMP_FILE (mktemp)

    curl -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO" > "$TMP_FILE"

    function _get_jq_attr
        jq ".$argv[1]" "$TMP_FILE" | tr -d '"'
    end

    echo "["(_get_jq_attr 'name')"]("(_get_jq_attr 'html_url')")"
    echo
    echo "*Description*: "(_get_jq_attr 'description')
    echo
    echo "*Labels*: #"(_get_jq_attr 'language')

    set -l HOMEPAGE (_get_jq_attr 'homepage')
    if test -n "$HOMEPAGE" -a "$HOMEPAGE" != "null"
        echo
        echo "*Docs*: $HOMEPAGE"
    end

    rm "$TMP_FILE"
end

function _kmap_search
    open "$MY_KNOWLEDGE_MAP_HOST/search?q=$argv[1]"
end

# main
if test "$argv[1]" = "get"
    _kmap_get_repo "$argv[2]"
else if test "$argv[1]" = "search"
    _kmap_search "$argv[2]"
else
    _kmap_usage
end
