# !/bin/sh

## Run this command from the project root directory to build a new 
## release tarball. This assumes that the CVSROOT environment variable 
## has been set appropriately, and that autogen is available on your path.
## You will also need cvs2cl.pl from http://www.red-bean.com/cvs2cl/
##
## Don't forget 'cvs update' to make sure you haven't forgotten anything!
##
## Define the following in ~/.netrc:
##      machine upload.sf.net
##      login anonymous
##      password username@users.sf.net
##      macdef init
##         bin
##         cd incoming
##         mput octave-forge-*
##         bye
##      <leave this line empty!!>
##
## Finally, log in to your source forge account and use the following
## page to announce the new release of the package:
## https://sourceforge.net/project/admin/qrs.php?package_id=2841&group_id=2888
##
## You may also want to send an announcement to 
## octave-sources@bevo.che.wisc.edu
##
## You should also do:
## 	./cvs-tree > afunclist.html
## 	scp afunclist.html octave.sf.net:/home/groups/o/oc/octave/htdocs

# base name of the project
PROJECT=octave-forge

# use Ryyyy-mm-dd as the tag for revision yyyy.mm.dd
TAG=R`date +%Y-%m-%d`
ROOT=$PROJECT-`date +%Y.%m.%d`

# generate the updated ChangeLog
cvs2cl.pl --fsf --file ChangeLog.tmp
echo "# Automatically generated file --- DO NOT EDIT" | cat - ChangeLog.tmp > ChangeLog
rm ChangeLog.tmp
cvs commit -m '$TAG release' ChangeLog

# tag the CVS tree with the revision number
cvs rtag $TAG $PROJECT

# extract the tree into a tagged directory
cvs export -r $TAG -d $ROOT $PROJECT

# generate configure script
( cd $ROOT ; ./autogen.sh )

# build the tar ball
tar czf $ROOT.tar.gz $ROOT

# remove the tagged directory
rm -rf $ROOT

# optimistic: upload the file
ftp upload.sf.net

# display the ChangeLog so that you can generate a release description
more ChangeLog

