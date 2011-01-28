#
#   MAKEFILE for gmp
#

GMP_VER=5.0.1
GMP_CONFIGURE_ARGS = \
--enable-shared \
--disable-static \
--enable-fat

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

gmp-download : $(SRCTARDIR)/gmp-$(GMP_VER).tar.bz2
$(SRCTARDIR)/gmp-$(GMP_VER).tar.bz2 : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://gd.tuwien.ac.at/gnu/gnusrc/gmp/gmp-$(GMP_VER).tar.bz2

gmp-unpack : $(SRCDIR)/gmp/.unpack.marker
$(SRCDIR)/gmp/.unpack.marker : \
    $(SRCTARDIR)/gmp-$(GMP_VER).tar.bz2 \
    $(SRCDIR)/gmp/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	$(TOUCH) $@

# MIND that GMP requires a relative path for SRCDIR because configure
# hard-codes paths into test scripts and msys paths do not work
# with mingw32 gcc...
gmp-configure : $(BUILDDIR)/gmp/.config.marker
$(BUILDDIR)/gmp/.config.marker : \
    $(SRCDIR)/gmp/.unpack.marker \
    $(BUILDDIR)/gmp/.mkdir.marker
	cd $(dir $@) && ../../$(SRCDIR)/gmp/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(GMP_CONFIGURE_ARGS) $(GMP_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

gmp-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=gmp

gmp-build : $(BUILDDIR)/gmp/.build.marker 
$(BUILDDIR)/gmp/.build.marker : $(BUILDDIR)/gmp/.config.marker
	$(MAKE) gmp-rebuild
	$(TOUCH) $@

gmp-reinstall :
	$(MAKE) common-make TGT=install PKG=gmp
	$(MAKE) gmp-install-lic

gmp-install-lic :
	mkdir -p $(PREFIX)/license/gmp
	cp -a $(SRCDIR)/gmp/COPYING $(PREFIX)/license/gmp
	cp -a $(SRCDIR)/gmp/COPYING.LIB $(PREFIX)/license/gmp

gmp-install : $(BUILDDIR)/gmp/.install.marker 
$(BUILDDIR)/gmp/.install.marker : $(BUILDDIR)/gmp/.build.marker
	$(MAKE) gmp-reinstall
	$(TOUCH) $@

gmp-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=gmp
	$(MAKE) gmp-install-lic

gmp-install-strip : $(BUILDDIR)/gmp/.installstrip.marker 
$(BUILDDIR)/gmp/.installstrip.marker : $(BUILDDIR)/gmp/.build.marker
	$(MAKE) gmp-reinstall-strip
	$(TOUCH) $@

gmp-check : $(BUILDDIR)/gmp/.check.marker
$(BUILDDIR)/gmp/.check.marker : $(BUILDDIR)/gmp/.build.marker
	$(MAKE) common-make TGT=check PKG=gmp
	$(TOUCH) $@

gmp-all : \
    gmp-download \
    gmp-unpack \
    gmp-configure \
    gmp-build \
    gmp-install

all : gmp-all
all-download : gmp-download
all-install : gmp-install
all-reinstall : gmp-reinstall
all-install-strip : gmp-install-strip
all-reinstall-strip : gmp-install-strip
all-rebuild : gmp-rebuild gmp-reinstall
all-pkg : gmp-pkg

gmp-pkg : PREFIX=/opt/pkg-$(ARCH)/gmp
gmp-pkg : $(BUILDDIR)/gmp/.pkg.marker
$(BUILDDIR)/gmp/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) gmp-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gmp-$(GMP_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libgmp-10.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gmp-$(GMP_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/gmp-$(GMP_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 gmp-$(GMP_VER)-src.zip $(SRCTARDIR)/gmp-$(GMP_VER).tar.bz2 $(MAKEFILEDIR)gmp.mk makefile
	$(TOUCH) $@
