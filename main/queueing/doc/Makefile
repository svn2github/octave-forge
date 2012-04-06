DOC=queueing
CHAPTERS=$(wildcard *.texi)
DISTFILES=README INSTALL $(DOC).pdf $(DOC).html $(DOC).texi $(CHAPTERS)
SUBDIRS=demos help

.PHONY: clean dist

ALL: pdf html INSTALL

html: $(DOC).html

pdf: $(DOC).pdf

info: $(DOC).info

INSTALL: installation.texi
	-$(MAKEINFO) -D INSTALLONLY \
	  --no-validate --no-headers --no-split --output INSTALL $<

$(DOC).html: $(DOC).texi $(CHAPTERS) demos/DONE help/DONE
	-$(MAKEINFO) --html --no-split $(DOC).texi

$(DOC).pdf: $(DOC).texi $(CHAPTERS) demos/DONE help/DONE
	texi2pdf  -o $(DOC).pdf $(DOC).texi

$(DOC).info: $(DOC).texi $(CHAPTERS) demos/DONE help/DONE
	-$(MAKEINFO) $(DOC).texi

demos/DONE:
	$(MAKE) -C demos

help/DONE:
	$(MAKE) -C help

dist:
	ln $(DISTFILES) ../`cat ../fname`/doc/

clean:
	for d in $(SUBDIRS); do \
		$(MAKE) -C $$d $(MAKECMDGOALS); \
	done
	\rm -f *.fns *.pdf *.aux *.log *.dvi *.out *.info *.html *.ky *.tp *.toc *.vr *.cp *.fn *.pg *.op *.au *.aus *.cps x.log *~ DOCSTRINGS DEMOS HELP INSTALL

distclean: clean
	for d in $(SUBDIRS); do \
		$(MAKE) -C $$d $(MAKECMDGOALS); \
	done

