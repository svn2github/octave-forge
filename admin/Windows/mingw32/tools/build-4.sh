#!/usr/bin/sh

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo $0: ACTION = "${ACTION}";

# install GCC 4.3.0-2
( cd gcc-4.4.0 && ./build-4.4.0-4.sh ${ACTION} )

# install MSYS 1.0.11
( cd msys && ./build-1.0.11-4.sh ${ACTION} )

# install Notepad++
( cd notepad++ && ./build-5.6.6-4.sh ${ACTION} )

# install gnuplot
( cd gnuplot && ./build-4.4.0-4.sh ${ACTION} )

# install ATLAS
( cd atlas && ./build-3.8.2-4.sh ${ACTION} )

# install CPUFEATURE
( cd cpufeature && ./build-1.0.0-4.sh ${ACTION} )
