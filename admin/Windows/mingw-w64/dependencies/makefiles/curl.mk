#
#   MAKEFILE for curl
#

CURL_VER=7.21.2
CURL_CONFIGURE_ARGS = \
CPPFLAGS=-I$(PREFIX)/include \
LDFLAGS=-L$(PREFIX)/lib
#--enable-shared \
#--enable-static \ 

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

curl-download : $(SRCTARDIR)/curl-$(CURL_VER).tar.lzma
$(SRCTARDIR)/curl-$(CURL_VER).tar.lzma : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://curl.haxx.se/download/curl-$(CURL_VER).tar.lzma

curl-unpack : $(SRCDIR)/curl/.unpack.marker
$(SRCDIR)/curl/.unpack.marker : \
    $(SRCTARDIR)/curl-$(CURL_VER).tar.lzma \
    $(SRCDIR)/curl/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -x --lzma -f $<
	$(TOUCH) $@

curl-configure : $(BUILDDIR)/curl/.config.marker
$(BUILDDIR)/curl/.config.marker : \
    $(SRCDIR)/curl/.unpack.marker \
    $(BUILDDIR)/curl/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/curl/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(CURL_CONFIGURE_ARGS) $(CURL_CONFIGURE_XTRA_ARGS)
	libtool_remove_versuffix.sh $(BUILDDIR)/curl/libtool
	$(TOUCH) $@

curl-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=curl

curl-build : $(BUILDDIR)/curl/.build.marker 
$(BUILDDIR)/curl/.build.marker : $(BUILDDIR)/curl/.config.marker
	$(MAKE) curl-rebuild
	$(TOUCH) $@

curl-reinstall :
	$(MAKE) common-make TGT=install PKG=curl
	$(MAKE) curl-install-lic

curl-install-lic :
	mkdir -p $(PREFIX)/license/curl
	cp -a $(SRCDIR)/curl/COPYING $(PREFIX)/license/curl

curl-install : $(BUILDDIR)/curl/.install.marker 
$(BUILDDIR)/curl/.install.marker : $(BUILDDIR)/curl/.build.marker
	$(MAKE) curl-reinstall
	$(TOUCH) $@

curl-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=curl
	$(MAKE) curl-install-lic

curl-install-strip : $(BUILDDIR)/curl/.installstrip.marker 
$(BUILDDIR)/curl/.installstrip.marker : $(BUILDDIR)/curl/.build.marker
	$(MAKE) curl-reinstall-strip
	$(TOUCH) $@

curl-check : $(BUILDDIR)/curl/.check.marker
$(BUILDDIR)/curl/.check.marker : $(BUILDDIR)/curl/.build.marker
	$(ADDPATH) && $(MAKE) common-make TGT=test PKG=curl
	$(TOUCH) $@

curl-all : \
    curl-download \
    curl-unpack \
    curl-configure \
    curl-build \
    curl-install

all : curl-all
all-download : curl-download
all-install : curl-install
all-reinstall : curl-reinstall
all-install-strip : curl-install-strip
all-reinstall-strip : curl-install-strip
all-rebuild : curl-rebuild curl-reinstall
all-pkg : curl-pkg

curl-pkg : PREFIX=/opt/pkg-$(ARCH)/curl
curl-pkg :$(BUILDDIR)/curl/.pkg.marker
$(BUILDDIR)/curl/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) curl-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/curl-$(CURL_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/*.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/curl-$(CURL_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/curl.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/curl-$(CURL_VER)-$(BUILD_ARCH)$(ID)-dev.zip lib include bin/curl-config
	cd $(PREFIX) && zip -qr9 $(CURDIR)/curl-$(CURL_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 curl-$(CURL_VER)-src.zip $(SRCTARDIR)/curl-$(CURL_VER).tar.lzma $(MAKEFILEDIR)curl.mk makefile
	$(TOUCH) $@
