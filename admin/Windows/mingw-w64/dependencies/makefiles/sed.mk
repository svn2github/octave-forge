#
#   MAKEFILE for sed
#

SED_VER=4.1.5
SED_CONFIGURE_ARGS = \
--disable-nls \
--disable-i18n \
--with-gnu-ld \
--without-included-regex \
CPPFLAGS="-I$(PREFIX)/include" \
LDFLAGS="-L$(PREFIX)/lib"

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

sed-download : $(SRCTARDIR)/sed-$(SED_VER).tar.gz
$(SRCTARDIR)/sed-$(SED_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ ftp://ftp.gnu.org/gnu/sed/sed-$(SED_VER).tar.gz

sed-unpack : $(SRCDIR)/sed/.unpack.marker
$(SRCDIR)/sed/.unpack.marker : \
    $(SRCTARDIR)/sed-$(SED_VER).tar.gz \
    $(SRCDIR)/sed/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	$(TOUCH) $@

sed-configure : $(BUILDDIR)/sed/.config.marker
$(BUILDDIR)/sed/.config.marker : \
    $(SRCDIR)/sed/.unpack.marker \
    $(BUILDDIR)/sed/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/sed/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(SED_CONFIGURE_ARGS) $(SED_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

sed-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=sed

sed-build : $(BUILDDIR)/sed/.build.marker 
$(BUILDDIR)/sed/.build.marker : $(BUILDDIR)/sed/.config.marker
	$(MAKE) sed-rebuild
	$(TOUCH) $@

sed-reinstall : PKG=sed
sed-reinstall : \
    $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/sed/sed/sed.exe    $(PREFIX)/bin
	$(MAKE) sed-install-lic

sed-install-lic : 
	mkdir -p $(PREFIX)/license/sed
	cp -a $(SRCDIR)/sed/COPYING $(PREFIX)/license/sed

sed-install : $(BUILDDIR)/sed/.install.marker 
$(BUILDDIR)/sed/.install.marker : $(BUILDDIR)/sed/.build.marker
	$(MAKE) sed-reinstall
	$(TOUCH) $@

sed-reinstall-strip : sed-reinstall
	$(STRIP) $(PREFIX)/bin/sed.exe

sed-install-strip : $(BUILDDIR)/sed/.installstrip.marker 
$(BUILDDIR)/sed/.installstrip.marker : $(BUILDDIR)/sed/.build.marker
	$(MAKE) sed-reinstall-strip
	$(TOUCH) $@

sed-check : $(BUILDDIR)/sed/.check.marker
$(BUILDDIR)/sed/.check.marker : $(BUILDDIR)/sed/.build.marker
	$(MAKE) common-make TGT=check PKG=sed
	$(TOUCH) $@

sed-all : \
    sed-download \
    sed-unpack \
    sed-configure \
    sed-build \
    sed-install

all : sed-all
all-download : sed-download
all-install : sed-install
all-reinstall : sed-reinstall
all-install-strip : sed-install-strip
all-reinstall-strip : sed-install-strip
all-rebuild : sed-rebuild sed-reinstall
all-pkg : sed-pkg

sed-pkg : PREFIX=/opt/pkg-$(ARCH)/sed
sed-pkg : $(BUILDDIR)/sed/.pkg.marker
$(BUILDDIR)/sed/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) sed-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/sed-$(SED_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/sed.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/sed-$(SED_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 sed-$(SED_VER)-src.zip $(SRCTARDIR)/sed-$(SED_VER).tar.gz $(MAKEFILEDIR)sed.mk makefile
	$(TOUCH) $@
