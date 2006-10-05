sinclude ../../../Makeconf

TEX = mintoolkit.tex  optim-mini-howto-2.tex
PDF = $(patsubst %.tex,%.pdf,$(TEX))
HTML = $(patsubst %.tex,%/index.html,$(TEX))

all : $(PDF) html

.PHONY: html
html : $(HTML)
	if [ -e "html" ]; then \
	  rm -fr html; \
	fi; \
	mkdir html; \
	$(INSTALL_DATA) -d mintoolkit html; \
	$(INSTALL_DATA) -d optim-mini-howto-2 html; \
	echo '<html><body>' > html/index.html; \
	echo '<p><a href="minitoolkit/index.html">minitoolkit</a></p>' >> html/index.html; \
	echo '<p><a href="optim-mini-howto-2/index.html">optim-mini-howto-2</a></p>' >> html/index.html; \
	echo '</body></html>' >> html/index.html

%.pdf : %.tex
	latex $< > /dev/null 2>&1
	latex $< > /dev/null 2>&1
	dvipdf $(@:.pdf=.dvi)

%/index.html : %.tex
	latex2html $<

clean:
	rm -fr $(patsubst %.tex,%,$(TEX)) html *.log
	rm -f $(PDF) *~
	rm -f $(patsubst %.tex,%.aux,$(TEX))
	rm -f $(patsubst %.tex,%.out,$(TEX))
	rm -f $(patsubst %.tex,%.dvi,$(TEX))
