#
#   MAKEFILE for suitesparse
#

SUITESPARSE_VER=3.2.0

# these should be overridden by the main makefile
PREFIX ?= /usr/local
SRCDIR ?= src
SRCTARDIR ?= srctar
BUILDDIR ?= build
WGET  ?= wget
TOUCH ?= touch
STRIP ?= $(CROSS)strip

CHOLMOD_INCLUDES=cholmod_core.h cholmod_io64.h cholmod.h cholmod_supernodal.h cholmod_partition.h cholmod_modify.h cholmod_matrixops.h cholmod_internal.h cholmod_config.h cholmod_cholesky.h cholmod_check.h cholmod_blas.h cholmod_complexity.h cholmod_template.h
UMFPACK_INCLUDES=umfpack.h umfpack_get_lunz.h umfpack_numeric.h umfpack_report_perm.h umfpack_save_symbolic.h umfpack_transpose.h umfpack_col_to_triplet.h umfpack_get_numeric.h umfpack_qsymbolic.h umfpack_report_status.h umfpack_scale.h umfpack_triplet_to_col.h umfpack_defaults.h umfpack_get_symbolic.h umfpack_report_control.h umfpack_report_symbolic.h umfpack_solve.h umfpack_wsolve.h umfpack_free_numeric.h umfpack_global.h umfpack_report_info.h umfpack_report_triplet.h umfpack_symbolic.h umfpack_free_symbolic.h umfpack_load_numeric.h umfpack_report_matrix.h umfpack_report_vector.h umfpack_tictoc.h umfpack_get_determinant.h umfpack_load_symbolic.h umfpack_report_numeric.h umfpack_save_numeric.h umfpack_timer.h
AMD_INCLUDES=amd.h amd_internal.h
CAMD_INCLUDES=camd.h camd_internal.h
COLAMD_INCLUDES=colamd.h
CCOLAMD_INCLUDES=ccolamd.h
CXSPARSE_INCLUDES=cs.h

suitesparse-download : $(SRCTARDIR)/suitesparse-$(SUITESPARSE_VER).tar.gz
$(SRCTARDIR)/suitesparse-$(SUITESPARSE_VER).tar.gz : $(SRCTARDIR)/.mkdir.marker
	$(WGET) -O $@ http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-$(SUITESPARSE_VER).tar.gz

suitesparse-unpack : $(SRCDIR)/suitesparse/.unpack.marker
$(SRCDIR)/suitesparse/.unpack.marker : \
    $(SRCTARDIR)/suitesparse-$(SUITESPARSE_VER).tar.gz \
    $(PATCHDIR)/suitesparse-$(SUITESPARSE_VER).patch \
    $(SRCDIR)/suitesparse/.mkdir.marker 
	$(TAR) -C $(dir $@) --strip-components=1 -xzf $<
	cd $(SRCDIR)/suitesparse && patch -p1 -u -i $(CURDIR)/$(PATCHDIR)/suitesparse-$(SUITESPARSE_VER).patch
	$(TOUCH) $@

suitesparse-configure : $(BUILDDIR)/suitesparse/.config.marker
$(BUILDDIR)/suitesparse/.config.marker : \
    $(SRCDIR)/suitesparse/.unpack.marker \
    $(BUILDDIR)/suitesparse/.mkdir.marker
	mkdir -p $(BUILDDIR)/suitesparse/AMD/Lib
	mkdir -p $(BUILDDIR)/suitesparse/CAMD/Lib
	mkdir -p $(BUILDDIR)/suitesparse/CCOLAMD/Lib
	mkdir -p $(BUILDDIR)/suitesparse/COLAMD/Lib
	mkdir -p $(BUILDDIR)/suitesparse/CSparse/Lib
	mkdir -p $(BUILDDIR)/suitesparse/CXSparse/Lib
	mkdir -p $(BUILDDIR)/suitesparse/CHOLMOD/Lib
	mkdir -p $(BUILDDIR)/suitesparse/UMFPACK/Lib
	mkdir -p $(BUILDDIR)/suitesparse/UFConfig
	cp -a $(SRCDIR)/suitesparse/UFconfig/UFconfig.mk $(BUILDDIR)/suitesparse/UFconfig
	cp -a $(SRCDIR)/suitesparse/AMD/Lib/GNUmakefile  $(BUILDDIR)/suitesparse/AMD/Lib
	cp -a $(SRCDIR)/suitesparse/CAMD/Lib/GNUmakefile  $(BUILDDIR)/suitesparse/CAMD/Lib
	cp -a $(SRCDIR)/suitesparse/CCOLAMD/Lib/makefile  $(BUILDDIR)/suitesparse/CCOLAMD/Lib
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Lib/makefile  $(BUILDDIR)/suitesparse/CHOLMOD/Lib
	cp -a $(SRCDIR)/suitesparse/COLAMD/Lib/makefile  $(BUILDDIR)/suitesparse/COLAMD/Lib
	cp -a $(SRCDIR)/suitesparse/CSparse/Lib/makefile  $(BUILDDIR)/suitesparse/CSparse/Lib
	cp -a $(SRCDIR)/suitesparse/CXSparse/Lib/makefile  $(BUILDDIR)/suitesparse/CXSparse/Lib
	cp -a $(SRCDIR)/suitesparse/UMFPACK/Lib/GNUmakefile  $(BUILDDIR)/suitesparse/UMFPACK/Lib
	$(TOUCH) $@

suitesparse-rebuild : SRCTOP=$(CURDIR)/$(SRCDIR)/suitesparse
suitesparse-rebuild : 
	cd $(BUILDDIR)/suitesparse/AMD/Lib      && $(MAKE) CROSS=$(CROSS) SRCTOP=$(SRCTOP) LDFLAGS="$(LDFLAGS_SHAREDLIBGCC) -L$(PREFIX)/lib" $(MAKE_PARALLEL) -f GNUmakefile
	cd $(BUILDDIR)/suitesparse/CAMD/Lib     && $(MAKE) CROSS=$(CROSS) SRCTOP=$(SRCTOP) LDFLAGS="$(LDFLAGS_SHAREDLIBGCC) -L$(PREFIX)/lib" $(MAKE_PARALLEL) -f GNUmakefile
	cd $(BUILDDIR)/suitesparse/CCOLAMD/Lib  && $(MAKE) CROSS=$(CROSS) SRCTOP=$(SRCTOP) LDFLAGS="$(LDFLAGS_SHAREDLIBGCC) -L$(PREFIX)/lib" $(MAKE_PARALLEL) 
	cd $(BUILDDIR)/suitesparse/COLAMD/Lib   && $(MAKE) CROSS=$(CROSS) SRCTOP=$(SRCTOP) LDFLAGS="$(LDFLAGS_SHAREDLIBGCC) -L$(PREFIX)/lib" $(MAKE_PARALLEL) 
	cd $(BUILDDIR)/suitesparse/CSparse/Lib  && $(MAKE) CROSS=$(CROSS) SRCTOP=$(SRCTOP) LDFLAGS="$(LDFLAGS_SHAREDLIBGCC) -L$(PREFIX)/lib" $(MAKE_PARALLEL) 
	cd $(BUILDDIR)/suitesparse/CXSparse/Lib && $(MAKE) CROSS=$(CROSS) SRCTOP=$(SRCTOP) LDFLAGS="$(LDFLAGS_SHAREDLIBGCC) -L$(PREFIX)/lib" $(MAKE_PARALLEL) 
	cd $(BUILDDIR)/suitesparse/CHOLMOD/Lib  && $(MAKE) CROSS=$(CROSS) SRCTOP=$(SRCTOP) LDFLAGS="$(LDFLAGS_SHAREDLIBGCC) -L$(PREFIX)/lib" $(MAKE_PARALLEL) 
	cd $(BUILDDIR)/suitesparse/UMFPACK/Lib  && $(MAKE) CROSS=$(CROSS) SRCTOP=$(SRCTOP) LDFLAGS="$(LDFLAGS_SHAREDLIBGCC) -L$(PREFIX)/lib" $(MAKE_PARALLEL) -f GNUmakefile

suitesparse-build : $(BUILDDIR)/suitesparse/.build.marker
$(BUILDDIR)/suitesparse/.build.marker : $(BUILDDIR)/suitesparse/.config.marker
	$(MAKE) suitesparse-rebuild
	$(TOUCH) $@

suitesparse-reinstall : PKG=suitesparse
suitesparse-reinstall : \
    $(PREFIX)/.init.marker
	$(MAKE) suitesparse-reinstall-libs
	$(MAKE) suitesparse-reinstall-headers
	$(MAKE) suitesparse-reinstall-license

suitesparse-reinstall-libs :
	for a in amd camd ccolamd colamd csparse cxsparse cholmod umfpack; do \
	    cp -a $(BUILDDIR)/suitesparse/$$a/Lib/$$a.dll      $(PREFIX)/bin; \
	    cp -a $(BUILDDIR)/suitesparse/$$a/Lib/lib$$a.dll.a $(PREFIX)/lib; \
	    cp -a $(BUILDDIR)/suitesparse/$$a/Lib/lib$$a.a     $(PREFIX)/lib; \
	done;

suitesparse-reinstall-headers :
	-mkdir -p $(PREFIX)/include/suitesparse
	$(MAKE) LIB=UMFPACK  suitesparse-install-headers-core
	$(MAKE) LIB=CHOLMOD  suitesparse-install-headers-core
	$(MAKE) LIB=CXSPARSE suitesparse-install-headers-core
	$(MAKE) LIB=CSPARSE  suitesparse-install-headers-core
	$(MAKE) LIB=COLAMD   suitesparse-install-headers-core
	$(MAKE) LIB=CCOLAMD  suitesparse-install-headers-core
	$(MAKE) LIB=CAMD     suitesparse-install-headers-core
	$(MAKE) LIB=AMD      suitesparse-install-headers-core
	cp -a $(SRCDIR)/suitesparse/UFconfig/UFconfig.h $(PREFIX)/include/suitesparse

suitesparse-install-headers-core :
	for a in $($(LIB)_INCLUDES); do \
	    cp -a $(SRCDIR)/suitesparse/$(LIB)/include/$$a $(PREFIX)/include/suitesparse; \
	done

suitesparse-reinstall-license :
	cp -a $(SRCDIR)/suitesparse/AMD/doc/lesser.txt             $(PREFIX)/license/suitesparse/LGPL.txt
	cp -a $(SRCDIR)/suitesparse/AMD/doc/License                $(PREFIX)/license/suitesparse/LICENSE.AMD
	cp -a $(SRCDIR)/suitesparse/CAMD/doc/License               $(PREFIX)/license/suitesparse/LICENSE.CAMD
	cp -a $(SRCDIR)/suitesparse/CCOLAMD/Readme.txt             $(PREFIX)/license/suitesparse/Readme.CCOLAMD
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Check/License.txt      $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Check
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Cholesky/License.txt   $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Cholesky
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Core/License.txt       $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Core
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Demo/License.txt       $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Demo
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/MatrixOps/License.txt  $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.MatrixOps
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Modify/License.txt     $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Modify
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Partition/License.txt  $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Partition
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Supernodal/License.txt $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Supernodal
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Tcov/License.txt       $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Tcov
	cp -a $(SRCDIR)/suitesparse/CHOLMOD/Valgrind/License.txt   $(PREFIX)/license/suitesparse/LICENSE.CHOLMOD.Valgrind
	cp -a $(SRCDIR)/suitesparse/COLAMD/Readme.txt              $(PREFIX)/license/suitesparse/Readme.COLAMD
	cp -a $(SRCDIR)/suitesparse/CSparse/doc/License.txt        $(PREFIX)/license/suitesparse/LICENSE.CSparse
	cp -a $(SRCDIR)/suitesparse/CXSparse/doc/License.txt       $(PREFIX)/license/suitesparse/LICENSE.CXSparse
	cp -a $(SRCDIR)/suitesparse/UMFPACK/doc/License            $(PREFIX)/license/suitesparse/LICENSE.UMFPACK

suitesparse-install : $(BUILDDIR)/suitesparse/.install.marker 
$(BUILDDIR)/suitesparse/.install.marker : $(BUILDDIR)/suitesparse/.build.marker
	$(MAKE) suitesparse-reinstall
	$(TOUCH) $@

suitesparse-reinstall-strip : suitesparse-reinstall
	for a in amd camd ccolamd colamd csparse cxsparse cholmod; do \
	    $(STRIP) $(PREFIX)/bin/$$a.dll; \
	done

suitesparse-install-strip : $(BUILDDIR)/suitesparse/.installstrip.marker 
$(BUILDDIR)/suitesparse/.installstrip.marker : $(BUILDDIR)/suitesparse/.install.marker
	$(MAKE) suitesparse-reinstall-strip
	$(TOUCH) $@

suitesparse-check : $(BUILDDIR)/suitesparse/.check.marker
$(BUILDDIR)/suitesparse/.check.marker : $(BUILDDIR)/suitesparse/.build.marker
	$(MAKE) common-make TGT=test PKG=suitesparse
	$(MAKE) common-make TGT=testdll PKG=suitesparse
	$(TOUCH) $@

suitesparse-all : \
    suitesparse-download \
    suitesparse-unpack \
    suitesparse-configure \
    suitesparse-build \
    suitesparse-install

all : suitesparse-all
all-download : suitesparse-download
all-install : suitesparse-install
all-reinstall : suitesparse-reinstall
all-install-strip : suitesparse-install-strip
all-reinstall-strip : suitesparse-install-strip
all-rebuild : suitesparse-rebuild suitesparse-reinstall
all-pkg : suitesparse-pkg

suitesparse-pkg : PREFIX=/opt/pkg-$(ARCH)/suitesparse
suitesparse-pkg : $(BUILDDIR)/suitesparse/.pkg.marker
$(BUILDDIR)/suitesparse/.pkg.marker : 
	$(MAKE) PREFIX=$(PREFIX) suitesparse-reinstall-strip
	cd $(PREFIX) && zip -qr9 $(CURDIR)/suitesparse-$(SUITESPARSE_VER)-$(BUILD_ARCH)$(ID)-bin.zip bin/*.dll
	cd $(PREFIX) && zip -qr9 $(CURDIR)/suitesparse-$(SUITESPARSE_VER)-$(BUILD_ARCH)$(ID)-dev.zip include lib
	cd $(PREFIX) && zip -qr9 $(CURDIR)/suitesparse-$(SUITESPARSE_VER)-$(BUILD_ARCH)$(ID)-lic.zip license
	zip -qr9 suitesparse-$(SUITESPARSE_VER)-src.zip $(SRCTARDIR)/suitesparse-$(SUITESPARSE_VER).tar.gz $(MAKEFILEDIR)suitesparse.mk $(PATCHDIR)/suitesparse-$(SUITESPARSE_VER).patch makefile
	$(TOUCH) $@
