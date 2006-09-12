M4 := m4
MACRO_FILE := macros.m4
HTML_SRC = $(shell find . | grep "\.in")
IMG_HTML = $(HTML_SRC:.in=.html)

all: build-www developers.html
	make $(IMG_HTML)

build-www:
	./build-www.py

developers.html:
	wd=`pwd`
	cd ../admin && ./get_contents
	cd $(wd)
	cp ../doc/new_developer.html ./developers.in
	$(M4) $(MACRO_FILE) developers.in > developers.html

%.html : %.in
	$(M4) $(MACRO_FILE) $< > $@

clean:
	@for f in $(IMG_HTML); do \
	  d=`dirname $$f`; \
	  if [ -d $$d ]; then \
	    if [ "$$d" != "." ]; then \
	      rm -rf $$d; \
	    fi; \
	  fi; \
	done
	rm -f *.html developers.in

package:
