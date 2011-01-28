#
#   MAKEFILE for libpng
#

PNG_VER=1.4.3
PNG_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
CPPFLAGS="-I$(PREFIX)/include" \
LDFLAGS="-L$(PREFIX)/lib"

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

png-download : $(SRCTARDIR)/png-$(PNG_VER).tar.xz
$(SRCTARDIR)/png-$(PNG_VER).tar.xz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://downloads.sourceforge.net/libpng/libpng-$(PNG_VER).tar.xz

png-unpack : $(SRCDIR)/png/.unpack.marker
$(SRCDIR)/png/.unpack.marker : \
    $(SRCTARDIR)/png-$(PNG_VER).tar.xz \
    $(PATCHDIR)/png-$(PNG_VER).patch \
    $(SRCDIR)/png/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -x --xz -f $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/png-$(PNG_VER).patch
	$(TOUCH) $@

png-configure : $(BUILDDIR)/png/.config.marker
$(BUILDDIR)/png/.config.marker : \
    $(SRCDIR)/png/.unpack.marker \
    $(BUILDDIR)/png/.mkdir.marker
	cp -a $(SRCDIR)/png/scripts/makefile.mingw $(BUILDDIR)/png/makefile
	$(TOUCH) $@

png-rebuild : 
	$(MAKE) common-make TGT=all PKG=png \
	    SRCDIR=$(CURDIR)/$(SRCDIR)/png \
	    ZLIBLIB=$(PREFIX)/lib \
	    ZLIBINC=$(PREFIX)/include \
	    MINGW_LDFLAGS=$(LDFLAGS_SHAREDLIBGCC)

png-build : $(BUILDDIR)/png/.build.marker 
$(BUILDDIR)/png/.build.marker : $(BUILDDIR)/png/.config.marker
	$(MAKE) png-rebuild
	$(TOUCH) $@

png-reinstall : PKG=png
png-reinstall : $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/png/libpng14.dll $(PREFIX)/bin
	cp -a $(BUILDDIR)/png/libpng.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/png/libpng.a     $(PREFIX)/lib
	cp -a $(SRCDIR)/png/png.h          $(PREFIX)/include
	cp -a $(SRCDIR)/png/pngconf.h      $(PREFIX)/include
	cp -a $(BUILDDIR)/png/libpng.pc    $(PREFIX)/lib/pkgconfig
	$(MAKE) png-install-lic

png-install-lic :
	mkdir -p $(PREFIX)/license/png
	cp -a $(SRCDIR)/png/LICENSE $(PREFIX)/license/png

png-install : $(BUILDDIR)/png/.install.marker 
$(BUILDDIR)/png/.install.marker : $(BUILDDIR)/png/.build.marker
	$(MAKE) png-reinstall
	$(TOUCH) $@

png-reinstall-strip : 
	$(MAKE) png-reinstall
	$(STRIP) $(PREFIX)/bin/libpng14.dll

png-install-strip : $(BUILDDIR)/png/.installstrip.marker 
$(BUILDDIR)/png/.installstrip.marker : $(BUILDDIR)/png/.build.marker
	$(MAKE) png-reinstall-strip
	$(TOUCH) $@

png-check : $(BUILDDIR)/png/.check.marker
$(BUILDDIR)/png/.check.marker : $(BUILDDIR)/png/.build.marker
	$(ADDPATH); $(MAKE) common-make TGT=test PKG=png SRCDIR=$(CURDIR)/$(SRCDIR)/png ZLIBLIB=$(PREFIX)/lib ZLIBINC=$(PREFIX)/include
	$(TOUCH) $@

png-all : \
    png-download \
    png-unpack \
    png-configure \
    png-build \
    png-install

all : png-all
all-download : png-download
all-install : png-install
all-reinstall : png-reinstall
all-install-strip : png-install-strip
all-reinstall-strip : png-install-strip
all-rebuild : png-rebuild png-reinstall
all-pkg : png-pkg

png-pkg : PREFIX=/opt/pkg-$(ARCH)/png
png-pkg :$(BUILDDIR)/png/.pkg.marker
$(BUILDDIR)/png/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) png-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/png-$(PNG_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libpng14.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/png-$(PNG_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/png-$(PNG_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 png-$(PNG_VER)-src.zip $(SRCTARDIR)/png-$(PNG_VER).tar.xz $(PATCHDIR)/png-$(PNG_VER).patch $(MAKEFILEDIR)png.mk makefile
	$(TOUCH) $@
