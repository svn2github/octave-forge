sinclude ../../../Makeconf

INFODOC = comms.info
PSDOC = $(patsubst %.info,%.ps,$(INFODOC))
TEXIDOC = $(patsubst %.info,%.texi,$(INFODOC))
DOCS = $(INFODOC) $(PSDOC)
DOCSTRINGS = DOCSTRINGS
INDEX = ../INDEX
TMPDELETES = *.log *.dvi $(DOCSTRINGS) $(TEXIDOC) *~
DELETES = *.ps *.pdf *.info $(DOCS) *.html

all : $(INFODOC) $(PSDOC)

install : 
	@$(INSTALL) -d $(MPATH)/comm; \
	if test "x$(MAKEINFO)" != "x"; then \
	  $(INSTALL_DATA) $(INFODOC) $(MPATH)/comm ; \
	fi

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
	$(RM) -f $(TMPDELETES)

realclean: clean
	@$(RM) -f $(DELETES)

count:
	wc *.txi

