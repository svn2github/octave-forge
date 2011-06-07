# -*- coding: utf-8 -*-
CC=mkoctfile

.PHONY: all
all: compile clean

.PHONY: compile
compile:
	$(CC) -c -Wall -Wextra -I. compilador.c -o compilador.o
	$(CC) -c -Wall -Wextra -I. errores.c -o errores.o
	$(CC) -c -Wall -Wextra -I. eucli.c -o eucli.o
	$(CC) -c -Wall -Wextra -I. fgeneral.c -o fgeneral.o
	$(CC) -c -Wall -Wextra -I. greiner.c -o greiner.o
	$(CC) -c -Wall -Wextra -I. polig.c -o polig.o
	$(CC) -c -Wall -Wextra -I. ptopol.c -o ptopol.o
	$(CC) -c -Wall -Wextra -I. segmento.c -o segmento.o
	$(CC) -c -Wall -Wextra -I. ventorno.c -o ventorno.o
	$(CC) -s -Wall -Wextra -I. _oc_polybool.cc *.o

.PHONY: clean
clean:
	rm -rf *.o *~
