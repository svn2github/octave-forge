M4 := m4
MACRO_FILE := macros.m4
HTML_SRC := $(shell find . | grep "\.in")
IMG_HTML := $(HTML_SRC:.in=.html)

all: build-www $(IMG_HTML) developers.html
.PHONY: all

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
	sh cleanup.sh $(IMG_HTML)
	rm -f *.html developers.in
