M4 := m4
MACRO_FILE := macros.m4
M4_OPTIONS := --prefix-builtins
HTDOCS = ./htdocs/
HTML_SRC = $(shell find $(HTDOCS) | grep "\.in")
IMG_HTML = $(HTML_SRC:.in=.html)
HTDOCS_PKG = htdocs.tar.gz

all: build-www doc $(HTDOCS)developers.html doxygen $(HTDOCS)javascript.js
	make $(IMG_HTML)
	make -k -C coda www-dist
	if [ ! -e $(HTDOCS)coda ]; then rm -rf $(HTDOCS)coda; fi
	tar xzCf $(HTDOCS) coda/out/coda-www.tar.gz
	make $(HTDOCS_PKG)

build-www:
	@if [ -d  tmp ]; then rm -rf tmp; fi; \
	mkdir tmp
	../admin/build-www.py
	@rm -rf tmp

$(HTDOCS)developers.html: ../admin/template.ndev
	wd=`pwd`
	cd .. && ./admin/get_contents
	cd $(wd)
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) $(HTDOCS)developers.in > $(HTDOCS)developers.html

doc:
	wd=`pwd`
	cd .. && ./admin/make_index
	cd $(wd)

html: $(IMG_HTML)

%.html : %.in
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) $< > $@

$(HTDOCS)javascript.js: javascript.jsin
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) $< > $@

clean:
	@for f in $(IMG_HTML); do \
	  d=`dirname $$f`; \
	  if [ -d $$d ]; then \
	    if [ "$$d" != "./htdocs" ]; then \
	      if [ "$$d" != "." ]; then \
	        rm -rf $$d; \
	      fi; \
	    fi; \
	  fi; \
	done
	@rm -fr $(HTDOCS)*.html $(HTDOCS)developers.in INDEX $(HTDOCS)coda .octave_hist .octave_packages $(HTDOCS)doxygen $(HTDOCS)javascript.js tmphtmlheader.html tmphtmlfooter.html tmp $(HTDOCS_PKG) *~ $(HTDOCS)/*~
	@make -C coda clean

$(HTDOCS_PKG):
	@tar czf $@ --exclude=CVS --exclude=\*.in htdocs 

package:

doxygen: Doxyfile
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) htmlheader.htm > tmphtmlheader.html
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) htmlfooter.htm > tmphtmlfooter.html
	doxygen Doxyfile
	rm -f tmphtmlheader.html tmphtmlfooter.html
	$(M4) $(M4_OPTIONS) $(MACRO_FILE) $(HTDOCS)doxygen/html/index.html > index.result
	mv -f index.result $(HTDOCS)doxygen/html/index.html
