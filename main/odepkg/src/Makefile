# Filename:    Makefile
# Description: Makefile for the src directory of the OdePkg
# ChangeLog: 20070222, this Makefile was originally be created from
#    the Makefile of the 'communication' package. Modifications have
#    been made to create binaries from the source codes of the OdePkg.

sinclude Makeconf # This is ok, David changed this line

DEVELOPERDEFS = -Wall -W -Wshadow -D__ODEPKGDEBUG__

MKOCTFILE = mkoctfile # change the mkoctfile command if necessary
MKMEXFILE = mkoctfile --mex # $(DEVELOPERDEFS)
TGZUNPACK = tar -xzf # "tar -xzvf" to print some output
PATCHPROG = patch -p0 # Needed to patch the Fortran codes

EXTERNALDIRS  = hairer cash
EXTERNALPACKS = $(patsubst %, %.tgz,  $(EXTERNALDIRS))
EXTERNALDIFFS = $(patsubst %, %.diff, $(EXTERNALDIRS))

SOLVERSOURCES = odepkg_octsolver_mebdfi.cc
SOLVERDEPENDS = odepkg_auxiliary_functions.cc
SOLVEREXTERNS = cash/mebdfi.f
SOLVEROBJECTS = $(patsubst %.cc, %.o, $(SOLVERSOURCES)) \
	 	$(patsubst %.cc, %.o, $(SOLVERDEPENDS)) \
		$(patsubst %.f, %.o,  $(SOLVEREXTERNS))
SOLVEROCTFILE = odepkg_dldsolver_functions.oct

DOPRI5SOURCES = odepkg_mexsolver_dopri5.c
DOPRI5DEPENDS = odepkgmex.c odepkgext.c
DOPRI5EXTERNS = hairer/dopri5.f
DOPRI5OBJECTS = $(patsubst %.c, %.o,   $(DOPRI5SOURCES)) \
                $(patsubst %.c, %.o,   $(DOPRI5DEPENDS)) \
                $(patsubst %.f, %.o,   $(DOPRI5EXTERNS))
DOPRI5MXFILES = $(patsubst %.c, %.mex, $(DOPRI5SOURCES))

DOP853SOURCES = odepkg_mexsolver_dop853.c
DOP853DEPENDS = odepkgmex.c odepkgext.c
DOP853EXTERNS = hairer/dop853.f
DOP853OBJECTS = $(patsubst %.c, %.o,   $(DOP853SOURCES)) \
                $(patsubst %.c, %.o,   $(DOPRI5DEPENDS)) \
                $(patsubst %.f, %.o,   $(DOP853EXTERNS))
DOP853MXFILES = $(patsubst %.c, %.mex, $(DOP853SOURCES))

ODEXSOURCES = odepkg_mexsolver_odex.c
ODEXDEPENDS = odepkgmex.c odepkgext.c
ODEXEXTERNS = hairer/odex.f
ODEXOBJECTS = $(patsubst %.c, %.o,   $(ODEXSOURCES)) \
              $(patsubst %.c, %.o,   $(ODEXDEPENDS)) \
              $(patsubst %.f, %.o,   $(ODEXEXTERNS))
ODEXMXFILES = $(patsubst %.c, %.mex, $(ODEXSOURCES))

RADAUSOURCES = odepkg_mexsolver_radau.c
RADAUDEPENDS = odepkgmex.c odepkgext.c
RADAUEXTERNS = hairer/radau.f hairer/decsol.f hairer/dc_decsol.f
RADAUOBJECTS = $(patsubst %.c, %.o,   $(RADAUSOURCES)) \
               $(patsubst %.c, %.o,   $(RADAUDEPENDS)) \
               $(patsubst %.f, %.o,   $(RADAUEXTERNS))
RADAUMXFILES = $(patsubst %.c, %.mex, $(RADAUSOURCES))

RADAU5SOURCES = odepkg_mexsolver_radau5.c
RADAU5DEPENDS = odepkgmex.c odepkgext.c
RADAU5EXTERNS = hairer/radau5.f hairer/decsol.f hairer/dc_decsol.f
RADAU5OBJECTS = $(patsubst %.c, %.o,   $(RADAU5SOURCES)) \
                $(patsubst %.c, %.o,   $(RADAU5DEPENDS)) \
                $(patsubst %.f, %.o,   $(RADAU5EXTERNS))
RADAU5MXFILES = $(patsubst %.c, %.mex, $(RADAU5SOURCES))

RODASSOURCES = odepkg_mexsolver_rodas.c
RODASDEPENDS = odepkgmex.c odepkgext.c
RODASEXTERNS = hairer/rodas.f hairer/decsol.f hairer/dc_decsol.f
RODASOBJECTS = $(patsubst %.c, %.o,   $(RODASSOURCES)) \
               $(patsubst %.c, %.o,   $(RODASDEPENDS)) \
               $(patsubst %.f, %.o,   $(RODASEXTERNS))
RODASMXFILES = $(patsubst %.c, %.mex, $(RODASSOURCES))

SEULEXSOURCES = odepkg_mexsolver_seulex.c
SEULEXDEPENDS = odepkgmex.c odepkgext.c
SEULEXEXTERNS = hairer/seulex.f hairer/decsol.f hairer/dc_decsol.f
SEULEXOBJECTS = $(patsubst %.c, %.o,   $(SEULEXSOURCES)) \
                $(patsubst %.c, %.o,   $(SEULEXDEPENDS)) \
                $(patsubst %.f, %.o,   $(SEULEXEXTERNS))
SEULEXMXFILES = $(patsubst %.c, %.mex, $(SEULEXSOURCES))

ODEPKGOBJECTS = $(DOPRI5OBJECTS) $(DOP853OBJECTS) $(ODEXOBJECTS) \
  $(RADAUOBJECTS) $(RADAU5OBJECTS) $(RODASOBJECTS) $(SEULEXOBJECTS)
ODEPKGMXFILES = $(DOPRI5MXFILES) $(DOP853MXFILES) $(ODEXMXFILES) \
  $(RADAUMXFILES) $(RADAU5MXFILES) $(RODASMXFILES) $(SEULEXMXFILES)
ODEPKGDELETES = $(ODEPKGOBJECTS) $(ODEPKGMXFILES) *~ octave-core \
  $(EXTERNALDIRS) $(SOLVEROBJECTS) $(SOLVEROCTFILE)

%.o : %.f ; $(MKOCTFILE) -c $< -o $@
#	@if  [ `$(MKOCTFILE) -p F77` == "gfortran" ]; then \
#	  FFLAGS="-fno-automatic ${FFLAGS}" $(MKOCTFILE) -c $< -o $@ ; \
#	elif [ `$(MKOCTFILE) -p F77` == "g95" ]; then \
#	  FFLAGS="-fno-automatic ${FFLAGS}" $(MKOCTFILE) -c $< -o $@ ; \
#	elif [ `$(MKOCTFILE) -p F77` == "fort77" ]; then \
#	  $(MKOCTFILE) -c $< -o $@ ; \
#	else \
#	  $(MKOCTFILE) -c $< -o $@ ; \
#	fi

%.o : %.c ; $(MKOCTFILE) -c $< -o $@
%.mex : %.o ; $(MKMEXFILE) $^ -o $@
%.o : %.cc ; $(MKOCTFILE) -c $< -o $@

all : $(EXTERNALDIRS) $(SOLVEROCTFILE) $(ODEPKGOBJECTS) $(ODEPKGMXFILES)

$(SOLVEROCTFILE) : $(EXTERNALDIRS) $(SOLVEROBJECTS)
	$(MKOCTFILE) $(SOLVEROBJECTS) -o $(SOLVEROCTFILE)

$(DOPRI5MXFILES) : $(DOPRI5OBJECTS)
$(DOP853MXFILES) : $(DOP853OBJECTS)
$(ODEXMXFILES) : $(ODEXOBJECTS)
$(RADAUMXFILES) : $(RADAUOBJECTS)
$(RADAU5MXFILES) : $(RADAU5OBJECTS)
$(RODASMXFILES) : $(RODASOBJECTS)
$(SEULEXMXFILES) : $(SEULEXOBJECTS)

install :
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/odepkg

$(EXTERNALDIRS) :
	@for i in $(EXTERNALPACKS); do \
	  echo "Unpacking external packages: $$i"; \
	  $(TGZUNPACK) $$i; \
	done
	@for j in $(EXTERNALDIFFS); do \
	  $(PATCHPROG) < $$j; \
	done

clean :
	@echo "Cleaning..."; \
	$(RM) -fr $(ODEPKGDELETES)

distclean realclean : clean
	@echo "Really Cleaning..."; \
	$(RM) -r configure config.status config.log autom4te.cache Makeconf

dist : all
