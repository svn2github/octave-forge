#! /bin/sh

# This script builds stdc++.dll and the corresponding libstdc++dll.a.
# We do not use libstdc++.dll.a since that makes all g++ programs link
# against stdc++.dll, and we would like to be able to choose shared
# or static linking. 
#
# To statically link against libstdc++.a, use g++ as usual.
# To dynamically link against stdc++.dll, use gcc with the 
# following flags:
#    -Wl,--enable-runtime-pseudo-reloc -lstdc++dll
# If you use g++, it will link against libstdc++.a even with
# the extra flags.
#
# You may also want to use
#    -Wl,--export-all-symbols
#    -Wl,--enable-auto-image-base
# The flag --enable-auto-image-base may make loading the dll 
# faster by pre-assigning non-colliding addresses for all the
# functions loaded from the DLL.

mkdir buildc++
cd buildc++
ar x /usr/lib/libstdc++.a
gcc -shared -o/usr/bin/stdc++.dll \
	-Wl,--enable-auto-image-base,--out-implib,/usr/lib/libstdc++dll.a *.o
cd ..
rm -rf buildc++
