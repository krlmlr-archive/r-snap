#!/bin/sh

set -e

APPNAME=r-snap
APPDESC=R
BINPATH=R/bin

log() {
  echo $* >> /dev/stderr
}

clone_or_pull() {
  cd $SNAP_CACHE_DIR
  if test -d $APPNAME/.git; then
    log "Updating R"
    cd $APPNAME
    git pull
  else
    log "Cloning R"
    rm -rf $APPNAME
    git clone https://github.com/krlmlr/${APPNAME}.git
  fi
}

set_symlinks() {
  sudo ln -s -f $SNAP_CACHE_DIR/$APPNAME/$BINPATH/* /usr/local/bin
}

clone_or_pull
set_symlinks
