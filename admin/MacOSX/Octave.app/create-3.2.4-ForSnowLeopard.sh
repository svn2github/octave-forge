## Copyright (C) 2010   Todd V. Rovito   <rovitotv@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.
#
# Todd Rovito changed the script to support Mac OSX 10.6 (Snow Leopoard), 
# it still needs some work but it functions.
#
# Original Author Thomas Treichl (Thomas.Treichl@gmx.net)
# Recent modfications made by Todd V Rovito (rovitotv@gmail.com)
#
# Pre-Install steps
# 
# Change one of the Mac OSX Header files like so:
# Finally, having gotten tired of setting the _REENTRANT flag,
# I patched one of the Xcode headers to turn on lgamma_r and
# lgammal_r unconditionally.  These tests seemed pretty
# silly to me.  See /usr/include/architecture/i386/math.h
# at line 625.
# 
#
#!/bin/bash

#set -euv

file_curl_md5() {
  if [ $# -ne 3 ]; then
    echo "$vths: Function file_curl requires 3 input args"
    exit 1
  fi
  if [ ! -f $2 ]; then
    echo "$vths: Downloading file $2"
    /usr/bin/curl -s -S $1 --create-dirs -o $2
  fi
  if [ `md5 -q $2` != $3 ]; then
    echo "$vths: md5 checksum test of $2 failed"
    exit 1
  fi
}

prepare() {
  {sed,bison,flex,gawk} --version
  install -d $vprf/{bin,include,lib,share}
}

conf_make_inst() {
  if [ $# -ne 1 ]; then
    echo "$vths: Function conf_make_inst requires 1 input argument"
    exit 1
  else
    echo "$vths: Configuring $vpack..."
    eval "$vbsh ./configure $1 >> $vmsg 2>&1"
    echo "$vths: Compiling $vpack..."
    eval "$vbsh make >> $vmsg 2>&1"
    echo "$vths: Installing $vpack..."
    eval "$vbsh make install >> $vmsg 2>&1"
  fi
}

create_arpack() {
  vpack="arpack"
  vsrv=http://ftp.de.debian.org/debian/pool/main/a/arpack/
  varp=(arpack_2.1+parpack96.dfsg.orig.tar.gz 914186892030523e9d2e0f08b93212b4)
  vapp=(./patches/arpack-2.1+parpack96.dfsg.macosx.diff.gz 50fa1e5801c7ec6d07bab1a3a571d591)

  rm -rf ./work/arpack-2.1+parpack96.dfsg
  file_curl_md5 $vsrv/${varp[0]} ./work/${varp[0]} ${varp[1]}
  tar -C ./work -vxzf ./work/${varp[0]} >> $vmsg 2>&1

  file_curl_md5 ${vapp[0]} ${vapp[0]} ${vapp[1]}
  gunzip -c ${vapp[0]} | patch -d ./work -p0

  cd ./work/arpack-2.1+parpack96.dfsg
  # eval "$vbsh F77=\"$vf77\" F77FLAGS=\"$vffl\" make clean >> $vmsg 2>&1"
  eval "$vbsh WORK=`pwd` F77=\"$vf77\" F77FLAGS=\"$vffl\" make lib >> $vmsg 2>&1"
  install libarpack.a $vprf/lib
  cd $vpwd

  # local vnam=`find . -iname *.o`
  # eval "$vbsh $vgcc $vopt $vcfl -dynamiclib -single_module \
  #   -Wl,-headerpad_max_install_names -install_name libarpack.dylib \
  #   -o libarpack.dylib `echo $vnam` -Wl,-framework -Wl,vecLib -lf95 \
  #   -L/tmp/deps-ppc/lib/gcc-lib/powerpc-apple-darwin6.8/4.0.3 >> $vmsg 2>&1"
}

create_curl() {
  vpack="curl"
  vsrv=http://ftp.de.debian.org/debian/pool/main/c/curl
  vred=(curl_7.18.2.orig.tar.gz 4fe99398a64a34613c9db7bd61bf6e3c)

  rm -rf ./work/curl-7.18.2
  file_curl_md5 $vsrv/${vred[0]} ./work/${vred[0]} ${vred[1]}
  tar -C ./work -vxzf ./work/${vred[0]} >> $vmsg 2>&1
  cd ./work/curl-7.18.2
  # conf_make_inst "$vcnf --enable-ldaps --enable-sspi --with-libidn \
  #   --enable-ares --with-spnego --with-gssapi --with-krb4 \
  #   --enable-shared --disable-static"
  conf_make_inst "$vcnf --enable-shared --disable-static"
  cd $vpwd
}

create_fftw() {
  vpack="fftw"
  vsrv=http://ftp.de.debian.org/debian/pool/main/f/fftw3
  vfft=(fftw3_3.1.2.orig.tar.gz 08f2e21c9fd02f4be2bd53a62592afa4)

  file_curl_md5 $vsrv/${vfft[0]} ./work/${vfft[0]} ${vfft[1]}
  tar -C ./work -vxzf ./work/${vfft[0]} >> $vmsg 2>&1
  cd ./work/fftw-3.1.2

  case $vprc in
    ppc)  local vtmp="";; # "--enable-altivec";;
    i386) local vtmp="--enable-fma --enable-sse2";;
    *)    exit 1;;
  esac

  conf_make_inst "$vcnf $vtmp --enable-shared --disable-static"
  cd $vpwd; rm -rf ./work/fftw-3.1.2
  
  tar -C ./work -vxzf ./work/${vfft[0]} >> $vmsg 2>&1
  cd ./work/fftw-3.1.2
  conf_make_inst "$vcnf --enable-float --enable-shared --disable-static"
  cd $vpwd
}

create_fltk() {
   vpack="fltk"
	# to get FLTK to work I had to download v1.1.10 from fltk.org then
	# I applied this patch
	# Index: configure.in
	# ===================================================================
	# --- configure.in	(revision 6978)
	# +++ configure.in	(working copy)
	# @@ -94,6 +94,7 @@
	#	CFLAGS="$CFLAGS -arch i386"
	#	CXXFLAGS="$CXXFLAGS -arch i386"
	#	LDFLAGS="$LDFLAGS -arch i386"
	# +            DSOFLAGS="$DSOFLAGS -arch i386" 
	# 	fi
	#	;;
	# esac
	# this patch was posted on the FLTK web site here:
	# http://www.mail-archive.com/fltk-dev@easysw.com/msg03624.html
	# TO-DO: Change the script so it downloads the proper version.
	# TO-DO: Change the script so it automatically applies the patch.

  #vsrv=http://ftp.de.debian.org/debian/pool/main/f/fltk1.1
  vflt=(fltk-1.1.10-source.tar.bz2 d3c76db1b6cebce7a009429bbd125470)
  vflp=(./patches/fltk-macosx.diff.gz c2dbbe6a50e94749deb159b74531ff96)

  #file_curl_md5 $vsrv/${vflt[0]} ./work/${vflt[0]} ${vflt[1]}
  tar -C ./work -vxzf ./work/${vflt[0]} >> $vmsg 2>&1
  gunzip -c ${vflp[0]} | patch -d ./work/fltk-1.1.10 -p0

  cd ./work/fltk-1.1.10
  # --enable-quartz --enable-threads
  echo $vcnf
  # conf_make_inst "$vcnf --without-x --enable-quartz --enable-threads --enable-shared --disable-static  LDFLAGS=\"-Wl,-headerpad_max_install_names -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk\""
  conf_make_inst "$vcnf --without-x --enable-quartz --enable-threads --enable-shared --disable-static"
  rm -f $vprf/lib/libfltk*.a
  cd $vpwd
}

create_fltk_1_3_x() {
  vsrv=http://ftp.rz.tu-bs.de/pub/mirror/ftp.easysw.com/ftp/pub/fltk/snapshots
  vflt=(fltk-1.3.x-r6700.tar.gz 440b3420fb078c10afef1fbc6f2df920)

  file_curl_md5 $vsrv/${vflt[0]} ./work/${vflt[0]} ${vflt[1]}
  tar -C ./work -vxzf ./work/${vflt[0]} >> $vmsg 2>&1
  cd ./work/fltk-1.3.x-r6700
  # --enable-quartz --enable-threads
  conf_make_inst "$vcnf --without-x --enable-quartz --enable-threads --enable-shared --disable-static"
  rm -f $vprf/lib/libfltk*.a
  cd $vpwd
}

create_freetype() {
  vpack="freetype"
  vsrv=http://ftp.de.debian.org/debian/pool/main/f/freetype
  vftp=(freetype_2.3.7.orig.tar.gz c1a9f44fde316470176fd6d66af3a0e8)

  file_curl_md5 $vsrv/${vftp[0]} ./work/${vftp[0]} ${vftp[1]}
  tar -C ./work -vxzf ./work/${vftp[0]} >> $vmsg 2>&1
  tar -C ./work -vxjf ./work/freetype-2.3.7/freetype-2.3.7.tar.bz2 >> $vmsg 2>&1

  cd ./work/freetype-2.3.7
  conf_make_inst "$vcnf --enable-shared --disable-static"
  rm -rf $vprf/include/freetype
  cp -R -P -p  $vprf/include/freetype2/freetype $vprf/include
  rm -rf $vprf/include/freetype2
  cd $vpwd
}

create_ftgl() {
  vpack="ftgl"
  vsrv=http://ftp.de.debian.org/debian/pool/main/f/ftgl
  vftg=(ftgl_2.1.3~rc5.orig.tar.gz fcf4d0567b7de9875d4e99a9f7423633)

  file_curl_md5 $vsrv/${vftg[0]} ./work/${vftg[0]} ${vftg[1]}
  tar -C ./work -vxzf ./work/${vftg[0]} >> $vmsg 2>&1
  cd ./work/ftgl-2.1.3~rc5
  conf_make_inst "$vcnf --without-x --enable-shared --disable-static"
  cd $vpwd
}

# We are using gfortran from here:
#      http://r.research.att.com/gfortran-42-5646.pkg
# See email from Michael Godfrey here:
#      http://old.nabble.com/Install-status-on-Mac-OS-X-10.6.2-td27085759.html
# I removed this function from the main and placed into the pre-install steps
create_g95() {
  vpack="g95"
  case $vprc in
    ppc)
      local vfil=g95-powerpc-osx.tgz
      local vmd5=98393e01fa2cab68e3b711bf4c470903;;
    i386)
      local vfil=g95-x86-osx.tgz
      local vmd5=02bfb9879cf2d915de395d12dd4344f4;;
    *) exit 1;;
  esac

  local vsrc="http://ftp.g95.org/v0.91/$vfil"
  local vdes=./work/$vfil

  file_curl_md5 $vsrc $vdes $vmd5
  tar -C ./work -vxzf $vdes >> $vmsg 2>&1
  cp -R -P -p ./work/g95-install/* $vprf
  install -d $vprf/share/doc/g95
  mv $vprf/{G95Manual.pdf,INSTALL} $vprf/share/doc/g95
}

create_glpk() {
  vpack="glpk"
  vsrv=http://ftp.de.debian.org/debian/pool/main/g/glpk
  vglp=(glpk_4.29.orig.tar.gz 1e2d341619162499bbdebc96ca1d99a4)

  file_curl_md5 $vsrv/${vglp[0]} ./work/${vglp[0]} ${vglp[1]}
  tar -C ./work -vxzf ./work/${vglp[0]} >> $vmsg 2>&1
  cd ./work/glpk-4.29
  conf_make_inst "$vcnf --with-zlib --disable-static"
  mkdir $vprf/include/glpk
  ln -s $vprf/include/glpk.h $vprf/include/glpk/glpk.h
  cd $vpwd
}

create_graphicsmagick() {
  vpack="graphicsmagick"
  vsrv=http://ftp.de.debian.org/debian/pool/main/g/graphicsmagick
  vgmc=(graphicsmagick_1.1.11.orig.tar.gz 16a032350a153d822ac07cae01961a91)

  file_curl_md5 $vsrv/${vgmc[0]} ./work/${vgmc[0]} ${vgmc[1]}
  tar -C ./work -vxzf ./work/${vgmc[0]} >> $vmsg 2>&1
  cd ./work/GraphicsMagick-1.1.11
  conf_make_inst "$vcnf --enable-shared=yes --without-x \
    --enable-static=no --with-perl=no --without-gslib --disable-installed"
  cd $vpwd
}

create_hdf5() {
  vpack="hdf5"
  vsrv=http://ftp.de.debian.org/debian/pool/main/h/hdf5
  vhdf=(hdf5_1.6.6.orig.tar.gz 6c7fcc91f1579555d88bb10c6c9a33a9)
  vhdp=(hdf5_1.6.6-4.diff.gz   3976fab00d8834ff151da989efeb9821)

  file_curl_md5 $vsrv/${vhdf[0]} ./work/${vhdf[0]} ${vhdf[1]}
  tar -C ./work -vxzf ./work/${vhdf[0]} >> $vmsg 2>&1

  file_curl_md5 $vsrv/${vhdp[0]} ./work/${vhdp[0]} ${vhdp[1]}
  gunzip -c ./work/${vhdp[0]} | patch -d ./work -p0

  cd ./work/hdf5-1.6.6
  # autoreconf
  # local vtmp="CFLAGS=\"$varc $vcfl -I$vinc\" CPPFLAGS=\"-I$vinc\" \
  #   CXXFLAGS=\"$varc $vcfl -I$vinc\" FFLAGS=\"$vffl\" F77=\"$vf77\" \
  #   --prefix=$vprf --enable-cxx --disable-static --enable-fortran"
  local vtmp="CFLAGS=\"$varc $vcfl -I$vinc\" CPPFLAGS=\"-I$vinc\" \
    --prefix=$vprf --disable-cxx --disable-static"
  conf_make_inst "$vtmp"
  cd $vpwd
}

create_jpg() {
  vpack="jpg"
  vsrv=http://ftp.de.debian.org/debian/pool/main/libj/libjpeg6b
  vjpg=(libjpeg6b_6b.orig.tar.gz dbd5f3b47ed13132f04c685d608a7547)
  vjpp=(./patches/libjpeg6b_6b.macosx.diff.gz 4832c1b76408e255d1760a95a4acd3fb)

  file_curl_md5 $vsrv/${vjpg[0]} ./work/${vjpg[0]} ${vjpg[1]}
  tar -C ./work -vxzf ./work/${vjpg[0]} >> $vmsg 2>&1

  file_curl_md5 ${vjpp[0]} ${vjpp[0]} ${vjpp[1]}
  gunzip -c ${vjpp[0]} | patch -d ./work -p0

  cd ./work/jpeg-6b
  
  # chmod a=rwx libtool
  eval "$vbsh ./configure $vcnf --disable-shared --without-x >> $vmsg 2>&1"
  eval "$vbsh make >> $vmsg 2>&1"
  eval "$vbsh make install-lib >> $vmsg 2>&1"
  cd $vpwd
}

create_octave() {
  vpack="octave"
  # TVR had to patch for an error in 3.2.3 code due to gamma function. Here is
  # the post:
  #    http://www-old.cae.wisc.edu/pipermail/octave-maintainers/2009-August/013180.html
  
  local version=3.2.4

  #vsrv=ftp://ftp.octave.org/pub/octave
  voct=(octave-3.2.4.tar.bz2 a3805ed3838c76f4973d1ef7615d5f3c)
  #vopc=(./patches/octave-3.2.3.macosx.diff.gz 43acbd5d8d4eb8929c116b60b4f54ee3)

  rm -rf ./work/octave-$version
  #file_curl_md5 $vsrv/${voct[0]} ./work/${voct[0]} ${voct[1]}
  tar -C ./work -vxjf ./work/${voct[0]} >> $vmsg 2>&1
  cd ./work/octave-$version
  echo "$vcnf --without-x --enable-shared --disable-static"
  conf_make_inst "$vcnf --without-x --enable-shared --disable-static"
  #./configure "F77=gfortran -ff2c" LDFLAGS="-L/tmp/deps-i386/lib" CC="gcc -arch i386 -I/tmp/deps-i386/include" CPP="gcc -arch i386 -E" CXX="g++ -arch i386" CFLAGS="-O0 -march=i686 -msse3 -msse2 -msse -mmmx -J2"
  #make
  #make install

  echo "Replacing strings in mkoctfile-$version ..."
  sed -i.orig $vprf/bin/mkoctfile-$version \
    -e "s:$vcfl:$vopt:g" \
    -e "s:[ \t]*$varc::g" \
    -e "s:/private$vprf:\${0%%/bin/mkoctfile-$version}:g" \
    -e "s:$vprf:\${0%%/bin/mkoctfile-$version}:g"
    
  echo "Replacing strings in octave-config-$version ..."
  sed -i.orig $vprf/bin/octave-config-$version \
    -e "s:$vprf:\${0%%/bin/octave-config-$version}:g"
    
  mkdir $vprf/lib/octave-$version
  cp src/liboctinterp.dylib $vprf/lib/octave-$version/

  cd $vpwd
}

create_openjpeg() {
  vpack="openjpeg"
  vsrv=http://ftp.de.debian.org/debian/pool/main/o/openjpeg
  vjp2=(openjpeg_1.3+dfsg.orig.tar.gz 5fd807abf8a71adb021181d2790eda86)

  file_curl_md5 $vsrv/${vjp2[0]} ./work/${vjp2[0]} ${vjp2[1]}
  tar -C ./work -vxzf ./work/${vjp2[0]} >> $vmsg 2>&1
  cd ./work/openjpeg-1.3+dfsg.orig
  conf_make_inst "$vcnf --help --disable-static"
  cd $vpwd
}

create_pcre() {
  vpack="pcre"
  vsrv=http://ftp.de.debian.org/debian/pool/main/p/pcre3
  vpcr=(pcre3_7.6.orig.tar.gz b94cce871f70734c2dfc47b52a3aa670)

  file_curl_md5 $vsrv/${vpcr[0]} ./work/${vpcr[0]} ${vpcr[1]}
  tar -C ./work -vxzf ./work/${vpcr[0]} >> $vmsg 2>&1
  cd ./work/pcre-7.6
  conf_make_inst "$vcnf --enable-pcregrep-libz --enable-unicode-properties \
    --enable-pcretest-libreadline --disable-static"
  #./configure --prefix=/tmp/deps-i386/
  #make
  #make install
  cd $vpwd
}

create_png() {
  vpack="png"
  vsrv=http://ftp.de.debian.org/debian/pool/main/libp/libpng
  vpng=(libpng_1.2.41.orig.tar.bz2 2faa7f8d81e6a35beb991cb75edbf056)

  file_curl_md5 $vsrv/${vpng[0]} ./work/${vpng[0]} ${vpng[1]}
  tar -C ./work -vxjf ./work/${vpng[0]} >> $vmsg 2>&1
  cd ./work/libpng-1.2.41
  conf_make_inst "$vcnf --enable-static --disable-shared --with-binconfigs"
  cd $vpwd
}

create_readline() {
  vpack="readline"
  vsrv=http://ftp.de.debian.org/debian/pool/main/r/readline5
  vred=(readline5_5.2.orig.tar.gz e39331f32ad14009b9ff49cc10c5e751)

  file_curl_md5 $vsrv/${vred[0]} ./work/${vred[0]} ${vred[1]}
  tar -C ./work -vxzf ./work/${vred[0]} >> $vmsg 2>&1
  cd ./work/readline-5.2
  conf_make_inst "$vcnf --disable-static"
  cd $vpwd
}

create_qhull() {
  vpack="qhull"
  vsrv=http://ftp.de.debian.org/debian/pool/main/q/qhull
  vqhu=(qhull_2003.1.orig.tar.gz 48228e26422bff85ef1f45df5b6e3314)

  file_curl_md5 $vsrv/${vqhu[0]} ./work/${vqhu[0]} ${vqhu[1]}
  tar -C ./work -vxzf ./work/${vqhu[0]} >> $vmsg 2>&1
  cd ./work/qhull-2003.1
  conf_make_inst "$vcnf --disable-static"
  cd $vpwd
}

create_qrupdate() {
  vpack="qrupdate"
  vsrv=http://freefr.dl.sourceforge.net/sourceforge/qrupdate
  vqru=(qrupdate-1.0.tar.gz 9574e6ac7b921e9fd874edd610e28b1c)
  vqrp=(./patches/qrupdate-1.0.macosx.diff.gz d8aaf5ece9d1ce7dcbec994be9e28763)

  rm -rf ./work/qrupdate
  #file_curl_md5 $vsrv/${vqru[0]} ./work/${vqru[0]} ${vqru[1]}
  tar -C ./work -vxzf ./work/${vqru[0]} >> $vmsg 2>&1

  file_curl_md5 ${vqrp[0]} ${vqrp[0]} ${vqrp[1]}
  gunzip -c ${vqrp[0]} | patch -d ./work -p0

  cd ./work/qrupdate
  # eval "$vbsh F77=\"$vf77\" F77FLAGS=\"$vffl\" make clean >> $vmsg 2>&1"
  eval "$vbsh F77=\"$vf77\" F77FLAGS=\"$vffl\" make lib >> $vmsg 2>&1"
  eval "$vbsh F77=\"$vf77\" F77FLAGS=\"$vffl\" make test >> $vmsg 2>&1"
  install libqrupdate.a $vprf/lib
  # ar -x libqrupdate.a
  # eval "$vbsh $vf77 $vffl -dynamiclib -single_module -Wl,-framework -Wl,vecLib \
  #   src/*.o >> $vmsg 2>&1"
  cd $vpwd
}

create_ssh() {
  vpack="ssh"
  vsrv=http://ftp.de.debian.org/debian/pool/main/libs/libssh
  vssh=(libssh_0.2+svn20070321.orig.tar.gz c7be3f35da727477b1e98ee7413ca5e6)

  file_curl_md5 $vsrv/${vssh[0]} ./work/${vssh[0]} ${vssh[1]}
  tar -C ./work -vxzf ./work/${vssh[0]} >> $vmsg 2>&1
  cd ./work/libssh-0.2+svn20070321
  conf_make_inst "$vcnf --disable-static"
  cd $vpwd
}

create_suitesparse() {
  vpack="suiteparse"
  vsrv=http://ftp.de.debian.org/debian/pool/main/s/suitesparse
  vsus=(suitesparse_3.1.0.orig.tar.gz 58d90444feef92fc7c265cbd11a757c6)
  vssp=(./patches/suitesparse-3.1.0.macosx.diff.gz 487b366d2ec08f57ef00fc005b756185)

  file_curl_md5 $vsrv/${vsus[0]} ./work/${vsus[0]} ${vsus[1]}
  tar -C ./work -vxzf ./work/${vsus[0]} >> $vmsg 2>&1

  file_curl_md5 ${vssp[0]} ${vssp[0]} ${vssp[1]}
  gunzip -c ${vssp[0]} | patch -d ./work -p0

  cd ./work/SuiteSparse
  local vtmp="$vbsh CC=\"$vgcc\" CFLAGS=\"$vcfl -fno-common -no-cpp-precomp \
    -fexceptions -D_POSIX_C_SOURCE -D__NOEXTENSIONS__ -DNPARTITION\" PREFIX=$vprf"
  eval "$vtmp make >> $vmsg 2>&1"
  eval "$vtmp make install >> $vmsg 2>&1"
  cd $vpwd
}

create_tiff() {
  vpack="tiff"
  vsrv=http://ftp.de.debian.org/debian/pool/main/t/tiff
  vtif=(tiff_3.8.2.orig.tar.gz e6ec4ab957ef49d5aabc38b7a376910b)

  file_curl_md5 $vsrv/${vtif[0]} ./work/${vtif[0]} ${vtif[1]}
  tar -C ./work -vxzf ./work/${vtif[0]} >> $vmsg 2>&1
  tar -C ./work -vxzf ./work/tiff-3.8.2/tiff-3.8.2.tar.gz >> $vmsg 2>&1

  cd ./work/tiff-3.8.2
  conf_make_inst "$vcnf --without-x --with-apple-opengl-framework --disable-shared"
  cd $vpwd
}

create_zlib() {
  vpack="zlib"
  # The link /Developer/SDKs/MacOSX10.4u.sdk/usr/lib/libz.dylib has
  # to be removed, otherwise the SDK internal libz is found and this
  # results in a bug while linking.

  vsrv=http://ftp.de.debian.org/debian/pool/main/z/zlib
  vzlb=(zlib_1.2.3.3.dfsg.orig.tar.gz 39ae1c6fbdd3b98d4fa9af25206202c5)

  file_curl_md5 $vsrv/${vzlb[0]} ./work/${vzlb[0]} ${vzlb[1]}
  tar -C ./work -vxzf ./work/${vzlb[0]} >> $vmsg 2>&1

  cd ./work/zlib-1.2.3.3.dfsg
  local vtmp="$vbsh CC=\"$vgcc\" CFLAGS=\"$vcfl\" PREFIX=\"$vcfl\""
  eval "$vtmp ./configure --prefix=${vprf} --shared >> $vmsg 2>&1"
  eval "make && make install >> $vmsg 2>&1"
  # rm -f $vprf/lib/libz.a
  cd $vpwd
}

# For gnuplot to work well we should build AquaTerm from SourceForge and make
# sure gnuplot builds with AquaTerm support.  Read the INSTALL file and make sure
# to make the sym links so gnuplot will find AquaTerm.  If AquaTerm is not included
# then make sure the following is added to ~/.octaverc "setenv ("GNUTERM", "x11")".
# TODO: Add aquaterm to the create script.
create_gnuplot() {
  vgnuplot=(gnuplot-4.2.6.tar.gz c10468d74030e8bed0fd6865a45cf1fd)
  tar -C ./work -vxzf ./work/${vgnuplot[0]} >> $vmsg 2>&1
  
  cd ./work/gnuplot-4.2.6
  conf_make_inst "$vcnf"
  
  cd $vpwd
}

clear_dirs() {
  rm -rf $vprf
  cd ./work
  rm -rvf \
    GraphicsMagick-1.1.11 SuiteSparse arpack-2.1+parpack96.dfsg \
    curl-7.18.2 fftw-3.1.2 fltk-1.1.9 freetype-2.3.7 \
    ftgl-2.1.3~rc5 g95-install glpk-4.29 hdf5-1.6.6 \
    jpeg-6b libpng-1.2.36 octave-3.2.3 pcre-7.6 \
    qhull-2003.1 qrupdate readline-5.2 tiff-3.8.2 \
    zlib-1.2.3.3.dfsg
  cd $vpwd
}

####################################################################################
# Start the main procedure
if [ $# -ne 2 ]; then
  echo "Script $vths usage:"
  echo "  The first given argument must specify the platform (either -ppc or -i386)"
  echo "  The second given argument must be the name of a package (eg. -octave)"
  exit 1
fi

numberOfCPUS=2

case $1 in
  -ppc | -PPC)
      vprc=ppc
      vf77=powerpc-apple-darwin6.8-g95
      varc="-arch ppc"
      vopt="-O3 -mpowerpc -faltivec -maltivec -mabi=altivec"
      vhst="--host=powerpc-apple-darwin8.11.1"
    ;;
  -i386 | -I386)
      vprc=i386
      vf77=i386-apple-darwin8.11.1-g95
      varc="-arch i386"
      #vopt="-O3 -fforce-addr -march=i686 -mfpmath=sse,387 -mieee-fp -msse3 -msse2 -msse -mmmx"
      # TVR removed some of these options because compiles were not completing
      #vopt="-O2 -mfpmath=sse,387 -march=prescott"
	  vopt=""
      vhst="--host=i386-apple-darwin8.11.1"
    ;;

    *) echo "Unknown first input argument $1"; exit 1;;
esac

vths=${0##*/}         # The name of this file without any path information
vmsg=/tmp/build.log   # The file to which the output is written, eg. /dev/stdout
vprf=/tmp/deps-$vprc  # The directory where all libs and progs are installed
vpwd=`pwd`            # The name of the current directory that is saved
vbin=$vprf/bin:$PATH

vinc=$vprf/include
vx11=/usr/X11R6/include

vgcc="gcc $varc"
vcpp="$vgcc -E"
vcxx="g++ $varc"

# Please see note about fortran compiler first in the create_g95 function.
# I changed the sysroot to 10.6 which worked ok until I switched fortran compilers.
# After I switched fortran compilers I had to remove the sysroot all togther. The 
# down side of this approach is the binary is now limited to 10.6 only I bet, need
# to confirm.  Most likely caused because the new fortran compiler is for 10.6 only.
#
# vcfl="$vopt -isysroot /Developer/SDKs/MacOSX10.4u.sdk -I$vinc -I$vx11"


vcfl="$vopt -isysroot /Developer/SDKs/MacOSX10.6.sdk -I$vinc -J$numberOfCPUS"
vffl="$vopt -isysroot /Developer/SDKs/MacOSX10.6.sdk -I$vinc"

vldf="-L$vprf/lib -Wl,-headerpad_max_install_names \
  -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk"

vbsh="MACOSX_DEPLOYMENT_TARGET=10.6 DYLD_LIBRARY_PATH=${vprf}/lib \
  DYLD_FALLBACK_LIBRARY_PATH=${vprf}/lib PATH=${vprf}/bin:${PATH}"

vcnf="CC=\"$vgcc\" CPP=\"$vcpp\" CXX=\"$vcxx\" F77=\"$vf77\" \
 CFLAGS=\"$vcfl\" CPPFLAGS=\"$vcfl\" CXXFLAGS=\"$vcfl\" FFLAGS=\"$vffl\" \
 LDFLAGS=\"$vldf\" --prefix=$vprf $vhst"


#vcfl="$vopt  -J$numberOfCPUS -I$vinc -I$vx11"
#vcfl="$vopt  -I$vinc -I$vx11"
#vffl="$vopt -I$vinc -mieee-fp"

#vldf="-L$vprf/lib"

#vbsh="MACOSX_DEPLOYMENT_TARGET=10.6 DYLD_LIBRARY_PATH=${vprf}/lib \
#  DYLD_FALLBACK_LIBRARY_PATH=${vprf}/lib PATH=${vprf}/bin:${PATH}"

#vcnf="CC=\"$vgcc\" CPP=\"$vcpp\" CXX=\"$vcxx\" F77=\"$vf77\" \
# CFLAGS=\"$vcfl\" CPPFLAGS=\"$vcfl\" CXXFLAGS=\"$vcfl\" FFLAGS=\"$vffl\" \
# LDFLAGS=\"$vldf\" --prefix=$vprf $vhst"

echo "vopt: $vopt" >> $vmsg 2>&1
echo "vcfl: $vcfl" >> $vmsg 2>&1
echo "vldf: $vldf" >> $vmsg 2>&1
echo "vbsh: $vbsh" >> $vmsg 2>&1
echo "vcnf: $vcnf" >> $vmsg 2>&1
echo "varc: $varc" >> $vmsg 2>&1
echo "vhst: $vhst" >> $vmsg 2>&1
 
case $2 in
  -arpack)         create_arpack;;
  -curl)           create_curl;;
  -fftw)           create_fftw;;
  -fltk)           create_fltk;;
  -freetype)       create_freetype;;
  -ftgl)           create_ftgl;;
  -g95)            create_g95;;
  -glpk)           create_glpk;;
  -gnuplot)	   create_gnuplot;;
  -graphicsmagick) create_graphicsmagick;;
  -hdf5)           create_hdf5;;
  -jpg)            create_jpg;;
  -octave)         create_octave;;
# -openjpeg)       create_openjpeg;;
  -png)            create_png;;
  -pcre)           create_pcre;;
  -qhull)          create_qhull;;
  -qrupdate)       create_qrupdate;;
  -readline)       create_readline;;
# -ssh)            create_ssh;;
  -suitesparse)    create_suitesparse;;
  -tiff)           create_tiff;;
  -zlib)           create_zlib;;

  -clear) clear_dirs;;

  -libs) prepare
         create_zlib
         create_readline
         create_pcre
         create_hdf5
         create_fftw
#        create_ssh
         create_curl
         create_glpk
         create_qhull
         create_suitesparse
         create_arpack
         create_qrupdate
         create_arpack
	 ;;

  -graph) prepare
          create_freetype
          create_ftgl
          create_fltk
	  ;;

  -image) prepare
          create_jpg
#         create_openjpeg
          create_png
          create_tiff
          create_graphicsmagick
	  ;;

  -all) prepare
        eval "./$vths $1 -g95"
        eval "./$vths $1 -libs"
        eval "./$vths $1 -graph"
        eval "./$vths $1 -image"
        eval "./$vths $1 -gnuplot"
        create_octave
	;;

  *) echo "Unknown second input argument $2"; exit 1;;
esac

# copy the build file to the /tmp/deps-i386 directory
cp /tmp/build.log $vpwd



# build history and changes are documented here
# 2010-01-23 Tried the following options vopt="-O2 -J2" failed tests
#
# 2010-01-24 Tried the following options vopt="-march=i686 -J2"
# Compile error here:
# Undefined symbols:
#  "_XOpenDisplay", referenced from:
#      display_info::init(bool)  in display.o
#  "_XScreenNumberOfScreen", referenced from:
#      display_info::init(bool)  in display.o
# ld: symbol(s) not found
# collect2: ld returned 1 exit status
# make[2]: *** [liboctinterp.dylib] Error 1
#
# 2010-01-24 Tried no options vopt ="" no J2 either all tests passed! This works!!!!
# no sysroot set. Second set of options.
#
# 2010-01-24 These settings:
#      vopt="-O0 -march=i686 -msse3 -msse2 -msse -mmmx"
#      vhst="--host=i386-apple-darwin8.11.1"
# vcfl="$vopt -isysroot /Developer/SDKs/MacOSX10.6.sdk -I$vinc -I$vx11 -J$numberOfCPUS"
# vffl="$vopt -isysroot /Developer/SDKs/MacOSX10.6.sdk -I$vinc -mieee-fp"
#
# vldf="-L$vprf/lib -Wl,-headerpad_max_install_names \
#  -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk -mmacosx-version-min=10.6"
#
#vbsh="MACOSX_DEPLOYMENT_TARGET=10.6 DYLD_LIBRARY_PATH=${vprf}/lib \
#  DYLD_FALLBACK_LIBRARY_PATH=${vprf}/lib PATH=${vprf}/bin:${PATH}"
#
#vcnf="CC=\"$vgcc\" CPP=\"$vcpp\" CXX=\"$vcxx\" F77=\"$vf77\" \
# CFLAGS=\"$vcfl\" CPPFLAGS=\"$vcfl\" CXXFLAGS=\"$vcfl\" FFLAGS=\"$vffl\" \
# LDFLAGS=\"$vldf\" --prefix=$vprf $vhst"
# RESULT FAILED to BUILD!!!!!!!
#
# 2010-01-24 These settings which came from Thomas' email
# vopt: -O2 -mfpmath=sse,387 -march=prescott
# vcfl: -O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include
# vldf: -L/tmp/deps-i386/lib -Wl,-headerpad_max_install_names   -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk
# vbsh: MACOSX_DEPLOYMENT_TARGET=10.6 DYLD_LIBRARY_PATH=/tmp/deps-i386/lib   DYLD_FALLBACK_LIBRARY_PATH=/tmp/deps-i386/lib PATH=/tmp/deps-i386/bin:/tmp/mg/bin:/tmp/deps-i386/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin:/usr/texbin:/usr/X11/bin:/usr/local/bin:/usr/X11R6/bin:/usr/local/texlive/2008/bin/universal-darwin
# vcnf: CC="gcc -arch i386" CPP="gcc -arch i386 -E" CXX="g++ -arch i386" F77="i386-apple-darwin8.11.1-g95"  CFLAGS="-O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include" CPPFLAGS="-O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include" CXXFLAGS="-O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include" FFLAGS="-O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include"  LDFLAGS="-L/tmp/deps-i386/lib -Wl,-headerpad_max_install_names   -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk" --prefix=/tmp/deps-i386 --host=i386-apple-darwin8.11.1
# varc: -arch i386
# vhst: --host=i386-apple-darwin8.11.1
# vopt: -O2 -mfpmath=sse,387 -march=prescott
# vcfl: -O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include
# vldf: -L/tmp/deps-i386/lib -Wl,-headerpad_max_install_names   -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk
# vbsh: MACOSX_DEPLOYMENT_TARGET=10.6 DYLD_LIBRARY_PATH=/tmp/deps-i386/lib   DYLD_FALLBACK_LIBRARY_PATH=/tmp/deps-i386/lib PATH=/tmp/deps-i386/bin:/tmp/mg/bin:/tmp/deps-i386/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin:/usr/texbin:/usr/X11/bin:/usr/local/bin:/usr/X11R6/bin:/usr/local/texlive/2008/bin/universal-darwin
# vcnf: CC="gcc -arch i386" CPP="gcc -arch i386 -E" CXX="g++ -arch i386" F77="i386-apple-darwin8.11.1-g95"  CFLAGS="-O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include" CPPFLAGS="-O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include" CXXFLAGS="-O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include" FFLAGS="-O2 -mfpmath=sse,387 -march=prescott -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include"  LDFLAGS="-L/tmp/deps-i386/lib -Wl,-headerpad_max_install_names   -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk" --prefix=/tmp/deps-i386 --host=i386-apple-darwin8.11.1
# varc: -arch i386
# vhst: --host=i386-apple-darwin8.11.1
# This build generates many build errors like this: error: unable to find a register to spill in class ‘MMX_REGS’
#
# 2010-01-24 another build but with no options just -J2 if this is as good so be it
# vopt: 
# vcfl:  -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include -J2
# vldf: -L/tmp/deps-i386/lib -Wl,-headerpad_max_install_names   -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk
# vbsh: MACOSX_DEPLOYMENT_TARGET=10.6 DYLD_LIBRARY_PATH=/tmp/deps-i386/lib   DYLD_FALLBACK_LIBRARY_PATH=/tmp/deps-i386/lib PATH=/tmp/deps-i386/bin:/tmp/mg/bin:/tmp/deps-i386/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin:/usr/texbin:/usr/X11/bin:/usr/local/bin:/usr/X11R6/bin:/usr/local/texlive/2008/bin/universal-darwin
# vcnf: CC="gcc -arch i386" CPP="gcc -arch i386 -E" CXX="g++ -arch i386" F77="i386-apple-darwin8.11.1-g95"  CFLAGS=" -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include -J2" CPPFLAGS=" -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include -J2" CXXFLAGS=" -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include -J2" FFLAGS=" -isysroot /Developer/SDKs/MacOSX10.6.sdk -I/tmp/deps-i386/include"  LDFLAGS="-L/tmp/deps-i386/lib -Wl,-headerpad_max_install_names   -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.6.sdk" --prefix=/tmp/deps-i386 --host=i386-apple-darwin8.11.1
# varc: -arch i386
# vhst: --host=i386-apple-darwin8.11.1
#
# This build passes all tests and produces a good result!  I am worried the binary has no optimizations.



