#!/bin/sh

# update_spec.sh
#
# by Quentin Spencer
# 17 Jun 2004
#
# This script edits the octave-forge.spec file to match the version of
# the current octave installation on the system.  See README for more
# details. This script is capable of adding, but not modifying a
# version dependency number. Hopefully that capability will be added
# when the author becomes more familiar with the use of sed.
#
# If the octave installation does not have an epoch defined, the epoch
# string will contain "(none)". It is unclear how this affects
# dependencies. The main reason for including this is that the RedHat
# maintainers added an epoch to octave packages starting with either
# RedHat 9 or Fedora 1, which really wasn't necessary, IMHO.

OCTAVE_EPOCH=`rpm -q --qf "%{EPOCH}" octave`
OCTAVE_VERSION=`rpm -q --qf "%{VERSION}" octave`
VER_STR=$OCTAVE_EPOCH:$OCTAVE_VERSION
EDIT_STR="'s/\(^Requires:.*octave\)\(.*$\)/\1 = "$VER_STR"\2/'"

eval "sed -i -e "$EDIT_STR" octave-forge.spec"
