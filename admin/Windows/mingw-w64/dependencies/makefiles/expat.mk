#
#   MAKEFILE for libexpat
#

EXPAT_VER=2.0.1
EXPAT_CONFIGURE_ARGS = \
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

expat-download : $(SRCTARDIR)/expat-$(EXPAT_VER).tar.gz
$(SRCTARDIR)/expat-$(EXPAT_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://downloads.sourceforge.net/expat/expat-$(EXPAT_VER).tar.gz

expat-unpack : $(SRCDIR)/expat/.unpack.marker
$(SRCDIR)/expat/.unpack.marker : \
    $(SRCTARDIR)/expat-$(EXPAT_VER).tar.gz \
    $(SRCDIR)/expat/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

expat-configure : $(BUILDDIR)/expat/.config.marker
$(BUILDDIR)/expat/.config.marker : \
    $(SRCDIR)/expat/.unpack.marker \
    $(BUILDDIR)/expat/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/expat/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(EXPAT_CONFIGURE_ARGS) $(EXPAT_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

expat-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=expat

expat-build : $(BUILDDIR)/expat/.build.marker 
$(BUILDDIR)/expat/.build.marker : $(BUILDDIR)/expat/.config.marker
	$(MAKE) expat-rebuild
	$(TOUCH) $@

expat-reinstall :
	$(MAKE) common-make TGT=install PKG=expat
	$(MAKE) expat-install-lic

expat-install-lic :
	mkdir -p $(PREFIX)/license/expat
	cp -a $(SRCDIR)/expat/COPYING $(PREFIX)/license/expat

expat-install : $(BUILDDIR)/expat/.install.marker 
$(BUILDDIR)/expat/.install.marker : $(BUILDDIR)/expat/.build.marker
	$(MAKE) expat-reinstall
	$(TOUCH) $@

expat-reinstall-strip : 
	$(MAKE) expat-reinstall
	$(STRIP) $(PREFIX)/bin/libexpat-1.dll
	$(STRIP) $(PREFIX)/bin/xmlwf.exe

expat-install-strip : $(BUILDDIR)/expat/.installstrip.marker 
$(BUILDDIR)/expat/.installstrip.marker : $(BUILDDIR)/expat/.build.marker
	$(MAKE) expat-reinstall-strip
	$(TOUCH) $@

expat-check : $(BUILDDIR)/expat/.check.marker
$(BUILDDIR)/expat/.check.marker : $(BUILDDIR)/expat/.build.marker
	$(MAKE) common-make TGT=check PKG=expat
	$(TOUCH) $@

expat-all : \
    expat-download \
    expat-unpack \
    expat-configure \
    expat-build \
    expat-install

all : expat-all
all-download : expat-download
all-install : expat-install
all-reinstall : expat-reinstall
all-install-strip : expat-install-strip
all-reinstall-strip : expat-install-strip
all-rebuild : expat-rebuild expat-reinstall
all-pkg : expat-pkg

expat-pkg : PREFIX=/opt/pkg-$(ARCH)/expat
expat-pkg : $(BUILDDIR)/expat/.pkg.marker
$(BUILDDIR)/expat/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) expat-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/expat-$(EXPAT_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libexpat-1.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/expat-$(EXPAT_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/xmlwf.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/expat-$(EXPAT_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/expat-$(EXPAT_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 expat-$(EXPAT_VER)-src.zip $(SRCTARDIR)/expat-$(EXPAT_VER).tar.gz $(MAKEFILEDIR)expat.mk makefile
	$(TOUCH) $@
