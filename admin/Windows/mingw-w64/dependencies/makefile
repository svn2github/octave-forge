#
#  main makefile
#

# dummy target

all : 

BUILDDIR = build-$(ARCH)
SRCDIR   = src
SRCTARDIR = srctar
PATCHDIR = patches
PREFIX   = /usr/local/octave64-$(ARCH)
MAKEFILEDIR = makefiles/

WGET = wget
TAR  = tar
TOUCH = touch
STRIP = $(CROSS)strip --strip-unneeded

MAKE_PARALLEL = -j4

# whether to build against shared libgcc or not (Y/N)
SHAREDLIBGCC ?= Y

# possible settings:
#   w32 ....... use mingw32 gcc
#   w32-tdm ... use tdm gcc
#   w64-x86 ... use mingw-w64 gcc, target i686-w64-mingw32
#   w64-x64 ... use mingw-w64 gcc, target x86_64-w64-mingw32
ARCH=w32

ifeq ($(ARCH),w32)

   BUILD_ARCH=i686-w32-mingw32
   CROSS=
   HOST_CONFIGURE_ARGS=
   ID=
   
else ifeq ($(ARCH),w32-tdm)

   BUILD_ARCH=i686-w32-mingw32
   CROSS=
   HOST_CONFIGURE_ARGS=
   ID=-tdm
   
else ifeq ($(ARCH),w64-x86)

   BUILD_ARCH=i686-w64-mingw32
   CROSS=$(BUILD_ARCH)-
   HOST_CONFIGURE_ARGS=--host=$(BUILD_ARCH)
   ID=

else ifeq ($(ARCH),w64-x64)

   BUILD_ARCH=x86_64-w64-mingw32
   CROSS=$(BUILD_ARCH)-
   HOST_CONFIGURE_ARGS=--host=$(BUILD_ARCH)
   ID=

else

   $(error ARCH must be one of: w32, w32-tdm, w64-x86, w64-x64!)

endif

ifeq ($(SHAREDLIBGCC),Y)
    override COMMON_CONFIGURE_ARGS += CC="$(CROSS)gcc -shared-libgcc"
    LDFLAGS_SHAREDLIBGCC=-shared-libgcc
endif

w32_DIST=jpeg zlib tiff png expat freetype fontconfig gd iconv gettext pcre \
glib pkg-config pixman cairo pango blas lapack qrupdate fftw fftwf suitesparse \
ncurses readline gmp glpk wmf graphicsmagick fltk regex qhull curl hdf5 arpack \
less sed texinfo

# for each NAME in w32_DIST, w32-tdm_DIST, w64-x86_DIST, or w64-x64_DIST
# include the corresponding makefile NAME.mk located in MAKEFILEDIR
$(foreach lib,$($(ARCH)_DIST), $(eval include $(MAKEFILEDIR)$(lib).mk))


# ------------------------------------
#   Helper Targets
# ------------------------------------

%/.mkdir.marker:
	-mkdir -p $(dir $@)
	@touch -t 197001020101 $@

# a common target to call for libraries using the configure-make cycle
# define:  PKG ... the name of the library
#          TGT ... the make target to call
common-configure-make : 
	cd $(BUILDDIR)/$(PKG) && \
	$(MAKE) $(MAKE_PARALLEL) prefix=$(PREFIX) $(TGT)

# a common target to call for libraries that use simple make files (without a
# configure script)
# define:  PKG ... the name of the library
#          TGT ... the make target to call
common-make : 
	cd $(BUILDDIR)/$(PKG) && \
	$(MAKE) $(MAKE_PARALLEL) CROSS=$(CROSS) LDFLAGS="-L$(PREFIX)/lib $(LDFLAGS_SHAREDLIBGCC)" prefix=$(PREFIX) $(TGT)

%/.init.marker:
	mkdir -p $(dir $@)bin
	mkdir -p $(dir $@)lib
	mkdir -p $(dir $@)lib/pkgconfig
	mkdir -p $(dir $@)include
	mkdir -p $(dir $@)share
	mkdir -p $(dir $@)license/$(PKG)

ADDPATH=PATH=$(PREFIX)/bin:$${PATH}

TARGET_ARCHIVE=$(shell date '+%Y%m%d')-$(BUILD_ARCH)$(ID)

dist : dev-pkg bin-pkg src-pkg

dev-pkg : all-pkg $(TARGET_ARCHIVE)-dev.zip
bin-pkg : all-pkg $(TARGET_ARCHIVE)-bin.zip
src-pkg : all-pkg $(TARGET_ARCHIVE)-src.zip

$(TARGET_ARCHIVE)-dev.zip : TYP=dev
$(TARGET_ARCHIVE)-dev.zip : SRCPART=*-$(BUILD_ARCH)$(ID)-

$(TARGET_ARCHIVE)-bin.zip : TYP=bin
$(TARGET_ARCHIVE)-bin.zip : SRCPART=*-$(BUILD_ARCH)$(ID)-

$(TARGET_ARCHIVE)-src.zip : TYP=src
$(TARGET_ARCHIVE)-src.zip : SRCPART=*

$(TARGET_ARCHIVE)-dev.zip $(TARGET_ARCHIVE)-bin.zip $(TARGET_ARCHIVE)-src.zip : 
	for a in $($(ARCH)_DIST); do \
	    find . -maxdepth 1 -iname "$$a-$(SRCPART)$(TYP).zip"; \
	done | tee $(ARCH)-dist.lst
	if test -e /tmp/$(ARCH)-$(TYP)-pkg; then rm -rf /tmp/$(ARCH)-$(TYP)-pkg; fi
	while read line; do \
	    unzip -oq $$line -d /tmp/$(ARCH)-$(TYP)-pkg; \
	done < $(ARCH)-dist.lst
	if test -e $@; then rm $@; fi
	cd /tmp/$(ARCH)-$(TYP)-pkg && zip -qr9 $(CURDIR)/$@ *
