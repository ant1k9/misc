function _secrets_subcommands
    echo -e "to-envrc\nfrom-envrc"
end

complete -f -c secrets \
    -a "(_secrets_subcommands)"
