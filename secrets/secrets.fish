#!/usr/bin/env fish
function _secrets_usage
    echo "Usage:
    secrets to-envrc    # convert zip archive to .envrc format
    secrets from-envrc  # convert .envrc format to zip archive
    secrets get key     # get key from an archive
    secrets list        # list keys from an archive
    secrets load        # load archive from dropbox
    secrets sync        # sync archive with dropbox"
end

function _get_value_by_key
    unzip -P "$SECRETS_PASS" -p "$SECRETS_FILE" "$argv[1]"
end

function _list_keys
    unzip -l "$SECRETS_FILE" | tail -n +4 | head -n -2 | awk '{ print $4 }'
end

function _to_envrc
    for file in (_list_keys)
        set -l SECRET_VAR "$file="(_get_value_by_key "$file")
        if test (grep "$file" .envrc)
            sed -i'' "/$file/d" .envrc
        end
        echo "export $SECRET_VAR" >> .envrc
    end
    direnv allow
end

function _from_envrc
    for line in (grep = .envrc | grep -Ev 'SECRETS_FILE|SECRETS_PASS' )
        set SECRET_NAME (echo "$line" | awk -F'=' '{ print $1 }' | sed 's/export //g')
        echo "$line" | awk -F'=' '{ print $2 }' > "$SECRET_NAME"
        echo "set timeout -1
        spawn zip -e \"$SECRETS_FILE\" \"$SECRET_NAME\"
        match_max 100000
        expect -exact \"Enter password: \"
        send -- \"$SECRETS_PASS\r\"
        expect -exact \"Verify password: \"
        send -- \"$SECRETS_PASS\r\"
        expect eof" | expect
        rm "$SECRET_NAME"
    end
end

function _load_from_dropbox
    DROPBOX_DIRECTORY=/secrets DROPBOX_TOKEN=(cat /tmp/token) load-from-dropbox "$SECRETS_FILE"
end

function _load_to_dropbox
    cp "$SECRETS_FILE" /tmp
    set -l TMP_SECRETS /tmp/(basename $SECRETS_FILE)
    DROPBOX_DIRECTORY=/secrets DROPBOX_TOKEN=(cat /tmp/token) load-to-dropbox "$TMP_SECRETS"
end

if test "$argv[1]" = "to-envrc"
    _to_envrc
else if test "$argv[1]" = "from-envrc"
    _from_envrc
else if test "$argv[1]" = "get"
    _get_value_by_key "$argv[2]"
else if test "$argv[1]" = "list"
    _list_keys
else if test "$argv[1]" = "load"
    _load_from_dropbox
else if test "$argv[1]" = "sync"
    _load_to_dropbox
else
    _secrets_usage
end
