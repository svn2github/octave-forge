sinclude ../../Makeconf

GALOISTARGET = gf.oct
GALOISSOURCES = galois.cc galois-def.cc galoisfield.cc gf.cc op-fil-gm.cc \
	      op-gm-gm.cc op-gm-m.cc op-gm-s.cc op-m-gm.cc op-s-gm.cc \
	      ov-galois.cc 
GALOISOBJECTS = $(patsubst %.cc,%.o,$(GALOISSOURCES))
GALOISLINKTARGETS = isgalois.oct gdiag.oct greshape.oct gprod.oct gsum.oct \
                    gsumsq.oct gsqrt.oct glog.oct gexp.oct gfilter.oct \
                    glu.oct ginv.oct ginverse.oct gdet.oct grank.oct \
                    rsenc.oct rsdec.oct bchenco.oct bchdeco.oct

GALOISDEPENDS = $(patsubst %.cc,%.d,$(GALOISSOURCES))
OTHERSOURCES = primpoly.cc isprimitive.cc _errcore.cc cyclpoly.cc cyclgen.cc \
                    syndtable.cc _gfweight.cc
OTHERTARGETS = $(patsubst %.cc,%.oct,$(OTHERSOURCES))
OTHEROBJECTS = $(patsubst %.cc,%.o,$(OTHERSOURCES))
OTHERDEPENDS = $(patsubst %.cc,%.d,$(OTHERSOURCES))
SUBDIRS = doc

TARGETS = $(GALOISTARGET) $(GALOISLINKTARGETS) $(OTHERTARGETS)
OBJECTS = $(GALOISOBJECTS) $(OTHEROBJECTS)
ifeq ($(MAKECMDGOALS),all)
DEPENDS = $(GALOISDEPENDS) $(OTHERDEPENDS)
endif
ifeq ($(MAKECMDGOALS),)
DEPENDS = $(GALOISDEPENDS) $(OTHERDEPENDS)
endif

DELETES = $(OBJECTS) $(GALOISDEPENDS) $(OTHERDPENDS) *~ $(TARGETS) core octave-core

DEFINES = -DGALOIS_DISP_PRIVATES $(HAVE_DO_FORTRAN_INDEXING) $(HAVE_PROPAGATE_EMPTY_MATRICES) $(HAVE_ND_ARRAYS) $(TYPEID_HAS_CLASS) $(CLASS_HAS_LOAD_SAVE) $(HAVE_OCTAVE_CONCAT)
MOFLAGS =

.PHONY: all dist clean realclean count $(SUBDIRS)
.SUFFIXES:

all : $(DEPENDS) $(OTHERTARGETS) $(GALOISTARGET) $(GALOISLINKTARGETS) $(SUBDIRS)

install : $(SUBDIRS)
	@$(INSTALL) -d $(MPATH)/comm

$(GALOISTARGET) : $(DEPENDS) $(GALOISOBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(GALOISOBJECTS) -o $@

$(GALOISLINKTARGETS) :
	@echo "Symbolic linking $@"; $(RM) $@ ; \
	$(LN_S) $(GALOISTARGET) $@

ifneq (,$(DEPENDS))
  include $(DEPENDS)
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

