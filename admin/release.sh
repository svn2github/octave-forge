#! /bin/sh

## These are the steps you need to take to do a new octave-forge release.
## You will need:
##    * cvs2cl.pl from http://www.red-bean.com/cvs2cl/
##    * perl, python, and the texinfo toolchain
##    * autoconf
##    * wget
##
## You should also have the following in your .bashrc:
## 
##    export OFHOME=octave.sf.net:/home/groups/o/oc/octave/htdocs
## 
## 0) http://sourceforge.net/tracker/?group_id=2888&atid=102888
##    http://sourceforge.net/tracker/?group_id=2888&atid=202888
##    http://sourceforge.net/tracker/?group_id=2888&atid=302888
##
##    Try to close out all outstanding issues.
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
##    Make sure it builds and at least passes its own tests on your machine 
##    at least.
##
## 3) admin/make_index
##
##    Check the list of function that are either not found or uncategorized
##    and fix the INDEX files accordingly.
##
## 4) cvs2cl.pl -f changes
##
##    Generate a list of changes.  Use it to update www/NEWS.in and
##    www/index.in with a summary of changes.
##
## 5) make clean; make www
##
##    Build the web-pages and ancillary files.
##
## 6) admin/get_authors
##
##    Verify copyrights.  Look at the AUTHORS file to see which names
##    have been butcherd and update the corresponding sources.
##
## 7) cvs commit AUTHORS, README, www/htdocs/index.in and www/htdocs/NEWS.in
##
## 8) cvs -q update -dP
##
##    Make sure you've logged all changes to licenses and doc strings.
##
## 9) make comparepkgs
##
##    Compares the old versions of the packages on octave-forge for updates,
##    and flag any conflicts. Conflicts in the version numbering should be 
##    fixed and step 9) rerun.
##
##    Once run correctly, proceed to step 10.
##
## 10) https://sf.net/project/admin/qrs.php?package_id=2841&group_id=2888
##
##    Log in to your source forge account and announce the release of the
##    packages. Upload the packages that were identified as needing uploading
##    in step 9).
##
## 11) ./release.sh
##
##    This is the actual release step.  It tags the CVS tree.
##
## 12) Upload the webpages to sourceforge.
##
##        tar cvzf www.tar.gz www
##        scp doc/htdocs.tar.gz $OFHOME
##        ssh octave.sf.net
##        cd /home/groups/o/oc/octave/
##        rm -rf htdocs
##        tar xzf htdocs.tar.gz
##        chmod -R g+w htdocs
##
## 13) sources@octave.org, octave-dev@lists.sf.net
##
##    Announce the new release on the appropriate mailing lists.
##
## Done.

# Find the name of cvs2cl
if which cvs2cl.pl > /dev/null 2>&1; then
  CVS2CL="cvs2cl.pl"
elif which cvs2cl > /dev/null 2>&1; then
  CVS2CL="cvs2cl"
else
  echo "Can not find cvs2cl. Please visit http://www.red-bean.com/cvs2cl/"
  exit -1;
fi

# base name of the project
PROJECT=octave-forge

# use Ryyyy-mm-dd as the tag for revision yyyy.mm.dd
TAG=R`date +%Y-%m-%d`

# generate the updated ChangeLog and version command
$CVS2CL --fsf --file ChangeLog.tmp
echo "# Automatically generated file --- DO NOT EDIT" | cat - ChangeLog.tmp > ChangeLog
rm ChangeLog.tmp
cp -f ChangeLog doc/htdocs/ChangeLog

# generate the AUTHORS file
./admin/get_authors

cvs commit -m "$TAG release" ChangeLog README AUTHORS

# tag the CVS tree with the revision number
cvs rtag -F $TAG $PROJECT
