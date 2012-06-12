sinclude Makeconf

ifndef OCTAVE_FORGE
MKOCTFILE = mkoctfile
endif

ifndef LAPACK_LIBS
LAPACK_LIBS := $(shell $(MKOCTFILE) -p LAPACK_LIBS)
endif
ifndef BLAS_LIBS
BLAS_LIBS := $(shell $(MKOCTFILE) -p BLAS_LIBS)
endif
LFLAGS := $(shell $(MKOCTFILE) -p LFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS)
export LFLAGS

DEFINES = -DHAVE_CONFIG_H -Wall
GSVD_OBJECTS = gsvd.o dbleGSVD.o CmplxGSVD.o 
GSVD_TARGET = gsvd.oct
GSVD_TEST = gsvd
GSVD_DEPENDS = gsvd.d dbleGSVD.d CmplxGSVD.d

OBJECTS = $(GSVD_OBJECTS) 
TARGETS = $(GSVD_TARGET) 
DEPENDS = $(GSVD_DEPENDS) 

.PHONY: all test clean count

.SUFFIXES:

.PRECIOUS: %.d %.o

all : $(TARGETS) pgmres.oct

$(GSVD_TARGET) : $(GSVD_DEPENDS) $(GSVD_OBJECTS)
	$(MKOCTFILE) $(DEFINES) $(GSVD_OBJECTS) -o $@ ${LAPACK_LIBS}

$(GSVD_TEST) : $(GSVD_TARGET)

ifneq (,$(DEPENDS))
  sinclude $(DEPENDS)
endif

%.d:%.cc
	$(MKOCTFILE) $(DEFINES) -M $<

%.o:%.cc
%.o:%.cc %.d
	$(MKOCTFILE) $(DEFINES) -c $<

%.o:%.f
	$(MKOCTFILE) $(DEFINES) -c $<
%.oct:%.o
	$(MKOCTFILE) $(DEFINES) $< -o $@

%.oct: %.cc
	mkoctfile $(DEFINES) $< -o $@ ${LAPACK_LIBS}

.phony: test
test: $(GSVD_TEST)
	for i in $^; do echo "test $$i"; done | octave --silent

clean: 
	rm -f $(TARGETS) $(DEPENDS) $(OBJECTS) octave-core

count:
	wc *{.cc,.h,.f}
