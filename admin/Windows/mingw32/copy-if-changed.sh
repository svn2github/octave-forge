#!/usr/bin/sh
#
# Like cp $1 $2, but if the files are the same, do nothing.
# Status is 0 if $2 is changed, 1 otherwise.


case $1 in
  -*)
     shift;;
esac

if [ -d $2 ]; then
   bn=`basename $1`
   tn=$2/${bn}
else
   tn=$2;
fi

if test -e ${tn}; then
  if cmp $1 ${tn} > /dev/null; then
    echo $1 is unchanged
  else
    cp -vf $1 $2
  fi
else
  cp -vf $1 $2
fi
