include ../../Makeconf

MAKEINFO = makeinfo --no-split
TEXI2DVI = texi2dvi --clean
DVIPS = dvips

GALOISTARGET = gf.oct
GALOISSOURCES = galois.cc galois-def.cc galoisfield.cc gf.cc op-fil-gm.cc \
	      op-gm-gm.cc op-gm-m.cc op-gm-s.cc op-m-gm.cc op-s-gm.cc \
	      ov-galois.cc 
GALOISOBJECTS = $(patsubst %.cc,%.o,$(GALOISSOURCES))
GALOISLINKTARGETS = isgalois.oct gdiag.oct greshape.oct gprod.oct gsum.oct \
                    gsumsq.oct glog.oct gexp.oct gfilter.oct glu.oct ginv.oct \
                    ginverse.oct gdet.oct grank.oct rsenc.oct rsdec.oct

GALOISDEPENDS = $(patsubst %.cc,%.d,$(GALOISSOURCES))
OTHERSOURCES = primpoly.cc isprimitive.cc _errcore.cc
OTHERTARGETS = $(patsubst %.cc,%.oct,$(OTHERSOURCES))
OTHEROBJECTS = $(patsubst %.cc,%.o,$(OTHERSOURCES))
OTHERDEPENDS = $(patsubst %.cc,%.d,$(OTHERSOURCES))
DOCS = comms.info comms.ps

TARGETS = $(GALOISTARGET) $(GALOISLINKTARGETS) $(OTHERTARGETS)
OBJECTS = $(GALOISOBJECTS) $(OTHEROBJECTS)
DEPENDS = $(GALOISDEPENDS) $(OTHERDEPENDS)

DELETES = $(OBJECTS) $(DEPENDS) *~ *.log *.dvi *.ps *.info $(TARGETS) $(DOCS) DOCSTRINGS comms.texi core octave-core

DEFINES = -DGALOIS_DISP_PRIVATES
MOFLAGS =

# Cancel this rule because I want to use my own to create depend files
%.oct : %.cc

.SUFFIXES:

all : $(OTHERTARGETS) $(GALOISTARGET) $(GALOISLINKTARGETS) $(DOCS)

$(GALOISTARGET) : $(GALOISDEPENDS) $(GALOISOBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(GALOISOBJECTS) -o $@

$(GALOISLINKTARGETS) :
	@echo "Symbolic linking $@"; $(RM) $@ ; \
	$(LN_S) $(GALOISTARGET) $@

SUFFIXES:
SUFFIXES: .cc .oct .o .h

ifneq (,$(wildcard *.d))
include $(wildcard *.d)
endif

%.oct : %.d %.o
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(@:.oct=.o) -o $@

%.d: %.cc
	@echo "Depending $<"; \
	$(MKOCTFILE) $(MOFLAGS) -M $<

%.o:%.cc
	@echo "Compiling $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -c $< 

%.dvi : %.texi
	@echo "Making dvi $@"; \
	$(TEXI2DVI) $< ; \

%.ps : %.dvi
	@echo "Making postscript $@"; \
	$(DVIPS) -o $@ $< ; \

%.info : %.texi
	@echo "Making info $@"; \
	$(MAKEINFO) $< 

%.texi : %.txi
	@echo "Making texinfo $@"; \
	$(RM) -f $@; \
	./mkdoc > DOCSTRINGS; \
	./mktexi $< DOCSTRINGS > $@ 

clean:
	@echo "Cleaning..."; \
	 $(RM) -f $(DELETES)

count:
	wc *{.cc,.h,.m,.txi}

