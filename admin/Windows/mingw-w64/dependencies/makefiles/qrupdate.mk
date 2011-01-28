#
#   MAKEFILE for qrupdate
#

QRUPDATE_VER=1.1.1

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

qrupdate-download : $(SRCTARDIR)/qrupdate-$(QRUPDATE_VER).tar.gz
$(SRCTARDIR)/qrupdate-$(QRUPDATE_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://downloads.sourceforge.net/qrupdate/qrupdate-$(QRUPDATE_VER).tar.gz

qrupdate-unpack : $(SRCDIR)/qrupdate/.unpack.marker
$(SRCDIR)/qrupdate/.unpack.marker : \
    $(SRCTARDIR)/qrupdate-$(QRUPDATE_VER).tar.gz \
    $(PATCHDIR)/qrupdate-$(QRUPDATE_VER).patch \
    $(SRCDIR)/qrupdate/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(SRCDIR)/qrupdate && patch -p1 -u -i $(CURDIR)/$(PATCHDIR)/qrupdate-$(QRUPDATE_VER).patch
	$(TOUCH) $@

qrupdate-configure : $(BUILDDIR)/qrupdate/.config.marker
$(BUILDDIR)/qrupdate/.config.marker : \
    $(SRCDIR)/qrupdate/.unpack.marker \
    $(BUILDDIR)/qrupdate/.mkdir.marker
	mkdir -p $(BUILDDIR)/qrupdate/src
	mkdir -p $(BUILDDIR)/qrupdate/test
	cp $(SRCDIR)/qrupdate/makeconf $(BUILDDIR)/qrupdate
	cp $(SRCDIR)/qrupdate/makefile $(BUILDDIR)/qrupdate
	cp $(SRCDIR)/qrupdate/src/makefile $(BUILDDIR)/qrupdate/src
	cp $(SRCDIR)/qrupdate/test/makefile $(BUILDDIR)/qrupdate/test
	$(TOUCH) $@

qrupdate-rebuild : 
	$(MAKE) common-make PKG=qrupdate TGT=lib SRCDIR=$(CURDIR)/$(SRCDIR)/qrupdate
	$(MAKE) common-make PKG=qrupdate TGT=solib SRCDIR=$(CURDIR)/$(SRCDIR)/qrupdate

qrupdate-build : $(BUILDDIR)/qrupdate/.build.marker
$(BUILDDIR)/qrupdate/.build.marker : $(BUILDDIR)/qrupdate/.config.marker
	$(MAKE) qrupdate-rebuild
	$(TOUCH) $@

qrupdate-reinstall : PKG=qrupdate
qrupdate-reinstall : \
    $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/qrupdate/libqrupdate.a     $(PREFIX)/lib
	cp -a $(BUILDDIR)/qrupdate/libqrupdate.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/qrupdate/qrupdate.dll      $(PREFIX)/bin
	cp -a $(SRCDIR)/qrupdate/COPYING       $(PREFIX)/license/qrupdate

qrupdate-install : $(BUILDDIR)/qrupdate/.install.marker 
$(BUILDDIR)/qrupdate/.install.marker : $(BUILDDIR)/qrupdate/.build.marker
	$(MAKE) qrupdate-reinstall
	$(TOUCH) $@

qrupdate-reinstall-strip : qrupdate-reinstall
	$(STRIP) $(PREFIX)/bin/qrupdate.dll

qrupdate-install-strip : $(BUILDDIR)/qrupdate/.installstrip.marker 
$(BUILDDIR)/qrupdate/.installstrip.marker : $(BUILDDIR)/qrupdate/.install.marker
	$(MAKE) qrupdate-reinstall-strip
	$(TOUCH) $@

qrupdate-check : $(BUILDDIR)/qrupdate/.check.marker
$(BUILDDIR)/qrupdate/.check.marker : $(BUILDDIR)/qrupdate/.build.marker
	$(ADDPATH); cd $(BUILDDIR)/qrupdate/test && \
	$(MAKE) $(MAKE_PARALLEL) CROSS=$(CROSS) \
	    SRCDIR=$(CURDIR)/$(SRCDIR)/qrupdate \
	    LDFLAGS=-L$(PREFIX)/lib \
	    tests
	$(TOUCH) $@

qrupdate-all : \
    qrupdate-download \
    qrupdate-unpack \
    qrupdate-configure \
    qrupdate-build \
    qrupdate-install

all : qrupdate-all
all-download : qrupdate-download
all-install : qrupdate-install
all-reinstall : qrupdate-reinstall
all-install-strip : qrupdate-install-strip
all-reinstall-strip : qrupdate-install-strip
all-rebuild : qrupdate-rebuild qrupdate-reinstall
all-pkg : qrupdate-pkg

qrupdate-pkg : PREFIX=/opt/pkg-$(ARCH)/qrupdate
qrupdate-pkg : $(BUILDDIR)/qrupdate/.pkg.marker
$(BUILDDIR)/qrupdate/.pkg.marker : 
	$(MAKE) PREFIX=$(PREFIX) qrupdate-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/qrupdate-$(QRUPDATE_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/qrupdate.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/qrupdate-$(QRUPDATE_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/qrupdate-$(QRUPDATE_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 qrupdate-$(QRUPDATE_VER)-src.zip $(SRCTARDIR)/qrupdate-$(QRUPDATE_VER).tar.gz $(MAKEFILEDIR)qrupdate.mk $(PATCHDIR)/qrupdate-$(QRUPDATE_VER).patch makefile
	$(TOUCH) $@
