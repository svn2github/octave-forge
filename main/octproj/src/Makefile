# -*- coding: utf-8 -*-
CC=mkoctfile

.PHONY: all
all: compile clean

.PHONY: compile
compile:
	$(CC) -c -Wall -Wextra projwrap.c -o projwrap.o
	$(CC) -s -Wall -Wextra _op_transform.cc projwrap.o -lproj
	$(CC) -s -Wall -Wextra _op_fwd.cc projwrap.o -lproj
	$(CC) -s -Wall -Wextra _op_inv.cc projwrap.o -lproj
	$(CC) -s -Wall -Wextra _op_geod2geoc.cc -lproj
	$(CC) -s -Wall -Wextra _op_geoc2geod.cc -lproj

.PHONY: clean
clean:
	rm -rf _op_transform.o _op_fwd.o _op_inv.o _op_geod2geoc.o _op_geoc2geod.o
	rm -rf projwrap.o
