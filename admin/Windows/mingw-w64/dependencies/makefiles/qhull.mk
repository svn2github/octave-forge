#
#   MAKEFILE for qhull
#

QHULL_VER=2010.1
QHULL_CONFIGURE_ARGS =

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

qhull-download : $(SRCTARDIR)/qhull-$(QHULL_VER).tar.gz
$(SRCTARDIR)/qhull-$(QHULL_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.qhull.org/download/qhull-$(QHULL_VER)-src.tgz

qhull-unpack : $(SRCDIR)/qhull/.unpack.marker
$(SRCDIR)/qhull/.unpack.marker : \
    $(SRCTARDIR)/qhull-$(QHULL_VER).tar.gz \
    $(PATCHDIR)/qhull-$(QHULL_VER).patch \
    $(SRCDIR)/qhull/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/qhull-$(QHULL_VER).patch
	$(TOUCH) $@

qhull-configure : $(BUILDDIR)/qhull/.config.marker
$(BUILDDIR)/qhull/.config.marker : \
    $(SRCDIR)/qhull/.unpack.marker \
    $(BUILDDIR)/qhull/.mkdir.marker
	cp -a $(SRCDIR)/qhull/src/makefile $(BUILDDIR)/qhull/makefile
	$(TOUCH) $@

qhull-rebuild : 
	$(MAKE) common-make TGT=lib PKG=qhull SRCTOP=$(CURDIR)/$(SRCDIR)/qhull

qhull-build : $(BUILDDIR)/qhull/.build.marker 
$(BUILDDIR)/qhull/.build.marker : $(BUILDDIR)/qhull/.config.marker
	$(MAKE) qhull-rebuild
	$(TOUCH) $@

qhull-reinstall : PKG=qhull
qhull-reinstall : $(PREFIX)/.init.marker
	mkdir -p $(PREFIX)/include/qhull
	cp -a $(BUILDDIR)/qhull/qhull.dll      $(PREFIX)/bin
	cp -a $(BUILDDIR)/qhull/libqhull.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/qhull/libqhull.a     $(PREFIX)/lib
	for a in libqhull.h user.h qhull.h qhull_a.h geom.h io.h mem.h merge.h poly.h random.h qset.h stat.h; do \
	    cp -a $(SRCDIR)/qhull/src/$$a $(PREFIX)/include/qhull; \
	done
	$(MAKE) qhull-install-lic

qhull-install-lic :
	mkdir -p $(PREFIX)/license/qhull
	cp -a $(SRCDIR)/qhull/COPYING.txt $(PREFIX)/license/qhull

qhull-install : $(BUILDDIR)/qhull/.install.marker 
$(BUILDDIR)/qhull/.install.marker : $(BUILDDIR)/qhull/.build.marker
	$(MAKE) qhull-reinstall
	$(TOUCH) $@

qhull-reinstall-strip : 
	$(MAKE) qhull-reinstall
	$(STRIP) $(PREFIX)/bin/qhull.dll

qhull-install-strip : $(BUILDDIR)/qhull/.installstrip.marker 
$(BUILDDIR)/qhull/.installstrip.marker : $(BUILDDIR)/qhull/.build.marker
	$(MAKE) qhull-reinstall-strip
	$(TOUCH) $@

qhull-check : $(BUILDDIR)/qhull/.check.marker
$(BUILDDIR)/qhull/.check.marker : $(BUILDDIR)/qhull/.build.marker
	$(ADDPATH) && $(MAKE) common-make TGT=test PKG=qhull
	$(TOUCH) $@

qhull-all : \
    qhull-download \
    qhull-unpack \
    qhull-configure \
    qhull-build \
    qhull-install

all : qhull-all
all-download : qhull-download
all-install : qhull-install
all-reinstall : qhull-reinstall
all-install-strip : qhull-install-strip
all-reinstall-strip : qhull-install-strip
all-rebuild : qhull-rebuild qhull-reinstall
all-pkg : qhull-pkg

qhull-pkg : PREFIX=/opt/pkg-$(ARCH)/qhull
qhull-pkg :$(BUILDDIR)/qhull/.pkg.marker
$(BUILDDIR)/qhull/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) qhull-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/qhull-$(QHULL_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/qhull.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/qhull-$(QHULL_VER)-$(BUILD_ARCH)$(ID)-dev.zip lib include
	cd $(PREFIX) && zip -qr9 $(CURDIR)/qhull-$(QHULL_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 qhull-$(QHULL_VER)-src.zip $(SRCTARDIR)/qhull-$(QHULL_VER).tar.gz $(PATCHDIR)/qhull-$(QHULL_VER).patch $(MAKEFILEDIR)qhull.mk makefile
	$(TOUCH) $@
