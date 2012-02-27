# -*- coding: utf-8 -*-
ifndef MKOCTFILE
MKOCTFILE := mkoctfile
endif

CLIPOBJECT = compilador.o errores.o eucli.o fgeneral.o greiner.o polig.o \
             ptopol.o segmento.o ventorno.o

all:   _oc_polybool.oct

%.o: %.c
	$(MKOCTFILE) -I. -c $<

%.oct: %.cc $(CLIPOBJECT)
	$(MKOCTFILE) -v  -I. $(CLIPOBJECT) -s $<


clean:
	rm -rf *.o *~
