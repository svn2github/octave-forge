# -*- coding: utf-8 -*-
CC=mkoctfile

.PHONY: all
all: compile clean

.PHONY: compile
compile:
	$(CC) -c -Wall -Wextra compilador.c -o compilador.o
	$(CC) -c -Wall -Wextra errores.c -o errores.o
	$(CC) -c -Wall -Wextra eucli.c -o eucli.o
	$(CC) -c -Wall -Wextra fgeneral.c -o fgeneral.o
	$(CC) -c -Wall -Wextra greiner.c -o greiner.o
	$(CC) -c -Wall -Wextra polig.c -o polig.o
	$(CC) -c -Wall -Wextra ptopol.c -o ptopol.o
	$(CC) -c -Wall -Wextra segmento.c -o segmento.o
	$(CC) -c -Wall -Wextra ventorno.c -o ventorno.o
	$(CC) -s -Wall -Wextra _oc_polybool.cc *.o

.PHONY: clean
clean:
	rm -rf *.o *~
