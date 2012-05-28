# Filename:    Makefile
# Description: Makefile script for the src directory of the OdePkg

sinclude Makeconf # This is needed for packaging OdePkg correctly

DEVELOPERDEFS = -Wall -W -Wshadow
TGZUNPACK = tar -xzf  # "tar -xzvf" to print some output
PATCHPROG = patch -p0 # Needed to patch the Fortran codes

# MKOCTFILE = $(MKOCTFILE) has already been defined in Makeconf
# MKMEXFILE = $(MKOCTFILE) --mex
MKOCTFILE ?= mkoctfile

FFLAGS := $(shell $(MKOCTFILE) -p FFLAGS)
ifeq (gfortran,$(findstring gfortran,$(F77)))
  MKF77FILE = FFLAGS="-fno-automatic $(FFLAGS)" $(MKOCTFILE)
endif
ifeq (g95,$(findstring g95,$(F77)))
  MKF77FILE = FFLAGS="-fstatic $(FFLAGS)" $(MKOCTFILE)
else
  # eg. the combination f2c with fort77
  MKF77FILE = FFLAGS="$(FFLAGS)" $(MKOCTFILE)
endif

LAPACK_LIBS := $(shell $(MKOCTFILE) -p BLAS_LIBS) $(shell $(MKOCTFILE) -p LAPACK_LIBS)
FLIBS := $(shell $(MKOCTFILE) -p FLIBS)

EXTERNALDIRS  = hairer cash daskr
EXTERNALPACKS = $(patsubst %, %.tgz,  $(EXTERNALDIRS))
EXTERNALDIFFS = $(patsubst %, %.diff, $(EXTERNALDIRS))

SOLVERSOURCES = odepkg_octsolver_mebdfdae.cc odepkg_octsolver_mebdfi.cc \
		odepkg_octsolver_ddaskr.cc \
		odepkg_octsolver_radau.cc odepkg_octsolver_radau5.cc \
		odepkg_octsolver_rodas.cc odepkg_octsolver_seulex.cc
SOLVERDEPENDS = odepkg_auxiliary_functions.cc
SOLVEREXTERNS = cash/mebdfdae.f cash/mebdfi.f \
		daskr/ddaskr.f daskr/dlinpk.f \
		hairer/decsol.f hairer/dc_decsol.f \
		hairer/radau.f hairer/radau5.f hairer/rodas.f hairer/seulex.f
SOLVEROBJECTS = $(patsubst %.cc, %.o, $(SOLVERSOURCES)) \
	 	$(patsubst %.cc, %.o, $(SOLVERDEPENDS)) \
		$(patsubst %.f, %.o,  $(SOLVEREXTERNS))
SOLVEROCTFILE = dldsolver.oct

%.o : %.f ; $(MKF77FILE) -c $< -o $@
%.o : %.cc ; $(MKOCTFILE) -c $< -o $@

all : $(EXTERNALDIRS) $(SOLVEROCTFILE)

$(SOLVEROCTFILE) : $(EXTERNALDIRS) $(SOLVEROBJECTS)
	$(MKOCTFILE) $(SOLVEROBJECTS) -o $(SOLVEROCTFILE) \
        $(LAPACK_LIBS) $(FLIBS)

install :
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/odepkg

$(EXTERNALDIRS) :
	@for i in $(EXTERNALPACKS); do \
	  echo "Unpacking external packages: $$i"; \
	  $(TGZUNPACK) $$i; \
	done
	@for j in $(EXTERNALDIFFS); do \
	  echo "Applying patches from file: $$j"; \
	  $(PATCHPROG) < $$j; \
	done

clean :
	@echo "Cleaning..."; \
	$(RM) -rf $(EXTERNALDIRS) $(SOLVEROBJECTS) $(SOLVEROCTFILE)

distclean : clean
	@echo "Dist Cleaning..."; \
	$(RM) -rf *~ config.status config.log autom4te.cache Makeconf

realclean : distclean
	@echo "Really Cleaning..."; \
	$(RM) -rf configure

dist : all
