set -l _secrets_subcommands from-envrc get list load sync to-envrc from-env to-env

complete -f -c secrets \
    -n "not __fish_seen_subcommand_from $_secrets_subcommands" \
    -a "from-env" \
    -d "convert .env format to zip archive"

complete -f -c secrets \
    -n "not __fish_seen_subcommand_from $_secrets_subcommands" \
    -a "from-envrc" \
    -d "convert .envrc format to zip archive"

complete -f -c secrets \
    -n "not __fish_seen_subcommand_from $_secrets_subcommands" \
    -a "to-env" \
    -d "convert zip archive to .env format"

complete -f -c secrets \
    -n "not __fish_seen_subcommand_from $_secrets_subcommands" \
    -a "to-envrc" \
    -d "convert zip archive to .envrc format"

complete -f -c secrets \
    -n "not __fish_seen_subcommand_from $_secrets_subcommands" \
    -a "get" \
    -d "get key from an archive"

complete -f -c secrets \
    -n "not __fish_seen_subcommand_from $_secrets_subcommands" \
    -a "list" \
    -d "list keys from an archive"

complete -f -c secrets \
    -n "not __fish_seen_subcommand_from $_secrets_subcommands" \
    -a "load" \
    -d "load archive from dropbox"

complete -f -c secrets \
    -n "not __fish_seen_subcommand_from $_secrets_subcommands" \
    -a "sync" \
    -d "sync archive with dropbox"

complete -f -c secrets \
    -n "__fish_seen_subcommand_from get" \
    -a "(secrets list)"
