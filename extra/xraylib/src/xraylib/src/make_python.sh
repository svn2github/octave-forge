#!/bin/bash

#echo Trying to use swig ...
#swig -python xraylib.i
#echo
echo
echo 'Do you want to use local swig to create '
echo -n 'the python-to-c glue code (y/[n])? '
read yn
case "$yn" in
  Y* | y* ) echo "   (trying to use local swig...)" ; swig -python xraylib.i;;
  *) echo "   (using stored glue code) ";;
esac


PYTH_DIR=/usr/include/python/
echo -n "Python Include Directory? (${PYTH_DIR}) "
read arg
if [ ! $arg = '' ]; then PYTH_DIR=$arg; fi

if [ ! -d $PYTH_DIR ]; then
    echo "Directory $PYTH_DIR does not exist"
    echo
    exit
elif [ ! -f ${PYTH_DIR}/Python.h ]; then
    echo "File Python.h does not exist in Directory $PYTH_DIR"
    echo
    exit
fi    

echo Compiling C - python interface ...
gcc -c -fpic xraylib_wrap.c -I$PYTH_DIR
echo

compile.sh

echo Building module for python ...
gcc -Wall -shared  xraylib_wrap.o xrayfiles.o xrayglob.o cross_sections.o \
scattering.o atomicweight.o edges.o fluor_lines.o fluor_yield.o jump.o \
coskron.o radrate.o cs_line.o polarized.o splint.o cs_barns.o \
-o ../bin/_xraylib.so
echo

clean.sh
