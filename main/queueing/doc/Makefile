DOC=queueing
CHAPTERS=$(patsubst %.txi, %.texi, $(wildcard *.txi))
FIGS=qn_open_single qn_closed_single qn_web_model qn_closed_multi web power qn_closed_multi_apl
FIGS_EPS=$(FIGS:%=%.eps)
FIGS_PDF=$(FIGS:%=%.pdf)
FIGS_PNG=$(FIGS:%=%.png)
DISTFILES=README INSTALL $(DOC).pdf $(DOC).html $(DOC).texi $(CHAPTERS)

.PHONY: clean dist

ALL: pdf html INSTALL

html: $(DOC).html

pdf: $(DOC).pdf

info: $(DOC).info

INSTALL: installation.texi
	-$(MAKEINFO) -D INSTALLONLY \
	  --no-validate --no-headers --no-split --output INSTALL $<

$(DOC).html: $(DOC).texi $(CHAPTERS) $(FIGS_PNG)
	-$(MAKEINFO) --html --no-split $(DOC).texi

$(DOC).pdf: $(DOC).texi $(CHAPTERS) $(FIGS_PDF)
	texi2pdf  -o $(DOC).pdf $(DOC).texi

$(DOC).info: $(DOC).texi $(CHAPTERS)
	-$(MAKEINFO) $(DOC).texi

%.texi: %.txi
	octave -p../inst/ -q munge-texi.m $< ../inst/ > $@

%.png: %.fig
	fig2dev -L png -m 3 $< $@

%.pdf: %.fig
	fig2dev -L pdf $< $@

%.eps: %.fig
	fig2dev -L eps $< $@

web.eps power.eps: demo_web.m
	octave -p../inst/ -q $<

%.pdf: %.eps
	epstopdf $<

%.png: %.eps
	convert -density 300 -background white -flatten $< $@

dist: $(DISTFILES)
	ln $(DISTFILES) ../`cat ../fname`/doc/

clean:
	\rm -f *.fns *.pdf *.aux *.log *.dvi *.out *.info *.html *.ky *.tp *.toc *.vr *.cp *.fn *.pg *.op *.au *.aus *.cps x.log *~ DOCSTRINGS INSTALL $(CHAPTERS) $(FIGS_PDF) $(FIGS_EPS) $(FIGS_PNG)

distclean: clean

