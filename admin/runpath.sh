#! /bin/sh

# Walk the tree searching for all the directories that are supposed to be
# installed --- these become the new LOADPATH for octave-forge.

TESTPATH="."
for f in FIXES main/* extra/* nonfree/*; do
    # exclude CVS directories, only include directories, skip NOINSTALL
    if test $f = ${f%/CVS} -a -d $f -a ! -f $f/NOINSTALL; then 
	TESTPATH="$TESTPATH:$f"
	# if it is an install directory, also include its datapath
	if test -d $f/data; then TESTPATH="$TESTPATH:$f/data"; fi
    fi
done
echo $TESTPATH:
