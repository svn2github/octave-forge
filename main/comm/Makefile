include ../../Makeconf

MAKEINFO = makeinfo --no-split
TEXI2DVI = texi2dvi --clean
TEXI2HTML = texi2html -split_chapter -number
MV = /bin/mv
DVIPDF = dvipdf
DVIPS = dvips

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
INFODOC = comms.info
PSDOC = comms.ps
DOCSTRINGS = DOCSTRINGS

DOCS = $(INFODOC) $(PSDOC)
TARGETS = $(GALOISTARGET) $(GALOISLINKTARGETS) $(OTHERTARGETS)
OBJECTS = $(GALOISOBJECTS) $(OTHEROBJECTS)
DEPENDS = $(GALOISDEPENDS) $(OTHERDEPENDS)

DELETES = $(OBJECTS) $(DEPENDS) *~ *.log *.dvi *.ps *.pdf *.info $(TARGETS) $(DOCS) $(DOCSTRINGS) comms.texi core octave-core *.html

DEFINES = -DGALOIS_DISP_PRIVATES
MOFLAGS =

# Cancel this rule because I want to use my own to create depend files
%.oct : %.cc

.SUFFIXES:

all : $(OTHERTARGETS) $(GALOISTARGET) $(GALOISLINKTARGETS) $(DOCS)

install : $(INFODOC)
	$(INSTALL) -d $(MPATH)/comm
	$(INSTALL_DATA) $(INFODOC) $(MPATH)/comm/$(INFODOC)

$(GALOISTARGET) : $(GALOISDEPENDS) $(GALOISOBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(GALOISOBJECTS) -o $@

$(GALOISLINKTARGETS) :
	@echo "Symbolic linking $@"; $(RM) $@ ; \
	$(LN_S) $(GALOISTARGET) $@

SUFFIXES:
SUFFIXES: .cc .oct .o .h

ifneq (clean,$(MAKECMDGOALS))
  ifneq (,$(wildcard *.d))
    include $(wildcard *.d)
  endif
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
	$(TEXI2DVI) $< ;

%.ps : %.dvi
	@echo "Making postscript $@"; \
	$(DVIPS) -o $@ $< ;

%.pdf : %.dvi
	@echo "Making pdf $@"; \
	$(DVIPDF) -o $@ $< ;

%.info : %.texi
	@echo "Making info $@"; \
	$(MAKEINFO) $< 

%.html : %.texi
	@echo "Making html $@"; \
	$(TEXI2HTML) $< ; \
	$(MV) -f $(@:.html=_toc.html) $@

%.texi : %.txi
	@echo "Making texinfo $@"; \
	$(RM) -f $@; \
	./mkdoc > $(DOCSTRINGS); \
	./mktexi $< $(DOCSTRINGS) INDEX > $@ 

clean:
	@echo "Cleaning..."; \
	 $(RM) -f $(DELETES)

count:
	wc *{.cc,.h,.m,.txi}

