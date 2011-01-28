#
#   MAKEFILE for less
#

LESS_VER=436

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

less-download : $(SRCTARDIR)/less-$(LESS_VER).tar.gz
$(SRCTARDIR)/less-$(LESS_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.greenwoodsoftware.com/less/less-$(LESS_VER).tar.gz

less-unpack : $(SRCDIR)/less/.unpack.marker
$(SRCDIR)/less/.unpack.marker : \
    $(SRCTARDIR)/less-$(LESS_VER).tar.gz \
    $(PATCHDIR)/less-$(LESS_VER).patch \
    $(SRCDIR)/less/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(SRCDIR)/less && chmod 777 *
	cd $(SRCDIR)/less && patch -p1 -u -i $(CURDIR)/$(PATCHDIR)/less-$(LESS_VER).patch
	$(TOUCH) $@

less-configure : $(BUILDDIR)/less/.config.marker
$(BUILDDIR)/less/.config.marker : \
    $(SRCDIR)/less/.unpack.marker \
    $(BUILDDIR)/less/.mkdir.marker
	cp $(SRCDIR)/less/makefile.mingw32 $(BUILDDIR)/less/makefile
	$(TOUCH) $@

less-rebuild : 
	$(MAKE) common-make TGT=all PKG=less SRCDIR=$(CURDIR)/$(SRCDIR)/less CPPFLAGS="-I$(PREFIX)/include"

less-build : $(BUILDDIR)/less/.build.marker
$(BUILDDIR)/less/.build.marker : $(BUILDDIR)/less/.config.marker
	$(MAKE) less-rebuild
	$(TOUCH) $@

less-reinstall : PKG=less
less-reinstall : \
    $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/less/less.exe    $(PREFIX)/bin
	cp -a $(SRCDIR)/less/COPYING       $(PREFIX)/license/less
	cp -a $(SRCDIR)/less/LICENSE       $(PREFIX)/license/less

less-install : $(BUILDDIR)/less/.install.marker 
$(BUILDDIR)/less/.install.marker : $(BUILDDIR)/less/.build.marker
	$(MAKE) less-reinstall
	$(TOUCH) $@

less-reinstall-strip : less-reinstall
	$(STRIP) $(PREFIX)/bin/less.exe

less-install-strip : $(BUILDDIR)/less/.installstrip.marker 
$(BUILDDIR)/less/.installstrip.marker : $(BUILDDIR)/less/.install.marker
	$(MAKE) less-reinstall-strip
	$(TOUCH) $@

less-all : \
    less-download \
    less-unpack \
    less-configure \
    less-build \
    less-install

all : less-all
all-download : less-download
all-install : less-install
all-reinstall : less-reinstall
all-install-strip : less-install-strip
all-reinstall-strip : less-install-strip
all-rebuild : less-rebuild less-reinstall
all-pkg : less-pkg

less-pkg : PREFIX=/opt/pkg-$(ARCH)/less
less-pkg : $(BUILDDIR)/less/.pkg.marker
$(BUILDDIR)/less/.pkg.marker : 
	$(MAKE) PREFIX=$(PREFIX) less-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/less-$(LESS_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/less.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/less-$(LESS_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 less-$(LESS_VER)-src.zip $(SRCTARDIR)/less-$(LESS_VER).tar.gz $(MAKEFILEDIR)less.mk $(PATCHDIR)/less-$(LESS_VER).patch makefile
	$(TOUCH) $@
