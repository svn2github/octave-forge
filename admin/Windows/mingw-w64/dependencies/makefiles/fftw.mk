#
#   MAKEFILE for fftw
#

FFTW_VER=3.2.2
FFTW_CONFIGURE_ARGS = --enable-shared \
--enable-static \
--enable-sse2 \
--enable-portable-binary \
--with-our-malloc16

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

fftw-download : $(SRCTARDIR)/fftw-$(FFTW_VER).tar.gz
$(SRCTARDIR)/fftws-$(FFTW_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.fftw.org/fftw-$(FFTW_VER).tar.gz

fftw-unpack : $(SRCDIR)/fftw/.unpack.marker
$(SRCDIR)/fftw/.unpack.marker : \
    $(SRCTARDIR)/fftw-$(FFTW_VER).tar.gz \
    $(SRCDIR)/fftw/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

fftw-configure : $(BUILDDIR)/fftw/.config.marker
$(BUILDDIR)/fftw/.config.marker : \
    $(SRCDIR)/fftw/.unpack.marker \
    $(BUILDDIR)/fftw/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/fftw/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(FFTW_CONFIGURE_ARGS) $(FFTW_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

fftw-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=fftw

fftw-build : $(BUILDDIR)/fftw/.build.marker 
$(BUILDDIR)/fftw/.build.marker : $(BUILDDIR)/fftw/.config.marker
	$(MAKE) fftw-rebuild
	$(TOUCH) $@

fftw-reinstall : 
	$(MAKE) common-make TGT=install PKG=fftw
	$(MAKE) fftw-install-lic

fftw-install-lic : 
	mkdir -p $(PREFIX)/license/fftw
	cp -a $(SRCDIR)/fftw/COPYING $(PREFIX)/license/fftw
	cp -a $(SRCDIR)/fftw/COPYRIGHT $(PREFIX)/license/fftw

fftw-install : $(BUILDDIR)/fftw/.install.marker 
$(BUILDDIR)/fftw/.install.marker : $(BUILDDIR)/fftw/.build.marker
	$(MAKE) fftw-reinstall
	$(TOUCH) $@

fftw-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=fftw
	$(MAKE) fftw-install-lic

fftw-install-strip : $(BUILDDIR)/fftw/.installstrip.marker 
$(BUILDDIR)/fftw/.installstrip.marker : $(BUILDDIR)/fftw/.build.marker
	$(MAKE) fftw-reinstall-strip
	$(TOUCH) $@

fftw-check : $(BUILDDIR)/fftw/.check.marker
$(BUILDDIR)/fftw/.check.marker : $(BUILDDIR)/fftw/.build.marker
	$(MAKE) common-make TGT=check PKG=fftw
	$(TOUCH) $@

fftw-all : \
    fftw-download \
    fftw-unpack \
    fftw-configure \
    fftw-build \
    fftw-install

all : fftw-all
all-download : fftw-download
all-install : fftw-install
all-reinstall : fftw-reinstall
all-install-strip : fftw-install-strip
all-reinstall-strip : fftw-install-strip
all-rebuild : fftw-rebuild fftw-reinstall
all-pkg : fftw-pkg

fftw-pkg : PREFIX=/opt/pkg-$(ARCH)/fftw
fftw-pkg : $(BUILDDIR)/fftw/.pkg.marker
$(BUILDDIR)/fftw/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) fftw-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fftw-$(FFTW_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libfftw3-3.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fftw-$(FFTW_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fftw-$(FFTW_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fftw-$(FFTW_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 fftw-$(FFTW_VER)-src.zip $(SRCTARDIR)/fftw-$(FFTW_VER).tar.gz $(MAKEFILEDIR)fftw.mk makefile
	$(TOUCH) $@
