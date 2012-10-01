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
#Export flags for compilers and linker
export CFLAGS CXXFLAGS

.PHONY: all
all: compile clean

.PHONY: compile
compile:
	$(CC) -c -I. calctopo.c -o calctopo.o
	$(CC) -c -I. compilador.c -o compilador.o
	$(CC) -c -I. dpeucker.c -o dpeucker.o
	$(CC) -c -I. errores.c -o errores.o
	$(CC) -c -I. eucli.c -o eucli.o
	$(CC) -c -I. fgeneral.c -o fgeneral.o
	$(CC) -c -I. geocnan.c -o geocnan.o
	$(CC) -c -I. geocomp.c -o geocomp.o
	$(CC) -c -I. greiner.c -o greiner.o
	$(CC) -c -I. polig.c -o polig.o
	$(CC) -c -I. polil.c -o polil.o
	$(CC) -c -I. ptopol.c -o ptopol.o
	$(CC) -c -I. recpolil.c -o recpolil.o
	$(CC) -c -I. segmento.c -o segmento.o
	$(CC) -c -I. ventorno.c -o ventorno.o
	$(CC) -s -I. _oc_polybool.cc *.o

.PHONY: clean
clean:
	rm -rf *.o *~

.PHONY: cleanall
cleanall:
	rm -rf *~ *.o *.oct
