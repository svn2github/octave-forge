#!/usr/bin/sh

# CHANGELOG
# ---------
#
# 12-may-2009 benjamin lindner <lindnerb@users.sourceforge.net>
#
#    *) CREATION
#


# subdirecory where patches reside
PATCHDIR=patches
# directory of gnuplot sources to patch
NPP_DIR=npp-5.3.1

# the patches to apply
PATCHES="
npp_sci-bugfixes.patch
np_scintilla.patch
np_scimakefile.patch
np_wtof_unicode.patch
np_optifon.patch
np_nppmakefile.patch
np_npp.patch
npp_xml-config-model.patch
npp_xml-langs-model.patch
npp_xml-shortcut.patch
npp_xml-userdefinelang.patch
npp_sci-sloppy-code.patch
np_npp-disable-minidump.patch
np_npp-localizationString.patch
np_xml-localization.patch
npp_sci-lexprogress.patch
npp_catch-refrerence-to-const.patch
"

for a in $PATCHES; do
   echo applying $a ...
   ( cd $NPP_DIR && patch -p 1 -u -i ../$PATCHDIR/$a )
done

