sinclude Makeconf

## Quote filename to prevent backslashes in Windows file names from
## disappearing.
HDF5_LIBS := $(shell grep "\#define OCTAVE_CONF_HDF5_LIBS" '$(shell $(MKOCTFILE) -p OCTINCLUDEDIR)/oct-conf.h' | sed 's/^.*LIBS //;s/"//g')

GALOISTARGET = gf.oct
GALOISSOURCES = galois.cc galois-def.cc galoisfield.cc gf.cc \
	      op-gm-gm.cc op-gm-m.cc op-gm-s.cc op-m-gm.cc op-s-gm.cc \
	      ov-galois.cc 
GALOISOBJECTS = $(patsubst %.cc,%.o,$(GALOISSOURCES))
GALOISHEADERS = galois.h galois-def.h galois-ops.h galoisfield.h ov-galois.h

OTHERSOURCES = primpoly.cc isprimitive.cc __errcore__.cc cyclpoly.cc \
                    cyclgen.cc syndtable.cc __gfweight__.cc genqamdemod.cc
OTHERTARGETS = $(patsubst %.cc,%.oct,$(OTHERSOURCES))

DEFINES = -DGALOIS_DISP_PRIVATES
MOFLAGS =

.PHONY: all dist clean realclean count
.SUFFIXES:

all : $(OTHERTARGETS) $(GALOISTARGET)

install :
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/comm

$(GALOISTARGET) : $(GALOISOBJECTS) 
	$(MKOCTFILE) $(MOFLAGS) $(GALOISOBJECTS) -o $@ $(HDF5_LIBS)

$(GALOISOBJECTS): $(GALOISHEADERS)

%.o:%.cc
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -c $< 

clean:
	$(RM) -f *.oct *.o core octave-core *~

realclean: clean
	$(RM) -f Makeconf config.log config.status

dist:

count:
	wc *{.cc,.h,.m,.txi}

