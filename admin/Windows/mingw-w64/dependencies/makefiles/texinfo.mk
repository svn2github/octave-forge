#
#   MAKEFILE for texinfo
#

TEXINFO_VER=4.13
TEXINFO_CONFIGURE_ARGS = \
--disable-nls \
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

texinfo-download : $(SRCTARDIR)/texinfo-$(TEXINFO_VER).tar.gz
$(SRCTARDIR)/texinfo-$(TEXINFO_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ ftp://ftp.gnu.org/gnu/texinfo/texinfo-$(TEXINFO_VER).tar.gz

texinfo-unpack : $(SRCDIR)/texinfo/.unpack.marker
$(SRCDIR)/texinfo/.unpack.marker : \
    $(SRCTARDIR)/texinfo-$(TEXINFO_VER).tar.gz \
    $(PATCHDIR)/texinfo-$(TEXINFO_VER).patch \
    $(SRCDIR)/texinfo/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(SRCDIR)/texinfo && patch -p1 -u -i $(CURDIR)/$(PATCHDIR)/texinfo-$(TEXINFO_VER).patch
	$(TOUCH) $@

texinfo-configure : $(BUILDDIR)/texinfo/.config.marker
$(BUILDDIR)/texinfo/.config.marker : \
    $(SRCDIR)/texinfo/.unpack.marker \
    $(BUILDDIR)/texinfo/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/texinfo/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(TEXINFO_CONFIGURE_ARGS) $(TEXINFO_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

texinfo-rebuild : 
	cd $(BUILDDIR)/texinfo/gnulib/lib && $(MAKE) $(MAKE_PARALLEL) AR=$(CROSS)ar
	cd $(BUILDDIR)/texinfo/lib && $(MAKE) $(MAKE_PARALLEL) AR=$(CROSS)ar
	cd $(BUILDDIR)/texinfo/makeinfo && $(MAKE) $(MAKE_PARALLEL) AR=$(CROSS)ar

texinfo-build : $(BUILDDIR)/texinfo/.build.marker 
$(BUILDDIR)/texinfo/.build.marker : $(BUILDDIR)/texinfo/.config.marker
	$(MAKE) texinfo-rebuild
	$(TOUCH) $@

texinfo-reinstall : PKG=texinfo
texinfo-reinstall : \
    $(PREFIX)/.init.marker
	cp -a $(BUILDDIR)/texinfo/makeinfo/makeinfo.exe    $(PREFIX)/bin
	$(MAKE) texinfo-install-lic

texinfo-install-lic : 
	mkdir -p $(PREFIX)/license/texinfo
	cp -a $(SRCDIR)/texinfo/COPYING $(PREFIX)/license/texinfo

texinfo-install : $(BUILDDIR)/texinfo/.install.marker 
$(BUILDDIR)/texinfo/.install.marker : $(BUILDDIR)/texinfo/.build.marker
	$(MAKE) texinfo-reinstall
	$(TOUCH) $@

texinfo-reinstall-strip : texinfo-reinstall
	$(STRIP) $(PREFIX)/bin/makeinfo.exe

texinfo-install-strip : $(BUILDDIR)/texinfo/.installstrip.marker 
$(BUILDDIR)/texinfo/.installstrip.marker : $(BUILDDIR)/texinfo/.build.marker
	$(MAKE) texinfo-reinstall-strip
	$(TOUCH) $@

texinfo-check : $(BUILDDIR)/texinfo/.check.marker
$(BUILDDIR)/texinfo/.check.marker : $(BUILDDIR)/texinfo/.build.marker
	$(MAKE) common-make TGT=check PKG=texinfo
	$(TOUCH) $@

texinfo-all : \
    texinfo-download \
    texinfo-unpack \
    texinfo-configure \
    texinfo-build \
    texinfo-install

all : texinfo-all
all-download : texinfo-download
all-install : texinfo-install
all-reinstall : texinfo-reinstall
all-install-strip : texinfo-install-strip
all-reinstall-strip : texinfo-install-strip
all-rebuild : texinfo-rebuild texinfo-reinstall
all-pkg : texinfo-pkg

texinfo-pkg : PREFIX=/opt/pkg-$(ARCH)/texinfo
texinfo-pkg : $(BUILDDIR)/texinfo/.pkg.marker
$(BUILDDIR)/texinfo/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) texinfo-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/texinfo-$(TEXINFO_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/makeinfo.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/texinfo-$(TEXINFO_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 texinfo-$(TEXINFO_VER)-src.zip $(SRCTARDIR)/texinfo-$(TEXINFO_VER).tar.gz $(MAKEFILEDIR)texinfo.mk $(PATCHDIR)/texinfo-$(TEXINFO_VER).patch makefile
	$(TOUCH) $@
