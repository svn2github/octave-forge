sinclude ../../Makeconf

FIXEDVERTARGET = fixedversion.h
FIXEDTARGET = fixed.oct 

FIXEDLINKTARGETS = isfixed.oct fabs.oct fcos.oct fcosh.oct fsin.oct fsinh.oct \
	ftan.oct ftanh.oct fsqrt.oct fexp.oct flog.oct flog10.oct fround.oct \
	ffloor.oct fceil.oct fprod.oct fsum.oct fsumsq.oct fcumsum.oct \
	fcumprod.oct display_fixed_operations.oct reset_fixed_operations.oct \
	freshape.oct fdiag.oct fatan2.oct freal.oct fimag.oct fconj.oct \
	farg.oct fangle.oct

SUBDIRS = examples doc

ifeq (,$(findstring cygwin,$(canonical_host_type)))
  FIXEDSOURCES = fixedColVector.cc fixedRowVector.cc \
	fixedMatrix.cc fixedComplex.cc fixedCColVector.cc fixedCRowVector.cc \
	fixedCMatrix.cc Array-f.cc fixed-conv.cc ov-fixed.cc ov-fixed-mat.cc \
	fixedNDArray.cc fixedCNDArray.cc \
	ov-fixed-complex.cc ov-fixed-cx-mat.cc \
	op-fs-fs.cc   op-fs-fm.cc   op-fm-fs.cc   op-fm-fm.cc \
	op-fs-fcs.cc  op-fs-fcm.cc  op-fm-fcs.cc  op-fm-fcm.cc \
	op-fcs-fs.cc  op-fcs-fm.cc  op-fcm-fs.cc  op-fcm-fm.cc \
	op-fcs-fcs.cc op-fcs-fcm.cc op-fcm-fcs.cc op-fcm-fcm.cc \
	op-fil-fs.cc  op-fil-fm.cc  op-fil-fcs.cc op-fil-fcm.cc \
	fixed-var.cc fixed.cc
  FIXEDOBJECTS = fixed-int.o $(patsubst %.cc,%.o,$(FIXEDSOURCES))
  FIXEDDEPENDS = fixed-int.d $(patsubst %.cc,%.d,$(FIXEDSOURCES))

  TARGETS = $(FIXEDTARGET) $(FIXEDLINKTARGETS)
  OBJECTS = $(FIXEDOBJECTS)

  EXTRALIBS =
else
  SH_LD=g++
  SH_LDFLAGS=-shared -Wl,--export-all-symbols -Wl,--enable-auto-import
  SONAME_FLAGS=-Wl,--out-implib=$(FIXEDLIBTARGET).a
  LFLAGS=-L/usr/lib/octave-$(OCTAVE_VERSION)
  OCTAVE_LIBS=-loctave -lcruft -loctinterp

  FIXEDLIBTARGET = liboctave_fixed.dll
  FIXEDLIBSOURCES = fixedColVector.cc fixedRowVector.cc \
	fixedMatrix.cc fixedComplex.cc fixedCColVector.cc fixedCRowVector.cc \
	fixedCMatrix.cc Array-f.cc fixed-conv.cc ov-fixed.cc ov-fixed-mat.cc \
	fixedNDArray.cc fixedCNDArray.cc \
	ov-fixed-complex.cc ov-fixed-cx-mat.cc \
	op-fs-fs.cc   op-fs-fm.cc   op-fm-fs.cc   op-fm-fm.cc \
	op-fs-fcs.cc  op-fs-fcm.cc  op-fm-fcs.cc  op-fm-fcm.cc \
	op-fcs-fs.cc  op-fcs-fm.cc  op-fcm-fs.cc  op-fcm-fm.cc \
	op-fcs-fcs.cc op-fcs-fcm.cc op-fcm-fcs.cc op-fcm-fcm.cc \
	op-fil-fs.cc  op-fil-fm.cc  op-fil-fcs.cc op-fil-fcm.cc \
	fixed-var.cc 
  FIXEDLIBOBJECTS = fixed-int.o $(patsubst %.cc,%.o,$(FIXEDLIBSOURCES))
  FIXEDLIBDEPENDS = fixed-int.d $(patsubst %.cc,%.d,$(FIXEDLIBSOURCES))

  FIXEDSOURCES = fixed.cc
  FIXEDOBJECTS = $(patsubst %.cc,%.o,$(FIXEDSOURCES))
  FIXEDDEPENDS = $(FIXEDLIBDEPENDS) $(patsubst %.cc,%.d,$(FIXEDSOURCES))

  TARGETS = $(FIXEDLIBTARGET) $(FIXEDTARGET) $(FIXEDLINKTARGETS)
  OBJECTS = $(FIXEDLIBOBJECTS) $(FIXEDOBJECTS)

  EXTRALIBS = -L./ -loctave_fixed

  MY_SH_LDFLAGS = $(shell $(MKOCTFILE) -p SH_LDFLAGS) \
	-Wl,--out-implib=$(FIXEDLIBTARGET).a
endif

ifeq ($(MAKECMDGOALS),all)
  DEPENDS = $(FIXEDDEPENDS)
endif
ifeq ($(MAKECMDGOALS),)
  DEPENDS = $(FIXEDDEPENDS)
endif

DELETES = $(OBJECTS) $(FIXEDDEPENDS) $(TARGETS) $(FIXEDLIBTARGET).a \
	$(FIXEDVERTARGET) core octave-core *~ *.d-t int/fixed.o int/fixed.d \
	int/fixed.d-t

DEFINES = -DOCTAVE_FORGE $(HAVE_DO_FORTRAN_INDEXING) \
	$(HAVE_PROPAGATE_EMPTY_MATRICES) \
	$(HAVE_OK_TO_LOSE_IMAGINARY_PART) \
	$(HAVE_ND_ARRAYS) $(TYPEID_HAS_CLASS) \
	$(CLASS_HAS_LOAD_SAVE) $(HAVE_6ARG_MX_ND_RED)
MOFLAGS =

.PHONY: all clean count $(SUBDIRS)
.SUFFIXES:

all : $(FIXEDVERTARGET) $(DEPENDS) $(OBJECTS) $(TARGETS) $(SUBDIRS)

ifndef OCTAVE_FORGE
install :
	@echo "Where exactly do you want me to install to!!!"
else
ifeq (,$(findstring cygwin,$(canonical_host_type)))
install : $(SUBDIRS)
	@$(INSTALL) -d $(MPATH)/fixed
else
install : $(SUBDIRS)
	@$(INSTALL) -d $(MPATH)/fixed; \
	if test ! -e $(bindir)/liboctave.dll ; then \
	  echo "****** WARNING: $(FIXEDLIBTARGET) not correctly installed."; \
	  echo "****** To ensure correct operation $(FIXEDLIBTARGET) should"; \
	  echo "****** be in the same directory as liboctave.dll"; \
	fi; \
	$(INSTALL) $(FIXEDLIBTARGET) $(bindir); \
	if test ! -e $(libdir)/liboctave.dll.a ; then \
	  echo "****** WARNING: $(FIXEDLIBTARGET).a not correctly installed"; \
	  echo "****** To ensure correct operation $(FIXEDLIBTARGET).a"; \
	  echo "****** should be in the same directory as liboctave.dll.a"; \
	fi; \
	$(INSTALL) $(FIXEDLIBTARGET).a $(libdir);

$(FIXEDLIBTARGET): $(FIXEDLIBDEPENDS) $(FIXEDLIBOBJECTS) 
	@echo "Linking $@"; \
	$(RM) -f $@; \
	SH_LDFLAGS="$(MY_SH_LDFLAGS)" $(MKOCTFILE) -v -o $@ $(FIXEDLIBOBJECTS)
endif
endif

$(FIXEDTARGET) : $(DEPENDS) $(FIXEDOBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(FIXEDOBJECTS) $(EXTRALIBS) -o $@

$(FIXEDVERTARGET) :
	@echo "Creating $@"; $(RM) -f $@; \
	echo "#define OCTAVEFIXEDVERSION \"$(OCTAVEFIXEDVERSION)\"" > $@

$(FIXEDLINKTARGETS) :
	@echo "Symbolic linking $@ to $(FIXEDTARGET)"; \
	$(RM) -f $@ ; \
	$(LN_S) $(FIXEDTARGET) $@

ifneq (,$(DEPENDS))
  include $(DEPENDS)
endif

$(SUBDIRS) :
	@if test -z "$(MAKECMDGOALS)" ; then \
	    cd $@ && $(MAKE) ; \
	elif grep -q "^$(MAKECMDGOALS) *[:]" $@/Makefile ; then \
	    cd $@ && $(MAKE) $(MAKECMDGOALS) ; \
	fi

fixed-int.d : int/fixed.cc
	@echo "Depending $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -M int/fixed.cc; \
	$(LN_S) $(patsubst %.cc,%.d,$<) $@

fixed-int.o : int/fixed.cc
	@echo "Compiling $@ from $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -c $<; \
	$(RM) -f $@ ; \
	$(LN_S) $(patsubst %.cc,%.o,$<) $@

%.d: %.cc
	@echo "Depending $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -M $<

%.o:%.cc
	@echo "Compiling $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -c $< 

clean: $(SUBDIRS)
	@echo "Cleaning..."; \
	$(RM) -f $(DELETES)

realclean: $(SUBDIRS)
	@echo "Cleaning..."; \
	$(RM) -f $(DELETES)

dist: $(SUBDIRS)

count: $(SUBDIRS)
	wc *{.cc,.h,.m} int/*.{cc,h}
