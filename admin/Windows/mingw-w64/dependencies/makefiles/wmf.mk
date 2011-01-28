#
#   MAKEFILE for libwmf
#

WMF_VER=0.2.8.4
WMF_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
CPPFLAGS=-I$(PREFIX)/include \
LDFLAGS=-L$(PREFIX)/lib

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

wmf-download : $(SRCTARDIR)/wmf-$(WMF_VER).tar.gz
$(SRCTARDIR)/wmf-$(WMF_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://downloads.sourceforge.net/wvware/libwmf-$(WMF_VER).tar.gz

wmf-unpack : $(SRCDIR)/wmf/.unpack.marker
$(SRCDIR)/wmf/.unpack.marker : \
    $(SRCTARDIR)/wmf-$(WMF_VER).tar.gz \
    $(PATCHDIR)/wmf-$(WMF_VER).patch \
    $(SRCDIR)/wmf/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/wmf-$(WMF_VER).patch
	cd $(dir $@) && export WANT_AUTOMAKE=1.11; aclocal --force
	cd $(dir $@) && libtoolize --force --copy --install
	cd $(dir $@) && export WANT_AUTOMAKE=1.11; automake --force
	cd $(dir $@) && export WANT_AUTOMAKE=1.11; autoconf --force
	$(TOUCH) $@

wmf-configure : $(BUILDDIR)/wmf/.config.marker
$(BUILDDIR)/wmf/.config.marker : \
    $(SRCDIR)/wmf/.unpack.marker \
    $(BUILDDIR)/wmf/.mkdir.marker
	$(ADDPATH); cd $(dir $@) && $(CURDIR)/$(SRCDIR)/wmf/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(WMF_CONFIGURE_ARGS) $(WMF_CONFIGURE_XTRA_ARGS)
	cd $(BUILDDIR)/wmf && sed -e "s/need_relink=yes/need_relink=no/g" < libtool > libtool.mod && mv libtool.mod libtool
	$(TOUCH) $@

wmf-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=wmf

wmf-build : $(BUILDDIR)/wmf/.build.marker 
$(BUILDDIR)/wmf/.build.marker : $(BUILDDIR)/wmf/.config.marker
	$(MAKE) wmf-rebuild
	$(TOUCH) $@

wmf-reinstall :
	$(MAKE) common-make TGT=install PKG=wmf
	$(MAKE) wmf-install-lic

wmf-install-lic :
	mkdir -p $(PREFIX)/license/wmf
	cp -a $(SRCDIR)/wmf/COPYING $(PREFIX)/license/wmf

wmf-install : $(BUILDDIR)/wmf/.install.marker 
$(BUILDDIR)/wmf/.install.marker : $(BUILDDIR)/wmf/.build.marker
	$(MAKE) wmf-reinstall
	$(TOUCH) $@

wmf-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=wmf
	$(MAKE) wmf-install-lic

wmf-install-strip : $(BUILDDIR)/wmf/.installstrip.marker 
$(BUILDDIR)/wmf/.installstrip.marker : $(BUILDDIR)/wmf/.build.marker
	$(MAKE) wmf-reinstall-strip
	$(TOUCH) $@

wmf-check : $(BUILDDIR)/wmf/.check.marker
$(BUILDDIR)/wmf/.check.marker : $(BUILDDIR)/wmf/.build.marker
	$(MAKE) common-make TGT=check PKG=wmf
	$(TOUCH) $@

wmf-all : \
    wmf-download \
    wmf-unpack \
    wmf-configure \
    wmf-build \
    wmf-install

all : wmf-all
all-download : wmf-download
all-install : wmf-install
all-reinstall : wmf-reinstall
all-install-strip : wmf-install-strip
all-reinstall-strip : wmf-install-strip
all-rebuild : wmf-rebuild wmf-reinstall
all-pkg : wmf-pkg

wmf-pkg : PREFIX=/opt/pkg-$(ARCH)/wmf
wmf-pkg : $(BUILDDIR)/wmf/.pkg.marker
$(BUILDDIR)/wmf/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) wmf-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/wmf-$(WMF_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libwmflite-0-2-7.dll share/libwmf/fonts
	cd $(PREFIX) && zip -qr9 $(CURDIR)/wmf-$(WMF_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/libwmf-0-2-7.dll bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/wmf-$(WMF_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib bin/libwmf-config bin/libwmf-fontmap
	cd $(PREFIX) && zip -qr9 $(CURDIR)/wmf-$(WMF_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 wmf-$(WMF_VER)-src.zip $(SRCTARDIR)/wmf-$(WMF_VER).tar.gz $(MAKEFILEDIR)wmf.mk $(PATCHDIR)/wmf-$(WMF_VER).patch makefile
	$(TOUCH) $@
