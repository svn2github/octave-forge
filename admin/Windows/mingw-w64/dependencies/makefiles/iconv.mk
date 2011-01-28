#
#   MAKEFILE for libiconv
#

ICONV_VER=1.13.1
ICONV_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--enable-relocatable

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

iconv-download : $(SRCTARDIR)/iconv-$(ICONV_VER).tar.gz
$(SRCTARDIR)/iconv-$(ICONV_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://ftp.gnu.org/pub/gnu/libiconv/libiconv-$(ICONV_VER).tar.gz

iconv-unpack : $(SRCDIR)/iconv/.unpack.marker
$(SRCDIR)/iconv/.unpack.marker : \
    $(SRCTARDIR)/iconv-$(ICONV_VER).tar.gz \
    $(SRCDIR)/iconv/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

iconv-configure : $(BUILDDIR)/iconv/.config.marker
$(BUILDDIR)/iconv/.config.marker : \
    $(SRCDIR)/iconv/.unpack.marker \
    $(BUILDDIR)/iconv/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/iconv/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(ICONV_CONFIGURE_ARGS) $(ICONV_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

# parallel make segfaults during ranlib of libcharset ??
# so use single-threaded make for iconv.
iconv-rebuild : MAKE_PARALLEL=-j1
iconv-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=iconv

iconv-build : $(BUILDDIR)/iconv/.build.marker 
$(BUILDDIR)/iconv/.build.marker : $(BUILDDIR)/iconv/.config.marker
	$(MAKE) iconv-rebuild
	$(TOUCH) $@

# 2010-Jul-13  lindnerb@users.sourceforge.net
# make install-strip segfaults during build ?
# so install manually

iconv-reinstall : $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/iconv/lib/.libs/libiconv-2.dll $(PREFIX)/bin
	cp -a $(BUILDDIR)/iconv/lib/.libs/libiconv.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/iconv/lib/.libs/libiconv.a     $(PREFIX)/lib
	cp -a $(BUILDDIR)/iconv/libcharset/lib/.libs/libcharset-1.dll  $(PREFIX)/bin
	cp -a $(BUILDDIR)/iconv/libcharset/lib/.libs/libcharset.dll.a  $(PREFIX)/lib
	cp -a $(BUILDDIR)/iconv/libcharset/lib/.libs/libcharset.a      $(PREFIX)/lib
	cp -a $(BUILDDIR)/iconv/include/iconv.h  $(PREFIX)/include
	cp -a $(BUILDDIR)/iconv/libcharset/include/libcharset.h  $(PREFIX)/include
	cp -a $(BUILDDIR)/iconv/libcharset/include/localcharset.h  $(PREFIX)/include
	$(MAKE) iconv-install-lic

iconv-install-lic :
	mkdir -p $(PREFIX)/license/iconv
	cp -a $(SRCDIR)/iconv/COPYING $(PREFIX)/license/iconv
	cp -a $(SRCDIR)/iconv/COPYING.LIB $(PREFIX)/license/iconv

iconv-install : $(BUILDDIR)/iconv/.install.marker 
$(BUILDDIR)/iconv/.install.marker : $(BUILDDIR)/iconv/.build.marker
	$(MAKE) iconv-reinstall
	$(TOUCH) $@

iconv-reinstall-strip : 
	$(MAKE) iconv-reinstall
	$(STRIP) $(PREFIX)/bin/libiconv-2.dll
	$(STRIP) $(PREFIX)/bin/libcharset-1.dll

iconv-install-strip : $(BUILDDIR)/iconv/.installstrip.marker 
$(BUILDDIR)/iconv/.installstrip.marker : $(BUILDDIR)/iconv/.build.marker
	$(MAKE) iconv-reinstall-strip
	$(TOUCH) $@

iconv-all : \
    iconv-download \
    iconv-unpack \
    iconv-configure \
    iconv-build \
    iconv-install

all : iconv-all
all-download : iconv-download
all-install : iconv-install
all-reinstall : iconv-reinstall
all-install-strip : iconv-install-strip
all-reinstall-strip : iconv-install-strip
all-rebuild : iconv-rebuild iconv-reinstall
all-pkg : iconv-pkg

iconv-pkg : PREFIX=/opt/pkg-$(ARCH)/iconv
iconv-pkg : $(BUILDDIR)/iconv/.pkg.marker
$(BUILDDIR)/iconv/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) iconv-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/iconv-$(ICONV_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libcharset-1.dll bin/libiconv-2.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/iconv-$(ICONV_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/iconv-$(ICONV_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 iconv-$(ICONV_VER)-src.zip $(SRCTARDIR)/iconv-$(ICONV_VER).tar.gz $(MAKEFILEDIR)iconv.mk makefile
	$(TOUCH) $@
