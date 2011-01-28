#
#   MAKEFILE for fftwf
#

FFTWF_VER=3.2.2
FFTWF_CONFIGURE_ARGS = --enable-shared \
--enable-static \
--enable-sse \
--enable-single \
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

fftwf-download : $(SRCTARDIR)/fftw-$(FFTWF_VER).tar.gz
$(SRCTARDIR)/fftw-$(FFTWF_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.fftw.org/fftw-$(FFTWF_VER).tar.gz

fftwf-unpack : $(SRCDIR)/fftwf/.unpack.marker
$(SRCDIR)/fftwf/.unpack.marker : \
    $(SRCTARDIR)/fftw-$(FFTWF_VER).tar.gz \
    $(SRCDIR)/fftwf/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

fftwf-configure : $(BUILDDIR)/fftwf/.config.marker
$(BUILDDIR)/fftwf/.config.marker : \
    $(SRCDIR)/fftwf/.unpack.marker \
    $(BUILDDIR)/fftwf/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/fftwf/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(FFTWF_CONFIGURE_ARGS) $(FFTWF_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

fftwf-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=fftwf

fftwf-build : $(BUILDDIR)/fftwf/.build.marker 
$(BUILDDIR)/fftwf/.build.marker : $(BUILDDIR)/fftwf/.config.marker
	$(MAKE) fftwf-rebuild
	$(TOUCH) $@

fftwf-reinstall : 
	$(MAKE) common-make TGT=install PKG=fftwf
	$(MAKE) fftwf-install-lic

fftwf-install-lic : 
	mkdir -p $(PREFIX)/license/fftwf
	cp -a $(SRCDIR)/fftwf/COPYING $(PREFIX)/license/fftwf
	cp -a $(SRCDIR)/fftwf/COPYRIGHT $(PREFIX)/license/fftwf

fftwf-install : $(BUILDDIR)/fftwf/.install.marker 
$(BUILDDIR)/fftwf/.install.marker : $(BUILDDIR)/fftwf/.build.marker
	$(MAKE) fftwf-reinstall
	$(TOUCH) $@

fftwf-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=fftwf
	$(MAKE) fftwf-install-lic

fftwf-install-strip : $(BUILDDIR)/fftwf/.installstrip.marker 
$(BUILDDIR)/fftwf/.installstrip.marker : $(BUILDDIR)/fftwf/.build.marker
	$(MAKE) fftwf-reinstall-strip
	$(TOUCH) $@

fftwf-check : $(BUILDDIR)/fftwf/.check.marker
$(BUILDDIR)/fftwf/.check.marker : $(BUILDDIR)/fftwf/.build.marker
	$(MAKE) common-make TGT=check PKG=fftwf
	$(TOUCH) $@

fftwf-all : \
    fftwf-download \
    fftwf-unpack \
    fftwf-configure \
    fftwf-build \
    fftwf-install

all : fftwf-all
all-download : fftwf-download
all-install : fftwf-install
all-reinstall : fftwf-reinstall
all-install-strip : fftwf-install-strip
all-reinstall-strip : fftwf-install-strip
all-rebuild : fftwf-rebuild fftwf-reinstall
all-pkg : fftwf-pkg

fftwf-pkg : PREFIX=/opt/pkg-$(ARCH)/fftwf
fftwf-pkg : $(BUILDDIR)/fftwf/.pkg.marker
$(BUILDDIR)/fftwf/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) fftwf-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fftwf-$(FFTWF_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libfftw3f-3.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fftwf-$(FFTWF_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fftwf-$(FFTWF_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/fftwf-$(FFTWF_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 fftwf-$(FFTWF_VER)-src.zip $(SRCTARDIR)/fftw-$(FFTWF_VER).tar.gz $(MAKEFILEDIR)fftwf.mk makefile
	$(TOUCH) $@
