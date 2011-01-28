#
#   MAKEFILE for jpeg
#

JPEG_VER=8b
JPEG_CONFIGURE_ARGS = --enable-shared --enable-static

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

jpeg-download : $(SRCTARDIR)/jpegsrc.$(JPEG_VER).tar.gz
$(SRCTARDIR)/jpegsrc.$(JPEG_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.ijg.org/files/jpegsrc.v$(JPEG_VER).tar.gz

jpeg-unpack : $(SRCDIR)/jpeg/.unpack.marker
$(SRCDIR)/jpeg/.unpack.marker : \
    $(SRCTARDIR)/jpegsrc.$(JPEG_VER).tar.gz \
    $(SRCDIR)/jpeg/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

jpeg-configure : $(BUILDDIR)/jpeg/.config.marker
$(BUILDDIR)/jpeg/.config.marker : \
    $(SRCDIR)/jpeg/.unpack.marker \
    $(BUILDDIR)/jpeg/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/jpeg/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(JPEG_CONFIGURE_ARGS) $(JPEG_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

jpeg-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=jpeg

jpeg-build : $(BUILDDIR)/jpeg/.build.marker 
$(BUILDDIR)/jpeg/.build.marker : $(BUILDDIR)/jpeg/.config.marker
	$(MAKE) jpeg-rebuild
	$(TOUCH) $@

jpeg-reinstall : 
	$(MAKE) common-make TGT=install PKG=jpeg
	$(MAKE) jpeg-install-lic

jpeg-install-lic : 
	mkdir -p $(PREFIX)/license/jpeg
	cp -a $(SRCDIR)/jpeg/README $(PREFIX)/license/jpeg

jpeg-install : $(BUILDDIR)/jpeg/.install.marker 
$(BUILDDIR)/jpeg/.install.marker : $(BUILDDIR)/jpeg/.build.marker
	$(MAKE) jpeg-reinstall
	$(TOUCH) $@

jpeg-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=jpeg
	$(MAKE) jpeg-install-lic

jpeg-install-strip : $(BUILDDIR)/jpeg/.installstrip.marker 
$(BUILDDIR)/jpeg/.installstrip.marker : $(BUILDDIR)/jpeg/.build.marker
	$(MAKE) jpeg-reinstall-strip
	$(TOUCH) $@

jpeg-check : $(BUILDDIR)/jpeg/.check.marker
$(BUILDDIR)/jpeg/.check.marker : $(BUILDDIR)/jpeg/.build.marker
	$(MAKE) common-make TGT=check PKG=jpeg
	$(TOUCH) $@

jpeg-all : \
    jpeg-download \
    jpeg-unpack \
    jpeg-configure \
    jpeg-build \
    jpeg-install

all : jpeg-all
all-download : jpeg-download
all-install : jpeg-install
all-reinstall : jpeg-reinstall
all-install-strip : jpeg-install-strip
all-reinstall-strip : jpeg-install-strip
all-rebuild : jpeg-rebuild jpeg-reinstall
all-pkg : jpeg-pkg

jpeg-pkg : PREFIX=/opt/pkg-$(ARCH)/jpeg
jpeg-pkg : $(BUILDDIR)/jpeg/.pkg.marker
$(BUILDDIR)/jpeg/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) jpeg-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/jpeg-$(JPEG_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libjpeg-8.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/jpeg-$(JPEG_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/jpeg-$(JPEG_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/jpeg-$(JPEG_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 jpeg-$(JPEG_VER)-src.zip $(SRCTARDIR)/jpegsrc.$(JPEG_VER).tar.gz $(MAKEFILEDIR)jpeg.mk makefile
	$(TOUCH) $@
