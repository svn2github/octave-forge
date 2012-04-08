DOC=queueing
CHAPTERS=$(patsubst %.txi, %.texi, $(wildcard *.txi))
DISTFILES=README INSTALL $(DOC).pdf $(DOC).html $(DOC).texi $(CHAPTERS)

.PHONY: clean dist

ALL: pdf html INSTALL

html: $(DOC).html

pdf: $(DOC).pdf

info: $(DOC).info

INSTALL: installation.texi
	-$(MAKEINFO) -D INSTALLONLY \
	  --no-validate --no-headers --no-split --output INSTALL $<

$(DOC).html: $(DOC).texi $(CHAPTERS)
	-$(MAKEINFO) --html --no-split $(DOC).texi

$(DOC).pdf: $(DOC).texi $(CHAPTERS)
	texi2pdf  -o $(DOC).pdf $(DOC).texi

$(DOC).info: $(DOC).texi $(CHAPTERS)
	-$(MAKEINFO) $(DOC).texi

%.texi: %.txi
	octave -p../inst/ -q munge-texi.m $< ../inst/ > $@

dist: $(DISTFILES)
	ln $(DISTFILES) ../`cat ../fname`/doc/

clean:
	\rm -f *.fns *.pdf *.aux *.log *.dvi *.out *.info *.html *.ky *.tp *.toc *.vr *.cp *.fn *.pg *.op *.au *.aus *.cps x.log *~ DOCSTRINGS INSTALL $(CHAPTERS)

distclean: clean

