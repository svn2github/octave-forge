M4 := m4
MACRO_FILE := macros.m4
HTML_SRC := $(shell find . | grep "\.in")
IMG_HTML := $(HTML_SRC:.in=.html)

all: build-www $(IMG_HTML)
.PHONY: all

build-www:
	./build-www.py

%.html : %.in
	$(M4) $(MACRO_FILE) $< > $@

clean:
	sh cleanup.sh $(IMG_HTML)
