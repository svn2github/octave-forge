#
#   MAKEFILE for fltk
#

FLTK_VER=1.1.10
FLTK_CONFIGURE_ARGS = \
--enable-shared \
--enable-gl \
--enable-threads \
CFLAGS="-DFL_DLL" \
CXXFLAGS="-DFL_DLL" \
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

fltk-download : $(SRCTARDIR)/fltk-$(FLTK_VER).tar.bz2
$(SRCTARDIR)/fltk-$(FLTK_VER).tar.bz2 : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://ftp.funet.fi/pub/mirrors/ftp.easysw.com/pub/fltk/$(FLTK_VER)/fltk-$(FLTK_VER)-source.tar.bz2

fltk-unpack : $(SRCDIR)/fltk/.unpack.marker
$(SRCDIR)/fltk/.unpack.marker : \
    $(SRCTARDIR)/fltk-$(FLTK_VER).tar.bz2 \
    $(PATCHDIR)/fltk-$(FLTK_VER).patch \
    $(SRCDIR)/fltk/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/fltk-$(FLTK_VER).patch
	$(TOUCH) $@

fltk-configure : $(BUILDDIR)/fltk/.config.marker
$(BUILDDIR)/fltk/.config.marker : \
    $(SRCDIR)/fltk/.unpack.marker \
    $(BUILDDIR)/fltk/.mkdir.marker
	cd $(SRCDIR)/fltk && autoconf
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/fltk/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(FLTK_CONFIGURE_ARGS) $(FLTK_CONFIGURE_XTRA_ARGS)
	mkdir $(BUILDDIR)/fltk/src
	mkdir $(BUILDDIR)/fltk/lib
	mkdir $(BUILDDIR)/fltk/fluid
	mkdir $(BUILDDIR)/fltk/test
	cp -a $(SRCDIR)/fltk/makefile $(BUILDDIR)/fltk
	cp -a $(SRCDIR)/fltk/src/makefile $(BUILDDIR)/fltk/src
	cp -a $(SRCDIR)/fltk/fluid/makefile $(BUILDDIR)/fltk/fluid
	cp -a $(SRCDIR)/fltk/test/makefile $(BUILDDIR)/fltk/test
	sed -e \
	    "s@../FL@\$$(srcdir)/FL@g" \
	    $(SRCDIR)/fltk/src/makedepend > $(BUILDDIR)/fltk/src/makedepend
	sed -e \
	    "s@../FL@\$$(srcdir)/FL@g" \
	    $(SRCDIR)/fltk/fluid/makedepend > $(BUILDDIR)/fltk/fluid/makedepend
	sed -e \
	    "s@../FL@\$$(srcdir)/FL@g" \
	    $(SRCDIR)/fltk/test/makedepend > $(BUILDDIR)/fltk/test/makedepend
	$(TOUCH) $@

fltk-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=fltk DIRS="src fluid"

fltk-build : $(BUILDDIR)/fltk/.build.marker 
$(BUILDDIR)/fltk/.build.marker : $(BUILDDIR)/fltk/.config.marker
	$(MAKE) fltk-rebuild
	$(TOUCH) $@

fltk-reinstall :
	$(MAKE) common-make TGT=install PKG=fltk DIRS=src
	$(MAKE) fltk-install-lic

fltk-install-lic :
	mkdir -p $(PREFIX)/license/fltk
	cp -a $(SRCDIR)/fltk/COPYING $(PREFIX)/license/fltk

fltk-install : $(BUILDDIR)/fltk/.install.marker 
$(BUILDDIR)/fltk/.install.marker : $(BUILDDIR)/fltk/.build.marker
	$(MAKE) fltk-reinstall
	$(TOUCH) $@

fltk-reinstall-strip : 
	$(MAKE) fltk-reinstall
	$(STRIP) $(PREFIX)/bin/mgwfltknox_forms-1.1.dll
	$(STRIP) $(PREFIX)/bin/mgwfltknox_gl-1.1.dll
	$(STRIP) $(PREFIX)/bin/mgwfltknox_images-1.1.dll
	$(STRIP) $(PREFIX)/bin/mgwfltknox-1.1.dll

fltk-install-strip : $(BUILDDIR)/fltk/.installstrip.marker 
$(BUILDDIR)/fltk/.installstrip.marker : $(BUILDDIR)/fltk/.build.marker
	$(MAKE) fltk-reinstall-strip
	$(TOUCH) $@

fltk-check : $(BUILDDIR)/fltk/.check.marker
$(BUILDDIR)/fltk/.check.marker : $(BUILDDIR)/fltk/.build.marker
	$(ADDPATH); $(MAKE) common-make TGT=all PKG=fltk DIRS=test
	$(TOUCH) $@

fltk-all : \
    fltk-download \
    fltk-unpack \
    fltk-configure \
    fltk-build \
    fltk-install

all : fltk-all
all-download : fltk-download
all-install : fltk-install
all-reinstall : fltk-reinstall
all-install-strip : fltk-install-strip
all-reinstall-strip : fltk-install-strip
all-rebuild : fltk-rebuild fltk-reinstall
all-pkg : fltk-pkg

fltk-pkg : PREFIX=/opt/pkg-$(ARCH)/fltk
fltk-pkg : $(BUILDDIR)/fltk/.pkg.marker
$(BUILDDIR)/fltk/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) fltk-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fltk-$(FLTK_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/*.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fltk-$(FLTK_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib bin/fltk-config
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fltk-$(FLTK_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 fltk-$(FLTK_VER)-src.zip $(SRCTARDIR)/fltk-$(FLTK_VER).tar.bz2 $(MAKEFILEDIR)fltk.mk $(PATCHDIR)/fltk-$(FLTK_VER).patch makefile
	$(TOUCH) $@
