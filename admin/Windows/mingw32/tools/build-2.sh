#!/usr/bin/sh

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo $0: ACTION = "${ACTION}";

# install GCC 4.2.1-2
( cd gcc-4.2.1 && ./build-4.2.1-2.sh ${ACTION} )

# install Notepad++
( cd notepad++ && ./build-4.8.2-2.sh ${ACTION} )

# install gnuplot
( cd gnuplot && ./build-4.3.0-2008-03-24.sh ${ACTION} )

# install ATLAS
( cd atlas && ./build-3.8.1-2.sh ${ACTION} )
