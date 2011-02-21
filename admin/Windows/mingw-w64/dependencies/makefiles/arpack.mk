#
#   MAKEFILE for libarpack
#

ARPACK_VER=96
ARPACK_CONFIGURE_ARGS = 

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

arpack-download : \
    $(SRCTARDIR)/arpack-$(ARPACK_VER).tar.gz \
    $(SRCTARDIR)/arpack-$(ARPACK_VER)-patch.tar.gz

$(SRCTARDIR)/arpack-$(ARPACK_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.caam.rice.edu/software/ARPACK/SRC/arpack$(ARPACK_VER).tar.gz

$(SRCTARDIR)/arpack-$(ARPACK_VER)-patch.tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz

arpack-unpack : $(SRCDIR)/arpack/.unpack.marker
$(SRCDIR)/arpack/.unpack.marker : \
    $(SRCTARDIR)/arpack-$(ARPACK_VER).tar.gz \
    $(SRCTARDIR)/arpack-$(ARPACK_VER)-patch.tar.gz \
    $(PATCHDIR)/arpack-$(ARPACK_VER).patch \
    $(SRCDIR)/arpack/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xz -f $(word 1,$^)
	$(TAR) -C $(dir $@) --strip-components=1 -xz -f $(word 2,$^)
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/arpack-$(ARPACK_VER).patch
	$(TOUCH) $@

arpack-configure : $(BUILDDIR)/arpack/.config.marker
$(BUILDDIR)/arpack/.config.marker : \
    $(SRCDIR)/arpack/.unpack.marker \
    $(BUILDDIR)/arpack/.mkdir.marker
	cp -a $(SRCDIR)/arpack/makefile.mingw $(BUILDDIR)/arpack/makefile
	$(TOUCH) $@

arpack-rebuild : 
	$(MAKE) common-make TGT=all PKG=arpack SRCTOP=$(CURDIR)/$(SRCDIR)/arpack

arpack-build : $(BUILDDIR)/arpack/.build.marker 
$(BUILDDIR)/arpack/.build.marker : $(BUILDDIR)/arpack/.config.marker
	$(MAKE) arpack-rebuild
	$(TOUCH) $@

arpack-reinstall : PKG=arpack
arpack-reinstall : $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/arpack/arpack.dll      $(PREFIX)/bin
	cp -a $(BUILDDIR)/arpack/libarpack.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/arpack/libarpack.a     $(PREFIX)/lib
	$(MAKE) arpack-install-lic

arpack-install-lic :
	echo Nothing to do for arpack license...

arpack-install : $(BUILDDIR)/arpack/.install.marker 
$(BUILDDIR)/arpack/.install.marker : $(BUILDDIR)/arpack/.build.marker
	$(MAKE) arpack-reinstall
	$(TOUCH) $@

arpack-reinstall-strip : 
	$(MAKE) arpack-reinstall
	$(STRIP) $(PREFIX)/bin/arpack.dll

arpack-install-strip : $(BUILDDIR)/arpack/.installstrip.marker 
$(BUILDDIR)/arpack/.installstrip.marker : $(BUILDDIR)/arpack/.build.marker
	$(MAKE) arpack-reinstall-strip
	$(TOUCH) $@

arpack-check : $(BUILDDIR)/arpack/.check.marker
$(BUILDDIR)/arpack/.check.marker : $(BUILDDIR)/arpack/.build.marker
	$(ADDPATH) && $(MAKE) common-make TGT=test PKG=arpack
	$(TOUCH) $@

arpack-all : \
    arpack-download \
    arpack-unpack \
    arpack-configure \
    arpack-build \
    arpack-install

all : arpack-all
all-download : arpack-download
all-install : arpack-install
all-reinstall : arpack-reinstall
all-install-strip : arpack-install-strip
all-reinstall-strip : arpack-install-strip
all-rebuild : arpack-rebuild arpack-reinstall
all-pkg : arpack-pkg

arpack-pkg : PREFIX=/opt/pkg-$(ARCH)/arpack
arpack-pkg :$(BUILDDIR)/arpack/.pkg.marker
$(BUILDDIR)/arpack/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) arpack-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/arpack-$(ARPACK_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/arpack.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/arpack-$(ARPACK_VER)-$(BUILD_ARCH)$(ID)-dev.zip include 
	zip -qr9 arpack-$(ARPACK_VER)-src.zip \
	    $(SRCTARDIR)/arpack-$(ARPACK_VER).tar.gz \
	    $(SRCTARDIR)/arpack-$(ARPACK_VER)-patch.tar.gz \
	    $(PATCHDIR)/arpack-$(ARPACK_VER).patch \
	    $(MAKEFILEDIR)arpack.mk \
	    makefile
	$(TOUCH) $@
