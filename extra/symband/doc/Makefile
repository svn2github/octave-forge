sinclude ../../../Makeconf

TEX = $(wildcard *.tex)
PDF = $(patsubst %.tex,%.pdf,$(TEX))

all : $(PDF) html/index.html

%.pdf : %.tex
	latex $< > /dev/null 2>&1
	latex $< > /dev/null 2>&1
	$(DVIPDF) $(@:.pdf=.dvi)

# Note verbosity=0 as well as making latex2html quieter, has the side-effect
# of not including a url to the raw text, which it'll get wrong
html/index.html : $(TEX)
	latex2html -verbosity=0 -local_icons $<
	if [ -e "html" ]; then \
	  rm -fr html; \
	fi; \
	mv -f $(patsubst %.tex,%,$<) html

clean:
	rm -fr $(patsubst %.tex,%,$(TEX)) html *.log
	rm -f $(PDF) *~
	rm -f $(patsubst %.tex,%.aux,$(TEX))
	rm -f $(patsubst %.tex,%.out,$(TEX))
	rm -f $(patsubst %.tex,%.dvi,$(TEX))
	rm -f $(patsubst %.tex,%.toc,$(TEX))
	rm -f $(patsubst %.tex,%.idx,$(TEX))
