#
#   MAKEFILE for blas
#

BLAS_VER=

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

blas-download : $(SRCTARDIR)/blas.tar.gz
$(SRCTARDIR)/blas.tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.netlib.org/blas/blas.tgz

blas-unpack : $(SRCDIR)/blas/.unpack.marker
$(SRCDIR)/blas/.unpack.marker : \
    $(SRCTARDIR)/blas.tar.gz \
    $(PATCHDIR)/blas.patch \
    $(SRCDIR)/blas/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(SRCDIR)/blas && patch -p1 -u -i $(CURDIR)/$(PATCHDIR)/blas.patch
	$(TOUCH) $@

blas-configure : $(BUILDDIR)/blas/.config.marker
$(BUILDDIR)/blas/.config.marker : \
    $(SRCDIR)/blas/.unpack.marker \
    $(BUILDDIR)/blas/.mkdir.marker
	cp -va $(SRCDIR)/blas/makefile.mingw $(dir $@)makefile
	$(TOUCH) $@

blas-rebuild : 
	$(MAKE) common-make PKG=blas TGT=all SRCDIR=$(CURDIR)/$(SRCDIR)/blas

blas-build : $(BUILDDIR)/blas/.build.marker
$(BUILDDIR)/blas/.build.marker : $(BUILDDIR)/blas/.config.marker
	$(MAKE) blas-rebuild
	$(TOUCH) $@

blas-reinstall : PKG=blas
blas-reinstall : \
    $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/blas/libblas.a  $(PREFIX)/lib
	cp -a $(BUILDDIR)/blas/blas.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/blas/blas.dll   $(PREFIX)/bin

blas-install : $(BUILDDIR)/blas/.install.marker 
$(BUILDDIR)/blas/.install.marker : $(BUILDDIR)/blas/.build.marker
	$(MAKE) blas-reinstall
	$(TOUCH) $@

blas-reinstall-strip : blas-reinstall
	$(STRIP) $(PREFIX)/bin/blas.dll

blas-install-strip : $(BUILDDIR)/blas/.installstrip.marker 
$(BUILDDIR)/blas/.installstrip.marker : $(BUILDDIR)/blas/.install.marker
	$(MAKE) blas-reinstall-strip
	$(TOUCH) $@

blas-check : $(BUILDDIR)/blas/.check.marker
$(BUILDDIR)/blas/.check.marker : $(BUILDDIR)/blas/.build.marker
	$(TOUCH) $@

blas-all : \
    blas-download \
    blas-unpack \
    blas-configure \
    blas-build \
    blas-install

all : blas-all
all-download : blas-download
all-install : blas-install
all-reinstall : blas-reinstall
all-install-strip : blas-install-strip
all-reinstall-strip : blas-install-strip
all-rebuild : blas-rebuild blas-reinstall
all-pkg : blas-pkg

blas-pkg : PREFIX=/opt/pkg-$(ARCH)/blas
blas-pkg : $(BUILDDIR)/blas/.pkg.marker
$(BUILDDIR)/blas/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) blas-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/blas-$(BUILD_ARCH)$(ID)-bin.zip bin/blas.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/blas-$(BUILD_ARCH)$(ID)-dev.zip lib
	zip -qr9 blas-src.zip $(SRCTARDIR)/blas.tar.gz $(MAKEFILEDIR)blas.mk $(PATCHDIR)/blas.patch makefile
	$(TOUCH) $@
