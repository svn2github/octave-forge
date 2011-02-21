#
#   MAKEFILE for libregex
#

REGEX_VER=2.5.1
REGEX_CONFIGURE_ARGS = \
AR=$(CROSS)ar

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

regex-download : $(SRCTARDIR)/regex-$(REGEX_VER).tar.gz
$(SRCTARDIR)/regex-$(REGEX_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://downloads.sourceforge.net/mingw/mingw-libgnurx-$(REGEX_VER)-src.tar.gz

regex-unpack : $(SRCDIR)/regex/.unpack.marker
$(SRCDIR)/regex/.unpack.marker : \
    $(SRCTARDIR)/regex-$(REGEX_VER).tar.gz \
    $(PATCHDIR)/regex-$(REGEX_VER).patch \
    $(SRCDIR)/regex/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/regex-$(REGEX_VER).patch
	$(TOUCH) $@

regex-configure : $(BUILDDIR)/regex/.config.marker
$(BUILDDIR)/regex/.config.marker : \
    $(SRCDIR)/regex/.unpack.marker \
    $(BUILDDIR)/regex/.mkdir.marker
	cd $(SRCDIR)/regex && autoconf
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/regex/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(REGEX_CONFIGURE_ARGS) $(REGEX_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

regex-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=regex

regex-build : $(BUILDDIR)/regex/.build.marker 
$(BUILDDIR)/regex/.build.marker : $(BUILDDIR)/regex/.config.marker
	$(MAKE) regex-rebuild
	$(TOUCH) $@

regex-reinstall :
	$(MAKE) common-make TGT=install PKG=regex
	$(MAKE) regex-install-lic

regex-install-lic :
	mkdir -p $(PREFIX)/license/regex
	cp -a $(SRCDIR)/regex/COPYING.LIB $(PREFIX)/license/regex

regex-install : $(BUILDDIR)/regex/.install.marker 
$(BUILDDIR)/regex/.install.marker : $(BUILDDIR)/regex/.build.marker
	$(MAKE) regex-reinstall
	$(TOUCH) $@

regex-reinstall-strip : 
	$(MAKE) regex-reinstall
	$(STRIP) $(PREFIX)/bin/libgnurx-0.dll

regex-install-strip : $(BUILDDIR)/regex/.installstrip.marker 
$(BUILDDIR)/regex/.installstrip.marker : $(BUILDDIR)/regex/.build.marker
	$(MAKE) regex-reinstall-strip
	$(TOUCH) $@

regex-check : $(BUILDDIR)/regex/.check.marker
$(BUILDDIR)/regex/.check.marker : $(BUILDDIR)/regex/.build.marker
	$(MAKE) common-make TGT=check PKG=regex
	$(TOUCH) $@

regex-all : \
    regex-download \
    regex-unpack \
    regex-configure \
    regex-build \
    regex-install

all : regex-all
all-download : regex-download
all-install : regex-install
all-reinstall : regex-reinstall
all-install-strip : regex-install-strip
all-reinstall-strip : regex-install-strip
all-rebuild : regex-rebuild regex-reinstall
all-pkg : regex-pkg

regex-pkg : PREFIX=/opt/pkg-$(ARCH)/regex
regex-pkg : $(BUILDDIR)/regex/.pkg.marker
$(BUILDDIR)/regex/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) regex-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/regex-$(REGEX_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/*.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/regex-$(REGEX_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/regex-$(REGEX_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 regex-$(REGEX_VER)-src.zip $(SRCTARDIR)/regex-$(REGEX_VER).tar.gz $(MAKEFILEDIR)regex.mk $(PATCHDIR)/regex-$(REGEX_VER).patch makefile
	$(TOUCH) $@
