#!/usr/bin/env fish

set INSTALL_DIR # TODO
set _boxes ( \
    find "$INSTALL_DIR" -maxdepth 1 -type d -exec basename '{}' \; 2>/dev/null \
        | egrep -v vagrant-init \
)

function _usage
    echo "Usage:
    vg-init from  <box> # prepare minimal Vagrantfile for a new VM
    vg-init build <box> # build a base image from base Vagrantfiles"
end

function _please_install_vagrant
    if not test (which vagrant 2>/dev/null)
        echo "install vagrant to run vg-init build"
        exit 1
    end
end

function _please_provide_box_name
    if not contains "$argv[1]" "$_boxes"; or test -z "$argv[1]"
        echo "provide the box name from the list: $_boxes"
        exit 1
    end
end

function _ensure_can_run
    _please_install_vagrant
    _please_provide_box_name "$argv[1]"
end

function _install_box
    set -l _box_name "vginit-$argv[1]"
    fish -c "
        cd $INSTALL_DIR/$argv[1];
        vagrant up --provider virtualbox
        vagrant package --output $_box_name.box
        vagrant box add --name $_box_name $_box_name.box
        rm $_box_name.box"
end

function _init_box
    set -l _box_name "vginit-$argv[1]"
    echo '# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox"
  config.vm.box = "'$_box_name'"

  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true

  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: ".git/"
end' > Vagrantfile
end

if test "$argv[1]" = "from"
    _ensure_can_run "$argv[2]"
    _init_box "$argv[2]"
else if test "$argv[1]" = "build"
    _ensure_can_run "$argv[2]"
    _install_box "$argv[2]"
else
    _usage
end
