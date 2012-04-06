DOC=queueing
CHAPTERS=$(wildcard *.texi)
DISTFILES=README INSTALL $(DOC).pdf $(DOC).html $(DOC).texi $(CHAPTERS) $(wildcard demos/*.texi) $(wildcard help/*.texi)

.PHONY: clean dist

ALL: pdf html INSTALL

html: $(DOC).html

pdf: $(DOC).pdf

info: $(DOC).info

INSTALL: installation.texi
	-$(MAKEINFO) -D INSTALLONLY \
	  --no-validate --no-headers --no-split --output INSTALL $<

$(DOC).html: $(DOC).texi $(CHAPTERS) DEMOS HELP
	-$(MAKEINFO) --html --no-split $(DOC).texi

$(DOC).pdf: $(DOC).texi $(CHAPTERS) DEMOS HELP
	texi2pdf  -o $(DOC).pdf $(DOC).texi

$(DOC).info: $(DOC).texi $(CHAPTERS) DEMOS HELP
	-$(MAKEINFO) $(DOC).texi

DOCSTRINGS: $(wildcard ../inst/*.m)
	(cd ../scripts; ./mkdoc ../inst) > DOCSTRINGS || \rm -f DOCSTRINGS

DEMOS:
	cd demos && octave -p ../../inst/ -q ../grabdemo.m ../../inst/ && touch ../DEMOS

HELP:
	cd help && octave -p ../../inst/ -q ../grabhelp.m ../../inst/ && touch ../HELP

dist:
	ln $(DISTFILES) ../`cat ../fname`/doc/

clean:
	\rm -f *.fns *.pdf *.aux *.log *.dvi *.out *.info *.html *.ky *.tp *.toc *.vr *.cp *.fn *.pg *.op *.au *.aus *.cps x.log *~ demos/*.texi help/*.texi DOCSTRINGS DEMOS HELP $(CHAPTERS) INSTALL

distclean: clean

