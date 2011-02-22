#
#   MAKEFILE for hdf5
#

HDF5_VER=1.8.5-patch1
HDF5_CONFIGURE_ARGS = \
--enable-shared \
--enable-static \
--disable-fortran \
--disable-cxx \
--disable-embedded-libinfo \
--with-default-vfd=windows \
CPPFLAGS="-I$(PREFIX)/include" \
LDFLAGS="-L$(PREFIX)/lib" \
AR=$(CROSS)ar

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

hdf5-download : $(SRCTARDIR)/hdf5-$(HDF5_VER).tar.bz2
$(SRCTARDIR)/hdf5-$(HDF5_VER).tar.bz2 : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.hdfgroup.org/ftp/HDF5/prev-releases/hdf5-$(HDF5_VER)/src/hdf5-$(HDF5_VER).tar.bz2

hdf5-unpack : $(SRCDIR)/hdf5/.unpack.marker
$(SRCDIR)/hdf5/.unpack.marker : \
    $(SRCTARDIR)/hdf5-$(HDF5_VER).tar.bz2 \
    $(PATCHDIR)/hdf5-$(HDF5_VER).patch \
    $(SRCDIR)/hdf5/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xjf $<
	cd $(dir $@) && patch -p 1 -u -i $(CURDIR)/$(PATCHDIR)/hdf5-$(HDF5_VER).patch
	$(TOUCH) $@

hdf5-configure : $(BUILDDIR)/hdf5/.config.marker
$(BUILDDIR)/hdf5/.config.marker : \
    $(SRCDIR)/hdf5/.unpack.marker \
    $(BUILDDIR)/hdf5/.mkdir.marker
	cd $(SRCDIR)/hdf5 && automake && autoconf 
	cd $(dir $@) && $(CURDIR)/$(SRCDIR)/hdf5/configure \
	--prefix=$(PREFIX) \
	$(COMMON_CONFIGURE_ARGS) $(HOST_CONFIGURE_ARGS) \
	$(HDF5_CONFIGURE_ARGS) $(HDF5_CONFIGURE_XTRA_ARGS)
	$(TOUCH) $@

hdf5-rebuild : 
	$(MAKE) common-configure-make TGT=all PKG=hdf5

hdf5-build : $(BUILDDIR)/hdf5/.build.marker 
$(BUILDDIR)/hdf5/.build.marker : $(BUILDDIR)/hdf5/.config.marker
	$(MAKE) hdf5-rebuild
	$(TOUCH) $@

hdf5-reinstall :
	$(MAKE) common-make TGT=install PKG=hdf5
	$(MAKE) hdf5-install-lic

hdf5-install-lic :
	mkdir -p $(PREFIX)/license/hdf5
	cp -a $(SRCDIR)/hdf5/COPYING $(PREFIX)/license/hdf5

hdf5-install : $(BUILDDIR)/hdf5/.install.marker 
$(BUILDDIR)/hdf5/.install.marker : $(BUILDDIR)/hdf5/.build.marker
	$(MAKE) hdf5-reinstall
	$(TOUCH) $@

hdf5-reinstall-strip : 
	$(MAKE) common-make TGT=install-strip PKG=hdf5
	$(MAKE) hdf5-install-lic

hdf5-install-strip : $(BUILDDIR)/hdf5/.installstrip.marker 
$(BUILDDIR)/hdf5/.installstrip.marker : $(BUILDDIR)/hdf5/.build.marker
	$(MAKE) hdf5-reinstall-strip
	$(TOUCH) $@

hdf5-check : $(BUILDDIR)/hdf5/.check.marker
$(BUILDDIR)/hdf5/.check.marker : $(BUILDDIR)/hdf5/.build.marker
	$(MAKE) common-make TGT=check PKG=hdf5 HDF5_NOCLEANUP=1
	$(TOUCH) $@

hdf5-all : \
    hdf5-download \
    hdf5-unpack \
    hdf5-configure \
    hdf5-build \
    hdf5-install

all : hdf5-all
all-download : hdf5-download
all-install : hdf5-install
all-reinstall : hdf5-reinstall
all-install-strip : hdf5-install-strip
all-reinstall-strip : hdf5-install-strip
all-rebuild : hdf5-rebuild hdf5-reinstall
all-pkg : hdf5-pkg

hdf5-pkg : PREFIX=/opt/pkg-$(ARCH)/hdf5
hdf5-pkg : $(BUILDDIR)/hdf5/.pkg.marker
$(BUILDDIR)/hdf5/.pkg.marker :
	$(MAKE) PREFIX=$(PREFIX) hdf5-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/hdf5-$(HDF5_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/libhdf5-6.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/hdf5-$(HDF5_VER)-$(BUILD_ARCH)$(ID)-ext.zip bin/*.exe
	cd $(PREFIX) && zip -qr9 $(CURDIR)/hdf5-$(HDF5_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib/*.a lib/*.la
	cd $(PREFIX) && zip -qr9 $(CURDIR)/hdf5-$(HDF5_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 hdf5-$(HDF5_VER)-src.zip $(SRCTARDIR)/hdf5-$(HDF5_VER).tar.bz2 $(MAKEFILEDIR)hdf5.mk $(PATCHDIR)/hdf5-$(HDF5_VER).patch makefile
	$(TOUCH) $@
