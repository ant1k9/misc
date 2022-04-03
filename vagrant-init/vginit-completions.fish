set -l _vginit_commands from build

set INSTALL_DIR # TODO

function _get_boxes
    find "$INSTALL_DIR" -maxdepth 1 -type d -exec basename '{}' \; 2>/dev/null \
        | egrep -v vagrant-init
end

complete -f -c vg-init \
    -n "not __fish_seen_subcommand_from $_vginit_commands" \
    -a from \
    -d "prepare minimal Vagrantfile for a new VM"

complete -f -c vg-init \
    -n "not __fish_seen_subcommand_from $_vginit_commands" \
    -a build \
    -d "build a base image from base Vagrantfiles"

complete -f -c vg-init \
    -n "__fish_seen_subcommand_from $_vginit_commands" \
    -a "(_get_boxes)"
