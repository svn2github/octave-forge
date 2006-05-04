sinclude ../../Makeconf

ifndef OCTAVE_FORGE
MKOCTFILE = mkoctfile
endif

DEFINES = -DHAVE_CONFIG_H
GSVD_OBJECTS = gsvd.o dbleGSVD.o CmplxGSVD.o 
GSVD_TARGET = gsvd.oct
OBJECTS = GramSchmidt.o $(GSVD_OBJECTS)
TARGETS = $(GSVD_TARGET) GramSchmidt.oct

MYDEPENDS = $(patsubst %.o,%.d,$(OBJECTS))

ifeq ($(MAKECMDGOALS),all)
  DEPENDS = $(MYDEPENDS)
endif
ifeq ($(MAKECMDGOALS),)
  DEPENDS = $(MYDEPENDS)
endif

.PHONY: all clean count

.SUFFIXES:

.PRECIOUS: %.d %.o

all : $(TARGETS)

$(GSVD_TARGET) : $(DEPENDS) $(GSVD_OBJECTS)
	$(MKOCTFILE) $(DEFINES) $(GSVD_OBJECTS) -o $@

ifneq (,$(DEPENDS))
  sinclude $(DEPENDS)
endif

%.d:%.cc
	$(MKOCTFILE) $(DEFINES) -M $<

%.o:%.cc
%.o:%.cc %.d
	$(MKOCTFILE) $(DEFINES) -c $<

clean: 
	rm -f $(TARGETS) $(MYDEPENDS) $(OBJECTS) *~ $(MYDEPENDS) octave-core

count:
	wc *{.cc,.h}
