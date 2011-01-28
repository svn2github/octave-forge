#
#   MAKEFILE for lapack
#

LAPACK_VER=3.2.2

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

lapack-download : $(SRCTARDIR)/lapack-$(LAPACK_VER).tar.gz
$(SRCTARDIR)/lapack-$(LAPACK_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.netlib.org/lapack/lapack-$(LAPACK_VER).tgz

lapack-unpack : $(SRCDIR)/lapack/.unpack.marker
$(SRCDIR)/lapack/.unpack.marker : \
    $(SRCTARDIR)/lapack-$(LAPACK_VER).tar.gz \
    $(PATCHDIR)/lapack-$(LAPACK_VER).patch \
    $(SRCDIR)/lapack/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(SRCDIR)/lapack && patch -p1 -u -i $(CURDIR)/$(PATCHDIR)/lapack-$(LAPACK_VER).patch
	$(TOUCH) $@

lapack-configure : $(BUILDDIR)/lapack/.config.marker
$(BUILDDIR)/lapack/.config.marker : \
    $(SRCDIR)/lapack/.unpack.marker \
    $(BUILDDIR)/lapack/.mkdir.marker
	mkdir -p $(BUILDDIR)/lapack/SRC
	mkdir -p $(BUILDDIR)/lapack/INSTALL
	mkdir -p $(BUILDDIR)/lapack/TESTING
	mkdir -p $(BUILDDIR)/lapack/TESTING/EIG
	mkdir -p $(BUILDDIR)/lapack/TESTING/LIN
	mkdir -p $(BUILDDIR)/lapack/TESTING/MATGEN
	cp -a $(SRCDIR)/lapack/make.inc $(BUILDDIR)/lapack
	cp -a $(SRCDIR)/lapack/makefile $(BUILDDIR)/lapack
	cp -a $(SRCDIR)/lapack/install/makefile $(BUILDDIR)/lapack/install
	cp -a $(SRCDIR)/lapack/src/makefile $(BUILDDIR)/lapack/src
	cp -a $(SRCDIR)/lapack/testing/makefile $(BUILDDIR)/lapack/testing
	cp -a $(SRCDIR)/lapack/testing/eig/makefile $(BUILDDIR)/lapack/testing/eig
	cp -a $(SRCDIR)/lapack/testing/lin/makefile $(BUILDDIR)/lapack/testing/lin
	cp -a $(SRCDIR)/lapack/testing/matgen/makefile $(BUILDDIR)/lapack/testing/matgen
	$(TOUCH) $@

lapack-rebuild : 
	$(MAKE) common-make PKG=lapack TGT=lapacklib SRCDIR=$(CURDIR)/$(SRCDIR)/lapack
	$(MAKE) common-make PKG=lapack TGT=shlib SRCDIR=$(CURDIR)/$(SRCDIR)/lapack

lapack-build : $(BUILDDIR)/lapack/.build.marker
$(BUILDDIR)/lapack/.build.marker : $(BUILDDIR)/lapack/.config.marker
	$(MAKE) lapack-rebuild
	$(TOUCH) $@

lapack-reinstall : \
    $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/lapack/liblapack.a     $(PREFIX)/lib
	cp -a $(BUILDDIR)/lapack/liblapack.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/lapack/lapack.dll      $(PREFIX)/bin
	cp -a $(SRCDIR)/lapack/LICENSE           $(PREFIX)/license/lapack

lapack-install : $(BUILDDIR)/lapack/.install.marker 
$(BUILDDIR)/lapack/.install.marker : $(BUILDDIR)/lapack/.build.marker
	$(MAKE) lapack-reinstall
	$(TOUCH) $@

lapack-reinstall-strip : lapack-reinstall
	$(STRIP) $(PREFIX)/bin/lapack.dll

lapack-install-strip : $(BUILDDIR)/lapack/.installstrip.marker 
$(BUILDDIR)/lapack/.installstrip.marker : $(BUILDDIR)/lapack/.install.marker
	$(MAKE) lapack-reinstall-strip
	$(TOUCH) $@

lapack-check : $(BUILDDIR)/lapack/.check.marker
$(BUILDDIR)/lapack/.check.marker : $(BUILDDIR)/lapack/.build.marker
	$(ADDPATH); $(MAKE) common-make PKG=lapack TGT=lapack-testing SRCDIR=$(CURDIR)/$(SRCDIR)/lapack
	$(TOUCH) $@

lapack-all : \
    lapack-download \
    lapack-unpack \
    lapack-configure \
    lapack-build \
    lapack-install

all : lapack-all
all-download : lapack-download
all-install : lapack-install
all-reinstall : lapack-reinstall
all-install-strip : lapack-install-strip
all-reinstall-strip : lapack-install-strip
all-rebuild : lapack-rebuild lapack-reinstall
all-pkg : lapack-pkg

lapack-pkg : PREFIX=/opt/pkg-$(ARCH)/lapack
lapack-pkg : $(BUILDDIR)/lapack/.pkg.marker
$(BUILDDIR)/lapack/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) lapack-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/lapack-$(LAPACK_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/lapack.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/lapack-$(LAPACK_VER)-$(BUILD_ARCH)$(ID)-dev.zip lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/lapack-$(LAPACK_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 lapack-$(LAPACK_VER)-src.zip $(SRCTARDIR)/lapack-$(LAPACK_VER).tar.gz $(PATCHDIR)/lapack-$(LAPACK_VER).patch $(MAKEFILEDIR)lapack.mk makefile
	$(TOUCH) $@
