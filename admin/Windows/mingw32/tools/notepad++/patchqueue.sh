#!/usr/bin/sh

# CHANGELOG
# ---------
#
# 20-Feb-2010 benjamin lindner <lindnerb@users.sourceforge.net>
#
#    *) update for npp-5.6.6
#
# 24-oct-2009 benjamin lindner <lindnerb@users.sourceforge.net>
#
#    *) update for npp-5.5.1 and gcc-4.4.0 with mingwrt-3.16
#       - remove np_xml.localization.xml
#       - add countof-mingw.patch, mingwrt-3.16-fixes.patch
#       - updated np_npp-disable-minidump.patch
#                 np_npp-localizationString.patch
#                 np_npp.patch
#                 np_nppmakefile.patch
#                 np_optifon.patch
#                 np_scimakefile.patch
#                 np_scintilla.patch
#                 np_wtof_unicode.patch
#                 npp_catch-refrerence-to-const.patch
#                 npp_sci-bugfixes.patch
#                 npp_xml-config-model.patch
#                 npp_xml-langs-model.patch
#                 npp_xml-shortcut.patch
#                 npp_xml-userdefinelang.patch
#       
#    *) add --binary flag patch.exe
#
# 12-may-2009 benjamin lindner <lindnerb@users.sourceforge.net>
#
#    *) CREATION
#


# subdirecory where patches reside
PATCHDIR=patches
# directory of gnuplot sources to patch
NPP_DIR=npp-5.6.6

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
np_npp-disable-minidump.patch
np_npp-localizationString.patch
npp_catch-refrerence-to-const.patch
countof-mingw.patch
mingwrt-3.16-fixes.patch
npp_dialogs-not-beyond-desktop.patch
"

for a in $PATCHES; do
   echo applying $a ...
   ( cd $NPP_DIR && patch --binary -p 1 -u -i ../$PATCHDIR/$a )
done

