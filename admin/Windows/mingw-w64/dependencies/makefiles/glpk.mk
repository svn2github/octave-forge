#
#   MAKEFILE for glpk
#

GLPK_VER=4.43
GLPK_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--with-gmp \
LDFLAGS=-L$(PREFIX)/lib \
CPPFLAGS=-I$(PREFIX)/include 

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

glpk-download : $(SRCTARDIR)/glpk-$(GLPK_VER).tar.gz
$(SRCTARDIR)/glpk-$(GLPK_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://gd.tuwien.ac.at/gnu/gnusrc/glpk/glpk-$(GLPK_VER).tar.gz

glpk-unpack : $(SRCDIR)/glpk/.unpack.marker
$(SRCDIR)/glpk/.unpack.marker : \
    $(SRCTARDIR)/glpk-$(GLPK_VER).tar.gz \
    $(PATCHDIR)/glpk-$(GLPK_VER).patch \
    $(SRCDIR)/glpk/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/glpk-$(GLPK_VER).patch
	$(TOUCH) $@

glpk-configure : $(BUILDDIR)/glpk/.config.marker
$(BUILDDIR)/glpk/.config.marker : \
    $(SRCDIR)/glpk/.unpack.marker \
    $(BUILDDIR)/glpk/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/glpk/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(GLPK_CONFIGURE_ARGS) $(GLPK_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

glpk-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=glpk

glpk-build : $(BUILDDIR)/glpk/.build.marker 
$(BUILDDIR)/glpk/.build.marker : $(BUILDDIR)/glpk/.config.marker
	$(MAKE) glpk-rebuild
	$(TOUCH) $@

glpk-reinstall :
	$(MAKE) common-make TGT=install PKG=glpk
	$(MAKE) glpk-install-lic

glpk-install-lic :
	mkdir -p $(PREFIX)/license/glpk
	cp -a $(SRCDIR)/glpk/COPYING $(PREFIX)/license/glpk

glpk-install : $(BUILDDIR)/glpk/.install.marker 
$(BUILDDIR)/glpk/.install.marker : $(BUILDDIR)/glpk/.build.marker
	$(MAKE) glpk-reinstall
	$(TOUCH) $@

glpk-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=glpk
	$(MAKE) glpk-install-lic

glpk-install-strip : $(BUILDDIR)/glpk/.installstrip.marker 
$(BUILDDIR)/glpk/.installstrip.marker : $(BUILDDIR)/glpk/.build.marker
	$(MAKE) glpk-reinstall-strip
	$(TOUCH) $@

glpk-check : $(BUILDDIR)/glpk/.check.marker
$(BUILDDIR)/glpk/.check.marker : $(BUILDDIR)/glpk/.build.marker
	$(MAKE) common-make TGT=check PKG=glpk
	$(TOUCH) $@

glpk-all : \
    glpk-download \
    glpk-unpack \
    glpk-configure \
    glpk-build \
    glpk-install

all : glpk-all
all-download : glpk-download
all-install : glpk-install
all-reinstall : glpk-reinstall
all-install-strip : glpk-install-strip
all-reinstall-strip : glpk-install-strip
all-rebuild : glpk-rebuild glpk-reinstall
all-pkg : glpk-pkg

glpk-pkg : PREFIX=/opt/pkg-$(ARCH)/glpk
glpk-pkg : $(BUILDDIR)/glpk/.pkg.marker
$(BUILDDIR)/glpk/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) glpk-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/glpk-$(GLPK_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libglpk-0.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/glpk-$(GLPK_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/glpk-$(GLPK_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 glpk-$(GLPK_VER)-src.zip $(SRCTARDIR)/glpk-$(GLPK_VER).tar.gz $(MAKEFILEDIR)glpk.mk $(PATCHDIR)/glpk-$(GLPK_VER).patch makefile
	$(TOUCH) $@
