#!/bin/sh
export PATH="/bin:$PATH"

echo '                Welcome to Octave'
echo
echo
echo 'Octave has been successfully installed on your computer.'
echo 'At this point the software will customize the octave'
echo 'installation for your machine.'
echo

echo 'STEP 1'
echo
echo 'There is no step one for now.'
echo
#echo 'Octave has been optimized for various computer architectures.'
#echo 'The following optimized versions of octave are available:'
#echo
#
#maxchoice=0;
#for oct in /bin/octave-2.*.*-*atlas.exe ; do 
#    maxchoice=`expr $maxchoice + 1`;
#    echo "$maxchoice: "`basename $oct .exe` ; 
#done
#
#if [ "$maxchoice" = "1" ] ; then
#    echo "Selecting default octave version: $oct";
#    choice=1;
#else
#    choice=-1;
#fi
#
#while [ "$choice" -lt 1 -o "$choice" -gt $maxchoice ] ; do
#    echo -n 'Choose which version to install:'
#    read choice;
#done
#
#idx=0 ;
#for oct in /bin/octave-2.*.*-*atlas.exe ; do 
#    idx=`expr $idx + 1`;
#    if [ "$idx" = "$choice" ] ; then
#        ln -sf $oct /bin/octave.exe ;
#    else
#        rm $oct;
#    fi
#done

echo
echo 'STEP 2'
echo
#echo 'Setting links to your active drives'
#echo 'you will be able to access C: as /C from octave'

#for drive in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ; do
#    drvmsg=`cmd /c vol $drive: 2>&1 | sed -e'
#            1d
#           s/.*system cannot find.*/NOTOK/'`;
#    if [ "$drvmsg" = "NOTOK" ] ; then
#    else 
#        echo "Creating link to drive $drive:";
#        ln -sf /cygdrive/$drive /$drive ;
#    fi
#done

echo
echo 'Setting links to your oct-files'
echo

dir=`pwd`

ARCH=i686-pc-cygwin
cd /opt/octave/libexec/octave/2.*/oct/$ARCH
for file in *.link ; do . $file ; done

cd /opt/octave/libexec/octave/2.*/site/oct/$ARCH/octave-forge
for file in *.link ; do . $file ; done

cd /bin
for file in *.link ; do . $file ; done

cd $dir

echo
echo 'STEP 3'
echo
echo 'Set Editor used by the "edit" command'
echo 'The default is currently "notepad"'
echo 'If you wish to use a different editor, enter the path and'
echo 'filename here'
echo

echo -n "Editor (currently notepad)> ";
read neweditor
if [ -z "$neweditor" ] ; then
    neweditor=notepad
fi

echo "Installing editor $neweditor into start_octave.sh"
soct="start_octave.sh"
sed -e"s! EDITOR=.*! EDITOR=\'$neweditor\'!" /bin/$soct > /tmp/$soct
mv /tmp/$soct /bin/$soct 

echo
echo 'STEP 4'
echo
echo 'In order to use the epstk graphics functions, you'
echo 'need to have a postscript interpreter. This would'
echo 'typically be gswin or ghostscript'
echo

# get the program associated for ps file types
psassoc=`cmd /c assoc .ps | sed -e's/.ps=//'`;
if [ -n "$psassoc" ] ; then
    psfile=`cmd /c ftype $psassoc | sed -e"
            s/$psassoc=//
            s/^\"//
            s/\" *\"%1\"//
            "`;
fi

if [ -f "$psfile" ] ; then
    echo "The program associated with ps files is $psfile"
    echo "To accept this program type return, otherwise,"
    echo "enter the full path of the desired ps viewer program"
else
    echo "No program is currently associated with ps files"
    echo "If you have such a program installed, enter the"
    echo "full path to the executable, otherwise type return"
fi

echo -n "New PS viewer> ";
read newpsfile
if [ -n "$newpsfile" ] ; then
    psfile=$newpsfile;
fi
if [ -n "$psfile" ] ; then
    psfile=`cygpath -msa "$psfile"`
fi

echo "Installing PS viewer at $psfile into start_octave.sh"
soct="start_octave.sh"
sed -e"s!export PS_VIEWER=!&\"$psfile\"!" /bin/$soct > /tmp/$soct
mv /tmp/$soct /bin/$soct 



echo
echo "COMPLETE"
echo
echo "Configuration of octave is now complete"
echo "Press <return> key to continue"
echo
read choice
