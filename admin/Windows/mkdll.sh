#! /bin/sh

test $# -eq 0 && cat <<EOF && exit 1
mkdll.sh libarchive.a [outname.dll [outlib.lib]]

Converts a static library to a DLL plus a LIB for linking
to that DLL.  By default the output name is archive.

This routine goes to considerable trouble to protect
against object files of the same name in different
subdirectories.
EOF

# Get full path to archive name
archive="$1"
test "${archive#/}" = "$archive" && archive="`pwd`/$archive"
test ! -f "$archive" && echo "$archive does not exist" && exit -1 

# Get base name from /path/libbase.a
base="${archive##*/}"; base="${base#lib}"; base="${base%.a}"

# Determine dll and lib names, or default them from base
if test $# -gt 1 ; then
  dll="$2"
  if test $# -gt 2 ; then
    lib="$3"
  else
    lib="${dll%.dll}.lib"
  fi
else
  dll="$base.dll"
  lib="$base.lib"
fi

# Create a temporary directory for building the archive
test -e "/tmp/$base-dll" && echo "/tmp/$base-dll exists...remove it" && exit 1
mkdir "/tmp/$base-dll"

# extract the archive to a working directory
dir="`pwd`"
work="/tmp/$base-dll"
(cd "$work" && ar x "$archive")

# duplicate filenames in the archive need to be extracted individually 
dups=`ar t "$archive" | sort | uniq -c | grep -v '^ *1[^0-9]'`
even=0
cd "$work"
mkdir dups
for x in 0 junk $dups; do
    if test $even -eq 0; then 
	n=$x
	even=1
    else
	while test $n -gt 1; do
	    n=`expr $n - 1`
	    echo "extracting $x-$n"
	    (cd dups && ar xN $n "$archive" $x)
	    mv dups/$x $x-$n
	done
	even=0
    fi
done
rmdir dups

# Build the dll
cd "$dir"
gcc -shared "-o$dll" "-Wl,--out-implib,$lib" $work/*

# A little bit of cleanup
rm -f $work/*
rmdir $work
