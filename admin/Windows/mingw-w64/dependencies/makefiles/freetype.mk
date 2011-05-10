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
    $(PATCHDIR)/freetype-$(FREETYPE_VER).patch \
    $(SRCDIR)/freetype/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/freetype-$(FREETYPE_VER).patch
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
	$(MAKE) freetype-install-post

# move the headers from 
#  $prefix/include/freetype2/freetype/config
# to
#  $prefix/include/freetype/config
# and remove all build-time local paths from the config scripts
freetype-install-post :
	if test -d $(PREFIX)/include/freetype; then rm -rf $(PREFIX)/include/freetype; fi
	mv -t $(PREFIX)/include $(PREFIX)/include/freetype2/freetype
	rmdir $(PREFIX)/include/freetype2
	sed -e "s/^srcdir=.*/srcdir=/" \
	    -e "s/^prefix=.*/prefix=/" \
	    -e "s/^exec_prefix=.*/exec_prefix=/" \
	    -e "s/^bindir=.*/bindir=/" \
	    -e "s/^includedir=.*/includedir=/" \
	    -e "s/^libdir=.*/libdir=/" \
	    < $(PREFIX)/bin/freetype-config > $(PREFIX)/bin/freetype-config-mod && \
	mv $(PREFIX)/bin/freetype-config-mod $(PREFIX)/bin/freetype-config


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
	zip -qr9 freetype-$(FREETYPE_VER)-src.zip $(SRCTARDIR)/freetype-$(FREETYPE_VER).tar.bz2 $(MAKEFILEDIR)freetype.mk $(PATCHDIR)/freetype-$(FREETYPE_VER).patch makefile
	$(TOUCH) $@
