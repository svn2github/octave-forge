# !/bin/sh

## Run this command to build a new release tarball. This assumes that 
## the CVSROOT environment variable has been set appropriately, and 
## that autogen is available on your path.
##
## Next follow these instructions to perform the upload: 
##	1. FTP to upload.sourceforge.net 
## 	2. Login as "anonymous" 
##	3. Use your e-mail address as the password for this login 
##	4. Set your client to binary mode ("bin" on command-line clients) 
##	5. Change your current directory to /incoming ("cd /incoming") 
##	6. Upload the desired files for the release ("put filename") 
##
## Finally, log in to your source forge account and use the following
## page to announce the new release of the package:
## https://sourceforge.net/project/admin/qrs.php?package_id=2841&group_id=2888
##
## You may also want to send an announcement to 
## octave-sources@bevo.che.wisc.edu

# base name of the project
PROJECT=octave-forge

# use Ryyyy-mm-dd as the tag for revision yyyy.mm.dd
TAG=R`date +%Y-%m-%d`
ROOT=$PROJECT-`date +%Y.%m.%d`

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

