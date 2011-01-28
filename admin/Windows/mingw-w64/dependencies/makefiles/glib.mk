#
#   MAKEFILE for glib
#

GLIB_VER=2.24.0
GLIB_CONFIGURE_ARGS = \
--enable-shared \
--disable-static \
PKG_CONFIG=$(CURDIR)/pkg-config-stub \
--disable-gtk-doc \
--with-pcre=system \
PCRE_CFLAGS="" \
PCRE_LIBS="-lpcre" \
LDFLAGS="-L$(PREFIX)/lib" \
CPPFLAGS="-I$(PREFIX)/include"

# Must manually specify PCRE_CFLAGS and PCRE_LIBS because we do not have
# pkg-config built yet!!

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

glib-download : $(SRCTARDIR)/glib-$(GLIB_VER).tar.bz2
$(SRCTARDIR)/glib-$(GLIB_VER).tar.bz2 : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://ftp.gnome.org/pub/gnome/sources/glib/2.24/glib-$(GLIB_VER).tar.bz2

glib-unpack : $(SRCDIR)/glib/.unpack.marker
$(SRCDIR)/glib/.unpack.marker : \
    $(SRCTARDIR)/glib-$(GLIB_VER).tar.bz2 \
    $(SRCDIR)/glib/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	$(TOUCH) $@

glib-configure : $(BUILDDIR)/glib/.config.marker
$(BUILDDIR)/glib/.config.marker : \
    $(SRCDIR)/glib/.unpack.marker \
    $(BUILDDIR)/glib/.mkdir.marker
	$(ADDPATH) && cd $(dir $@) && $(CURDIR)/$(SRCDIR)/glib/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(GLIB_CONFIGURE_ARGS) $(GLIB_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

glib-rebuild : 
	$(ADDPATH); $(MAKE) common-configure-make TGT=all PKG=glib

glib-build : $(BUILDDIR)/glib/.build.marker 
$(BUILDDIR)/glib/.build.marker : $(BUILDDIR)/glib/.config.marker
	$(MAKE) glib-rebuild
	$(TOUCH) $@

glib-reinstall :
	$(MAKE) common-make TGT=install PKG=glib
	$(MAKE) glib-install-lic

glib-install-lic :
	mkdir -p $(PREFIX)/license/glib
	cp -a $(SRCDIR)/glib/COPYING $(PREFIX)/license/glib
	cp -a $(SRCDIR)/glib/gmodule/COPYING $(PREFIX)/license/glib/COPYING.gmodule

glib-install : $(BUILDDIR)/glib/.install.marker 
$(BUILDDIR)/glib/.install.marker : $(BUILDDIR)/glib/.build.marker
	$(MAKE) glib-reinstall
	$(TOUCH) $@

glib-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=glib
	$(MAKE) glib-install-lic

glib-install-strip : $(BUILDDIR)/glib/.installstrip.marker 
$(BUILDDIR)/glib/.installstrip.marker : $(BUILDDIR)/glib/.build.marker
	$(MAKE) glib-reinstall-strip
	$(TOUCH) $@

glib-all : \
    glib-download \
    glib-unpack \
    glib-configure \
    glib-build \
    glib-install

all : glib-all
all-download : glib-download
all-install : glib-install
all-reinstall : glib-reinstall
all-install-strip : glib-install-strip
all-reinstall-strip : glib-install-strip
all-rebuild : glib-rebuild glib-reinstall
all-pkg : glib-pkg

glib-pkg : PREFIX=/opt/pkg-$(ARCH)/glib
glib-pkg : $(BUILDDIR)/glib/.pkg.marker
$(BUILDDIR)/glib/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) glib-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/glib-$(GLIB_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/*.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/glib-$(GLIB_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/glib-$(GLIB_VER)-$(BUILD_ARCH)$(ID)-dev.zip bin/glib-gettextize bin/glib-mkenums include lib share
	cd $(PREFIX) && zip -qr9 $(CURDIR)/glib-$(GLIB_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -9rq glib-$(GLIB_VER)-src.zip $(SRCTARDIR)/glib-$(GLIB_VER).tar.bz2 $(MAKEFILEDIR)glib.mk makefile pkg-config-stub
	$(TOUCH) $@
