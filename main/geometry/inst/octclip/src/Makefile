# -*- coding: utf-8 -*-
ifndef MKOCTFILE
MKOCTFILE := mkoctfile
endif

CLIPOBJECT = compilador.o errores.o eucli.o fgeneral.o greiner.o polig.o \
             ptopol.o segmento.o ventorno.o
FLAGS = -Wall -Wextra

%.o: %.c
	$(MKOCTFILE) $(FLAGS) -I. -c $<

%.oct: %.cc $(CLIPOBJECT)
	$(MKOCTFILE) $< $(CLIPOBJECT) $(FLAGS) -v  -I.

all: _oc_polybool.oct

clean:
	rm -rf *.o *~
