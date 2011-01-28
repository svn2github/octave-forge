#
#   MAKEFILE for pkg-config
#

PKG_CONFIG_VER=0.23
PKG_CONFIG_CONFIGURE_ARGS = \
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

pkg-config-download : $(SRCTARDIR)/pkg-config-$(PKG_CONFIG_VER).tar.gz
$(SRCTARDIR)/pkg-config-$(PKG_CONFIG_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/pkg-config-$(PKG_CONFIG_VER).tar.gz

pkg-config-unpack : $(SRCDIR)/pkg-config/.unpack.marker
$(SRCDIR)/pkg-config/.unpack.marker : \
    $(SRCTARDIR)/pkg-config-$(PKG_CONFIG_VER).tar.gz \
    $(PATCHDIR)/pkg-config-$(PKG_CONFIG_VER).patch \
    $(SRCDIR)/pkg-config/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(SRCDIR)/pkg-config && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/pkg-config-$(PKG_CONFIG_VER).patch
	$(TOUCH) $@

pkg-config-configure : $(BUILDDIR)/pkg-config/.config.marker
$(BUILDDIR)/pkg-config/.config.marker : \
    $(SRCDIR)/pkg-config/.unpack.marker \
    $(BUILDDIR)/pkg-config/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/pkg-config/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(PKG_CONFIG_CONFIGURE_ARGS) $(PKG_CONFIG_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

pkg-config-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=pkg-config

pkg-config-build : $(BUILDDIR)/pkg-config/.build.marker 
$(BUILDDIR)/pkg-config/.build.marker : $(BUILDDIR)/pkg-config/.config.marker
	$(MAKE) pkg-config-rebuild
	$(TOUCH) $@

pkg-config-reinstall : $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/pkg-config/pkg-config.exe $(PREFIX)/bin
	$(MAKE) pkg-config-install-lic

pkg-config-install-lic :
	mkdir -p $(PREFIX)/license/pkg-config
	cp -a $(SRCDIR)/pkg-config/COPYING $(PREFIX)/license/pkg-config

pkg-config-install : $(BUILDDIR)/pkg-config/.install.marker 
$(BUILDDIR)/pkg-config/.install.marker : $(BUILDDIR)/pkg-config/.build.marker
	$(MAKE) pkg-config-reinstall
	$(TOUCH) $@

pkg-config-reinstall-strip : 
	$(MAKE) pkg-config-reinstall
	$(STRIP) $(PREFIX)/bin/pkg-config.exe

pkg-config-install-strip : $(BUILDDIR)/pkg-config/.installstrip.marker 
$(BUILDDIR)/pkg-config/.installstrip.marker : $(BUILDDIR)/pkg-config/.build.marker
	$(MAKE) pkg-config-reinstall-strip
	$(TOUCH) $@

pkg-config-all : \
    pkg-config-download \
    pkg-config-unpack \
    pkg-config-configure \
    pkg-config-build \
    pkg-config-install

all : pkg-config-all
all-download : pkg-config-download
all-install : pkg-config-install
all-reinstall : pkg-config-reinstall
all-install-strip : pkg-config-install-strip
all-reinstall-strip : pkg-config-install-strip
all-rebuild : pkg-config-rebuild pkg-config-reinstall
all-pkg : pkg-config-pkg

pkg-config-pkg : PREFIX=/opt/pkg-$(ARCH)/pkg-config
pkg-config-pkg : $(BUILDDIR)/pkg-config/.pkg.marker
$(BUILDDIR)/pkg-config/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) pkg-config-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pkg-config-$(PKG_CONFIG_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/pkg-config.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pkg-config-$(PKG_CONFIG_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 pkg-config-$(PKG_CONFIG_VER)-src.zip $(SRCTARDIR)/pkg-config-$(PKG_CONFIG_VER).tar.gz pkg-config.mk $(MAKEFILEDIR)makefile $(PATCHDIR)/pkg-config-$(PKG_CONFIG_VER).patch
	$(TOUCH) $@
