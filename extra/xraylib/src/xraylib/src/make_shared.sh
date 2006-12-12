#!/bin/bash

echo Compiling C source ...
echo

compile.sh

echo Building shared library ...
gcc -Wall -shared  xrayfiles.o xrayglob.o cross_sections.o \
scattering.o atomicweight.o edges.o fluor_lines.o fluor_yield.o jump.o \
coskron.o radrate.o cs_line.o polarized.o splint.o cs_barns.o \
-o ../lib/libxrl.so
echo

clean.sh

