#/bin/bash
echo 'Compiling source files ...'
gcc -Wall -c -fpic xrayfiles.c xrayglob.c cross_sections.c \
scattering.c atomicweight.c edges.c fluor_lines.c fluor_yield.c jump.c \
coskron.c radrate.c cs_line.c polarized.c splint.c cs_barns.c
echo
