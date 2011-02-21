#
#   MAKEFILE for fontconfig
#

FONTCONFIG_VER=2.8.0
FONTCONFIG_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--with-expat=$(PREFIX) \
--with-freetype-config=$(PREFIX)/bin/freetype-config \
CPPFLAGS="-I$(PREFIX)/include" \
LDFLAGS="-L$(PREFIX)/lib"

#  --- FIXME
#  fontconfig requires native gcc present when building
#  tell it explicitly to use the i686-w64-mingw32-gcc
ifeq ($(ARCH),w64-x64)
   FONTCONFIG_CONFIGURE_ARGS += "CC_FOR_BUILD=i686-w64-mingw32-gcc" --with-arch=le64
endif

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

fontconfig-download : $(SRCTARDIR)/fontconfig-$(FONTCONFIG_VER).tar.gz
$(SRCTARDIR)/fontconfig-$(FONTCONFIG_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://fontconfig.org/release/fontconfig-$(FONTCONFIG_VER).tar.gz

fontconfig-unpack : $(SRCDIR)/fontconfig/.unpack.marker
$(SRCDIR)/fontconfig/.unpack.marker : \
    $(SRCTARDIR)/fontconfig-$(FONTCONFIG_VER).tar.gz \
    $(SRCDIR)/fontconfig/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(dir $@) && aclocal -I . --force
	cd $(dir $@) && libtoolize --force --copy --install
	cd $(dir $@) && autoconf --force
	$(TOUCH) $@

fontconfig-configure : $(BUILDDIR)/fontconfig/.config.marker
$(BUILDDIR)/fontconfig/.config.marker : \
    $(SRCDIR)/fontconfig/.unpack.marker \
    $(BUILDDIR)/fontconfig/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/fontconfig/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(FONTCONFIG_CONFIGURE_ARGS) $(FONTCONFIG_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

fontconfig-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=fontconfig

fontconfig-build : $(BUILDDIR)/fontconfig/.build.marker 
$(BUILDDIR)/fontconfig/.build.marker : $(BUILDDIR)/fontconfig/.config.marker
	$(MAKE) fontconfig-rebuild
	$(TOUCH) $@

fontconfig-reinstall : 
	$(MAKE) common-make TGT=install PKG=fontconfig
	$(MAKE) fontconfig-install-lic

fontconfig-install-lic : 
	mkdir -p $(PREFIX)/license/fontconfig
	cp -a $(SRCDIR)/fontconfig/COPYING $(PREFIX)/license/fontconfig

fontconfig-install : $(BUILDDIR)/fontconfig/.install.marker 
$(BUILDDIR)/fontconfig/.install.marker : $(BUILDDIR)/fontconfig/.build.marker
	$(MAKE) fontconfig-reinstall
	$(TOUCH) $@

fontconfig-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=fontconfig
	$(MAKE) fontconfig-install-lic
	
fontconfig-install-strip : $(BUILDDIR)/fontconfig/.installstrip.marker 
$(BUILDDIR)/fontconfig/.installstrip.marker : $(BUILDDIR)/fontconfig/.build.marker
	$(MAKE) fontconfig-reinstall-strip
	$(TOUCH) $@

fontconfig-check : $(BUILDDIR)/fontconfig/.check.marker
$(BUILDDIR)/fontconfig/.check.marker : $(BUILDDIR)/fontconfig/.build.marker
	$(MAKE) common-make TGT=check PKG=fontconfig
	$(TOUCH) $@

fontconfig-all : \
    fontconfig-download \
    fontconfig-unpack \
    fontconfig-configure \
    fontconfig-build \
    fontconfig-install

all : fontconfig-all
all-download : fontconfig-download
all-install : fontconfig-install
all-reinstall : fontconfig-reinstall
all-install-strip : fontconfig-install-strip
all-reinstall-strip : fontconfig-install-strip
all-rebuild : fontconfig-rebuild fontconfig-reinstall
all-pkg : fontconfig-pkg

fontconfig-pkg : PKGPREFIX=/opt/pkg-$(ARCH)/fontconfig MAKE_PARALLEL=-j1
fontconfig-pkg : $(BUILDDIR)/fontconfig/.pkg.marker
$(BUILDDIR)/fontconfig/.pkg.marker :
	$(ADDPATH); $(MAKE) PREFIX=$(PKGPREFIX) fontconfig-reinstall-strip
	cd $(PKGPREFIX) && zip -qr9 $(CURDIR)/fontconfig-$(FONTCONFIG_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libfontconfig-1.dll etc/fonts/fonts.conf
	cd $(PKGPREFIX) && zip -qr9 $(CURDIR)/fontconfig-$(FONTCONFIG_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PKGPREFIX) && zip -qr9 $(CURDIR)/fontconfig-$(FONTCONFIG_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PKGPREFIX) && zip -qr9 $(CURDIR)/fontconfig-$(FONTCONFIG_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 fontconfig-$(FONTCONFIG_VER)-src.zip $(SRCTARDIR)/fontconfig-$(FONTCONFIG_VER).tar.gz $(MAKEFILEDIR)fontconfig.mk makefile
	$(TOUCH) $@
