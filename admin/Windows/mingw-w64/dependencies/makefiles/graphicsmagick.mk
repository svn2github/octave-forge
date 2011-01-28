#
#   MAKEFILE for libgraphicsmagick
#

GRAPHICSMAGICK_VER=1.3.12
GRAPHICSMAGICK_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
CPPFLAGS="-DProvideDllMain -I$(PREFIX)/include" \
LDFLAGS="-L$(PREFIX)/lib" \
--without-perl \
--without-x \
--with-quantum-depth=16 \
--disable-installed

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

graphicsmagick-download : $(SRCTARDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER).tar.lzma
$(SRCTARDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER).tar.lzma : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://downloads.sourceforge.net/graphicsmagick/GraphicsMagick-$(GRAPHICSMAGICK_VER).tar.lzma

graphicsmagick-unpack : $(SRCDIR)/graphicsmagick/.unpack.marker
$(SRCDIR)/graphicsmagick/.unpack.marker : \
    $(SRCTARDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER).tar.lzma \
    $(PATCHDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER).patch \
    $(SRCDIR)/graphicsmagick/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -x --lzma -f $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER).patch
	$(TOUCH) $@

graphicsmagick-configure : $(BUILDDIR)/graphicsmagick/.config.marker
$(BUILDDIR)/graphicsmagick/.config.marker : \
    $(SRCDIR)/graphicsmagick/.unpack.marker \
    $(BUILDDIR)/graphicsmagick/.mkdir.marker
	cd $(SRCDIR)/graphicsmagick && aclocal --force
	cd $(SRCDIR)/graphicsmagick && libtoolize --force --copy --install
	cd $(SRCDIR)/graphicsmagick && automake --force
	cd $(SRCDIR)/graphicsmagick && autoconf --force
	$(ADDPATH); cd $(dir $@) && $(CURDIR)/$(SRCDIR)/graphicsmagick/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(GRAPHICSMAGICK_CONFIGURE_ARGS) $(GRAPHICSMAGICK_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

graphicsmagick-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=graphicsmagick

graphicsmagick-build : $(BUILDDIR)/graphicsmagick/.build.marker 
$(BUILDDIR)/graphicsmagick/.build.marker : $(BUILDDIR)/graphicsmagick/.config.marker
	$(MAKE) graphicsmagick-rebuild
	$(TOUCH) $@

graphicsmagick-reinstall :
	$(MAKE) common-make TGT=install PKG=graphicsmagick
	$(MAKE) graphicsmagick-install-lic

graphicsmagick-install-lic :
	mkdir -p $(PREFIX)/license/graphicsmagick
	mkdir -p $(PREFIX)/license/graphicsmagick/Magick++
	cp -a $(SRCDIR)/graphicsmagick/Copyright.txt $(PREFIX)/license/graphicsmagick
	cp -a $(SRCDIR)/graphicsmagick/Magick++/COPYING $(PREFIX)/license/graphicsmagick/Magick++

graphicsmagick-install : $(BUILDDIR)/graphicsmagick/.install.marker 
$(BUILDDIR)/graphicsmagick/.install.marker : $(BUILDDIR)/graphicsmagick/.build.marker
	$(MAKE) graphicsmagick-reinstall
	$(TOUCH) $@

graphicsmagick-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=graphicsmagick
	$(MAKE) graphicsmagick-install-lic

graphicsmagick-install-strip : $(BUILDDIR)/graphicsmagick/.installstrip.marker 
$(BUILDDIR)/graphicsmagick/.installstrip.marker : $(BUILDDIR)/graphicsmagick/.build.marker
	$(MAKE) graphicsmagick-reinstall-strip
	$(TOUCH) $@

graphicsmagick-check : $(BUILDDIR)/graphicsmagick/.check.marker
$(BUILDDIR)/graphicsmagick/.check.marker : $(BUILDDIR)/graphicsmagick/.build.marker
	$(MAKE) common-make TGT=check PKG=graphicsmagick
	$(TOUCH) $@

graphicsmagick-all : \
    graphicsmagick-download \
    graphicsmagick-unpack \
    graphicsmagick-configure \
    graphicsmagick-build \
    graphicsmagick-install

all : graphicsmagick-all
all-download : graphicsmagick-download
all-install : graphicsmagick-install
all-reinstall : graphicsmagick-reinstall
all-install-strip : graphicsmagick-install-strip
all-reinstall-strip : graphicsmagick-install-strip
all-rebuild : graphicsmagick-rebuild graphicsmagick-reinstall
all-pkg : graphicsmagick-pkg

graphicsmagick-pkg : PREFIX=/opt/pkg-$(ARCH)/graphicsmagick
graphicsmagick-pkg : $(BUILDDIR)/graphicsmagick/.pkg.marker
$(BUILDDIR)/graphicsmagick/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) graphicsmagick-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/*.dll bin/gm.exe share/GraphicsMagick-$(GRAPHICSMAGICK_VER)/config
	cd $(PREFIX) && zip -qr9 $(CURDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER)-$(BUILD_ARCH)$(ID)-dev.zip bin/*-config include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 graphicsmagick-$(GRAPHICSMAGICK_VER)-src.zip $(SRCTARDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER).tar.lzma $(MAKEFILEDIR)graphicsmagick.mk $(PATCHDIR)/graphicsmagick-$(GRAPHICSMAGICK_VER).patch makefile
	$(TOUCH) $@
