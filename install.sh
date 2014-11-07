#!/bin/sh

set -e
set -x

APPNAME=r-snap
APPDESC=R
BINPATH=R/bin

log() {
  echo $* >> /dev/stderr
}

clone() {
  ( cd $SNAP_CACHE_DIR/$APPNAME && git pull && git checkout . && git clean -fdx )
}

clone_or_pull() {
  if ! clone; then
    rm -rf $SNAP_CACHE_DIR/$APPNAME
    git clone https://github.com/krlmlr/${APPNAME}.git $SNAP_CACHE_DIR/$APPNAME
  fi
}

set_symlinks() {
  sudo ln -s -f $SNAP_CACHE_DIR/$APPNAME/$BINPATH/* /usr/local/bin
}

clone_or_pull
set_symlinks
sudo yum install -y gcc-gfortran.x86_64 texinfo
