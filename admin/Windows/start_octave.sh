#!/bin/sh
# This script is executed under sh.exe to start octave
# $Id$
export PATH="/bin:$PATH"
export HOME="/octave_files"
export PS_VIEWER=
export EDITOR=notepad
cd "$HOME"
#ulimit -c 0 # no core files
octave.exe --traditional
rm -f /tmp/*
