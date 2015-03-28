#!/bin/sh

{ # Prevent execution if this script was only partially downloaded

EXUA_URL=https://raw.githubusercontent.com/bacher09/ua-vlc-scripts/master/playlist/exua.lua
FSTO_URL=https://raw.githubusercontent.com/bacher09/ua-vlc-scripts/master/playlist/fsto.lua

save_scripts() {
    # overwrite file if exists
    curl -L $EXUA_URL > $1/exua.lua
    curl -L $FSTO_URL > $1/fsto.lua
}

default_install() {
    DIR=~/.local/share/vlc/lua/playlist
    mkdir -p $DIR
    save_scripts $DIR
}

osx_install() {
    DIR=/Applications/VLC.app/Contents/MacOS/share/lua/playlist/
    if [ ! -d "$DIR" ] ; then
        echo "Error: VLC is not installed"
        exit 1
    fi
    save_scripts $DIR
}

case $(uname -s) in
    Darwin) osx_install;;
    *) default_install;;
esac

} # End of wrapping
