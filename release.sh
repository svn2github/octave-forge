# !/bin/sh

## These are the steps you need to take to do a new octave-forge release.
## You will need:
##    * cvs2cl.pl from http://www.red-bean.com/cvs2cl/
##    * perl and the texinfo toolchain
##    * autoconf
##
## You should also have the following in your .bashrc:
## 
##    export OFHOME=octave.sf.net:/home/groups/o/oc/octave/htdocs
## 
## 1) cvs -q update -dP
##
##    Make sure you haven't forgetten to post anything.  Indexing will 
##    be more reliable if you don't have extra files that you don't 
##    intend to post.  You may want to start with a fresh copy
##    of the repository in a separate directory.
##
## 2) ./configure; make; make check
##
##    Make sure it builds on your machine at least.
##
## 3) cvs2cl.pl -f changes
##
##    Generate a list of changes.  Use it to update RELEASE_NOTES with 
##    a summary of changes.  Set the date in the RELEASE_NOTES file.
##
## 4) cvs commit RELEASE_NOTES
##
##    Post the new notes.
##
## 3) admin/get_contents
## 
##    Update README and the developer's guide.  Follow the instructions 
##    for updating the web and CVS.
##
## 4) admin/get_authors
##
##    Verify copyrights.  Look at the AUTHORS file to see which names
##    have been butcherd and update the corresponding sources.
##
## 5) admin/make_index
##
##    Verify documentation and licenses.  To update the web docs, use the 
##    following commands:
##
##        tar czf index.tar.gz index
##        scp index.tar.gz $OFHOME
##        ssh octave.sf.net
##        cd /home/groups/o/oc/octave/htdocs
##        rm -rf index
##        tar xzf index.tar.gz
##	  chmod -R g+w index
##
## 6) cvs -q update -dP
##
##    Make sure you've logged all changes to licenses and doc strings.
##
## 7) ./release.sh
##
##    This is the actual release step.  It tags the CVS tree and generates 
##    a release tarball. 
##
## 8) https://sf.net/project/admin/qrs.php?package_id=2841&group_id=2888
##
##    Log in to your source forge account and announce the release of the
##    package.  Cut and paste the top two sections of RELEASE_NOTES.  Use 
##    the Upload button to add the new tarball
##
##        octave-forge-yyyy.mm.dd.tar.gz
##
## 9) sources@octave.org, octave-dev@lists.sf.net
##
##    Announce the new release on the appropriate mailing lists.
##
## 10) ./cvs-tree > afunclist.html; scp afunclist.html $OFHOME
##
##    Update the alphabetical list (do we still need this??)
##
## Done.

# base name of the project
PROJECT=octave-forge

# use Ryyyy-mm-dd as the tag for revision yyyy.mm.dd
TAG=R`date +%Y-%m-%d`
ROOT=$PROJECT-`date +%Y.%m.%d`

# generate the updated ChangeLog and version command
cvs2cl.pl --fsf --file ChangeLog.tmp
echo "# Automatically generated file --- DO NOT EDIT" | cat - ChangeLog.tmp > ChangeLog
rm ChangeLog.tmp
cat <<EOF > main/miscellaneous/OCTAVE_FORGE_VERSION.m
## OCTAVE_FORGE_VERSION The release date of octave-forge, as integer YYYYMMDD
function v=OCTAVE_FORGE_VERSION
  v=`date +%Y%m%d`;
endfunction
EOF
cvs commit -m "$TAG release" ChangeLog main/miscellaneous/OCTAVE_FORGE_VERSION.m

# tag the CVS tree with the revision number
cvs rtag -F $TAG $PROJECT

# extract the tree into a tagged directory
cvs export -r $TAG -d $ROOT $PROJECT

# generate the AUTHORS file
( cd $ROOT ; make dist )

# build the tar ball
tar czf $ROOT.tar.gz $ROOT

# remove the tagged directory
rm -rf $ROOT
