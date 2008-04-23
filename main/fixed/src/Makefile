sinclude Makeconf

FIXEDVERTARGET = fixedversion.h
FIXEDTARGET = fixed.oct 

DLLDEF =
ADD_FLAGS =
ifneq (,$(findstring cygwin,$(canonical_host_type)))
   DLLDEF = -DFIXED_DLL
   ADD_FLAGS = -Wl,--out-implib=libfixed.a
endif
ifneq (,$(findstring mingw,$(canonical_host_type)))
   DLLDEF = -DFIXED_DLL
   ADD_FLAGS = -Wl,--out-implib=libfixed.a
endif
ifneq (,$(findstring msdosmsvc,$(canonical_host_type)))
   DLLDEF = -DFIXED_DLL
endif

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

ifeq ($(MAKECMDGOALS),all)
  DEPENDS = $(FIXEDDEPENDS)
endif
ifeq ($(MAKECMDGOALS),)
  DEPENDS = $(FIXEDDEPENDS)
endif

DELETES = $(OBJECTS) $(FIXEDDEPENDS) $(TARGETS) $(FIXEDVERTARGET) \
	core octave-core *~ *.d-t int/fixed.o int/fixed.d \
	int/fixed.d-t FILES

DEFINES = -DOCTAVE_FORGE $(DLLDEF)
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
install : 
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/fixed

$(FIXEDOBJECTS) $(FIXEDDEPENDS): DEFINES := $(DEFINES) $(DLLDEF)
endif

$(FIXEDTARGET) : $(DEPENDS) $(FIXEDOBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(ADD_FLAGS) $(MOFLAGS) $(FIXEDOBJECTS) $(EXTRALIBS) -o $@

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
	$(RM) -f $(DELETES) Makeconf config.log config.status

dist:

count:
	wc *{.cc,.h,.m} int/*.{cc,h}
