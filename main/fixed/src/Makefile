sinclude Makeconf

FIXEDVERTARGET = fixedversion.h
FIXEDTARGET = fixed.oct 

ifeq (,$(findstring cygwin,$(canonical_host_type)))
 ifeq (,$(findstring mingw,$(canonical_host_type)))
   OCT_INCLUDES_LIB = 1
  endif
endif

ifeq (1,$(OCT_INCLUDES_LIB))
  FIXEDSOURCES = fixedColVector.cc fixedRowVector.cc \
	fixedMatrix.cc fixedComplex.cc fixedCColVector.cc fixedCRowVector.cc \
	fixedCMatrix.cc Array-f.cc fixed-conv.cc ov-fixed.cc ov-fixed-mat.cc \
	fixedNDArray.cc fixedCNDArray.cc \
	ov-fixed-complex.cc ov-fixed-cx-mat.cc \
	op-fs-fs.cc   op-fs-fm.cc   op-fm-fs.cc   op-fm-fm.cc \
	op-fs-fcs.cc  op-fs-fcm.cc  op-fm-fcs.cc  op-fm-fcm.cc \
	op-fcs-fs.cc  op-fcs-fm.cc  op-fcm-fs.cc  op-fcm-fm.cc \
	op-fcs-fcs.cc op-fcs-fcm.cc op-fcm-fcs.cc op-fcm-fcm.cc \
	fixed-var.cc fixed.cc
  FIXEDOBJECTS = fixed-int.o $(patsubst %.cc,%.o,$(FIXEDSOURCES))
  FIXEDDEPENDS = fixed-int.d $(patsubst %.cc,%.d,$(FIXEDSOURCES))

  TARGETS = $(FIXEDTARGET)
  OBJECTS = $(FIXEDOBJECTS)

  EXTRALIBS =
else
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
	fixed-var.cc 
  FIXEDLIBOBJECTS = fixed-int.o $(patsubst %.cc,%.o,$(FIXEDLIBSOURCES))
  FIXEDLIBDEPENDS = fixed-int.d $(patsubst %.cc,%.d,$(FIXEDLIBSOURCES))

  FIXEDSOURCES = fixed.cc
  FIXEDOBJECTS = $(patsubst %.cc,%.o,$(FIXEDSOURCES))
  FIXEDDEPENDS = $(FIXEDLIBDEPENDS) $(patsubst %.cc,%.d,$(FIXEDSOURCES))

  TARGETS = $(FIXEDLIBTARGET) $(FIXEDTARGET)
  OBJECTS = $(FIXEDLIBOBJECTS) $(FIXEDOBJECTS)

  EXTRALIBS = -L./ -loctave_fixed

  # The name of this flag changed in version 2.1.54. Use both versions
  # so that one of them will work.
  MY_SH_LDFLAGS = $(shell $(MKOCTFILE) -p SH_LDFLAGS) \
	-Wl,--out-implib=$(FIXEDLIBTARGET).a
  MY_DL_LDFLAGS = $(shell $(MKOCTFILE) -p DL_LDFLAGS) \
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
	int/fixed.d-t FILES

DEFINES = -DOCTAVE_FORGE
MOFLAGS =

.PHONY: all clean count

.SUFFIXES:

.PRECIOUS: %.d %.o

all : $(TARGETS)
	@if [ -f FILES ]; then \
	  $(RM) -f FILES; \
	fi; \
	touch FILES; \
	for _f in $(TARGETS); do \
	  echo $$_f >> FILES; \
	done

ifndef OCTAVE_FORGE
install :
	@echo "Where exactly do you want me to install to!!!"
else
ifeq (1,$(OCT_INCLUDES_LIB))
install : 
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/fixed
else
install : 
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/fixed; \
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
	DL_LDFLAGS="$(MY_DL_LDFLAGS)" SH_LDFLAGS="$(MY_SH_LDFLAGS)" $(MKOCTFILE) -v -o $@ $(FIXEDLIBOBJECTS)
endif
endif

$(FIXEDTARGET) : $(DEPENDS) $(FIXEDOBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(FIXEDOBJECTS) $(EXTRALIBS) -o $@

$(FIXEDVERTARGET) :
	@echo "Creating $@"; $(RM) -f $@; \
	echo "#define OCTAVEFIXEDVERSION \"$(OCTAVEFIXEDVERSION)\"" > $@

ifneq (,$(DEPENDS))
  sinclude $(DEPENDS)
endif

fixed-int.d : int/fixed.cc
	@echo "Depending $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -M int/fixed.cc; \
	$(LN_S) $(patsubst %.cc,%.d,$<) $@

fixed-var.d : $(FIXEDVERTARGET)

fixed-int.o : int/fixed.cc fixed-int.d
	@echo "Compiling $@ from $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -c $<; \
	$(RM) -f $@ ; \
	$(LN_S) $(patsubst %.cc,%.o,$<) $@

%.d: %.cc
	@echo "Depending $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -M $<

%.o:%.cc
%.o:%.cc %.d
	@echo "Compiling $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -c $< 

clean:
	@echo "Cleaning..."; \
	$(RM) -f $(DELETES)

realclean:
	@echo "Cleaning..."; \
	$(RM) -f $(DELETES)

dist:

count:
	wc *{.cc,.h,.m} int/*.{cc,h}
