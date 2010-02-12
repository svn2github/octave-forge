.PHONY: all
all: compile clean

.PHONY: compile
compile:
	cc -c -O3 -Wall -Wextra projwrap.c -o projwrap.o
	mkoctfile -s -Wall -Wextra _op_transform.cc projwrap.o -lproj
	mkoctfile -s -Wall -Wextra _op_fwd.cc projwrap.o -lproj
	mkoctfile -s -Wall -Wextra _op_inv.cc projwrap.o -lproj
	mkoctfile -s -Wall -Wextra _op_geod2geoc.cc -lproj
	mkoctfile -s -Wall -Wextra _op_geoc2geod.cc -lproj

.PHONY: clean
clean:
	rm _op_transform.o _op_fwd.o _op_inv.o _op_geod2geoc.o _op_geoc2geod.o
	rm projwrap.o
