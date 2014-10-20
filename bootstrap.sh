#!/bin/sh

set -e

provide_latex() {
  if ! test -d texlive; then
    if ! install_latex; then
      rm -rf texlive
      return 1
    fi
  fi
}

install_latex() {
  mkdir texlive
  pushd /tmp
  curl -L http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar -xzv
  cd install-tl-*
  ./install-tl --profile=$SNAP_WORKING_DIR/texlive.profile
  popd
}

recompile_r() {
  cd r-devel
  git pull

  sudo yum install -y gcc-gfortran.x86_64
  ./configure
  tools/rsync-recommended
}

cd $SNAP_CACHE_DIR

provide_latex
exit 0

if test -d r-devel; then
  recompile_r
else
  git clone https://github.com/wch/r-source.git r-devel
  recompile_r
fi
