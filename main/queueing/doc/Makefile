DOC=queueing
CHAPTERS=$(patsubst %.txi,%.texi,$(wildcard *.txi))
DISTFILES=README INSTALL $(DOC).pdf $(DOC).html

.PHONY: clean dist

ALL: pdf html INSTALL

html: $(DOC).html

pdf: $(DOC).pdf

info: $(DOC).info

INSTALL: installation.texi
	rm -f ../INSTALL	
	-$(MAKEINFO) -D INSTALLONLY \
	  --no-validate --no-headers --no-split --output INSTALL $<

$(DOC).html: $(DOC).texi $(CHAPTERS)
	-$(MAKEINFO) --html --no-split $(DOC).texi

$(DOC).pdf: $(DOC).texi $(CHAPTERS)
	texi2pdf  -o $(DOC).pdf $<

$(DOC).info: $(DOC).texi $(CHAPTERS)
	-$(MAKEINFO) $<

%.texi: %.txi DOCSTRINGS
	../scripts/munge-texi -d DOCSTRINGS < $< > $@

DOCSTRINGS: $(wildcard ../inst/*.m)
	(cd ../scripts; ./mkdoc ../inst) > DOCSTRINGS || \rm -f DOCSTRINGS

dist:
	ln $(DISTFILES) ../`cat ../fname`/doc/

clean:
	\rm -f *.fns *.pdf *.aux *.log *.dvi *.out *.info *.html *.ky *.tp *.toc *.vr *.cp *.fn *.pg *.op *.au *.aus *.cps x.log *~ DOCSTRINGS $(CHAPTERS) ../INSTALL

distclean: clean

