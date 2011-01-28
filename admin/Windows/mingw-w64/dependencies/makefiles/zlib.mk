#
#   MAKEFILE for zlib
#

ZLIB_VER=1.2.5

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

zlib-download : $(SRCTARDIR)/zlib-$(ZLIB_VER).tar.gz
$(SRCTARDIR)/zlib-$(ZLIB_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://zlib.net/zlib-$(ZLIB_VER).tar.gz

zlib-unpack : $(SRCDIR)/zlib/.unpack.marker
$(SRCDIR)/zlib/.unpack.marker : \
    $(SRCTARDIR)/zlib-$(ZLIB_VER).tar.gz \
    $(SRCDIR)/zlib/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

zlib-configure : $(BUILDDIR)/zlib/.config.marker
$(BUILDDIR)/zlib/.config.marker : \
    $(SRCDIR)/zlib/.unpack.marker \
    $(BUILDDIR)/zlib/.mkdir.marker
	cp -rf $(SRCDIR)/zlib $(BUILDDIR)
	cd $(dir $@) && sed -e '/	/s+win32/zlib1.rc+$$<+' \
	                    -e '/	/s+win32/zlib.def+$$<+' \
			    -e 's/^\(IMPLIB[ 	]\+=\).*/\1 libz.dll.a/' \
			    -e 's/PREFIX/CROSS/g' \
			    win32/makefile.gcc > makefile
	$(TOUCH) $@

zlib-rebuild : 
	$(MAKE) common-make TGT=all PKG=zlib

zlib-build : $(BUILDDIR)/zlib/.build.marker
$(BUILDDIR)/zlib/.build.marker : $(BUILDDIR)/zlib/.config.marker
	$(MAKE) zlib-rebuild
	$(TOUCH) $@

zlib-reinstall : PKG=zlib
zlib-reinstall : \
    $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/zlib/libz.a     $(PREFIX)/lib
	cp -a $(BUILDDIR)/zlib/libz.dll.a $(PREFIX)/lib
	cp -a $(BUILDDIR)/zlib/zlib1.dll  $(PREFIX)/bin
	cp -a $(BUILDDIR)/zlib/zlib.h     $(PREFIX)/include
	cp -a $(BUILDDIR)/zlib/zconf.h    $(PREFIX)/include
	cp -a $(SRCDIR)/zlib/README       $(PREFIX)/license/zlib

zlib-install : $(BUILDDIR)/zlib/.install.marker 
$(BUILDDIR)/zlib/.install.marker : $(BUILDDIR)/zlib/.build.marker
	$(MAKE) zlib-reinstall
	$(TOUCH) $@

zlib-reinstall-strip : zlib-reinstall
	$(STRIP) $(PREFIX)/bin/zlib1.dll

zlib-install-strip : $(BUILDDIR)/zlib/.installstrip.marker 
$(BUILDDIR)/zlib/.installstrip.marker : $(BUILDDIR)/zlib/.install.marker
	$(MAKE) zlib-reinstall-strip
	$(TOUCH) $@

zlib-check : $(BUILDDIR)/zlib/.check.marker
$(BUILDDIR)/zlib/.check.marker : $(BUILDDIR)/zlib/.build.marker
	$(MAKE) common-make TGT=test PKG=zlib
	$(MAKE) common-make TGT=testdll PKG=zlib
	$(TOUCH) $@

zlib-all : \
    zlib-download \
    zlib-unpack \
    zlib-configure \
    zlib-build \
    zlib-install

all : zlib-all
all-download : zlib-download
all-install : zlib-install
all-reinstall : zlib-reinstall
all-install-strip : zlib-install-strip
all-reinstall-strip : zlib-install-strip
all-rebuild : zlib-rebuild zlib-reinstall
all-pkg : zlib-pkg

zlib-pkg : PREFIX=/opt/pkg-$(ARCH)/zlib
zlib-pkg : $(BUILDDIR)/zlib/.pkg.marker
$(BUILDDIR)/zlib/.pkg.marker : 
	$(MAKE) PREFIX=$(PREFIX) zlib-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/zlib-$(ZLIB_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/zlib1.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/zlib-$(ZLIB_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/zlib-$(ZLIB_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 zlib-$(ZLIB_VER)-src.zip $(SRCTARDIR)/zlib-$(ZLIB_VER).tar.gz $(MAKEFILEDIR)zlib.mk makefile
	$(TOUCH) $@
