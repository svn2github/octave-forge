#!/usr/bin/sh

# CHANGELOG
# ---------
#
# 27-jan-2009 benjamin lindner <lindnerb@users.sourceforge.net>
#
#    *) CREATION
#


# subdirecory where patches reside
PATCHDIR=patches
# directory of gnuplot sources to patch
GNUPLOT_DIR=gnuplot-4.3.0-2008-11-21

# the patches to apply
PATCHES="
gp_console-GetModuleHandle.patch \
gp_local_documentation.patch \
gp_emf-style.patch \
gp_gd.patch \
gp_gd-substitute-helvetica.patch \
gp_post-style.patch \
gp_makefile-SRCDIR.patch \
gp_makefile-CAIRO.patch \
gp_makefile-documentation.patch \
gp_makefile-localconf.patch \
gp_octave-version.patch"

for a in $PATCHES; do
   echo applying $a ...
   ( cd $GNUPLOT_DIR && patch -p 1 -u -i ../$PATCHDIR/$a )
done

