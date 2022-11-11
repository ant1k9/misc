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

function _kmap_get_html
    set -l SITE "$argv[1]"
    set -g TMP_FILE (mktemp)

    curl "$SITE" | pup 'h1 json{}' > "$TMP_FILE"

    function _get_jq_text_attr
        jq "$argv[1] | ..|objects|.text//empty" "$TMP_FILE" | tr -d '"\n'
    end

    echo "["(_get_jq_text_attr '.[0]')"]($SITE)"
    echo
    if test (cat "$TMP_FILE" | jq 'length') -eq 2
        echo "*Description*: "(_get_jq_text_attr '.[1]')
    else
        echo "*Description*: "(_get_jq_text_attr '.[0]')
    end
    echo
    echo "*Labels*: # "

    rm "$TMP_FILE"
end

function _kmap_get_resource
    set -l RESOURCE "$argv[1]"
    if string match -r "https://github.com.*" "$RESOURCE" >/dev/null
        _kmap_get_repo "$RESOURCE"
    else
        _kmap_get_html "$RESOURCE"
    end
end

function _kmap_search
    open "$MY_KNOWLEDGE_MAP_HOST/search?q=$argv[1]"
end

# main
if test "$argv[1]" = "get"
    _kmap_get_resource "$argv[2]"
else if test "$argv[1]" = "search"
    _kmap_search "$argv[2]"
else
    _kmap_usage
end
