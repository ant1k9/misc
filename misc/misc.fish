#!/usr/bin/env fish

set INSTALL_DIR # TODO

if test "$argv[1]" = "list"
    fish -c "
        cd $INSTALL_DIR;
        find . -maxdepth 1 -not -name '.*' -and -not -name 'misc' -type d | tr -d './'"
else if test "$argv[1]" = "update"
    fish -c "cd $INSTALL_DIR; and git pull"
else if test "$argv[1]" = "install"
    fish -c "cd $INSTALL_DIR; and ./install.fish $argv[2]"
end
