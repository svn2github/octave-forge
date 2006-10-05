# Makefile for coda

outputdir:=out
dbflags:=-o $(outputdir) 
#-V %root-filename%=coda
autoidx:=$(outputdir)/HTML.index # Defined in "dbparam.dsl"
coidxflags:=-g -s 'Symbols'
coidx:=perl /usr/bin/collateindex.pl
tidyflags:=--wrap 79 --tidy-mark false

src_appendices=examples gnufdl gnugpl
src_oct=advanced oct quickref tut-basic tut-interm tut-intro tutorial
src_standalone=standalone
src_base=coda bibliography
src=$(src_appendices:%=appendices/%.sgml) $(src_oct:%=oct/%.sgml) \
	$(src_standalone:%=standalone/%.sgml) $(src_base:%=%.sgml)

htmlimages=$(outputdir)/matpow.png
pdfimages=$(outputdir)/matpow.eps

.phony: all
all: pdf html

.phony: check
check: $(src)
	grep --line-number $$'\t' $(src) | cat --show-tabs
	checkXML coda.sgml

.phony: clean
clean:
	$(RM) index.sgml
	cd $(outputdir) && $(RM) *.html *.ps HTML.index
	cd $(outputdir) && $(RM) coda.{out,tex,dvi,log,aux,ps.gz,pdf}
	cd $(outputdir) && $(RM) *.tar.gz
	$(RM) -fr coda coda.junk

.phony: distclean
distclean: clean
	$(RM) *~ *.bak core

.phony: www-dist
www-dist: html pdf dist
	$(RM) $(outputdir)/coda/*
	install -d $(outputdir)/coda
	cd $(outputdir) && install -m 644 -p *.html *.png coda.pdf coda-sgml.tar.gz coda/
	cd $(outputdir) && tar czf coda-www.tar.gz coda
	rm -rf $(outputdir)/coda


.phony: html
html: $(outputdir)/matpow.png $(outputdir)/index.html 

.phony: ps
ps: $(outputdir)/coda.ps.gz

.phony: pdf
pdf: $(outputdir)/coda.pdf

.phony: dist
dist: $(outputdir)/coda-sgml.tar.gz

$(outputdir)/coda-sgml.tar.gz: $(src) $(htmlimages) $(pdfimages) Makefile
	tar czf $@ $^

index.sgml: $(src)
	-docbook2html $(dbflags) -V html-index coda.sgml
	test \! -f $(autoidx) && touch $(autoidx); true
	$(coidx) $(coidxflags) $(autoidx) > index.sgml

$(outputdir)/index.html: $(src) index.sgml
	-docbook2html $(dbflags) coda.sgml
	cd $(outputdir) && tidy -modify $(tidyflags) *.html 2>/dev/null; true
	cd $(outputdir) && \
        for f in *.html; do \
            mv $$f $$f.bak; \
            sed -e 's!FIXME:!<b class="fixme">FIXME:</b>!i' \
                -e 's/&#13; *//g' < $${f}.bak > $$f; \
            $(RM) $$f.bak; \
        done

$(outputdir)/coda.ps: $(src) index.sgml $(pdfimages)
	docbook2tex coda.sgml
	cd $(outputdir) && \
	    $(RM) coda.tex ; mv ../coda.tex . ; \
	    jadetex coda.tex ; jadetex coda.tex ; jadetex coda.tex ; \
	    dvips -D 600 -Z -o coda.ps coda.dvi

$(outputdir)/coda.ps.gz: $(outputdir)/coda.ps

## Work around faulty Mandriva 2006 sgml -> tex mangle for muticol tables
## by calling three times in a single shell. The use of "make -k" ensures
## that the error here will be bypassed.
$(outputdir)/coda.pdf: $(src) index.sgml $(pdfimages)
	docbook2pdf -o $(outputdir) coda.sgml >/dev/null 2>&1 ; \
	docbook2pdf -o $(outputdir) coda.sgml >/dev/null 2>&1 ; \
	docbook2pdf -o $(outputdir) coda.sgml

#	cd $(outputdir) && \
#	    gs -q -r600 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
#                -sOutputFile=coda.pdf coda.ps

%.gz: %
	gzip --best --stdout $< > $@


