#!/usr/bin/sh

# CHANGELOG
# ---------
#
# 01-oct-2009 benjamin lindner <lindnerb@users.sourceforge.net>
#
#    *) update patches for 2009-07-08 CVS snapshot
#    *) add gp_makefile-WXWIDGETS.patch
#    *) add gp_disable-SIGINT-handler-console.patch
#    *) add gp_enable-CAIRO.patch
#    *) add gp_enable-WXWIDGETS.patch
#    *) add gp_makefile-add-override.patch
#
# 26-aug-2009 benjamin lindner <lindnerb@users.sourceforge.net>
#
#    *) update to 2009-07-08-CVS snapshot
#
# 27-jan-2009 benjamin lindner <lindnerb@users.sourceforge.net>
#
#    *) CREATION
#


# subdirecory where patches reside
PATCHDIR=patches
# directory of gnuplot sources to patch
GNUPLOT_DIR=gnuplot-4.3.0-2009-07-08

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
gp_makefile-WXWIDGETS.patch \
gp_makefile-documentation.patch \
gp_makefile-localconf.patch \
gp_octave-version.patch \
gp_disable-SIGINT-handler-console.patch \
gp_enable-CAIRO.patch \
gp_enable-WXWIDGETS.patch \
gp_makefile-add-override.patch"

for a in $PATCHES; do
   echo applying $a ...
   ( cd $GNUPLOT_DIR && patch -p 1 -u -i ../$PATCHDIR/$a )
done

