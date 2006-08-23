sinclude ../../../Makeconf

# Fill in the variables as it makes testing the package manager easier
ifeq ($(MKDOC),)
MKDOC = ../../../admin/mkdoc
MKTEXI = ../../../admin/mktexi
MAKEINFO = makeinfo --no-split
TEXI2DVI = texi2dvi --clean
DVIPS = dvips
endif

INFODOC = comms.info
PSDOC = $(patsubst %.info,%.ps,$(INFODOC))
PDFDOC = $(patsubst %.info,%.pdf,$(INFODOC))
TEXIDOC = $(patsubst %.info,%.texi,$(INFODOC))
DOCS = $(INFODOC) $(PDFDOC) 
DOCSTRINGS = DOCSTRINGS
INDEX = ../INDEX
TMPDELETES = *.log *.dvi $(DOCSTRINGS) $(TEXIDOC) *~
DELETES = $(TMPDELETES) *.ps *.pdf *.info $(DOCS) *.html

all : $(PDFDOC) ../inst/doc.info

../inst/doc.info : $(INFODOC)
	cp -f $(INFODOC) ../inst/doc.info

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
%.html : %.texi
	@if test "x$(TEXI2HTML)" != "x"; then \
	  echo "Making html $@"; \
	  $(TEXI2HTML) -I . -I ../../.. -expandinfo $< ; \
	  if test ! -e "$@"; then \
	    $(INSTALL_DATA) -f $(@:.html=_toc.html) $@ ; \
	  fi \
	fi

%.texi : %.txi
	@echo "Making texinfo $@"; \
	$(RM) -f $(DOCSTRINGS); \
	$(MKDOC) ../ > $(DOCSTRINGS); \
	$(MKTEXI) $< $(DOCSTRINGS) $(INDEX) > $@ ; \
	$(RM) -f $(DOCSTRINGS);

clean:
	@echo "Cleaning..."; \
	$(RM) -f $(DELETES)

dist: all

count:
	wc *.txi

