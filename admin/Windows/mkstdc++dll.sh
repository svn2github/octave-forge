#! /bin/sh

# This script builds stdc++.dll and the corresponding libstdc++.dll.a.
# Now you have two choices:
#
# (1) Put libstdc++.dll.a into /usr/lib.  Now all g++ will link shared 
#     to stdc++.dll by default, but you can override it by adding
#     -static to your link line.  You should put stdc++.dll into /usr/bin
#     if you do this, and be sure to include it with any executables
#     that you distribute.
#
# (2) Put libstdc++.dll.a into a private lib directory.  All g++ will
#     continue to link statically by default, but you can override it
#     by adding -Lpath_to_private_libs to your link line.  You should
#     install stdc++.dll into the directory containing the executable,
#     and be sure to include it with any executables that you distribute.
#
# Older versions of cygwin (but not too old) require the flag 
#    -Wl,--enable-runtime-pseudo-reloc
# to link against stdc++.dll.  As of this writing, this is no
# longer required.
#
# Paul Kienzle
# 2003-07-17

mkdir buildc++
cd buildc++
ar x /usr/lib/libstdc++.a
gcc -shared -o../stdc++.dll \
	-Wl,--enable-auto-image-base,--out-implib,../libstdc++.dll.a *.o
cd ..
rm -rf buildc++
strip stdc++.dll
