# Makefile for coda

outputdir:=./out
dbflags:=-V use-output-dir -V %output-dir%=$(outputdir) \
-V %root-filename%=coda
autoidx:=$(outputdir)/HTML.index # Defined in "dbparam.dsl"
coidxflags:=-g -s 'Symbols'
coidx:=perl /usr/share/sgml/docbkdsl/bin/collateindex.pl
tidyflags:=--wrap 79 --tidy-mark false

srcdirs:=appendices oct standalone
src:=$(wildcard *.sgml) $(foreach dir,$(srcdirs),$(wildcard $(dir)/*.sgml))


.phony: check
check:
	grep --line-number $$'\t' $(src) | cat --show-tabs
	xml-check coda.sgml

.phony: clean
clean:
	rm -f index.sgml
	cd $(outputdir) && rm -f *.html *.ps HTML.index 
	cd $(outputdir) && rm -f coda.{tex,dvi,log,aux,ps.gz,pdf}
	cd $(outputdir) && rm -f *.tar.gz

.phony: distclean
distclean: clean
	rm -f *~ *.bak core

.phony: www-install
www-install: all
	cd $(outputdir) && install -m 644 -p *.html coda.ps.gz coda.pdf coda-sgml.tar.gz /site/wwwroot/octave/coda

.phony: all
all: html pdf targz

.phony: html
html: subdirs $(outputdir)/coda.html

.phony: ps
ps: subdirs $(outputdir)/coda.ps.gz

.phony: pdf
pdf: subdirs $(outputdir)/coda.pdf

.phony: targz
targz: $(outputdir)/coda-sgml.tar.gz $(outputdir)/coda.ps.gz

.phony: subdirs
subdirs:
	for dir in $(srcdirs); do \
	    make --directory=$$dir; \
	done

$(outputdir)/coda-sgml.tar.gz: $(src) Makefile
	tar czf $@ $^

$(outputdir)/coda.html: $(src)
	@echo '===  Pass 1  ==='
	touch index.sgml; true
	db2html $(dbflags) -V html-index coda.sgml
	test \! -f $(autoidx) && touch $(autoidx); true
	$(coidx) $(coidxflags) $(autoidx) > index.sgml
	@echo '===  Pass 2  ==='
	db2html $(dbflags) coda.sgml
	cd $(outputdir) && tidy -modify $(tidyflags) *.html 2>/dev/null; true
	cd $(outputdir) && \
        for f in *.html; do \
            mv $$f $$f.bak; \
            sed -e 's!FIXME:!<b class="fixme">FIXME:</b>!i' \
                -e 's/&#13; *//g' < $${f}.bak > $$f; \
            rm $$f.bak; \
        done

$(outputdir)/coda.ps: $(src)
	db2tex coda.sgml
	cd $(outputdir) && \
	    cp ../coda.tex . ; jadetex coda.tex ; jadetex coda.tex ; \
	    dvips -D 600 -Z -o coda.ps coda.dvi

$(outputdir)/coda.ps.gz: $(outputdir)/coda.ps

$(outputdir)/coda.pdf: $(outputdir)/coda.ps
	cd $(outputdir) && \
	    gs -q -r600 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
                -sOutputFile=coda.pdf coda.ps

%.gz: %
	gzip --best --stdout $< > $@


