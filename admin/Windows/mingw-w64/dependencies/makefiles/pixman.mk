#
#   MAKEFILE for pixman
#

PIXMAN_VER=0.18.2
PIXMAN_CONFIGURE_ARGS = \
--enable-shared \
--enable-static

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

pixman-download : $(SRCTARDIR)/pixman-$(PIXMAN_VER).tar.gz
$(SRCTARDIR)/pixman-$(PIXMAN_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://cairographics.org/releases/pixman-$(PIXMAN_VER).tar.gz

pixman-unpack : $(SRCDIR)/pixman/.unpack.marker
$(SRCDIR)/pixman/.unpack.marker : \
    $(SRCTARDIR)/pixman-$(PIXMAN_VER).tar.gz \
    $(SRCDIR)/pixman/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

pixman-configure : $(BUILDDIR)/pixman/.config.marker
$(BUILDDIR)/pixman/.config.marker : \
    $(SRCDIR)/pixman/.unpack.marker \
    $(BUILDDIR)/pixman/.mkdir.marker
	$(ADDPATH) && cd $(dir $@) && $(CURDIR)/$(SRCDIR)/pixman/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(PIXMAN_CONFIGURE_ARGS) $(PIXMAN_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

pixman-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=pixman

pixman-build : $(BUILDDIR)/pixman/.build.marker 
$(BUILDDIR)/pixman/.build.marker : $(BUILDDIR)/pixman/.config.marker
	$(MAKE) pixman-rebuild
	$(TOUCH) $@

pixman-reinstall :
	$(MAKE) common-make TGT=install PKG=pixman
	$(MAKE) pixman-install-lic

pixman-install-lic :
	mkdir -p $(PREFIX)/license/pixman
	cp -a $(SRCDIR)/pixman/COPYING $(PREFIX)/license/pixman

pixman-install : $(BUILDDIR)/pixman/.install.marker 
$(BUILDDIR)/pixman/.install.marker : $(BUILDDIR)/pixman/.build.marker
	$(MAKE) pixman-reinstall
	$(TOUCH) $@

pixman-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=pixman
	$(MAKE) pixman-install-lic

pixman-install-strip : $(BUILDDIR)/pixman/.installstrip.marker 
$(BUILDDIR)/pixman/.installstrip.marker : $(BUILDDIR)/pixman/.build.marker
	$(MAKE) pixman-reinstall-strip
	$(TOUCH) $@

pixman-all : \
    pixman-download \
    pixman-unpack \
    pixman-configure \
    pixman-build \
    pixman-install

all : pixman-all
all-download : pixman-download
all-install : pixman-install
all-reinstall : pixman-reinstall
all-install-strip : pixman-install-strip
all-reinstall-strip : pixman-install-strip
all-rebuild : pixman-rebuild pixman-reinstall
all-pkg : pixman-pkg

pixman-pkg : PREFIX=/opt/pkg-$(ARCH)/pixman
pixman-pkg : $(BUILDDIR)/pixman/.pkg.marker
$(BUILDDIR)/pixman/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) pixman-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pixman-$(PIXMAN_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libpixman-1-0.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pixman-$(PIXMAN_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pixman-$(PIXMAN_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 pixman-$(PIXMAN_VER)-src.zip $(SRCTARDIR)/pixman-$(PIXMAN_VER).tar.gz $(MAKEFILEDIR)pixman.mk makefile
	$(TOUCH) $@
