M4 := m4
MACRO_FILE := macros.m4
M4_OPTIONS := --prefix-builtins
HTML_SRC = $(shell find . | grep "\.in")
IMG_HTML = $(HTML_SRC:.in=.html)

all: doxygen build-www doc developers.html
	make $(IMG_HTML)
	make -k -C ../doc/coda www-dist
	if [ ! -e coda ]; then rm -rf coda; fi
	tar xzf ../doc/coda/out/coda-www.tar.gz

build-www:
	./build-www.py

developers.html: ../admin/template.ndev
	wd=`pwd`
	cd .. && ./admin/get_contents
	cd $(wd)
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) developers.in > developers.html

doc:
	wd=`pwd`
	cd .. && admin/make_index
	cd $(wd)

html: $(IMG_HTML)
	
#doc/f/edit.html:
#	@echo Skipping edit.html

%.html : %.in
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) $< > $@

clean:
	@for f in $(IMG_HTML); do \
	  d=`dirname $$f`; \
	  if [ -d $$d ]; then \
	    if [ "$$d" != "." ]; then \
	      rm -rf $$d; \
	    fi; \
	  fi; \
	done
	rm -fr *.html developers.in INDEX coda .octave_hist .octave_packages install doxygen 

package:

doxygen: Doxyfile
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) htmlheader.htm > tmphtmlheader.html
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) htmlfooter.htm > tmphtmlfooter.html
	doxygen Doxyfile
	rm -f tmphtmlheader.html tmphtmlfooter.html
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) doxygen/html/index.html > index.result
	mv -f index.result doxygen/html/index.html
