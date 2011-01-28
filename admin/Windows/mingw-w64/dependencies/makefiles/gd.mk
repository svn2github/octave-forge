#
#   MAKEFILE for libgd
#

GD_VER=2.0.36RC1
GD_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--without-libiconv-prefix \
CPPFLAGS="-DBGDWIN32 -DWIN32 -DgdHACK_BOOLEAN=int -I$(PREFIX)/include" \
LDFLAGS="-L$(PREFIX)/lib" \
--with-freetype=$(PREFIX) \
--with-fontconfig=$(PREFIX)

#--with-jpeg=$(PREFIX) \
#--with-png=$(PREFIX) \

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
PATCHDIR ?= patches
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

gd-download : $(SRCTARDIR)/gd-$(GD_VER).tar.bz2
$(SRCTARDIR)/gd-$(GD_VER).tar.bz2 : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.libgd.org/releases/gd-$(GD_VER).tar.bz2

gd-unpack : $(SRCDIR)/gd/.unpack.marker
$(SRCDIR)/gd/.unpack.marker : \
    $(SRCTARDIR)/gd-$(GD_VER).tar.bz2 \
    $(PATCHDIR)/gd-$(GD_VER).patch \
    $(SRCDIR)/gd/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	cd $(SRCDIR)/gd && patch -p1 -u -i $(CURDIR)/$(PATCHDIR)/gd-$(GD_VER).patch
	$(TOUCH) $@

gd-configure : $(BUILDDIR)/gd/.config.marker
$(BUILDDIR)/gd/.config.marker : \
    $(SRCDIR)/gd/.unpack.marker \
    $(BUILDDIR)/gd/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/gd/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(GD_CONFIGURE_ARGS) $(GD_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

gd-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=gd

gd-build : $(BUILDDIR)/gd/.build.marker 
$(BUILDDIR)/gd/.build.marker : $(BUILDDIR)/gd/.config.marker
	$(MAKE) gd-rebuild
	$(TOUCH) $@

gd-reinstall :
	$(MAKE) common-make TGT=install PKG=gd
	$(MAKE) gd-install-lic

gd-install-lic :
	mkdir -p $(PREFIX)/license/gd
	cp -a $(SRCDIR)/gd/COPYING $(PREFIX)/license/gd

gd-install : $(BUILDDIR)/gd/.install.marker 
$(BUILDDIR)/gd/.install.marker : $(BUILDDIR)/gd/.build.marker
	$(MAKE) gd-reinstall
	$(TOUCH) $@

gd-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=gd
	$(MAKE) gd-install-lic

gd-install-strip : $(BUILDDIR)/gd/.installstrip.marker 
$(BUILDDIR)/gd/.installstrip.marker : $(BUILDDIR)/gd/.build.marker
	$(MAKE) gd-reinstall-strip
	$(TOUCH) $@

gd-all : \
    gd-download \
    gd-unpack \
    gd-configure \
    gd-build \
    gd-install

all : gd-all
all-download : gd-download
all-install : gd-install
all-reinstall : gd-reinstall
all-install-strip : gd-install-strip
all-reinstall-strip : gd-install-strip
all-rebuild : gd-rebuild gd-reinstall
all-pkg : gd-pkg

gd-pkg : PREFIX=/opt/pkg-$(ARCH)/gd 
gd-pkg : $(BUILDDIR)/gd/.pkg.marker
$(BUILDDIR)/gd/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) gd-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gd-$(GD_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libgd-2.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gd-$(GD_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gd-$(GD_VER)-$(BUILD_ARCH)$(ID)-dev.zip bin/gdlib-config lib include
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gd-$(GD_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 gd-$(GD_VER)-src.zip $(SRCTARDIR)/gd-$(GD_VER).tar.bz2 gd.mk $(MAKEFILEDIR)makefile $(PATCHDIR)/gd-$(GD_VER).patch
	$(TOUCH) $@
