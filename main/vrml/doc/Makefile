
all:	vrml-mini-howto-1.ps

%.ps:	%.tex
	latex $*.tex
	latex $*.tex
	dvips -o $*.ps $*.dvi

clean:
	rm -f *.aux *.log *.dvi *~