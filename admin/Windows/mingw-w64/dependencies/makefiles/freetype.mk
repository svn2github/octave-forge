#
#   MAKEFILE for freetype
#

FREETYPE_VER=2.3.12
FREETYPE_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
LDFLAGS=-L$(PREFIX)/lib \
CPPFLAGS=-I$(PREFIX)/include

#  --- FIXME
#  freetype requires native gcc present when building
#  fool it into believeing we are i686-w64-mingw32
ifeq ($(ARCH),w64-x64)
   FREETYPE_CONFIGURE_ARGS += "--build=i686-w64-mingw32"
endif

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

freetype-download : $(SRCTARDIR)/freetype-$(FREETYPE_VER).tar.bz2
$(SRCTARDIR)/freetype-$(FREETYPE_VER).tar.bz2 : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://downloads.sourceforge.net/freetype/freetype-$(FREETYPE_VER).tar.bz2

freetype-unpack : $(SRCDIR)/freetype/.unpack.marker
$(SRCDIR)/freetype/.unpack.marker : \
    $(SRCTARDIR)/freetype-$(FREETYPE_VER).tar.bz2 \
    $(SRCDIR)/freetype/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	cd $(dir $@) && ./autogen.sh
	$(TOUCH) $@

freetype-configure : $(BUILDDIR)/freetype/.config.marker
$(BUILDDIR)/freetype/.config.marker : \
    $(SRCDIR)/freetype/.unpack.marker \
    $(BUILDDIR)/freetype/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/freetype/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(FREETYPE_CONFIGURE_ARGS) $(FREETYPE_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

freetype-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=freetype

freetype-build : $(BUILDDIR)/freetype/.build.marker 
$(BUILDDIR)/freetype/.build.marker : $(BUILDDIR)/freetype/.config.marker
	$(MAKE) freetype-rebuild
	$(TOUCH) $@

freetype-reinstall : 
	$(MAKE) common-make TGT=install PKG=freetype
	$(MAKE) freetype-install-lic

freetype-install-lic : 
	mkdir -p $(PREFIX)/license/freetype
	cp -a $(SRCDIR)/freetype/docs/GPL.txt $(PREFIX)/license/freetype
	cp -a $(SRCDIR)/freetype/docs/LICENSE.txt $(PREFIX)/license/freetype
	cp -a $(SRCDIR)/freetype/src/pcf/README $(PREFIX)/license/freetype/README.pcf

freetype-install : $(BUILDDIR)/freetype/.install.marker 
$(BUILDDIR)/freetype/.install.marker : $(BUILDDIR)/freetype/.build.marker
	$(MAKE) freetype-reinstall
	$(TOUCH) $@

freetype-reinstall-strip : 
	$(MAKE) freetype-reinstall
	$(STRIP) $(PREFIX)/bin/libfreetype-6.dll

freetype-install-strip : $(BUILDDIR)/freetype/.installstrip.marker 
$(BUILDDIR)/freetype/.installstrip.marker : $(BUILDDIR)/freetype/.build.marker
	$(MAKE) freetype-reinstall-strip
	$(TOUCH) $@

freetype-check : $(BUILDDIR)/freetype/.check.marker
$(BUILDDIR)/freetype/.check.marker : $(BUILDDIR)/freetype/.build.marker
	$(MAKE) common-make TGT=check PKG=freetype
	$(TOUCH) $@

freetype-all : \
    freetype-download \
    freetype-unpack \
    freetype-configure \
    freetype-build \
    freetype-install

all : freetype-all
all-download : freetype-download
all-install : freetype-install
all-reinstall : freetype-reinstall
all-install-strip : freetype-install-strip
all-reinstall-strip : freetype-install-strip
all-rebuild : freetype-rebuild freetype-reinstall
all-pkg : freetype-pkg

freetype-pkg : PREFIX=/opt/pkg-$(ARCH)/freetype
freetype-pkg : $(BUILDDIR)/freetype/.pkg.marker
$(BUILDDIR)/freetype/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) freetype-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/freetype-$(FREETYPE_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libfreetype-6.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/freetype-$(FREETYPE_VER)-$(BUILD_ARCH)$(ID)-dev.zip bin/freetype-config include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/freetype-$(FREETYPE_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 freetype-$(FREETYPE_VER)-src.zip $(SRCTARDIR)/freetype-$(FREETYPE_VER).tar.bz2 $(MAKEFILEDIR)freetype.mk makefile
	$(TOUCH) $@
