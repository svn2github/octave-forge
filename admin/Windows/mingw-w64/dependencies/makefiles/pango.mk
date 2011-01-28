#
#   MAKEFILE for libpango
#

PANGO_VER=1.28.1
PANGO_CONFIGURE_ARGS = \
--enable-shared \
--disable-static \
--disable-gtk-doc \
--without-x \
--enable-explicit-deps=no \
--with-included-modules=yes
#
#  Pango cannot be built as static library on windows!
#

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

pango-download : $(SRCTARDIR)/pango-$(PANGO_VER).tar.bz2
$(SRCTARDIR)/pango-$(PANGO_VER).tar.bz2 : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://ftp.gnome.org/pub/GNOME/sources/pango/1.28/pango-$(PANGO_VER).tar.bz2

pango-unpack : $(SRCDIR)/pango/.unpack.marker
$(SRCDIR)/pango/.unpack.marker : \
    $(SRCTARDIR)/pango-$(PANGO_VER).tar.bz2 \
    $(SRCDIR)/pango/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	$(TOUCH) $@

pango-configure : $(BUILDDIR)/pango/.config.marker
$(BUILDDIR)/pango/.config.marker : \
    $(SRCDIR)/pango/.unpack.marker \
    $(BUILDDIR)/pango/.mkdir.marker
	$(ADDPATH) && cd $(dir $@) && $(CURDIR)/$(SRCDIR)/pango/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(PANGO_CONFIGURE_ARGS) $(PANGO_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

pango-rebuild : 
	$(ADDPATH); $(MAKE) common-configure-make TGT=all PKG=pango

pango-build : $(BUILDDIR)/pango/.build.marker 
$(BUILDDIR)/pango/.build.marker : $(BUILDDIR)/pango/.config.marker
	$(MAKE) pango-rebuild
	$(TOUCH) $@

pango-reinstall :
	$(MAKE) common-make TGT=install PKG=pango
	$(MAKE) pango-install-lic
	$(MAKE) pango-install-postproc

pango-install-lic :
	mkdir -p $(PREFIX)/license/pango
	cp -a $(SRCDIR)/pango/COPYING $(PREFIX)/license/pango

pango-install : $(BUILDDIR)/pango/.install.marker 
$(BUILDDIR)/pango/.install.marker : $(BUILDDIR)/pango/.build.marker
	$(MAKE) pango-reinstall
	$(TOUCH) $@

pango-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=pango
	$(MAKE) pango-install-lic
	$(MAKE) pango-install-postproc

pango-install-strip : $(BUILDDIR)/pango/.installstrip.marker 
$(BUILDDIR)/pango/.installstrip.marker : $(BUILDDIR)/pango/.build.marker
	$(MAKE) pango-reinstall-strip
	$(TOUCH) $@

pango-install-postproc :
	sed -e "s/^# ModulesPath =.*/#/" $(PREFIX)/etc/pango/pango.modules > $(PREFIX)/etc/pango/pango.modules.mod \
	&& mv $(PREFIX)/etc/pango/pango.modules.mod $(PREFIX)/etc/pango/pango.modules
	-mv $(PREFIX)/lib/libpango*.dll $(PREFIX)/bin
# when cross-compiling, pango installs the dlls into $(PREFIX)/lib/ ??

pango-all : \
    pango-download \
    pango-unpack \
    pango-configure \
    pango-build \
    pango-install

all : pango-all
all-download : pango-download
all-install : pango-install
all-reinstall : pango-reinstall
all-install-strip : pango-install-strip
all-reinstall-strip : pango-install-strip
all-rebuild : pango-rebuild pango-reinstall
all-pkg : pango-pkg

pango-pkg : PREFIX=/opt/pkg-$(ARCH)/pango
pango-pkg : $(BUILDDIR)/pango/.pkg.marker
$(BUILDDIR)/pango/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) pango-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pango-$(PANGO_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/*.dll etc
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pango-$(PANGO_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pango-$(PANGO_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/pango-$(PANGO_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 pango-$(PANGO_VER)-src.zip $(SRCTARDIR)/pango-$(PANGO_VER).tar.bz2 $(MAKEFILEDIR)pango.mk makefile
	$(TOUCH) $@
