DOC=queueing
CHAPTERS=summary.texi installation.texi markovchains.texi singlestation.texi queueingnetworks.texi conf.texi ack.texi contributing.texi gpl.texi gettingstarted.texi
DISTFILES=README $(DOC).pdf $(DOC).html $(DOC).texi

.PHONY: clean

ALL: pdf html ../INSTALL

html: $(DOC).html

pdf: $(DOC).pdf

info: $(DOC).info

../INSTALL: installation.texi
	rm -f ../INSTALL	
	-$(MAKEINFO) -D INSTALLONLY \
	  --no-validate --no-headers --no-split --output ../INSTALL $<

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

dist: $(DOC).pdf $(DOC).html
	ln $(DISTFILES) ../`cat ../fname`/doc/

clean:
	\rm -f *.fns *.pdf *.aux *.log *.dvi *.out *.info *.html *.ky *.tp *.toc *.vr *.cp *.fn *.pg *.op *.au *.aus *.cps x.log *~ DOCSTRINGS $(CHAPTERS) ../INSTALL

distclean: clean

