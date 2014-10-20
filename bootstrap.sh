#!/bin/sh

set -e

recompile_r() {
  cd r-devel
  git pull
  snap-shell
  ./configure
  tools/rsync-recommended
}

cd $SNAP_CACHE_DIR
if test -d r-devel; then
  recompile_r
else
  git clone https://github.com/wch/r-source.git r-devel
  recompile_r
fi
