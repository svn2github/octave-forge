sinclude ../../../Makeconf

# Fill in the variables as it makes testing the package manager easier
ifeq ($(MKDOC),)
MKDOC = ../../../admin/mkdoc
MKTEXI = ../../../admin/mktexi
MAKEINFO = makeinfo --no-split
TEXI2DVI = texi2dvi --clean
DVIPS = dvips
LN_S = ln -s
endif

FIXEDVERTARGET = fixedversion.txi
INFODOC = fixed.info
PSDOC = $(patsubst %.info,%.ps,$(INFODOC))
PDFDOC = $(patsubst %.info,%.pdf,$(INFODOC))
TEXIDOC = $(patsubst %.info,%.texi,$(INFODOC))
DOCS = $(INFODOC) $(PDFDOC)
DOCSTRINGS = DOCSTRINGS
INDEX = ../INDEX
TMPDELETES = *.log *.dvi $(DOCSTRINGS) $(FIXEDVERTARGET) $(TEXIDOC) *~
DELETES = $(TMPDELETES) *.ps *.pdf *.info $(DOCS) *.html fixed/ html/

all : $(PDFDOC) ../inst/doc.info

../inst/doc.info : $(INFODOC)
	cp -f $(INFODOC) ../inst/doc.info

$(FIXEDVERTARGET) :
	@echo "Creating $@"; $(RM) -f $@; \
	echo "@set VERSION $(OCTAVEFIXEDVERSION)" > $@ 

%.dvi : %.texi
	@if test "x$(TEXI2DVI)" != "x"; then \
	  echo "Making dvi $@"; \
	  TEXINPUTS="./:$../../..:$(TEXINPUTS):"; \
          export TEXINPUTS; \
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
	  $(MAKEINFO) -I./ -I../../../ $< ; \
	fi

# Need a stupid copy of the TOC for older texi2html versions
# Newer texi2html place documentation in a sub-directory
%.html : %.texi
	@if test "x$(TEXI2HTML)" != "x"; then \
	  echo "Making html $@"; \
	  $(TEXI2HTML) -I . -I ../../.. -expandinfo $< ; \
	  if test ! -e "$(@:.html=_toc.html)"; then \
	    if test ! -e "fixed/$@"; then \
	      $(INSTALL_DATA) fixed/$(@:.html=_toc.html) fixed/$@ ; \
	    fi; \
	    $(LN_S) $@ fixed/index.html; \
	    mv fixed html; \
	    $(INSTALL_DATA) *.png html; \
	  else \
	    if test ! -e "$@"; then \
	      $(INSTALL_DATA) $(@:.html=_toc.html) $@ ; \
	    fi; \
	    if [ ! -e "html/" ]; then \
	      mkdir html; \
	    fi; \
	    $(INSTALL_DATA) *.png *.html html; \
	    $(LN_S) $@ html/index.html; \
	  fi \
	fi

%.texi : %.txi $(FIXEDVERTARGET) 
	@echo "Making texinfo $@"; \
	$(RM) -f $(DOCSTRINGS); \
	$(MKDOC) ../ > $(DOCSTRINGS); \
	$(MKTEXI) $< $(DOCSTRINGS) $(INDEX) > $@ ; \
	$(RM) -f $(DOCSTRINGS);

clean:
	@echo "Cleaning..."; \
	$(RM) -fr $(DELETES)

dist: all

count:
	wc *.txi

