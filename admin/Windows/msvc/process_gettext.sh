#!/bin/sh

output=
input=

function output_file
{
  echo "`echo \"$1\" | sed -e 's,/,_,g'`"
}

function check_output_file
{
  of=`output_file "$1"`
  if test ! -f "$of"; then
    echo "processing $1..."
    input="$1"
    output="$of"
    cp "$input" "$output"
    return 0
  else
    echo "skipping $1..."
    return 1
  fi
}

function commit_file
{
  mv "$output" "$input"
}

function process_configure_for_absolute_name
{
  if check_output_file "$1"; then
    hnames=`sed -n -e 's/^.*absolute name of <\([^>]*\)>.*$/\1/p' "$input" | sort | uniq`
    for h in $hnames; do
      h1=`echo $h | sed -e 's/\./\\./'`
      sed -e "\\#/$h1# s,/,\[/\\\\\\\\],g" "$output" > ttt &&
        mv ttt "$output"
    done
    commit_file
  fi
}

# change gettext-runtime/configure and gettext-tools/configure
# to make it support backslashes when looking for absolute names
# of header files

process_configure_for_absolute_name gettext-runtime/configure
process_configure_for_absolute_name gettext-tools/configure

# gettext-runtime/intl/export.h
#   add BUILDING_LIBINTL trick to correctly export symbols

if check_output_file "gettext-runtime/intl/export.h"; then
  sed -e '/^#define LIBINTL_DLL_EXPORTED *$/ {c\
#ifdef BUILDING_LIBINTL\
#define LIBINTL_DLL_EXPORTED __declspec(dllexport)\
#else\
#define LIBINTL_DLL_EXPORTED __declspec(dllimport)\
#endif
;}' "$output" > ttt &&
    mv ttt "$output"
  commit_file
fi

# gettext-runtime/intl/Makefile.in, gettext-tools/intl/Makefile.in
#   add -Wl,linintl.res to LDFLAGS_yes
#   WOE32DLL => yes => no in libgnuintl.h build rule

if check_output_file "gettext-runtime/intl/Makefile.in"; then
  sed -e 's/^LDFLAGS_yes =/LDFLAGS_yes = -Wl,libintl.res/' \
      -e "s/'@WOE32DLL@'/'no'/" \
      "$output" > ttt &&
    mv ttt "$output"
  commit_file
fi

# gettext-runtime/config.h.in, gettext-runtime/libasprintf/config.h.in
#   append #define intmax_t long long

if check_output_file "gettext-runtime/config.h.in"; then
  echo "#define intmax_t long long" >> "$output"
  commit_file
fi

if check_output_file "gettext-runtime/libasprintf/config.h.in"; then
  echo "#define intmax_t long long" >> "$output"
  commit_file
fi

# gettext-runtime/libasprintf/Makefile.in
#   generate asprintf.def
#   add -Wl,-def:asprintf.def to LDFLAGS

if check_output_file "gettext-runtime/libasprintf/Makefile.in"; then
  sed -e 's/^libasprintf_la_LDFLAGS =/libasprintf_la_LDFLAGS = -Wl,-def:asprintf.def/' \
      -e 's/\(^libasprintf\.la:.*$\)/\1 asprintf.def/' \
      "$output" > ttt &&
    mv ttt "$output" &&
  (cat >> "$output" <<\EOF
asprintf.def: $(libasprintf_la_OBJECTS)
	echo "EXPORTS" > $@
	nm $(addprefix .libs/, $(libasprintf_la_OBJECTS:.lo=.o)) | \
	  sed -n -e 's/^.* T _\(.*\)$/\1/p' >> $@
EOF
  commit_file
)
fi

# gettext-runtime/gnulib-lib/Makefile.in
#   AR = ar-msvc => ar

if check_output_file "gettext-runtime/gnulib-lib/Makefile.in"; then
  sed -e 's/^AR =.*$/AR = ar/' "$output" > ttt &&
    mv ttt "$output"
  commit_file
fi

# gettext-tools/config.h
#   comment redefinition of gmtime and localtime

if check_output_file "gettext-tools/config.h.in"; then
  sed -e 's,#undef gmtime,/*#undef gmtime*/,' \
      -e 's,#undef localtime,/*#undef localtime*/,' \
      "$output" > ttt &&
    mv ttt "$output"
  commit_file
fi

# gettext-tools/gnulib-lib/sys_stat.in.h
#   add #include <direct.h> before including io.h

if check_output_file "gettext-tools/gnulib-lib/sys_stat.in.h"; then
  sed -e '/^# *include *<io\.h> *$/ {c\
#include <direct.h>\
#include <io.h>
;}' "$output" > ttt &&
    mv ttt "$output"
  commit_file
fi

# gettext-tools/gnulib-lib/[html-]styled-ostream.h and ostream.h
#   fix for use in C++ (add extern "C")

for f in html-styled-ostream styled-ostream ostream; do
  in_file="gettext-tools/gnulib-lib/$f.h"
  if check_output_file "$in_file"; then
    ti="`echo $f | sed -e 's/-/_/g'`_typeinfo"
    sed -e "/\\(^extern .*$ti;$\\)/ {i\\
#ifdef __cplusplus\\
extern \"C\" {\\
#endif
;p;i\\
#ifdef __cplusplus\\
};\\
#endif
;}" "$output" > ttt &&
      mv ttt "$output"
    commit_file
  fi
done

# gettext-tools/gnulib-lib/[un]setenv.c
#   define __environ to _environ when _MSC_VER is defined

for f in setenv unsetenv; do
  if check_output_file "gettext-tools/gnulib-lib/$f.c"; then
    sed -e 's/^extern char \*\*environ;$/#define __environ _environ/' \
        "$output" > ttt &&
      mv ttt "$output"
    commit_file
  fi
done

# gettext-tools/src/hostname.c
#   add guards for inclusion of sys/param.h

if check_output_file "gettext-tools/src/hostname.c"; then
  sed -e '/^# *include <sys\/param\.h>/ {i\
#ifdef HAVE_SYS_PARAM_H
;p;i\
#endif
;d;}' "$output" > ttt &&
    mv ttt "$output"
  commit_file
fi

# gettext-tools/libgrep/Makefile
#   AR = ar-msvc => ar

if check_output_file "gettext-tools/libgrep/Makefile.in"; then
  sed -e 's/^AR =.*$/AR = ar/' "$output" > ttt &&
    mv ttt "$output"
  commit_file
fi

# gettext-tools/src/Makefile
#   add -lmsvcprt to msggrep_LDFLAGS
#   add gettextsrc.def file generation
#   comment gettextsrc-exports.lo object dependency

if check_output_file "gettext-tools/src/Makefile.in"; then
  sed -e 's/^libgettextsrc\.la:.*$/& gettextsrc.def/' \
      -e 's/^libgettextsrc_la_LDFLAGS =/& -Wl,-def:gettextsrc.def -Wl,gettext.res/' \
      -e 's/^.* = .*exports\.lo//' \
      -e 's/^@.*@msggrep_LDFLAGS =/& -lmsvcprt/' \
      "$output" > ttt &&
    mv ttt "$output" &&
  (cat >> "$output" <<\EOF
gettextsrc.def: $(libgettextsrc_la_OBJECTS)
	echo "EXPORTS" > $@
	nm $(addprefix .libs/, $(libgettextsrc_la_OBJECTS:.lo=.o)) | \
	  sed -n -e 's/^.* T _\(.*\)$$/\1/p' | sort | uniq >> $@
	sed -n -e 's/^VARIABLE(\(.*\))/\1 DATA/p' ../woe32dll/gettextsrc-exports.c >> $@
EOF
)
  commit_file
fi

# gettext-tools/gnulib-lib/Makefile
#   add gettextlib.def file generation
#   comment gettextlib-exports.lo object dependency

if check_output_file "gettext-tools/gnulib-lib/Makefile.in"; then
  sed -e 's/^libgettextlib\.la:.*$/& gettextlib.def/' \
      -e 's/^libgettextlib_la_LDFLAGS =/& -Wl,-def:gettextlib.def -Wl,gettext.res/' \
      -e 's/^.* = .*exports\.lo//' \
      "$output" > ttt &&
    mv ttt "$output" &&
  (cat >> "$output" <<\EOF
allobjects = $(libgettextlib_la_OBJECTS) $(gl_LTLIBOBJS)
gettextlib.def: $(allobjects)
	echo "EXPORTS" > $@
	nm $(join $(dir $(allobjects)), $(addprefix .libs/, $(notdir $(allobjects:.lo=.o)))) | \
	  sed -n -e 's/^.* T _\(.*\)$$/\1/p' | sort | uniq >> $@
	sed -n -e 's/^VARIABLE(\(.*\))/\1 DATA/p' ../woe32dll/gettextlib-exports.c >> $@
EOF
)
  commit_file
fi

# gettext-tools/tests/setlocale.c
#   disable code when _MSC_VER is defined

if check_output_file "gettext-tools/tests/setlocale.c"; then
  (echo "#ifndef _MSC_VER"; cat "$output"; echo "#endif") > ttt &&
    mv ttt "$output"
  commit_file
fi

# gettext-tools/src/[read|write]-[properties|stringtable|po].h
#   add guards for use in C++

for f in read-properties write-properties read-stringtable write-stringtable read-po; do
  if check_output_file "gettext-tools/src/$f.h"; then
    sed -e '/^extern DLL_VARIABLE .*$/ {i\
#ifdef __cplusplus\
extern "C" {\
#endif
;p;i\
#ifdef __cplusplus\
};\
#endif
;d;}' "$output" > ttt &&
      mv ttt "$output"
    commit_file
  fi
done

# gettext-tools/libgettextpo/Makefile
#   add 2>&1 1>/dev/null to $(COMPILE) command of config.h build rule
#   comment gettextpo-exports.lo object dependency
#   add gettextpo.def generation (based on gettext-po.lo only)
#   add -Wl,libgettextpo.res to libgettextpo_la_LDFLAGS

if check_output_file "gettext-tools/libgettextpo/Makefile.in"; then
  sed -e 's/^libgettextpo\.la:.*$/& gettextpo.def/' \
      -e 's/^libgettextpo_la_LDFLAGS =/& -Wl,-def:gettextpo.def -Wl,libgettextpo.res/' \
      -e 's/^.* = .*exports\.lo//' \
      -e 's,\(\$(COMPILE) .*\) ||,\1 2>\&1 1>/dev/null ||,' \
      "$output" > ttt &&
    mv ttt "$output" &&
  (cat >> "$output" <<\EOF
gettextpo.def: gettext-po.lo
	echo "EXPORTS" > $@
	nm .libs/gettext-po.o | \
	  sed -n -e 's/^.* T _\(.*\)$$/\1/p' | sort | uniq >> $@
	sed -n -e 's/^VARIABLE(\(.*\))/\1 DATA/p' ../woe32dll/gettextpo-exports.c >> $@
EOF
)
  commit_file
fi

# CONFIGURE FLAGS
#   CPPFLAGS="`pkg-config --cflags glib-2-.0 libxml-2.0`"
#   ac_cv_func_memset=yes
#   --disable-nls
#   --disable-java
#   --disable-native-java
#   --enable-relocatable
#   --with-included-gettext

# POST-PROCESSING for libtool usage with MSVC
#   warning: CXX config is used for gettext-runtime/libasprintf/libtool
#            and gettext-tools/libtool
