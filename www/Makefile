ifeq ($(shell hostname), bevo.che.wisc.edu)
  SHELL = /usr/local/gnu/bin/bash
else
  ifeq ($(shell hostname), bahaha.che.wisc.edu)
    SHELL = /usr/local/gnu/bin/bash
  endif
endif

destdir = /usr/local/www/octave.org

INSTALL_DATA = install -m 644

MV := mv

M4 := m4

MACRO_FILE := macros.m4

HTML_SRC := $(shell find . | grep "\.in")

IMG_HTML := $(HTML_SRC:.in=.html)

all: build-www $(IMG_HTML)
.PHONY: all

build-www:
	./build-www.py
	touch $(HTML_SRC)

%.html : %.in
	$(M4) $(MACRO_FILE) $< > $@

clean:
	rm -f $(IMG_HTML)
	rmdir text
.PHONY: clean

define do-install
if [ ! -f $(destdir)/$f -o $f -nt $(destdir)/$f ] ; then \
  echo installing $f in $(destdir) ; \
  $(INSTALL_DATA) $f $(destdir)/$f ; \
fi

endef

install: all
	@$(foreach f, $(FILES_TO_INSTALL), $(do-install))
.PHONY: install

dist: 
	tar cf dist.tar $(SOURCES) Makefile macros.m4
	gzip --best dist.tar
.PHONY: dist
