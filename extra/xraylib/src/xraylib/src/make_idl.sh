#!/bin/bash

IDL_DIR=/opt/idl/external/
echo -n "IDL Export Include Directory? (${IDL_DIR}) "
read arg
if [ ! $arg = '' ]; then IDL_DIR=$arg; fi
 
if [ ! -d $IDL_DIR ]; then
    echo "Directory $IDL_DIR does not exist"
    echo
    exit
elif [ ! -f ${IDL_DIR}/export.h ]; then
    echo "File export.h does not exist in Directory $IDL_DIR"
    echo
    exit
fi    
echo Compiling C - IDL interface ...
gcc -c -fpic xraylib_idl.c -I${IDL_DIR}
echo

compile.sh

echo Building module for IDL ...
gcc -shared  xraylib_idl.o xrayfiles.o xrayglob.o cross_sections.o \
scattering.o atomicweight.o edges.o fluor_lines.o fluor_yield.o jump.o \
coskron.o radrate.o cs_line.o polarized.o splint.o cs_barns.o \
-o ../idl/xraylib_idl.so
echo

clean.sh

