#
#   MAKEFILE for libreadline
#

READLINE_VER=6.1
READLINE_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--with-curses \
CPPFLAGS=-I$(PREFIX)/include \
LDFLAGS=-L$(PREFIX)/lib \
AR=$(CROSS)ar


# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

readline-download : $(SRCTARDIR)/readline-$(READLINE_VER).tar.gz
$(SRCTARDIR)/readline-$(READLINE_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ ftp://ftp.gnu.org/gnu/readline/readline-$(READLINE_VER).tar.gz

readline-unpack : $(SRCDIR)/readline/.unpack.marker
$(PATCHDIR)/readline-$(REDALINE_VER).patch \
$(SRCDIR)/readline/.unpack.marker : \
    $(SRCTARDIR)/readline-$(READLINE_VER).tar.gz \
    $(PATCHDIR)/readline-$(READLINE_VER).patch \
    $(SRCDIR)/readline/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/readline-$(READLINE_VER).patch
	$(TOUCH) $@

readline-configure : $(BUILDDIR)/readline/.config.marker
$(BUILDDIR)/readline/.config.marker : \
    $(SRCDIR)/readline/.unpack.marker \
    $(BUILDDIR)/readline/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/readline/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(READLINE_CONFIGURE_ARGS) $(READLINE_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

readline-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=readline
	$(MAKE) common-configure-make TGT=examples PKG=readline

readline-build : $(BUILDDIR)/readline/.build.marker 
$(BUILDDIR)/readline/.build.marker : $(BUILDDIR)/readline/.config.marker
	$(MAKE) readline-rebuild
	$(TOUCH) $@

readline-reinstall : $(PREFIX)/.init.marker
	$(MAKE) common-make TGT=install PKG=readline
	$(MAKE) readline-install-lic

readline-install-lic :
	mkdir -p $(PREFIX)/license/readline
	cp -a $(SRCDIR)/readline/COPYING $(PREFIX)/license/readline
	cp -a $(SRCDIR)/readline/USAGE $(PREFIX)/license/readline

readline-install : $(BUILDDIR)/readline/.install.marker 
$(BUILDDIR)/readline/.install.marker : $(BUILDDIR)/readline/.build.marker
	$(MAKE) readline-reinstall
	$(TOUCH) $@

readline-reinstall-strip : 
	$(MAKE) readline-reinstall
	$(STRIP) $(PREFIX)/bin/libreadline6.dll
	$(STRIP) $(PREFIX)/bin/libhistory6.dll

readline-install-strip : $(BUILDDIR)/readline/.installstrip.marker 
$(BUILDDIR)/readline/.installstrip.marker : $(BUILDDIR)/readline/.build.marker
	$(MAKE) readline-reinstall-strip
	$(TOUCH) $@

readline-check : $(BUILDDIR)/readline/.check.marker
$(BUILDDIR)/readline/.check.marker : $(BUILDDIR)/readline/.build.marker
	$(MAKE) common-make TGT=check PKG=readline
	$(TOUCH) $@

readline-all : \
    readline-download \
    readline-unpack \
    readline-configure \
    readline-build \
    readline-install

all : readline-all
all-download : readline-download
all-install : readline-install
all-reinstall : readline-reinstall
all-install-strip : readline-install-strip
all-reinstall-strip : readline-install-strip
all-rebuild : readline-rebuild readline-reinstall
all-pkg : readline-pkg

readline-pkg : PREFIX=/opt/pkg-$(ARCH)/readline
readline-pkg : $(BUILDDIR)/readline/.pkg.marker
$(BUILDDIR)/readline/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) readline-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/readline-$(READLINE_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libreadline6.dll bin/libhistory6.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/readline-$(READLINE_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib -x '*.old'
	cd $(PREFIX) && zip -qr9 $(CURDIR)/readline-$(READLINE_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 readline-$(READLINE_VER)-src.zip $(SRCTARDIR)/readline-$(READLINE_VER).tar.gz $(PATCHDIR)/readline-$(READLINE_VER).patch $(MAKEFILEDIR)readline.mk makefile
	$(TOUCH) $@
