#!/usr/bin/env fish
set SECRETS_DIR $HOME/.config/secret-cli

function _secrets_usage
    echo "Usage:
    SECRETS_PASS=PasSWoRD SECRETS_FILE=secrets.zip secrets to-envrc
    SECRETS_PASS=PasSWoRD SECRETS_FILE=secrets.zip secrets from-envrc"
end

function _to_envrc
    for file in (unzip -l "$SECRETS_FILE" | tail -n +4 | head -n -2 | awk '{ print $4 }')
        set -l SECRET_VAR "$file="(unzip -P "$SECRETS_PASS" -p "$SECRETS_FILE" "$file")
        if test (grep "$file" .envrc)
            sed -i'' "/$file/d" .envrc
        end
        echo "$SECRET_VAR" >> .envrc
    end
    direnv allow
end

function _from_envrc
    for line in (grep = .envrc)
        set SECRET_NAME (echo "$line" | awk -F'=' '{ print $1 }')
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

if test "$argv[1]" = "to-envrc"
    _to_envrc
else if test "$argv[1]" = "from-envrc"
    _from_envrc
else
    _secrets_usage
end
