#! /bin/sh

mkdir buildc++
cd buildc++
ar x /usr/lib/libstdc++.a
gcc -shared -o/usr/bin/libstdc++.dll \
	-Wl,--enable-auto-image-base,--out-implib,/usr/lib/libstdc++.dll.a
cd ..
rm -rf buildc++
