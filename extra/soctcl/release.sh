# !/bin/sh

# Grab the version number from octave.tcl
octcl=`grep "variable version" octave.tcl | sed -e "s/ *variable version //"`
grep -q "octave $octcl " pkgIndex.tcl || (echo "inconsistent version in pkgIndex.tcl and octave.tcl" && exit)

# Generate the package directory as it will appear in the tcl tree
mkdir octave$octcl
mkdir octave$octcl/demo
cp demo/* octave$octcl/demo
cp *.tcl *.m *.doc README octave$octcl

# Generate the tarball
if tar czf soctcl$octcl.tar.gz octave$octcl ; then
  echo "soctcl$octcl.tar.gz built"
else
  echo "soctcl$octcl.tar.gz not built"
fi

# Generate the zip file
if find octave$octcl -print | xargs zip -q soctcl$octcl.zip ; then
  echo "soctcl$octcl.zip built"
else
  echo "soctcl$octcl.zip not built"
fi

# Remove the package directory
rm -rf octave$octcl
