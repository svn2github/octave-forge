sinclude Makeconf

HDF5_LIBS := $(shell  grep "\#define OCTAVE_CONF_HDF5_LIBS"  $(shell  $(MKOCTFILE) -p OCTINCLUDEDIR)/oct-conf.h | sed 's/^.*LIBS //;s/"//g'  )

GALOISTARGET = gf.oct
GALOISSOURCES = galois.cc galois-def.cc galoisfield.cc gf.cc \
	      op-gm-gm.cc op-gm-m.cc op-gm-s.cc op-m-gm.cc op-s-gm.cc \
	      ov-galois.cc 
GALOISOBJECTS = $(patsubst %.cc,%.o,$(GALOISSOURCES))

GALOISDEPENDS = $(patsubst %.cc,%.d,$(GALOISSOURCES))
OTHERSOURCES = primpoly.cc isprimitive.cc __errcore__.cc cyclpoly.cc \
                    cyclgen.cc syndtable.cc __gfweight__.cc genqamdemod.cc
OTHERTARGETS = $(patsubst %.cc,%.oct,$(OTHERSOURCES))
OTHEROBJECTS = $(patsubst %.cc,%.o,$(OTHERSOURCES))
OTHERDEPENDS = $(patsubst %.cc,%.d,$(OTHERSOURCES))

TARGETS = $(GALOISTARGET) $(OTHERTARGETS)
SOURCES = $(GALOISSOURCES) $(OTHERSOURCES)
OBJECTS = $(GALOISOBJECTS) $(OTHEROBJECTS)
ifeq ($(MAKECMDGOALS),all)
DEPENDS = $(GALOISDEPENDS) $(OTHERDEPENDS)
endif
ifeq ($(MAKECMDGOALS),)
DEPENDS = $(GALOISDEPENDS) $(OTHERDEPENDS)
endif

DELETES = $(OBJECTS) $(GALOISDEPENDS) $(OTHERDEPENDS) *~ $(TARGETS) core octave-core

DEFINES = -DGALOIS_DISP_PRIVATES
MOFLAGS =

.PHONY: all dist clean realclean count
.SUFFIXES:

all : $(DEPENDS) $(OTHERTARGETS) $(GALOISTARGET)

install :
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/comm

$(GALOISTARGET) : $(DEPENDS) $(GALOISOBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(GALOISOBJECTS) -o $@ $(HDF5_LIBS)

ifneq (,$(DEPENDS))
  sinclude $(DEPENDS)
endif

%.oct : %.d %.o
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(@:.oct=.o) -o $@ $(HDF5_LIBS)

%.d: %.cc
	@echo "Depending $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -M $<

%.o:%.cc
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
	wc *{.cc,.h,.m,.txi}

