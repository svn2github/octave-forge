sinclude ../../../Makeconf

# "make dist" clears the MKDOC, etc variables. Fill them in if needed
ifeq ($(MKDOC),)
MKDOC = ../../../admin/mkdoc
MKTEXI = ../../../admin/mktexi
MAKEINFO = makeinfo --no-split
TEXI2DVI = texi2dvi --clean
DVIPS = dvips
endif

FIXEDVERTARGET = fixedversion.txi
INFODOC = fixed.info
PSDOC = fixed.ps
DOCS = $(INFODOC) $(PSDOC)
DOCSTRINGS = DOCSTRINGS
INDEX = ../INDEX
TMPDELETES = *.log *.dvi $(DOCSTRINGS) $(FIXEDVERTARGET) fixed.texi *~
DELETES = *.ps *.pdf *.info $(DOCS) *.html

all : $(INFODOC) $(PSDOC)

ifndef OCTAVE_FORGE
install :
	@echo "Where exactly do you want me to install to!!!"
else
install : 
	@$(INSTALL) -d $(MPATH)/fixed; \
	if test "x$(MAKEINFO)" != "x"; then \
	  $(INSTALL_DATA) $(INFODOC) $(MPATH)/fixed ; \
	fi
endif

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
%.html : %.texi
	@if test "x$(TEXI2HTML)" != "x"; then \
	  echo "Making html $@"; \
	  $(TEXI2HTML) -I . -I ../../.. -expandinfo $< ; \
	  if test ! -e "$@"; then \
	    $(INSTALL_DATA) -f $(@:.html=_toc.html) $@ ; \
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
	$(RM) -f $(TMPDELETES)

realclean: clean
	@$(RM) -f $(DELETES)

dist: all

count:
	wc *.txi

