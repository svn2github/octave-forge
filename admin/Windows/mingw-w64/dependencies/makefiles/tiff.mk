#
#   MAKEFILE for libtiff
#

TIFF_VER=3.9.4
TIFF_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--with-zlib-include-dir=$(PREFIX)/include \
--with-zlib-lib-dir=$(PREFIX)/lib \
--with-jpeg-include-dir=$(PREFIX)/include \
--with-jpeg-lib-dir=$(PREFIX)/lib

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

tiff-download : $(SRCTARDIR)/tiff-$(TIFF_VER).tar.gz
$(SRCTARDIR)/tiff-$(TIFF_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ ftp://ftp.remotesensing.org/libtiff/tiff-$(TIFF_VER).tar.gz

tiff-unpack : $(SRCDIR)/tiff/.unpack.marker
$(SRCDIR)/tiff/.unpack.marker : \
    $(SRCTARDIR)/tiff-$(TIFF_VER).tar.gz \
    $(SRCDIR)/tiff/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

tiff-configure : $(BUILDDIR)/tiff/.config.marker
$(BUILDDIR)/tiff/.config.marker : \
    $(SRCDIR)/tiff/.unpack.marker \
    $(BUILDDIR)/tiff/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/tiff/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(TIFF_CONFIGURE_ARGS) $(TIFF_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

tiff-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=tiff

tiff-build : $(BUILDDIR)/tiff/.build.marker 
$(BUILDDIR)/tiff/.build.marker : $(BUILDDIR)/tiff/.config.marker
	$(MAKE) tiff-rebuild
	$(TOUCH) $@

tiff-reinstall :
	$(MAKE) common-make TGT=install PKG=tiff
	$(MAKE) tiff-install-lic

tiff-install-lic :
	mkdir -p $(PREFIX)/license/tiff
	cp -a $(SRCDIR)/tiff/COPYRIGHT $(PREFIX)/license/tiff

tiff-install : $(BUILDDIR)/tiff/.install.marker 
$(BUILDDIR)/tiff/.install.marker : $(BUILDDIR)/tiff/.build.marker
	$(MAKE) tiff-reinstall
	$(TOUCH) $@

tiff-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=tiff
	$(MAKE) tiff-install-lic

tiff-install-strip : $(BUILDDIR)/tiff/.installstrip.marker 
$(BUILDDIR)/tiff/.installstrip.marker : $(BUILDDIR)/tiff/.build.marker
	$(MAKE) tiff-reinstall-strip
	$(TOUCH) $@

tiff-check : $(BUILDDIR)/tiff/.check.marker
$(BUILDDIR)/tiff/.check.marker : $(BUILDDIR)/tiff/.build.marker
	$(MAKE) common-make TGT=check PKG=tiff
	$(TOUCH) $@

tiff-all : \
    tiff-download \
    tiff-unpack \
    tiff-configure \
    tiff-build \
    tiff-install

all : tiff-all
all-download : tiff-download
all-install : tiff-install
all-reinstall : tiff-reinstall
all-install-strip : tiff-install-strip
all-reinstall-strip : tiff-install-strip
all-rebuild : tiff-rebuild tiff-reinstall
all-pkg : tiff-pkg

tiff-pkg : PREFIX=/opt/pkg-$(ARCH)/tiff
tiff-pkg : $(BUILDDIR)/tiff/.pkg.marker
$(BUILDDIR)/tiff/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) tiff-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/tiff-$(TIFF_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libtiff-3.dll bin/libtiffxx-3.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/tiff-$(TIFF_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/tiff-$(TIFF_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/tiff-$(TIFF_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 tiff-$(TIFF_VER)-src.zip $(SRCTARDIR)/tiff-$(TIFF_VER).tar.gz $(MAKEFILEDIR)tiff.mk makefile
	$(TOUCH) $@
