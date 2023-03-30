#!/usr/bin/env fish
function _secrets_usage
    echo \
"Usage:
    secrets from-env    # convert .env format to zip archive
    secrets from-envrc  # convert .envrc format to zip archive
    secrets to-env      # convert zip archive to .env format
    secrets to-envrc    # convert zip archive to .envrc format
    secrets get key     # get key from an archive
    secrets list        # list keys from an archive
    secrets load        # load archive from dropbox
    secrets sync        # sync archive with dropbox

Environment variables:
    SECRETS_PASS - password to encrypt secrets
    SECRETS_FILE - archive to upload to dropbox"
end

function _get_value_by_key
    unzip -P "$SECRETS_PASS" -p "$SECRETS_FILE" "$argv[1]"
end

function _list_keys
    unzip -l "$SECRETS_FILE" | tail -n +4 | head -n -2 | awk '{ print $4 }'
end

function _to_envrc_print
    echo "export $argv[1]"
end

function _to_env_print
    echo "$argv[1]"
end

function _to_env_format
    set -l ENV_FILE "$argv[1]"
    set -l print_function "$argv[2]"
    for file in (_list_keys)
        set -l SECRET_VAR "$file="(_get_value_by_key "$file")
        if test (grep "$file" "$ENV_FILE")
            sed -i'' "/$file/d" "$ENV_FILE"
        end
        $print_function "$SECRET_VAR" >> "$ENV_FILE"
    end
end

function _from_envformat
    set -l ENV_FILE "$argv[1]"
    for line in (grep = "$ENV_FILE" | grep -Ev 'SECRETS_FILE|SECRETS_PASS' )
        set SECRET_NAME (string split '=' "$line" -f1 | sed 's/export //g')
        string split '=' "$line" -m1 -f2 > "$SECRET_NAME"
        zip -P "$SECRETS_PASS" "$SECRETS_FILE" "$SECRET_NAME"
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
    _to_env_format ".envrc" "_to_envrc_print"
    direnv allow
else if test "$argv[1]" = "from-envrc"
    _from_envformat ".envrc"
else if test "$argv[1]" = "to-env"
    _to_env_format ".env" "_to_env_print"
else if test "$argv[1]" = "from-env"
    _from_envformat ".env"
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
