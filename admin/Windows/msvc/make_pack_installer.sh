octave_prefix=
exec_prefix=
packages=
do_nsiclean=true
NSI_DIR=
VCLIBS_ROOT=

while test $# -gt 0; do
  case "$1" in
    --prefix=*)
      octave_prefix=`echo $1 | sed -e 's/--prefix=//'` 
      ;;
    --exec-prefix=*)
      exec_prefix=`echo $1 | sed -e 's/--exec-prefix=//'`
      ;;
    --keep)
      do_nsiclean=false
      ;;
    *)
      if test -z "$packages"; then
        packages="$1"
      else
        packages="$packages $1"
      fi
      ;;
  esac
  shift
done

if test -z "$octave_prefix" -o ! -d "$octave_prefix"; then
  echo "$0: octave prefix must be given and point to a valid directory"
  exit -1
fi

export PATH="$octave_prefix/bin:$PATH"

octave_version=`octave-config -p VERSION`
octave_prefix_w32=`cd $octave_prefix && pwd -W`
octave_prefix_w32=`echo $octave_prefix_w32 | sed -e 's,/,\\\\\\\\,g'`

if test -n "$exec_prefix"; then
  exec_prefix_w32=`cd $exec_prefix && pwd -W`
  exec_prefix_w32=`echo $exec_prefix_w32 | sed -e 's,/,\\\\\\\\,g'`
fi

if test -d "/c/Software/NSIS"; then
  NSI_DIR=/c/Software/NSIS
elif test -d "/d/Software/NSIS"; then
  NSI_DIR=/d/Software/NSIS
else
  echo "$0: NSIS directory not found"
  exit -1
fi

##############################################################################

function check_exec_prefix()
{
  if test -z "$exec_prefix"; then
    echo "WARNING: no --exec-prefix argument given"
    echo "WARNING: package creation might fail"
  fi
}

function get_nsi_additional_files()
{
  packname=$1
  packinstdir=$2
  case "$packname" in
    ftp)
      check_exec_prefix
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libftp-3.dll\""
      ;;
    database)
      check_exec_prefix
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libsqlite3-0.dll\""
      ;;
    video)
      check_exec_prefix
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libavformat-*.dll\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libavcodec-*.dll\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libavutil-*.dll\""
      ;;
  esac
  return 0
}

function get_nsi_dependencies()
{
  packname=$1
  descfile="$2"
  sed -n -e 's/ *$//' \
         -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
         -e 's/^depends: *//p' "$descfile" | \
    awk -F ', ' '{c=split($0, s); for(n=1; n<=c; ++n) printf("%s\n", s[n]) }' | \
      sed -n -e 's/^octave.*$//' \
             -e 's/\([a-zA-Z0-9_]\+\) *\(( *\([<>]=\?\) *\([0-9]\+\.[0-9]\+\.[0-9]\+\) *) *\)\?/  !insertmacro CheckDependency "\1" "\4" "\3"/p'
}

function create_nsi_package_file()
{
  packname=$1
  found=`find "$octave_prefix/share/octave/packages" -type d -a -name "$packname-*" -maxdepth 1`
  if test ! -z "$found"; then
    packdesc=`grep -e '^Name:' "$found/packinfo/DESCRIPTION" | sed -e 's/^Name *: *//'`
    packdesc_low=`echo $packdesc | sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
    #packver=`grep -e '^Version:' "$found/packinfo/DESCRIPTION" | sed -e 's/^Version *: *//'`
    packver=`basename "$found" | sed -e "s/$packname-//"`
    if test -f "release-$octave_version/octave-$octave_version-$packname-$packver-setup.exe"; then
      return 0
    fi
    echo -n "creating installer for $packname... "
    mkdir -p "release-$octave_version"
    packinstdir=$packdesc_low-$packver
    packinfo=`sed -e '/^ /{H;$!d;}' -e 'x;/^Description: /!d;' "$found/packinfo/DESCRIPTION" | sed -e ':a;N;$!ba;s/\n */\ /g' | sed -e 's/^Description: //'`
    packfiles=`get_nsi_additional_files $packname`
    if test ! -z "$packfiles"; then
      echo "$packfiles" > octave_pkg_${packname}_files.nsi
      packfiles="!include \\\"octave_pkg_${packname}_files.nsi\\\""
    fi
    packdeps=`get_nsi_dependencies $packname "$found/packinfo/DESCRIPTION"`
    if test ! -z "$packdeps"; then
      echo "$packdeps" > octave_pkg_${packname}_deps.nsi
      packdeps="!include \\\"octave_pkg_${packname}_deps.nsi\\\""
    fi
	if test -f "$found/packinfo/.autoload"; then
      packautoload=1
    else
      packautoload=0
    fi
	have_arch_files="#"
	if test -d "$octave_prefix/libexec/octave/packages/$packinstdir"; then
      have_arch_files=
    fi
    sed -e "s/@PACKAGE_NAME@/$packname/" \
        -e "s/@PACKAGE_LONG_NAME@/$packdesc/" \
        -e "s/@PACKAGE_VERSION@/$packver/" \
        -e "s/@PACKAGE_INFO@/$packinfo/" \
        -e "s/@OCTAVE_VERSION@/$octave_version/" \
        -e "s/@VCLIBS_ROOT@/$exec_prefix_w32/" \
	-e "s/!define OCTAVE_ROOT .*/!define OCTAVE_ROOT "$octave_prefix_w32"/" \
        -e "s/@PACKAGE_FILES@/$packfiles/" \
        -e "s/@PACKAGE_DEPENDENCY@/$packdeps/" \
        -e "s/@PACKAGE_AUTOLOAD@/$packautoload/" \
        -e "s/@HAVE_ARCH_FILES@/$have_arch_files/" \
        -e "s/@SOFTWARE_ROOT@/$software_root/" octave_package.nsi.in > octave_pkg_$packname.nsi
    $NSI_DIR/makensis.exe octave_pkg_$packname.nsi | tee nsi.tmp
	packsize=`sed -n -e 's,^Install data: *[0-9]\+ / \([0-9]\+\) bytes$,\1,p' nsi.tmp`
	let "packsize = packsize / 1024"
	rm -f nsi.tmp
    if $do_nsiclean; then
      rm -f octave_pkg_$packname*.nsi
    fi
    if test ! -f "octave-$octave_version-$packname-$packver-setup.exe"; then
      echo "failed"
      return -1
    else
      mv -f "octave-$octave_version-$packname-$packver-setup.exe" "release-$octave_version"
	  if test -z "$isolated_sizes"; then
        isolated_sizes="\$$packname:$packsize\$"
      else
        isolated_sizes="$isolated_sizes$packname:$packsize\$"
      fi
      echo "done"
      return 0
    fi
  fi
}

##############################################################################

for pack in $packages; do
  create_nsi_package_file $pack
done
