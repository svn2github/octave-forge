#! /bin/sh

## Generate ./configure
rm -f configure.in
echo "dnl --- DO NOT EDIT --- Automatically generated by autogen.sh" > configure.in
cat configure.base >> configure.in
files=`find . -name configure.add -print`
if test ! -z "$files" ; then
  cat $files >> configure.in
fi
echo "AC_OUTPUT(Makeconf octinst.sh)" >> configure.in
autoconf && rm -f configure.in

## Generate ./Makeconf.in
rm -f Makeconf.in
cp Makeconf.base Makeconf.in
files=`find . -name Makeconf.add -print`
if test ! -z "$files" ; then
  cat $files >> Makeconf.in
fi

