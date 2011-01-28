#
#   MAKEFILE for libcairo
#

CAIRO_VER=1.8.10
CAIRO_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
CPPFLAGS="-I$(PREFIX)/include" \
LDFLAGS="-L$(PREFIX)/lib" \
LIBS="-lpthread"
#
# Requre explicit -lpthread because cairo's configure script does not add it?
#

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

# 2010-oct-15  lindner@users.sourceforge.net
#  cairo relies on "strings" for checking float word ordering.
#  In a cross-compile-scenario it should be $(CROSS)strings instead
#  This would require a re-autoconfigure step which I'd like to avoid,
#  so explicitly state that the ordering is little-endian
CAIRO_CONFIGURE_XTRA_ARGS=ax_cv_c_float_words_bigendian=no

cairo-download : $(SRCTARDIR)/cairo-$(CAIRO_VER).tar.gz
$(SRCTARDIR)/cairo-$(CAIRO_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://cairographics.org/releases/cairo-$(CAIRO_VER).tar.gz

cairo-unpack : $(SRCDIR)/cairo/.unpack.marker
$(SRCDIR)/cairo/.unpack.marker : \
    $(SRCTARDIR)/cairo-$(CAIRO_VER).tar.gz \
    $(PATCHDIR)/cairo-$(CAIRO_VER).patch \
    $(SRCDIR)/cairo/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(SRCDIR)/cairo && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/cairo-$(CAIRO_VER).patch
	$(TOUCH) $@

cairo-configure : $(BUILDDIR)/cairo/.config.marker
$(BUILDDIR)/cairo/.config.marker : \
    $(SRCDIR)/cairo/.unpack.marker \
    $(BUILDDIR)/cairo/.mkdir.marker
	$(ADDPATH) && cd $(dir $@) && $(CURDIR)/$(SRCDIR)/cairo/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(CAIRO_CONFIGURE_ARGS) $(CAIRO_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

cairo-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=cairo

cairo-build : $(BUILDDIR)/cairo/.build.marker 
$(BUILDDIR)/cairo/.build.marker : $(BUILDDIR)/cairo/.config.marker
	$(MAKE) cairo-rebuild
	$(TOUCH) $@

cairo-reinstall :
	$(MAKE) common-make TGT=install PKG=cairo
	$(MAKE) cairo-install-lic

cairo-install-lic :
	mkdir -p $(PREFIX)/license/cairo
	cp -a $(SRCDIR)/cairo/COPYING          $(PREFIX)/license/cairo
	cp -a $(SRCDIR)/cairo/COPYING-MPL-1.1  $(PREFIX)/license/cairo
	cp -a $(SRCDIR)/cairo/COPYING-LGPL-2.1 $(PREFIX)/license/cairo

cairo-install : $(BUILDDIR)/cairo/.install.marker 
$(BUILDDIR)/cairo/.install.marker : $(BUILDDIR)/cairo/.build.marker
	$(MAKE) cairo-reinstall
	$(TOUCH) $@

cairo-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=cairo
	$(MAKE) cairo-install-lic

cairo-install-strip : $(BUILDDIR)/cairo/.installstrip.marker 
$(BUILDDIR)/cairo/.installstrip.marker : $(BUILDDIR)/cairo/.build.marker
	$(MAKE) cairo-reinstall-strip
	$(TOUCH) $@

cairo-all : \
    cairo-download \
    cairo-unpack \
    cairo-configure \
    cairo-build \
    cairo-install

all : cairo-all
all-download : cairo-download
all-install : cairo-install
all-reinstall : cairo-reinstall
all-install-strip : cairo-install-strip
all-reinstall-strip : cairo-install-strip
all-rebuild : cairo-rebuild cairo-reinstall
all-pkg : cairo-pkg

cairo-pkg : PREFIX=/opt/pkg-$(ARCH)/cairo
cairo-pkg : $(BUILDDIR)/cairo/.pkg.marker
$(BUILDDIR)/cairo/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) cairo-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/cairo-$(CAIRO_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libcairo-2.dll 
	cd $(PREFIX) && zip -qr9 $(CURDIR)/cairo-$(CAIRO_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/cairo-$(CAIRO_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 cairo-$(CAIRO_VER)-src.zip $(SRCTARDIR)/cairo-$(CAIRO_VER).tar.gz $(MAKEFILEDIR)cairo.mk makefile $(PATCHDIR)/cairo-$(CAIRO_VER).patch
	$(TOUCH) $@
