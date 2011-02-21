#
#   MAKEFILE for libpcre
#

PCRE_VER=8.10
PCRE_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--enable-utf8 \
--enable-unicode-properties \
--enable-newline-is-any \
--disable-cpp

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

pcre-download : $(SRCTARDIR)/pcre-$(PCRE_VER).tar.bz2
$(SRCTARDIR)/pcre-$(PCRE_VER).tar.bz2 : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://downloads.sourceforge.net/pcre/pcre-$(PCRE_VER).tar.bz2

pcre-unpack : $(SRCDIR)/pcre/.unpack.marker
$(SRCDIR)/pcre/.unpack.marker : \
    $(SRCTARDIR)/pcre-$(PCRE_VER).tar.bz2 \
    $(PATCHDIR)/pcre-$(PCRE_VER).patch \
    $(SRCDIR)/pcre/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/pcre-$(PCRE_VER).patch
	$(TOUCH) $@

pcre-configure : $(BUILDDIR)/pcre/.config.marker
$(BUILDDIR)/pcre/.config.marker : \
    $(SRCDIR)/pcre/.unpack.marker \
    $(BUILDDIR)/pcre/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/pcre/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(PCRE_CONFIGURE_ARGS) $(PCRE_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

pcre-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=pcre

pcre-build : $(BUILDDIR)/pcre/.build.marker 
$(BUILDDIR)/pcre/.build.marker : $(BUILDDIR)/pcre/.config.marker
	$(MAKE) pcre-rebuild
	$(TOUCH) $@

pcre-reinstall : $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/pcre/.libs/libpcre-0.dll $(PREFIX)/bin
	cp -a $(BUILDDIR)/pcre/.libs/libpcre.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/pcre/.libs/libpcre.a     $(PREFIX)/lib
	cp -a $(BUILDDIR)/pcre/libpcre.pc          $(PREFIX)/lib/pkgconfig
	cp -a $(BUILDDIR)/pcre/pcre.h              $(PREFIX)/include
	cp -a $(BUILDDIR)/pcre/pcre-config         $(PREFIX)/bin
	$(MAKE) pcre-install-lic

pcre-install-lic :
	mkdir -p $(PREFIX)/license/pcre
	cp -a $(SRCDIR)/pcre/COPYING $(PREFIX)/license/pcre

pcre-install : $(BUILDDIR)/pcre/.install.marker 
$(BUILDDIR)/pcre/.install.marker : $(BUILDDIR)/pcre/.build.marker
	$(MAKE) pcre-reinstall
	$(TOUCH) $@

pcre-reinstall-strip : 
	$(MAKE) pcre-reinstall
	$(STRIP) $(PREFIX)/bin/libpcre-0.dll

pcre-install-strip : $(BUILDDIR)/pcre/.installstrip.marker 
$(BUILDDIR)/pcre/.installstrip.marker : $(BUILDDIR)/pcre/.build.marker
	$(MAKE) pcre-reinstall-strip
	$(TOUCH) $@

pcre-check : $(BUILDDIR)/pcre/.check.marker
$(BUILDDIR)/pcre/.check.marker : $(BUILDDIR)/pcre/.build.marker
	$(MAKE) common-make TGT=check PKG=pcre
	$(TOUCH) $@

pcre-all : \
    pcre-download \
    pcre-unpack \
    pcre-configure \
    pcre-build \
    pcre-install

all : pcre-all
all-download : pcre-download
all-install : pcre-install
all-reinstall : pcre-reinstall
all-install-strip : pcre-install-strip
all-reinstall-strip : pcre-install-strip
all-rebuild : pcre-rebuild pcre-reinstall
all-pkg : pcre-pkg

pcre-pkg : PREFIX=/opt/pkg-$(ARCH)/pcre
pcre-pkg : $(BUILDDIR)/pcre/.pkg.marker
$(BUILDDIR)/pcre/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) pcre-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pcre-$(PCRE_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libpcre-0.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pcre-$(PCRE_VER)-$(BUILD_ARCH)$(ID)-dev.zip lib bin/pcre-config
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pcre-$(PCRE_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 pcre-$(PCRE_VER)-src.zip $(SRCTARDIR)/pcre-$(PCRE_VER).tar.bz2 $(MAKEFILEDIR)pcre.mk $(PATCHDIR)/prec-$(PCRE_VER).patch makefile
	$(TOUCH) $@
