#
#   MAKEFILE for libgettext
#

GETTEXT_VER=0.18.1.1
GETTEXT_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--disable-java \
--disable-native-java \
--disable-csharp \
--enable-relocatable \
--disable-openmp \
--disable-largefile \
--disable-threads \
--disable-acl \
--without-cvs \
--with-libiconv-prefix=$(PREFIX)

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

# 2010-Oct-15  lindnerb@users.sourceforge.net
#  gettext apparently requires CC and CXX set explicitly, otherwise
#  configure silently fails in gettext-tools/ and the following build stage
#  fails with a libtool error on 'unsupported hardlinking'
#  (gettext uses "g++" for building man pages...)
#  TML uses this also for his GTK+64 builds.
#
# 2010-Nov-25  lindnerb@users.sourceforge.net
#  CC is already set in COMMON_CONFIGURE_ARGS (required by the shared libgcc
#  dance with libtool)
GETTEXT_CONFIGURE_XTRA_ARGS = CXX="$(CROSS)g++"

gettext-download : $(SRCTARDIR)/gettext-$(GETTEXT_VER).tar.gz
$(SRCTARDIR)/gettext-$(GETTEXT_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://ftp.gnu.org/pub/gnu/gettext/gettext-$(GETTEXT_VER).tar.gz

gettext-unpack : $(SRCDIR)/gettext/.unpack.marker
$(SRCDIR)/gettext/.unpack.marker : \
    $(SRCTARDIR)/gettext-$(GETTEXT_VER).tar.gz \
    $(SRCDIR)/gettext/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

gettext-configure : $(BUILDDIR)/gettext/.config.marker
$(BUILDDIR)/gettext/.config.marker : \
    $(SRCDIR)/gettext/.unpack.marker \
    $(BUILDDIR)/gettext/.mkdir.marker
	$(ADDPATH) && cd $(dir $@) && $(CURDIR)/$(SRCDIR)/gettext/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(GETTEXT_CONFIGURE_ARGS) $(GETTEXT_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

gettext-rebuild : 
	$(ADDPATH); $(MAKE) common-configure-make TGT=all PKG=gettext

gettext-build : $(BUILDDIR)/gettext/.build.marker 
$(BUILDDIR)/gettext/.build.marker : $(BUILDDIR)/gettext/.config.marker
	$(MAKE) gettext-rebuild
	$(TOUCH) $@

gettext-reinstall : $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/gettext/gettext-runtime/intl/.libs/libintl-8.dll $(PREFIX)/bin
	cp -a $(BUILDDIR)/gettext/gettext-runtime/intl/.libs/libintl.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/gettext/gettext-runtime/intl/.libs/libintl.a     $(PREFIX)/lib
	cp -a $(BUILDDIR)/gettext/gettext-runtime/intl/libintl.h           $(PREFIX)/include
	cp -a $(BUILDDIR)/gettext/gettext-tools/src/.libs/msgfmt.exe       $(PREFIX)/bin
	cp -a $(BUILDDIR)/gettext/gettext-tools/src/.libs/libgettextsrc-0-18-1.dll $(PREFIX)/bin
	cp -a $(BUILDDIR)/gettext/gettext-tools/gnulib-lib/.libs/libgettextlib-0-18-1.dll $(PREFIX)/bin
	$(MAKE) gettext-install-lic

gettext-install-lic :
	mkdir -p $(PREFIX)/license/gettext
	cp -a $(SRCDIR)/gettext/COPYING $(PREFIX)/license/gettext
	cp -a $(SRCDIR)/gettext/gettext-runtime/COPYING $(PREFIX)/license/gettext/COPING.gettext-runtime

gettext-install : $(BUILDDIR)/gettext/.install.marker 
$(BUILDDIR)/gettext/.install.marker : $(BUILDDIR)/gettext/.build.marker
	$(MAKE) gettext-reinstall
	$(TOUCH) $@

gettext-reinstall-strip : 
	$(MAKE) gettext-reinstall
	$(STRIP) $(PREFIX)/bin/libintl-8.dll
	$(STRIP) $(PREFIX)/bin/libgettextsrc-0-18-1.dll
	$(STRIP) $(PREFIX)/bin/libgettextlib-0-18-1.dll

gettext-install-strip : $(BUILDDIR)/gettext/.installstrip.marker 
$(BUILDDIR)/gettext/.installstrip.marker : $(BUILDDIR)/gettext/.build.marker
	$(MAKE) gettext-reinstall-strip
	$(TOUCH) $@

gettext-all : \
    gettext-download \
    gettext-unpack \
    gettext-configure \
    gettext-build \
    gettext-install

all : gettext-all
all-download : gettext-download
all-install : gettext-install
all-reinstall : gettext-reinstall
all-install-strip : gettext-install-strip
all-reinstall-strip : gettext-install-strip
all-rebuild : gettext-rebuild gettext-reinstall
all-pkg : gettext-pkg

gettext-pkg : PREFIX=/opt/pkg-$(ARCH)/gettext
gettext-pkg : $(BUILDDIR)/gettext/.pkg.marker
$(BUILDDIR)/gettext/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) gettext-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gettext-$(GETTEXT_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libintl-8.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gettext-$(GETTEXT_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/msgfmt.exe bin/libgettextsrc-0-18-1.dll bin/libgettextlib-0-18-1.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gettext-$(GETTEXT_VER)-$(BUILD_ARCH)$(ID)-dev.zip lib include
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gettext-$(GETTEXT_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 gettext-$(GETTEXT_VER)-src.zip $(SRCTARDIR)/gettext-$(GETTEXT_VER).tar.gz $(MAKEFILEDIR)gettext.mk makefile
	$(TOUCH) $@
