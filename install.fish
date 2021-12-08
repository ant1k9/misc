#!/usr/bin/env fish

set -l PROGRAM
if test (count $argv) -eq 1
    set PROGRAM $argv[1]
end

if test "$PROGRAM" = "misc"
    cp misc/misc.fish "$HOME/bin/misc"
    cp misc/misc-completions.fish "$HOME/.config/fish/completions/misc.fish"
    chmod +x "$HOME/bin/misc"
    sed -i "s:# TODO:$PWD:g" "$HOME/bin/misc"
end

if test "$PROGRAM" = "knowledge-map"
    cp knowledge-map/kmap.fish "$HOME/bin/kmap"
    cp knowledge-map/kmap-completions.fish "$HOME/.config/fish/completions/kmap.fish"
    chmod +x "$HOME/bin/kmap"
end

if test "$PROGRAM" = "load-to-dropbox"
    cp dropbox/load-to-dropbox.sh "$HOME/bin/load-to-dropbox"
    chmod +x "$HOME/bin/load-to-dropbox"
end

if test "$PROGRAM" = "newsletter"
    cp newsletter/generate.fish "$HOME/bin/newsletter"
    cp newsletter/newsletter-app.py "$HOME/bin/newsletter-app"
    chmod +x "$HOME/bin/newsletter" "$HOME/bin/newsletter-app"
    sed -i "s:links.sqlite3:$PWD/newsletter/links.sqlite3:g" "$HOME/bin/newsletter"
    sed -i "s:links.sqlite3:$PWD/newsletter/links.sqlite3:g" "$HOME/bin/newsletter-app"
end

if test "$PROGRAM" = "pdf-picker"
    git submodule update
    cp pdf-picker/pdf-picker/pdf_picker.py "$HOME/bin/pdf-picker"
    cp pdf-picker/pdf-picker-completions.fish "$HOME/.config/fish/completions/pdf-picker.fish"
    chmod +x "$HOME/bin/pdf-picker"
    sed -i "/LIBRARY_DIR =/ s:'\(.*\)':'$HOME/.config/pdf-picker/library':g" "$HOME/bin/pdf-picker"
    sed -i "/CHAPTERS_DIR =/ s:'\(.*\)':'$HOME/.config/pdf-picker/chapters':g" "$HOME/bin/pdf-picker"
    sed -i "/DATABASE =/ s:'\(.*\)':'$HOME/.config/pdf-picker/library.db':g" "$HOME/bin/pdf-picker"
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
