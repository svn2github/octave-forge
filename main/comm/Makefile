include ../../Makeconf

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

install : 
	@$(INSTALL) -d $(MPATH)/comm; \
	if test "x$(MAKEINFO)" != "x"; then \
	  $(INSTALL_DATA) $(INFODOC) $(MPATH)/comm ; \
	fi

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
	@if test "x$(TEXI2DVI)" != "x"; then \
	  echo "Making dvi $@"; \
	  $(TEXI2DVI) $< ; \
	fi

%.ps : %.dvi
	@if test "x$(TEXI2DVI)" != "x" && test "x$(DVIPS)" != "x"; then \
	  echo "Making postscript $@"; \
	  $(DVIPS) -o $@ $< ; \
	fi

%.pdf : %.dvi
	@if test "x$(TEXI2DVI)" != "x" && test "x$(DVIPDF)" != "x"; then \
	  echo "Making pdf $@"; \
	  $(DVIPDF) $< $@ ; \
	fi

%.info : %.texi
	@if test "x$(MAKEINFO)" != "x"; then \
	  echo "Making info $@"; \
	  $(MAKEINFO) $< ; \
	fi

%.html : %.texi
	@if test "x$(TEXI2HTML)" != "x"; then \
	  echo "Making html $@"; \
	  $(TEXI2HTML) $< ; \
	  $(MV) -f $(@:.html=_toc.html) $@ ; \
	fi

%.texi : %.txi
	@echo "Making texinfo $@"; \
	./mkdoc > $(DOCSTRINGS); \
	./mktexi $< $(DOCSTRINGS) INDEX > $@ ;

clean:
	@echo "Cleaning..."; \
	-$(RM) -f $(DELETES)

count:
	wc *{.cc,.h,.m,.txi}

