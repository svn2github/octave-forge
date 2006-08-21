sinclude Makeconf

GALOISTARGET = gf.oct
GALOISSOURCES = galois.cc galois-def.cc galoisfield.cc gf.cc \
	      op-gm-gm.cc op-gm-m.cc op-gm-s.cc op-m-gm.cc op-s-gm.cc \
	      ov-galois.cc 
GALOISOBJECTS = $(patsubst %.cc,%.o,$(GALOISSOURCES))

GALOISDEPENDS = $(patsubst %.cc,%.d,$(GALOISSOURCES))
OTHERSOURCES = primpoly.cc isprimitive.cc _errcore.cc cyclpoly.cc cyclgen.cc \
                    syndtable.cc _gfweight.cc genqamdemod.cc
OTHERTARGETS = $(patsubst %.cc,%.oct,$(OTHERSOURCES))
OTHEROBJECTS = $(patsubst %.cc,%.o,$(OTHERSOURCES))
OTHERDEPENDS = $(patsubst %.cc,%.d,$(OTHERSOURCES))
##SUBDIRS = ../doc
SUBDIRS = 

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

.PHONY: all dist clean realclean count $(SUBDIRS)
.SUFFIXES:

all : $(DEPENDS) $(OTHERTARGETS) $(GALOISTARGET) $(SUBDIRS)

install : $(SUBDIRS)
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/comm

$(GALOISTARGET) : $(DEPENDS) $(GALOISOBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(GALOISOBJECTS) -o $@

ifneq (,$(DEPENDS))
  sinclude $(DEPENDS)
endif

$(SUBDIRS) :
	@if test -z "$(MAKECMDGOALS)" ; then \
	    cd $@ && $(MAKE) ; \
	elif grep -q "^$(MAKECMDGOALS) *[:]" $@/Makefile ; then \
	    cd $@ && $(MAKE) $(MAKECMDGOALS) ; \
	fi

%.oct : %.d %.o
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(@:.oct=.o) -o $@

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
	wc *{.cc,.h,.m,.txi}

