# -*- coding: utf-8 -*-
#Compiler
CC=mkoctfile
#Common warning flags for C and C++
FLAGSCOMW=-Wall -Wextra -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings
#Common optimization flags for C and C++
FLAGSCOMO=-O2 -funroll-loops -fno-common -fshort-enums
#Flags for C
CFLAGS=-std=c99 -pedantic $(FLAGSCOMW) -Wconversion -Wmissing-prototypes
CFLAGS+=-Wstrict-prototypes -Wnested-externs $(FLAGSCOMO)
#Flags for C++
CXXFLAGS=$(FLAGSCOMW) $(FLAGSCOMO)
#Flags for the linker
LDFLAGS=-lproj
#Export flags for compilers and linker
export CFLAGS CXXFLAGS

.PHONY: all
all: compile clean

.PHONY: compile
compile:
	$(CC) -c -v projwrap.c -o projwrap.o
	$(CC) -s -v _op_transform.cc projwrap.o $(LDFLAGS)
	$(CC) -s _op_fwd.cc projwrap.o $(LDFLAGS)
	$(CC) -s _op_inv.cc projwrap.o $(LDFLAGS)
	$(CC) -s _op_geod2geoc.cc $(LDFLAGS)
	$(CC) -s _op_geoc2geod.cc $(LDFLAGS)

.PHONY: clean
clean:
	rm -rf *.o

.PHONY: cleanall
cleanall:
	rm -rf *~ *.o *.oct
