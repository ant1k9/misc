#!/usr/bin/env fish

set -l PROGRAM
if test (count $argv) -ge 1
    set PROGRAM $argv[1]
end

function _install_package
    set -l PACKAGE "$argv[1]"
    set -l CURRENT_DIR (pwd)
    set -l PACKAGE_DIR $PACKAGE-(random)

    cd /tmp
    mkdir -p "$PACKAGE_DIR"
    git clone "https://github.com/ant1k9/$PACKAGE" "$PACKAGE_DIR"
    cd "$PACKAGE_DIR"

    echo "Installing $PACKAGE..."
    sh -c "$argv[2]"
    cp "completions/$PACKAGE.fish" ~/.config/fish/completions

    cd "$CURRENT_DIR"
    rm -rf "/tmp/$PACKAGE_DIR"
end

function _install_rust_package
    _install_package "$argv[1]" "cargo install --path ."
end

function _install_make_package
    _install_package "$argv[1]" "make install $argv[2..]"
end

if test "$PROGRAM" = "misc"
    cp misc/misc.fish "$HOME/bin/misc"
    cp misc/misc-completions.fish "$HOME/.config/fish/completions/misc.fish"
    chmod +x "$HOME/bin/misc"
    sed -i "s:# TODO:$PWD:g" "$HOME/bin/misc"
end

if test "$PROGRAM" = "agile-cli"
    mkdir -p "$HOME/.local/share/agile-cli"
    cp agile-cli/agile-cli.fish "$HOME/bin/agile"
    cp agile-cli/agile-completions.fish "$HOME/.config/fish/completions/agile.fish"
    chmod +x "$HOME/bin/agile"
end

if test "$PROGRAM" = "aliasme"
    if test (count $argv) -eq 1
        _install_make_package "$PROGRAM"
    else
        _install_make_package "aliasme" "EXTRAFLAGS='-DALIASME_DIRECTORY=\\\"$argv[2]\\\"'"
    end
end

if test "$PROGRAM" = "auto-launcher"
    go install github.com/ant1k9/auto-launcher/cmd/auto-launcher@latest
    cp (which auto-launcher) "$HOME/bin/al"
    al completion fish > "$HOME/.config/fish/completions/al.fish"
end

if test "$PROGRAM" = "auto-builder"
    go install github.com/ant1k9/auto-launcher/cmd/auto-launcher@latest
    cp (which auto-builder) "$HOME/bin/bld"
end

if test "$PROGRAM" = "blog-notifier"
    cp blog-notifier/blog-notifier.fish "$HOME/bin/blog-notifier"
    cp blog-notifier/blog-notifier-completions.fish "$HOME/.config/fish/completions/blog-notifier.fish"
    chmod +x "$HOME/bin/blog-notifier"
end

if test "$PROGRAM" = "bookmarks"
    mkdir -p "$HOME/.local/share/bookmarks"
    cp bookmarks/bookmarks.fish "$HOME/bin/bookmarks"
    cp bookmarks/bookmarks-completions.fish "$HOME/.config/fish/completions/bookmarks.fish"
    chmod +x "$HOME/bin/bookmarks"
end

if test "$PROGRAM" = "dropbox"
    cp dropbox/load-to-dropbox.sh "$HOME/bin/load-to-dropbox"
    cp dropbox/load-from-dropbox.sh "$HOME/bin/load-from-dropbox"
    chmod +x "$HOME/bin/load-to-dropbox" "$HOME/bin/load-from-dropbox"
end

if test "$PROGRAM" = "formatter" -o "$PROGRAM" = "noter" -o "$PROGRAM" = "backup-tool"
    _install_rust_package "$PROGRAM"
end

if test "$PROGRAM" = "knowledge-map"
    cp knowledge-map/kmap.fish "$HOME/bin/kmap"
    cp knowledge-map/kmap-completions.fish "$HOME/.config/fish/completions/kmap.fish"
    chmod +x "$HOME/bin/kmap"
end

if test "$PROGRAM" = "newsletter"
    cp newsletter/generate.fish "$HOME/bin/newsletter"
    cp newsletter/newsletter-app.py "$HOME/bin/newsletter-app"
    cp newsletter/newsletter-completions.fish "$HOME/.config/fish/completions/newsletter.fish"
    chmod +x "$HOME/bin/newsletter" "$HOME/bin/newsletter-app"
    sed -i "s:links.sqlite3:$PWD/newsletter/links.sqlite3:g" "$HOME/bin/newsletter"
    sed -i "s:links.sqlite3:$PWD/newsletter/links.sqlite3:g" "$HOME/bin/newsletter-app"
end

if test "$PROGRAM" = "pdf-picker"
    git submodule update
    pip3 install -r pdf-picker/pdf-picker/requirements.txt
    cp pdf-picker/pdf-picker/pdf_picker.py "$HOME/bin/pdf-picker"
    cp pdf-picker/pdf-picker-completions.fish "$HOME/.config/fish/completions/pdf-picker.fish"
    chmod +x "$HOME/bin/pdf-picker"
    sed -i "/LIBRARY_DIR =/ s:'\(.*\)':'$HOME/.local/share/pdf-picker/library':g" "$HOME/bin/pdf-picker"
    sed -i "/CHAPTERS_DIR =/ s:'\(.*\)':'$HOME/.local/share/pdf-picker/chapters':g" "$HOME/bin/pdf-picker"
    sed -i "/DATABASE =/ s:'\(.*\)':'$HOME/.local/share/pdf-picker/library.db':g" "$HOME/bin/pdf-picker"
end

if test "$PROGRAM" = "pg-analyze"
    cp pg-analyze/pg-analyze.fish "$HOME/bin/pg-analyze"
    cp pg-analyze/pg-analyze-completions.fish "$HOME/.config/fish/completions/pg-analyze.fish"
    chmod +x "$HOME/bin/pg-analyze"
end

if test "$PROGRAM" = "repeat"
    cp repeat/repeat.fish "$HOME/bin/repeat"
    cp repeat/repeat-completions.fish "$HOME/.config/fish/completions/repeat.fish"
    chmod +x "$HOME/bin/repeat"
end

if test "$PROGRAM" = "secrets"
    cp secrets/secrets.fish "$HOME/bin/secrets"
    cp secrets/secrets-completions.fish "$HOME/.config/fish/completions/secrets.fish"
    chmod +x "$HOME/bin/secrets"
end

if test "$PROGRAM" = "vagrant-init"
    cp vagrant-init/vagrant-init.fish "$HOME/bin/vg-init"
    cp vagrant-init/vginit-completions.fish "$HOME/.config/fish/completions/vg-init.fish"
    chmod +x "$HOME/bin/vg-init"
    sed -i "s:# TODO:$PWD/vagrant-init:g" "$HOME/bin/vg-init"
    sed -i "s:# TODO:$PWD/vagrant-init:g" "$HOME/.config/fish/completions/vg-init.fish"
end

if test "$PROGRAM" = "youtube-playlist-sorter"
    cp youtube-playlist-sorter/youtube.fish "$HOME/bin/yps"
    cp youtube-playlist-sorter/yps-completions.fish "$HOME/.config/fish/completions/yps.fish"
    chmod +x "$HOME/bin/yps"

    if ! test -f "$HOME/.config/yps/config.env"
        cp youtube-playlist-sorter/config.example.env "$HOME/.config/yps/config.env"
    end

    mkdir -p "$HOME/.config/yps"
    if ! test -f "$HOME/.config/yps/playlists.sqlite3"
        cat "youtube-playlist-sorter/schema.sql" | sqlite3 "$HOME/.config/yps/playlists.sqlite3"
    end
end
