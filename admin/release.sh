#! /bin/sh

## These are the steps you need to take to do a new octave-forge release.
## You will need:
##    * svn2cl.pl from http://ch.tudelft.nl/~arthur/svn2cl/
##    * perl, python, and the texinfo toolchain
##    * autoconf
##    * wget
##    * The latest release of Octave installed in ${topdir}/../octave
##
## You should also have the following in your .bashrc:
## 
##    export OFHOME=octave.sf.net:/home/groups/o/oc/octave
## 
## 0) http://sourceforge.net/tracker/?group_id=2888&atid=102888
##    http://sourceforge.net/tracker/?group_id=2888&atid=202888
##    http://sourceforge.net/tracker/?group_id=2888&atid=302888
##
##    Try to close out all outstanding issues.
##
## 1) svn status -u
##
##    Make sure you haven't forgetten to post anything.  Indexing will 
##    be more reliable if you don't have extra files that you don't 
##    intend to post.  You may want to start with a fresh copy
##    of the repository in a separate directory.
##
## 2) ./autogen.sh; ./configure; make clean; make all; make check
##
##    Fix any versioning errors identified by "make all".
##
##    Make sure it builds and at least passes its own tests on your machine 
##    at least.
##
## 3) make www; admin/make_index
##
##    Check the list of function that are either not found or uncategorized
##    and fix the INDEX files accordingly.
##
## 4) svn2cl -f changes
##
##    Generate a list of changes.  Use it to update www/NEWS.in and
##    www/index.in with a summary of changes.
##
## 5) make clean; make all; make www
##
##    Build the web-pages and ancillary files.
##
## 6) admin/get_authors
##
##    Verify copyrights.  Look at the AUTHORS file to see which names
##    have been butcherd and update the corresponding sources.
##
## 7) svn commit AUTHORS, README, www/htdocs/index.in and www/htdocs/NEWS.in
##
## 8) svn status -u
##
##    Make sure you've logged all changes to licenses and doc strings.
##
## 9) ./release.sh
##
##    This is the actual release step.  It tags the SVN tree.
##
## 10) Upload the webpages to sourceforge.
##
##        scp doc/htdocs.tar.gz $OFHOME
##        ssh octave.sf.net
##        cd /home/groups/o/oc/octave/
##        rm -rf htdocs
##        tar xzf htdocs.tar.gz
##        chmod -R g+w htdocs
##
## 11) Use releaseforge (cf http://releaseforge.sf.net) to upload the 
##     packages to the sourceforge file release system. Packages needing
##     uploading were identified in step 2).
##
##     Finish upload process in the sourceforge admin system at
##     https://sf.net/project/admin/qrs.php?package_id=2841&group_id=2888
## 
## 12) sources@octave.org, octave-dev@lists.sf.net
##
##    Announce the new release on the appropriate mailing lists.
##
## Done.

# Find the name of svn2cl
if which svn2cl.pl > /dev/null 2>&1; then
  SVN2CL="svn2cl.pl"
elif which svn2cl > /dev/null 2>&1; then
  SVN2CL="svn2cl"
else
  echo "Can not find svn2cl. Please visit http://ch.tudelft.nl/~arthur/svn2cl/"
  exit -1;
fi

# base name of the project
PROJECT=octave-forge

# use Ryyyy-mm-dd as the tag for revision yyyy.mm.dd
TAG=R`date +%Y-%m-%d`

# generate the updated ChangeLog and version command
$SVN2CL --fsf --file ChangeLog.tmp
echo "# Automatically generated file --- DO NOT EDIT" | cat - ChangeLog.tmp > ChangeLog
rm ChangeLog.tmp
cp -f ChangeLog doc/htdocs/ChangeLog

# generate the AUTHORS file
./admin/get_authors

svn commit -m "$TAG release" ChangeLog README AUTHORS

# tag the SVN tree with the revision number
svn copy trunk tags/$TAG
