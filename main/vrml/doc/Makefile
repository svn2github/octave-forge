sinclude ../../../Makeconf

TEX = vrml-mini-howto-1.tex
PDF = $(patsubst %.tex,%.pdf,$(TEX))

all : $(PDF) html/index.html

%.pdf : %.tex
	latex $< > /dev/null 2>&1
	latex $< > /dev/null 2>&1
	dvipdf $(@:.pdf=.dvi)

html/index.html : $(TEX)
	latex2html $<
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
