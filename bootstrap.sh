#!/bin/sh

cd $SNAP_CACHE_DIR
test -d r-devel || git clone https://github.com/wch/r-source.git r-devel
cd r-devel
git fetch
