# Makefile for coda

outputdir:=./out
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

htmlimages=oct/matpow.png
pdfimages=oct/matpow.eps

.phony: all
all: html pdf targz

.phony: check
check: $(src)
	grep --line-number $$'\t' $(src) | cat --show-tabs
	checkXML coda.sgml

.phony: clean
clean:
	$(RM) index.sgml
	cd $(outputdir) && $(RM) *.html *.ps HTML.index matpow.png
	cd $(outputdir) && $(RM) coda.{out,tex,dvi,log,aux,ps.gz,pdf}
	cd $(outputdir) && $(RM) *.tar.gz
	rmdir $(outputdir) coda coda.junk

.phony: distclean
distclean: clean
	rm -f *~ *.bak core

.phony: www-install
www-install: all
	cd $(outputdir) && install -m 644 -p *.html coda.ps.gz coda.pdf coda-sgml.tar.gz /site/wwwroot/octave/coda

.phony: html
html: $(outputdir)/index.html $(outputdir)/matpow.png

.phony: ps
ps: $(outputdir)/coda.ps.gz

.phony: pdf
pdf: $(outputdir)/coda.pdf

.phony: targz
targz: $(outputdir)/coda-sgml.tar.gz

$(outputdir)/coda-sgml.tar.gz: $(src) $(htmlimages) Makefile
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
            rm $$f.bak; \
        done

$(outputdir)/coda.ps: $(src) index.sgml
	docbook2tex coda.sgml
	cd $(outputdir) && \
	    $(RM) coda.tex ; mv ../coda.tex . ; \
	    jadetex coda.tex ; jadetex coda.tex ; jadetex coda.tex ; \
	    dvips -D 600 -Z -o coda.ps coda.dvi

$(outputdir)/coda.ps.gz: $(outputdir)/coda.ps

$(outputdir)/coda.pdf: $(src) index.sgml
	-docbook2pdf -o $(outputdir) coda.sgml >/dev/null 2>&1
	docbook2pdf -o $(outputdir) coda.sgml

$(outputdir)/matpow.png: oct/matpow.png
	cp $< $@

#	cd $(outputdir) && \
#	    gs -q -r600 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
#                -sOutputFile=coda.pdf coda.ps

%.gz: %
	gzip --best --stdout $< > $@


