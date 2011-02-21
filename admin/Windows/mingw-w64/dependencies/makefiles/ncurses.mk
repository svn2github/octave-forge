#
#   MAKEFILE for ncurses
#

NCURSES_VER=5.7
NCURSES_CONFIGURE_ARGS = \
--without-ada \
--without-cxx \
--without-cxx-binding \
--without-shared \
--without-libtool \
--with-normal \
--enable-term-driver \
--enable-sp-funcs 


# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

NCURSES_ROLLUPPATCH=ncurses-5.7-20110108-patch.sh.bz2
NCURSES_PATCHES=\
ncurses-5.7-20110115.patch.gz \
ncurses-5.7-20110122.patch.gz 

ncurses-download : \
    $(SRCTARDIR)/ncurses-$(NCURSES_VER).tar.gz \
    $(addprefix $(SRCTARDIR)/, $(NCURSES_PATCHES) $(NCURSES_ROLLUPPATCH))

$(SRCTARDIR)/ncurses-$(NCURSES_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(NCURSES_VER).tar.gz

$(addprefix $(SRCTARDIR)/, $(NCURSES_PATCHES) $(NCURSES_ROLLUPPATCH)) : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ ftp://invisible-island.net/ncurses/5.7/$(notdir $@)

ncurses-unpack : $(SRCDIR)/ncurses/.unpack.marker
$(SRCDIR)/ncurses/.unpack.marker : \
    $(SRCTARDIR)/ncurses-$(NCURSES_VER).tar.gz \
    $(PATCHDIR)/ncurses-$(NCURSES_VER).patch \
    $(addprefix $(SRCTARDIR)/, $(NCURSES_PATCHES) $(NCURSES_ROLLUPPATCH)) \
    $(SRCDIR)/ncurses/.mkdir.marker 
	$(TAR) -C $(dir $@)  --no-same-permissions --no-same-owner --strip-components=1 -xzf $<
	chmod 777 -R $(SRCDIR)/ncurses
	$(MAKE) ncurses-unpack-rolluppatch
	$(MAKE) ncurses-unpack-patches
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/ncurses-$(NCURSES_VER).patch
	$(TOUCH) $@

# apply official patches...
ncurses-unpack-rolluppatch : $(SRCDIR)/ncurses/.rolluppatch.marker
$(SRCDIR)/ncurses/.rolluppatch.marker :
	cd $(SRCDIR)/ncurses && rm -f include/ncurses_dll.h
	cd $(SRCDIR)/ncurses && for a in $(NCURSES_ROLLUPPATCH); do \
	    p=`basename $$a`; \
	    echo applying $$p...; \
	    case $$p in \
	    *.bz2) \
		bunzip2 -dc $(CURDIR)/$(SRCTARDIR)/$$p | patch -p1 \
		;; \
	    *.gz) \
		gunzip -cd $(CURDIR)/$(SRCTARDIR)/$$p | patch -p1 \
		;; \
	    esac; \
	done 

ncurses-unpack-patches : $(SRCDIR)/ncurses/.patch.marker
$(SRCDIR)/ncurses/.patch.marker :
	cd $(SRCDIR)/ncurses && for a in $(NCURSES_PATCHES); do \
	    p=`basename $$a`; \
	    echo applying $$p...; \
	    case $$p in \
	    *.bz2) \
		bunzip2 -dc $(CURDIR)/$(SRCTARDIR)/$$p | patch -p1 \
		;; \
	    *.gz) \
		gunzip -cd $(CURDIR)/$(SRCTARDIR)/$$p | patch -p1 \
		;; \
	    esac; \
	done

ncurses-configure : $(BUILDDIR)/ncurses/.config.marker
$(BUILDDIR)/ncurses/.config.marker : \
    $(SRCDIR)/ncurses/.unpack.marker \
    $(BUILDDIR)/ncurses/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/ncurses/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(NCURSES_CONFIGURE_ARGS) $(NCURSES_CONFIGURE_XTRA_ARGS)
	sed -e "s/ar /\$$\{CROSS\}ar /g" < $(dir $@)mk-dlls.sh > $(dir $@)mk-dlls.sh.mod && mv $(dir $@)mk-dlls.sh.mod $(dir $@)mk-dlls.sh
	$(TOUCH) $@

ncurses-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=ncurses
	export CROSS=$(CROSS); $(MAKE) common-configure-make TGT=dlls PKG=ncurses

ncurses-build : $(BUILDDIR)/ncurses/.build.marker 
$(BUILDDIR)/ncurses/.build.marker : $(BUILDDIR)/ncurses/.config.marker
	$(MAKE) ncurses-rebuild
	$(TOUCH) $@

ncurses-reinstall : 
	$(MAKE) common-make TGT=install PKG=ncurses
	$(MAKE) ncurses-install-dll
	$(MAKE) ncurses-install-lic

ncurses-install-dll :
	mkdir -p $(PREFIX)/bin
	for a in ncurses menu form panel; do \
	    cp -a $(BUILDDIR)/ncurses/lib/w$$a.dll $(PREFIX)/bin; \
	    cp -a $(BUILDDIR)/ncurses/lib/lib$$a.dll.a $(PREFIX)/lib; \
	done

ncurses-install-lic : 
	mkdir -p $(PREFIX)/license/ncurses
	cp -a $(SRCDIR)/ncurses/README $(PREFIX)/license/ncurses

ncurses-install : $(BUILDDIR)/ncurses/.install.marker 
$(BUILDDIR)/ncurses/.install.marker : $(BUILDDIR)/ncurses/.build.marker
	$(MAKE) ncurses-reinstall
	$(TOUCH) $@

ncurses-reinstall-strip : 
	$(MAKE) ncurses-reinstall
	$(STRIP) $(PREFIX)/bin/wncurses.dll
	$(STRIP) $(PREFIX)/bin/wform.dll
	$(STRIP) $(PREFIX)/bin/wmenu.dll
	$(STRIP) $(PREFIX)/bin/wpanel.dll
	$(STRIP) $(PREFIX)/bin/captoinfo.exe
	$(STRIP) $(PREFIX)/bin/clear.exe
	$(STRIP) $(PREFIX)/bin/infocmp.exe
	$(STRIP) $(PREFIX)/bin/infotocap.exe
	$(STRIP) $(PREFIX)/bin/reset.exe
	$(STRIP) $(PREFIX)/bin/tabs.exe
	$(STRIP) $(PREFIX)/bin/tic.exe
	$(STRIP) $(PREFIX)/bin/toe.exe
	$(STRIP) $(PREFIX)/bin/tput.exe
	$(STRIP) $(PREFIX)/bin/tset.exe

ncurses-install-strip : $(BUILDDIR)/ncurses/.installstrip.marker 
$(BUILDDIR)/ncurses/.installstrip.marker : $(BUILDDIR)/ncurses/.build.marker
	$(MAKE) ncurses-reinstall-strip
	$(TOUCH) $@

ncurses-check : $(BUILDDIR)/ncurses/.check.marker
$(BUILDDIR)/ncurses/.check.marker : $(BUILDDIR)/ncurses/.build.marker
	$(MAKE) common-make TGT=check PKG=ncurses
	$(TOUCH) $@

ncurses-all : \
    ncurses-download \
    ncurses-unpack \
    ncurses-configure \
    ncurses-build \
    ncurses-install

all : ncurses-all
all-download : ncurses-download
all-install : ncurses-install
all-reinstall : ncurses-reinstall
all-install-strip : ncurses-install-strip
all-reinstall-strip : ncurses-install-strip
all-rebuild : ncurses-rebuild ncurses-reinstall
all-pkg : ncurses-pkg

ncurses-pkg : PREFIX=/opt/pkg-$(ARCH)/ncurses
ncurses-pkg : $(BUILDDIR)/ncurses/.pkg.marker
$(BUILDDIR)/ncurses/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) ncurses-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/ncurses-$(NCURSES_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/wncurses.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/ncurses-$(NCURSES_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe bin/wform.dll bin/wmenu.dll bin/wpanel.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/ncurses-$(NCURSES_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib bin/ncurses5-config
	cd $(PREFIX) && zip -qr9 $(CURDIR)/ncurses-$(NCURSES_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 ncurses-$(NCURSES_VER)-src.zip \
	    $(SRCTARDIR)/ncurses-$(NCURSES_VER).tar.gz \
	    $(addprefix $(SRCTARDIR)/, $(NCURSES_PATCHES) $(NCURSES_ROLLUPPATCH)) \
	    $(MAKEFILEDIR)ncurses.mk \
	    $(PATCHDIR)/ncurses-$(NCURSES_VER).patch \
	    makefile
	$(TOUCH) $@
