sinclude ../../../Makeconf

all: ad.pdf


ifeq (,$(TEXI2PDF))
%.pdf : %.dvi
	@if test "x$(TEXI2DVI)" != "x" && test "x$(DVIPDF)" != "x"; then \
	  echo "Making pdf $@"; \
	  $(DVIPDF) $< ; \
	fi
else
%.pdf : %.texi
	@if test "x$(TEXI2PDF)" != "x"; then \
	  echo "Making pdf $@"; \
	  TEXINPUTS="./:../../..:$(TEXINPUTS):"; \
          export TEXINPUTS; \
	  $(TEXI2PDF) $< ; \
	fi
endif

%.dvi : %.texi
	@if test "x$(TEXI2DVI)" != "x"; then \
	  echo "Making dvi $@"; \
	  TEXINPUTS="./:$../../..:$(TEXINPUTS):"; \
          export TEXINPUTS; \
	  $(TEXI2DVI) $< ; \
	fi

clean:
	@echo "Cleaning..."; \
	$(RM) -fr *.log *.dvi *.pdf *~
