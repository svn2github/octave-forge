sinclude ../../../Makeconf

TEX = optim-mini-howto-2.tex
PDF = $(patsubst %.tex,%.pdf,$(TEX))
HTML = $(patsubst %.tex,html/%/index.html,$(TEX))

all : $(PDF) html

.PHONY: html
html : $(HTML)
	echo '<html><body>' > html/index.html; \
	echo '<p><a href="optim-mini-howto-2/index.html">optim-mini-howto-2</a></p>' >> html/index.html; \
	echo '</body></html>' >> html/index.html

%.pdf : %.tex
	latex $< > /dev/null 2>&1
	latex $< > /dev/null 2>&1
	$(DVIPDF) $(@:.pdf=.dvi)

# Note verbosity=0 as well as making latex2html quieter, has the side-effect
# of not including a url to the raw text, which it'll get wrong
html/%/index.html : %.tex
	latex2html -verbosity=0 -local_icons $<
	if [ ! -e "html" ]; then \
	  mkdir html; \
	fi; \
	mv -f $(patsubst html/%/index.html,%,$@) html

clean:
	rm -fr $(patsubst %.tex,%,$(TEX)) html *.log
	rm -f $(PDF) *~
	rm -f $(patsubst %.tex,%.aux,$(TEX))
	rm -f $(patsubst %.tex,%.out,$(TEX))
	rm -f $(patsubst %.tex,%.dvi,$(TEX))
