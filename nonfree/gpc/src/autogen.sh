#! /bin/bash

function run {
  echo -n Running `$1 --version | sed q`"... "
  $*
  echo "done"
}

run aclocal \
  && run automake \
  && run autoconf


