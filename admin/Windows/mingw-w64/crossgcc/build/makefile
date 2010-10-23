#  GCC toolchain building system
#
#  Based on the mingw-w64 project's makebuildroot.mk available at
#  http://mingw-w64.svn.sourceforge.net/viewvc/mingw-w64/experimental/buildsystem/makebuildroot.mk
#  
#  This file is distributed in the hope that it will be useful but WITHOUT 
#  ANY WARRANTY.  ALL WARRANTIES, EXPRESSED OR IMPLIED ARE HEREBY DISCLAIMED. 
#  This includes but is not limited to warranties of MERCHANTABILITY or 
#  FITNESS FOR A PARTICULAR PURPOSE.
#

all :   # default target

# --------------------------------------
#  Configurable variables
# --------------------------------------

# Toolchain default target arch
TARGET_ARCH ?= i686-w64-mingw32
HOST_ARCH ?=
# Force to update all svn/cvs sources
ALL_UPDATE ?= 0
# parallel make invocation
MAKE_PARALLEL ?= -j4

# enable multilib build (Y/N)
ENABLE_MULTILIB ?= N

# Version variables
GMP_VERSION ?= 5.0.1
MPFR_VERSION ?= 3.0.0
MPC_VERSION ?= 0.8.2
MINGW_REVISION ?= head
MINGW_BRANCH ?= trunk
GCC_REVISION ?= head
GCC_BRANCH ?= trunk

# extra flags to pass to configure script
GMP_CONFIG_EXTRA_ARGS ?=
MPFR_CONFIG_EXTRA_ARGS ?=
MPC_CONFIG_EXTRA_ARGS ?=
BINUTILS_CONFIG_EXTRA_ARGS ?=
GCC_CONFIG_EXTRA_ARGS ?=
CRT_CONFIG_EXTRA_ARGS ?=

# extra flags to pass to make
PTHREADS_MAKE_ARGS ?= clean GC

# Update svn/cvs sources
MINGW_UPDATE ?= $(ALL_UPDATE)
BINUTILS_UPDATE ?= $(ALL_UPDATE)
GCC_UPDATE ?= $(ALL_UPDATE)
PTHREADS_UPDATE ?= $(ALL_UPDATE)

# --------------------------------------
# Tools
#  CVS     Compression defaulted to 9
#  SVN     Default options for all svn commands
#  SVN_CO  Override this checkout command to "export" if desired
#  TAR     default to tar
#  WGET    Try wget, fall back to curl
# --------------------------------------

TAR = tar
CVS = cvs -z9
SVN = svn
SVN_CO = co
WGET = wget

BUILD_DIR = build
SRC_DIR = src
INSTALL_DIR = root

PREFIX=$(CURDIR)/$(INSTALL_DIR)

# --------------------------------------
# Download URLs
# --------------------------------------
PTHREADS_CVS_PULL ?= :pserver:anoncvs@sourceware.org:/cvs/pthreads-win32
PTHREADS_CVS_DATE ?= '5/11/2010'

# --------------------------------------
# DO NOT EDIT BELOW THIS LINE
# --------------------------------------


GMP_CONFIG_ARGS = --enable-fat --enable-cxx
MPFR_CONFIG_ARGS =
MPC_CONFIG_ARGS =
BINUTILS_CONFIG_ARGS = --disable-nls
GCC_CONFIG_ARGS = \
--enable-fully-dynamic-string \
--enable-libgomp \
--with-dwarf2 \
--enable-version-specific-runtime-libs \
--disable-win32-registry \
--disable-nls \
--disable-lto
CRT_CONFIG_ARGS = CPPFLAGS=-D__MINGW_SHOW_INVALID_PARAMETER_EXCEPTION

# --------------------------------------
# Multilib helper
# --------------------------------------
BINUTILS_CONFIG_EXTRA_ARGS_MULTI_Y := --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32
BINUTILS_CONFIG_EXTRA_ARGS_MULTI_N :=
GCC_CONFIG_EXTRA_ARGS_MULTI_Y := --enable-multilib --enable-targets=all
GCC_CONFIG_EXTRA_ARGS_MULTI_N := --disable-multilib
MINGW_CONFIG_EXTRA_ARGS_MULTI_Y := --enable-lib32 --enable-lib64
MINGW_CONFIG_EXTRA_ARGS_MULTI_N :=

# Add toolchain bin to PATH
ADD_BIN_PATH ?= PATH=$(realpath ${PREFIX}/bin):$$PATH

# Configuration
ifeq (,$(filter-out x86_64-%,${TARGET_ARCH}))
  MINGW_LIBDIR := lib64
else ifeq (,$(filter-out i386-% i486-% i586-% i686-%,${TARGET_ARCH}))
  MINGW_LIBDIR := lib32
else
  $(error Unknown CPU for target arch ${TARGET_ARCH})
endif


# --------------------------------------
#  GMP
# --------------------------------------
gmp-download : $(SRC_DIR)/gmp.tar.bz2

$(SRC_DIR)/gmp.tar.bz2 : $(SRC_DIR)/.mkdir.marker
	$(WGET) -O $@ ftp://ftp.gnu.org/gnu/gmp/gmp-$(strip ${GMP_VERSION}).tar.bz2

gmp-extract : $(SRC_DIR)/gmp/.gmp.extract.marker
$(SRC_DIR)/gmp/.gmp.extract.marker : $(SRC_DIR)/gmp.tar.bz2 $(SRC_DIR)/gmp/src/.mkdir.marker
	$(TAR) -C $(dir $@)src --strip-components=1 -xjf $<
	touch $@

gmp-configure : $(BUILD_DIR)/gmp/obj/.config.marker
$(BUILD_DIR)/gmp/obj/.config.marker : $(BUILD_DIR)/gmp/obj/.mkdir.marker $(SRC_DIR)/gmp/.gmp.extract.marker
	cd $(dir $@) && ../../../$(SRC_DIR)/gmp/src/configure \
	--enable-static --disable-shared \
	--prefix=$(CURDIR)/$(BUILD_DIR)/gmp/install \
	$(GMP_CONFIG_ARGS) $(GMP_CONFIG_EXTRA_ARGS)
	touch $@

gmp-build : $(BUILD_DIR)/gmp/obj/.build.marker
$(BUILD_DIR)/gmp/obj/.build.marker : $(BUILD_DIR)/gmp/obj/.config.marker
	$(MAKE) -C $(dir $@) $(MAKE_PARALLEL) 
	touch $@

gmp-install : ${BUILD_DIR}/gmp/install/.install.marker
${BUILD_DIR}/gmp/install/.install.marker : ${BUILD_DIR}/gmp/obj/.build.marker ${BUILD_DIR}/gmp/install/.mkdir.marker
	$(MAKE) -C ${BUILD_DIR}/gmp/obj install
	touch $@

gmp-all : \
gmp-download \
gmp-extract \
gmp-configure \
gmp-build \
gmp-install 

# --------------------------------------
#  MPFR
# --------------------------------------
mpfr-download : $(SRC_DIR)/mpfr.tar.xz

$(SRC_DIR)/mpfr.tar.xz : $(SRC_DIR)/.mkdir.marker
	$(WGET) -O $@ http://www.mpfr.org/mpfr-$(strip ${MPFR_VERSION})/mpfr-$(strip ${MPFR_VERSION}).tar.xz

mpfr-extract : $(SRC_DIR)/mpfr/.mpfr.extract.marker
$(SRC_DIR)/mpfr/.mpfr.extract.marker : $(SRC_DIR)/mpfr.tar.xz $(SRC_DIR)/mpfr/src/.mkdir.marker
	$(TAR) -C $(dir $@)src --strip-components=1 --xz -xf $<
	touch $@

mpfr-configure : $(BUILD_DIR)/mpfr/obj/.config.marker
$(BUILD_DIR)/mpfr/obj/.config.marker : $(BUILD_DIR)/mpfr/obj/.mkdir.marker
	cd $(dir $@) && ../../../$(SRC_DIR)/mpfr/src/configure \
	--enable-static --disable-shared \
	--prefix=$(CURDIR)/$(BUILD_DIR)/mpfr/install \
	--with-gmp=$(CURDIR)/$(BUILD_DIR)/gmp/install \
	$(MPFR_CONFIG_ARGS) $(MPFR_CONFIG_EXTRA_ARGS)
	touch $@

mpfr-build : $(BUILD_DIR)/mpfr/obj/.build.marker
$(BUILD_DIR)/mpfr/obj/.build.marker : $(BUILD_DIR)/mpfr/obj/.config.marker
	$(MAKE) -C $(dir $@) $(MAKE_PARALLEL) 
	touch $@

mpfr-install : ${BUILD_DIR}/mpfr/install/.install.marker
${BUILD_DIR}/mpfr/install/.install.marker : ${BUILD_DIR}/mpfr/obj/.build.marker ${BUILD_DIR}/mpfr/install/.mkdir.marker
	$(MAKE) -C ${BUILD_DIR}/mpfr/obj install
	touch $@

mpfr-all : \
mpfr-download \
mpfr-extract \
mpfr-configure \
mpfr-build \
mpfr-install 

# --------------------------------------
#  MPC
# --------------------------------------
mpc-download : $(SRC_DIR)/mpc.tar.gz

$(SRC_DIR)/mpc.tar.gz : $(SRC_DIR)/.mkdir.marker
	$(WGET) -O $@ http://www.multiprecision.org/mpc/download/mpc-$(strip ${MPC_VERSION}).tar.gz

mpc-extract : $(SRC_DIR)/mpc/.mpc.extract.marker
$(SRC_DIR)/mpc/.mpc.extract.marker : $(SRC_DIR)/mpc.tar.gz $(SRC_DIR)/mpc/src/.mkdir.marker
	$(TAR) -C $(dir $@)src --strip-components=1 -xzf $<
	touch $@

mpc-configure : $(BUILD_DIR)/mpc/obj/.config.marker
$(BUILD_DIR)/mpc/obj/.config.marker : $(BUILD_DIR)/mpc/obj/.mkdir.marker $(SRC_DIR)/mpc/.mpc.extract.marker
	cd $(dir $@) && ../../../$(SRC_DIR)/mpc/src/configure \
	--enable-static --disable-shared \
	--prefix=$(CURDIR)/$(BUILD_DIR)/mpc/install \
	--with-gmp=$(CURDIR)/$(BUILD_DIR)/gmp/install \
	--with-mpfr=$(CURDIR)/$(BUILD_DIR)/mpfr/install \
	$(MPC_CONFIG_ARGS) $(MPC_CONFIG_EXTRA_ARGS)
	touch $@

mpc-build : $(BUILD_DIR)/mpc/obj/.build.marker
$(BUILD_DIR)/mpc/obj/.build.marker : $(BUILD_DIR)/mpc/obj/.config.marker
	$(MAKE) -C $(dir $@) $(MAKE_PARALLEL) 
	touch $@

mpc-install : ${BUILD_DIR}/mpc/install/.install.marker
${BUILD_DIR}/mpc/install/.install.marker : ${BUILD_DIR}/mpc/obj/.build.marker ${BUILD_DIR}/mpc/install/.mkdir.marker
	$(MAKE) -C ${BUILD_DIR}/mpc/obj install
	touch $@

mpc-all : \
mpc-download \
mpc-extract \
mpc-configure \
mpc-build \
mpc-install 

# --------------------------------------
#  PREPARE INSTALLATION PREFIX DIRECTORY
# --------------------------------------
prefix-init : $(PREFIX)/.init.marker
$(PREFIX)/.init.marker : \
    $(PREFIX)/.mkdir.marker \
    $(PREFIX)/$(TARGET_ARCH)/.mkdir.marker
	test -e $(PREFIX)/mingw || junction $(PREFIX)/mingw $(PREFIX)/$(TARGET_ARCH)
	test -e $(PREFIX)/mingw
	test -e $(PREFIX)/$(TARGET_ARCH)/lib32 || mkdir $(PREFIX)/$(TARGET_ARCH)/lib32
	test -e $(PREFIX)/$(TARGET_ARCH)/lib64 || mkdir $(PREFIX)/$(TARGET_ARCH)/lib64
	test -e $(PREFIX)/$(TARGET_ARCH)/lib || junction "$(PREFIX)/$(TARGET_ARCH)/lib" "$(PREFIX)/$(TARGET_ARCH)/$(MINGW_LIBDIR)"
	test -e $(PREFIX)/$(TARGET_ARCH)/lib
	touch $@

# --------------------------------------
#  DOWNLOAD MINGW-W64
# --------------------------------------
mingw-download : $(SRC_DIR)/mingw64/.co.marker
$(SRC_DIR)/mingw64/.co.marker : $(SRC_DIR)/mingw64/.mkdir.marker
	$(SVN) co --revision ${MINGW_REVISION} --non-interactive --no-auth-cache \
	https://mingw-w64.svn.sourceforge.net/svnroot/mingw-w64/$(strip ${MINGW_BRANCH})/ $(dir $@)
	@touch $@

mingw-update : $(SRC_DIR)/mingw64/.update.marker
ifeq (0,$(strip $(MINGW_UPDATE)))
.PHONY: $(SRC_DIR)/mingw64/.update.marker
else
$(SRC_DIR)/mingw64/.update.marker : $(SRC_DIR)/mingw64/.co.marker
	cd $(dir $@) && $(SVN) update --revision ${MINGW_REVISION}
endif

# --------------------------------------
#  MINGW-W64 HEADERS
# --------------------------------------
headers-configure : $(BUILD_DIR)/headers/obj/.config.marker
$(BUILD_DIR)/headers/obj/.config.marker : $(BUILD_DIR)/headers/obj/.mkdir.marker
	cd $(dir $@) && $(CURDIR)/$(SRC_DIR)/mingw64/mingw-w64-headers/configure \
	--prefix=$(PREFIX) \
	--with-sysroot=$(PREFIX) \
	--host=$(TARGET_ARCH) \
	--enable-sdk=all
	touch $@

headers-build : $(BUILD_DIR)/headers/obj/.build.marker
$(BUILD_DIR)/headers/obj/.build.marker : $(BUILD_DIR)/headers/obj/.config.marker
	$(MAKE) -C $(dir $@) $(MAKE_PARALLEL) 
	touch $@

headers-install : $(BUILD_DIR)/headers/obj/.install.marker 
${BUILD_DIR}/headers/obj/.install.marker : \
    $(BUILD_DIR)/headers/obj/.build.marker \
    $(PREFIX)/.init.marker
	$(MAKE) -C $(dir $@) install
	touch $@

headers-all : \
mingw-download \
headers-configure \
headers-build \
headers-install 

# --------------------------------------
#  BINUTILS
# --------------------------------------
binutils-download :$(SRC_DIR)/binutils/.co.marker
$(SRC_DIR)/binutils/.co.marker : $(SRC_DIR)/binutils/.mkdir.marker 
	cd $(dir $@) && $(CVS) -d ":pserver:anoncvs@sourceware.org:/cvs/src" -z3 checkout -d . -N binutils
	touch $@

binutils-update : $(SRC_DIR)/binutils/.update.marker
ifeq ($(BINUTILS_UPDATE),1)
$(SRC_DIR)/binutils/.update.marker :
	cd $(dir $@) && $(CVS) -d ":pserver:anoncvs@sourceware.org:/cvs/src" -z3 update
else
.PHONY: $(SRC_DIR)/binutils/.update.marker
endif

binutils-configure : $(BUILD_DIR)/binutils/obj/.config.marker
$(BUILD_DIR)/binutils/obj/.config.marker : $(BUILD_DIR)/binutils/obj/.mkdir.marker
	cd $(dir $@) && ../../../$(SRC_DIR)/binutils/src/configure \
	--prefix=$(PREFIX) \
	--with-sysroot=$(PREFIX) \
	--target=$(TARGET_ARCH) \
	--with-gmp=$(CURDIR)/$(BUILD_DIR)/gmp/install \
	--with-mpfr=$(CURDIR)/$(BUILD_DIR)/mpfr/install \
	--with-mpc=$(CURDIR)/$(BUILD_DIR)/mpc/install \
	$(BINUTILS_CONFIG_ARGS) \
	${BINUTILS_CONFIG_EXTRA_ARGS_MULTI_${ENABLE_MULTILIB}} \
	$(BINUTILS_CONFIG_EXTRA_ARGS)
	touch $@

binutils-build : $(BUILD_DIR)/binutils/obj/.build.marker
$(BUILD_DIR)/binutils/obj/.build.marker : $(BUILD_DIR)/binutils/obj/.config.marker
	$(MAKE) -C $(dir $@) $(MAKE_PARALLEL) 
	touch $@

binutils-install : $(BUILD_DIR)/binutils/obj/.install.marker
$(BUILD_DIR)/binutils/obj/.install.marker : \
    $(BUILD_DIR)/binutils/obj/.build.marker \
    $(PREFIX)/.init.marker
	$(MAKE) -C $(dir $@) install
	touch $@

binutils-all : \
binutils-download \
binutils-update \
binutils-configure \
binutils-build \
binutils-install 

# --------------------------------------
#  DOWNLOAD GCC
# --------------------------------------
gcc-download : $(SRC_DIR)/gcc/.co.marker
$(SRC_DIR)/gcc/.co.marker : $(SRC_DIR)/gcc/.mkdir.marker
	cd $(dir $@) && $(SVN) co --revision ${GCC_REVISION} \
	svn://gcc.gnu.org/svn/gcc/$(strip ${GCC_BRANCH})/ .
	@touch $@

gcc-update : $(SRC_DIR)/gcc/.update.marker
ifeq ($(GCC_UPDATE),0)
.PHONY: $(SRC_DIR)/gcc/.update.marker
else
$(SRC_DIR)/gcc/.update.marker : $(SRC_DIR)/gcc/.co.marker
	cd $(dir $@) && $(SVN) revert gcc/doc/tm.texi
	cd $(dir $@) && $(SVN) revert gcc/doc/tm.texi.in
	cd $(dir $@) && $(SVN) update --revision ${GCC_REVISION}
endif

# --------------------------------------
#   CONFIGURE GCC
# --------------------------------------
gcc-configure : $(BUILD_DIR)/gcc/.config.marker
$(BUILD_DIR)/gcc/.config.marker : \
    $(BUILD_DIR)/gcc/.mkdir.marker \
    $(BUILD_DIR)/gmp/install/.install.marker \
    $(BUILD_DIR)/mpfr/install/.install.marker \
    $(BUILD_DIR)/mpc/install/.install.marker \
    $(BUILD_DIR)/binutils/obj/.install.marker \
    $(PREFIX)/.init.marker
	$(ADD_BIN_PATH); cd $(dir $@) && ../../$(SRC_DIR)/gcc/configure \
	--target=${TARGET_ARCH} \
	--prefix=$(PREFIX) \
	--with-sysroot=$(PREFIX) \
	--with-gmp=${CURDIR}/${BUILD_DIR}/gmp/install \
	--with-mpfr=${CURDIR}/${BUILD_DIR}/mpfr/install \
	--with-mpc=${CURDIR}/${BUILD_DIR}/mpc/install \
	--enable-languages=c,c++,fortran \
	$(GCC_CONFIG_ARGS) \
	${GCC_CONFIG_EXTRA_ARGS_MULTI_${ENABLE_MULTILIB}} \
	$(GCC_CONFIG_EXTRA_ARGS)
	touch $@

# --------------------------------------
#   BOOTSTRAP GCC
# --------------------------------------
gcc-bootstrap-compile : $(BUILD_DIR)/gcc/.bootstrap.compile.marker
$(BUILD_DIR)/gcc/.bootstrap.compile.marker : $(BUILD_DIR)/gcc/.config.marker
	u2d $(SRC_DIR)/gcc/gcc/doc/tm.texi $(SRC_DIR)/gcc/gcc/doc/tm.texi.in
	$(MAKE) -C $(dir $@) $(MAKE_PARALLEL) all-gcc
	touch $@

gcc-bootstrap-install : $(BUILD_DIR)/gcc/.bootstrap.install.marker
$(BUILD_DIR)/gcc/.bootstrap.install.marker : $(BUILD_DIR)/gcc/.bootstrap.compile.marker
	$(MAKE) -C $(dir $@) install-gcc
	touch $@

gcc-bootstrap-all : \
gcc-download \
gcc-update \
gcc-configure \
gcc-bootstrap-compile \
gcc-bootstrap-install

# --------------------------------------
#   MINGW-W64 CRT
# --------------------------------------
crt-configure : $(BUILD_DIR)/crt/obj/.config.marker
$(BUILD_DIR)/crt/obj/.config.marker : \
    $(BUILD_DIR)/crt/obj/.mkdir.marker \
    $(BUILD_DIR)/headers/obj/.install.marker \
    $(BUILD_DIR)/gcc/.bootstrap.install.marker
	$(ADD_BIN_PATH); cd $(dir $@) && ../../../$(SRC_DIR)/mingw64/mingw-w64-crt/configure \
	--host=$(TARGET_ARCH) \
	--prefix=$(PREFIX) \
	--with-sysroot=$(PREFIX) \
	$(CRT_CONFIG_ARGS) \
	${MINGW_CONFIG_EXTRA_ARGS_MULTI_${ENABLE_MULTILIB}} \
	$(CRT_CONFIG_EXTRA_ARGS)
	touch $@

crt-build : $(BUILD_DIR)/crt/obj/.build.marker
$(BUILD_DIR)/crt/obj/.build.marker : $(BUILD_DIR)/crt/obj/.config.marker
	$(ADD_BIN_PATH); $(MAKE) -C $(dir $@) $(MAKE_PARALLEL) 
	touch $@

crt-install : $(BUILD_DIR)/crt/obj/.install.marker
$(BUILD_DIR)/crt/obj/.install.marker : $(BUILD_DIR)/crt/obj/.build.marker
	$(ADD_BIN_PATH); $(MAKE) -C $(dir $@) install
	touch $@

crt-all : \
crt-configure \
crt-build \
crt-install

# --------------------------------------
#  gcc-libgcc
# --------------------------------------
gcc-libgcc-compile : $(BUILD_DIR)/gcc/.libgcc.build.marker
$(BUILD_DIR)/gcc/.libgcc.build.marker : $(BUILD_DIR)/crt/obj/.install.marker
	$(MAKE) -C $(dir $@) $(MAKE_PARALLEL) all-target-libgcc
	touch $@

gcc-libgcc-install : $(BUILD_DIR)/gcc/.libgcc.install.marker
$(BUILD_DIR)/gcc/.libgcc.install.marker : $(BUILD_DIR)/gcc/.libgcc.build.marker
	$(MAKE) -C $(dir $@) install-target-libgcc
	cp -av $(PREFIX)/lib/gcc/$(TARGET_ARCH)/lib/libgcc_s.a $(PREFIX)/lib/gcc/$(TARGET_ARCH)/`cat $(SRC_DIR)/gcc/gcc/BASE-VER`
	rm -f $(PREFIX)/lib/gcc/$(TARGET_ARCH)/lib/libgcc_s.a
	touch $@

gcc-libgcc-all : \
gcc-libgcc-compile \
gcc-libgcc-install

# --------------------------------------
#  PTHREADS
# --------------------------------------
pthreads-download : $(SRC_DIR)/pthreads/.co.marker
$(SRC_DIR)/pthreads/.co.marker : $(SRC_DIR)/pthreads/.mkdir.marker
	cd ${SRC_DIR} && $(CVS) cvs -z9 -d $(PTHREADS_CVS_PULL) checkout -D ${PTHREADS_CVS_DATE} pthreads
	@touch $@

pthreads-update : $(SRC_DIR)/pthreads/.update.marker
ifeq ($(strip $(PTHREADS_UPDATE)),1)
$(SRC_DIR)/pthreads/.update.marker :
	cd $(dir $@) && $(CVS) update -D ${PTHREADS_CVS_DATE}
else
.PHONY: $(SRC_DIR)/pthreads/.update.marker
endif

pthreads-patch: $(BUILD_DIR)/pthreads/.patch.marker
$(BUILD_DIR)/pthreads/.patch.marker : \
    $(SRC_DIR)/pthreads/.co.marker \
    patches/w64sup.patch
	cp -prf src/pthreads $(BUILD_DIR)/
	cp -p $(CURDIR)/patches/w64sup.patch $(dir $@)
	cd $(dir $@) && patch -Np1 -i w64sup.patch
	cp -p $(dir $@)/config.h $(dir $@)pthreads_win32_config.h
	cp -p $(dir $@)/GNUmakefile $(dir $@)GNUmakefile.ori
	sed -e 's/HAVE_CONFIG_H/1/' \
	  -e 's/config.h/pthreads_win32_config.h/' \
	  < $(dir $@)/pthread.h >$(dir $@)pthread.h.out
	mv $(dir $@)/pthread.h.out $(dir $@)pthread.h
	@touch $@

pthreads-build: \
    $(BUILD_DIR)/pthreads/.build.$(ENABLE_MULTILIB)

$(BUILD_DIR)/pthreads/.build.Y: \
    $(BUILD_DIR)/pthreads/.build.x86_64-w64-mingw32 \
    $(BUILD_DIR)/pthreads/.build.i686-w64-mingw32
	@touch $@

${BUILD_DIR}/pthreads/.build.N: \
    $(BUILD_DIR)/pthreads/.build.$(TARGET_ARCH)
	@touch $@

$(BUILD_DIR)/pthreads/.build.x86_64-w64-mingw32: \
    $(BUILD_DIR)/pthreads/.patch.marker \
    $(BUILD_DIR)/gcc/.libgcc.install.marker
	sed -e 's/dlltool$$/& -m i386:x86-64/' \
	  -e 's/gcc$$/& -m64/' \
	  -e 's/g++$$/& -m64/' \
	  -e 's/windres$$/& -F pe-x86-64/' \
	  -e 's/pthreadGC\$$(DLL_VER)/&-w64/g' \
	  -e 's/pthreadGCE\$$(DLL_VER)/&-w64/g' \
	  < $(dir $@)GNUmakefile.ori > $(dir $@)GNUmakefile
	$(ADD_BIN_PATH); $(MAKE) $(MAKE_PARALLEL) -C $(dir $@) CROSS=$(TARGET_ARCH)- $(PTHREADS_MAKE_ARGS)
	@touch $@

$(BUILD_DIR)/pthreads/.build.i686-w64-mingw32: \
    $(BUILD_DIR)/pthreads/.patch.marker \
    $(BUILD_DIR)/gcc/.libgcc.install.marker
	sed -e 's/dlltool$$/& -m i386/' \
	  -e 's/gcc$$/& -m32/' \
	  -e 's/g++$$/& -m32/' \
	  -e 's/windres$$/& -F pe-i386/' \
	  -e 's/pthreadGC\$$(DLL_VER)/&-w32/g' \
	  -e 's/pthreadGCE\$$(DLL_VER)/&-w32/g' \
	  < $(dir $@)GNUmakefile.ori > $(dir $@)GNUmakefile
	$(ADD_BIN_PATH); $(MAKE) $(MAKE_PARALLEL) -C $(dir $@) CROSS=$(TARGET_ARCH)- $(PTHREADS_MAKE_ARGS)
	@touch $@

ifeq ($(TARGET_ARCH), x86_64-w64-mingw32)
  PTHREAD_DLL := pthreadGC2-w64.dll
else
  PTHREAD_DLL := pthreadGC2-w32.dll
endif

pthreads-install: \
    $(BUILD_DIR)/pthreads/.install.${ENABLE_MULTILIB}

$(BUILD_DIR)/pthreads/.install.common: \
    $(BUILD_DIR)/pthreads/.patch.marker
	cp -p $(BUILD_DIR)/pthreads/pthread.h \
	  $(BUILD_DIR)/pthreads/sched.h \
	  $(BUILD_DIR)/pthreads/semaphore.h \
	  $(BUILD_DIR)/pthreads/pthreads_win32_config.h \
	  $(PREFIX)/$(TARGET_ARCH)/include
	cp -p $(BUILD_DIR)/pthreads/$(PTHREAD_DLL) \
	  $(PREFIX)/$(TARGET_ARCH)/lib/libpthread.a
	@touch $@

$(BUILD_DIR)/pthreads/.install.Y: \
    $(BUILD_DIR)/pthreads/.build.Y \
    $(BUILD_DIR)/pthreads/.install.common \
    $(BUILD_DIR)/pthreads/.install.x86_64-w64-mingw32 \
    $(BUILD_DIR)/pthreads/.install.i686-w64-mingw32
	@touch $@

$(BUILD_DIR)/pthreads/.install.N: \
    $(BUILD_DIR)/pthreads/.build.N \
    $(BUILD_DIR)/pthreads/.install.common \
    $(BUILD_DIR)/pthreads/.install.$(TARGET_ARCH)
	@touch $@

$(BUILD_DIR)/pthreads/.install.x86_64-w64-mingw32: \
    $(BUILD_DIR)/pthreads/.build.x86_64-w64-mingw32
	cp -p $(BUILD_DIR)/pthreads/pthreadGC2-w64.dll \
	  $(PREFIX)/bin
	cp -fp $(BUILD_DIR)/pthreads/pthreadGC2-w64.dll \
	  $(PREFIX)/$(TARGET_ARCH)/lib64/libpthread.a
	@touch $@

$(BUILD_DIR)/pthreads/.install.i686-w64-mingw32: \
    $(BUILD_DIR)/pthreads/.build.i686-w64-mingw32
	cp -p $(BUILD_DIR)/pthreads/pthreadGC2-w32.dll \
	  $(PREFIX)/bin
	cp -fp $(BUILD_DIR)/pthreads/pthreadGC2-w32.dll \
	  $(PREFIX)/$(TARGET_ARCH)/lib32/libpthread.a
	@touch $@

pthreads-all : \
    pthreads-download \
    pthreads-update \
    pthreads-patch \
    pthreads-build \
    pthreads-install

# --------------------------------------
#  build full gcc
# --------------------------------------
gcc-build : $(BUILD_DIR)/gcc/.build.marker
$(BUILD_DIR)/gcc/.build.marker : \
    $(BUILD_DIR)/gcc/.libgcc.install.marker \
    $(BUILD_DIR)/pthreads/.install.$(ENABLE_MULTILIB)
	$(ADD_BIN_PATH); $(MAKE) -C $(dir $@) $(MAKE_PARALLEL) 
	touch $@

gcc-install : $(BUILD_DIR)/gcc/.install.marker
$(BUILD_DIR)/gcc/.install.marker : $(BUILD_DIR)/gcc/.build.marker
	$(ADD_BIN_PATH); $(MAKE) -C $(dir $@) install
	touch $@

GCC_FORWARDERS=\
gcc.exe \
g++.exe \
gfortran.exe \
cpp.exe \
c++.exe

gcc-forwarders : $(GCC_FORWARDERS)

$(GCC_FORWARDERS) : $(CURDIR)/tools/forward/forward.c
	cd $(PREFIX)/bin && $(TARGET_ARCH)-gcc.exe -o $@ -s -mconsole -DPROGRAM_NAME=\"$(TARGET_ARCH)-$@\" $<

# --------------------------------------
#  helper targets
# --------------------------------------

%/.mkdir.marker:
	mkdir -p $(dir $@)
	@touch -t 197001020101 $@

all-update : \
    mingw-update \
    gcc-update \
    pthreads-update \
    binutils-update

all : \
    gmp-all \
    mpfr-all \
    mpc-all \
    binutils-all \
    headers-all \
    gcc-bootstrap-all \
    crt-all \
    gcc-libgcc-all \
    pthreads-all \
    gcc-build \
    gcc-install

strip-exe :
	find $(PREFIX) -iname '*.exe' \
	-print -exec strip.exe --strip-unneeded '{}' \;

dist :
	cd $(PREFIX) && $(TAR) c --exclude '*.marker' --exclude '*.la' * | lzma -czv7 > $(CURDIR)/$(TARGET_ARCH)_gcc-$(GCC_BRANCH)_`date "+%Y%m%d"`.tar.lzma
	cd $(PREFIX) && zip -r -9 $(CURDIR)/$(TARGET_ARCH)_gcc-$(GCC_BRANCH)_`date "+%Y%m%d"`.zip . -x '.*.marker' '*.*.marker' '*.la'

mostly-clean :
	if test -e $(PREFIX)/mingw; then junction -d $(PREFIX)/mingw; fi
	if test -e $(PREFIX)/$(TARGET_ARCH)/lib; then junction -d "$(PREFIX)/$(TARGET_ARCH)/lib"; fi
	-rm -rf $(PREFIX)
	-rm -rf $(BUILD_DIR)/binutils
	-rm -rf $(BUILD_DIR)/gcc
	-rm -rf $(BUILD_DIR)/headers
	-rm -rf $(BUILD_DIR)/crt
	-rm -rf $(BUILD_DIR)/pthreads

dist-clean : mostly-clean
	-rm -rf $(BUILD_DIR)/mpc
	-rm -rf $(BUILD_DIR)/mpfr
	-rm -rf $(BUILD_DIR)/gmp
