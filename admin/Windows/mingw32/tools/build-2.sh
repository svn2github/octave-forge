#!/usr/bin/sh

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo $0: ACTION = "${ACTION}";

# install GCC 4.2.1-2
( cd gcc-4.2.1 && ./build-4.2.1-2.sh ${ACTION} )

# install Notepad++
( cd notepad++ && ./build-4.7.5-2.sh ${ACTION} )
