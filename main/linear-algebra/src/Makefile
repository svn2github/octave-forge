sinclude Makeconf

ifndef OCTAVE_FORGE
MKOCTFILE = mkoctfile
endif

DEFINES = -DHAVE_CONFIG_H
GSVD_OBJECTS = gsvd.o dbleGSVD.o CmplxGSVD.o 
GSVD_TARGET = gsvd.oct
GSVD_TEST = gsvd
GSVD_DEPENDS = gsvd.d dbleGSVD.d CmplxGSVD.d

OTHER_OBJECTS = mgorth.o
OTHER_TARGETS = $(patsubst %.o,%.oct,$(OTHER_OBJECTS))
OTHER_DEPENDS = $(patsubst %.o,%.d,$(OTHER_OBJECTS))

OBJECTS = $(OTHER_OBJECTS) $(GSVD_OBJECTS) 
TARGETS = $(OTHER_TARGETS) $(GSVD_TARGET) 
DEPENDS = $(OTHER_DEPENDS) $(GSVD_DEPENDS) 

.PHONY: all test clean count

.SUFFIXES:

.PRECIOUS: %.d %.o

all : $(TARGETS)

$(GSVD_TARGET) : $(GSVD_DEPENDS) $(GSVD_OBJECTS)
	$(MKOCTFILE) $(DEFINES) $(GSVD_OBJECTS) -o $@

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

.phony: test
test: $(GSVD_TEST)
	for i in $^; do echo "test $$i"; done | octave --silent

clean: 
	rm -f $(TARGETS) $(DEPENDS) $(OBJECTS) octave-core

count:
	wc *{.cc,.h,.f}
