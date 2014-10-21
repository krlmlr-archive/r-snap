#!/bin/sh

set -e

CACHE_BASE_PATH=$SNAP_CACHE_DIR/r-snap
CACHE_VERSION_FILENAME=r-snap-cache-version
CACHE_VERSION_PATH=$CACHE_BASE_PATH/$CACHE_VERSION_FILENAME
CURRENT_VERSION=2

log() {
  echo $* >> /dev/stderr
}

check_cache_version() {
  CACHE_VERSION=$(cat $CACHE_VERSION_PATH 2> /dev/null || echo 0)
  log "Cache version: $CACHE_VERSION"
  log "Current version: $CURRENT_VERSION"
  if test $CACHE_VERSION -lt $CURRENT_VERSION; then
    log "Clearing cache"
    rm -rf $CACHE_BASE_PATH
  fi
  mkdir -p $CACHE_BASE_PATH
  update_cache_version
}

update_cache_version() {
  echo $CURRENT_VERSION > $CACHE_VERSION_PATH
}

provide_r() {
  if test -d r-devel; then
    cd r-devel
    git pull
  else
    git clone https://github.com/wch/r-source.git r-devel
  fi

  recompile_r
}

recompile_r() {
  sudo yum install -y gcc-gfortran.x86_64 texinfo

  if ! build_r; then
    git clean -fdx
    build_r
  fi
}

build_r() {
  tools/rsync-recommended
  R_PAPERSIZE=letter \
    R_BATCHSAVE="--no-save --no-restore" \
    R_BROWSER=xdg-open \
    PAGER=/usr/bin/pager \
    PERL=/usr/bin/cat \
    R_UNZIPCMD=/usr/bin/unzip \
    R_ZIPCMD=/usr/bin/zip \
    R_PRINTCMD=/usr/bin/lpr \
    LIBnn=lib \
    AWK=/usr/bin/awk \
    CFLAGS="-pipe -std=gnu99 -Wall -pedantic -O3" \
    CXXFLAGS="-pipe -Wall -pedantic -O3" \
    ./configure \
      --prefix=$CACHE_BASE_PATH/R \
      --enable-R-shlib \
      --without-blas \
      --without-lapack \
      --without-readline

  (cd doc/manual && make front-matter html-non-svn)

  git log -n 1 --date=iso |
    tac |
    sed -n -E '/^ +git-svn-id: / {s/^[^@]+@([0-9]+).*$/Revision: \1/;p}; /^Date:/ {s/^Date: +/Last Changed Date: /;p}' > SVN-REVISION

  make
  make install
}

push_r() {
  rm -rf R
  cp -arx $CACHE_BASE_PATH/R .
  git add -A
  if test -n "$(git status --porcelain)"; then
    git commit -m "update bits"
    git push origin
  fi
}


curl -L https://raw.githubusercontent.com/krlmlr/r-snap-texlive/master/install.sh | sh

check_cache_version
cd $CACHE_BASE_PATH

provide_r
push_r
