#!/usr/bin/env fish

if test (count $argv) -ne 1
    echo 'Usage:
    kmap-from-github <repo-url>'
    exit 0
end

set -l REPO (string replace "https://github.com/" "" "$argv[1]")
set TMP_FILE (mktemp)

curl -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO" > "$TMP_FILE"

function _get_jq_attr
    jq ".$argv[1]" "$TMP_FILE" | tr -d '"'
end

echo "["(_get_jq_attr 'name')"]("(_get_jq_attr 'html_url')")"
echo
echo "_Description_: "(_get_jq_attr 'description')
echo
echo "_Labels_: #"(_get_jq_attr 'language')

set -l HOMEPAGE (_get_jq_attr 'homepage')
if test -n "$HOMEPAGE"
    echo
    echo "_Docs_: $HOMEPAGE"
end

rm "$TMP_FILE"
