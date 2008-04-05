#!/usr/bin/sh
#
# Like cp $1 $2, but if the files are the same, do nothing.
# Status is 0 if $2 is changed, 1 otherwise.

#cp -ufvp $*
#exit

case $1 in
  -*)
     shift;;
esac


src="";
tgt="";
until [ "0" == "1" ];
do
   src="${src} $1"
   tgt=$2;
   if [ "$3" == "" ]; then 
      break;
   fi
   shift;
done;

for a in $src; do 
   if [ -d $tgt ]; then
      bn=`basename $a`
      tn=$tgt/${bn}
   else
      tn=$tgt;
   fi
   
   if test -e ${tn}; then
      if cmp $a ${tn} > /dev/null; then
         echo $a is unchanged
      else
         cp -vfp $a $tgt
      fi
   else
      cp -vfp $a $tgt
   fi
done
