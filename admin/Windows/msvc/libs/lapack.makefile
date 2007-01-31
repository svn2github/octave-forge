LIBTARGET = lapack.dll
LIBSTATIC = liblapack_f77.lib

CC = cc-msvc
CFLAGS = -MD -O2
AR = ar-msvc

F2C = f2c

FSOURCES = $(wildcard *.f) ../INSTALL/dlamch.f ../INSTALL/slamch.f
CSOURCES = $(patsubst %.f,%.c, $(FSOURCES))
OBJECTS = $(patsubst %.f,%.o, $(FSOURCES))

DEF_FILES = $(patsubst %.f,%.def, $(FSOURCES))
LIB_DEFFILE = $(patsubst %.dll,%.def, $(LIBTARGET))

all: $(LIBTARGET) $(LIBSTATIC)

.SUFFIXES: .f .c .o .def

%.c : %.f
	$(F2C) < $< > $@

%.o : %.c
	$(CC) $(CFLAGS) -o $@ -c $<

%.o : %.f

%.def : %.f
	@echo "Making $@"
	@sed -n \
	     -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
	     -e 's/^\(      \|	\)\(.*function\|subroutine\|entry\)[ 	]*\([^ 	(]*\).*$$/\3_/p' < $< > $@

$(LIB_DEFFILE): $(DEF_FILES)
	echo "EXPORTS" > $@
	cat $(DEF_FILES) >> $@

$(LIBTARGET): $(OBJECTS) $(LIB_DEFFILE)
	$(CC) -shared -o $@ $(OBJECTS) -lf2c -lblas -Wl,-def:$(LIB_DEFFILE)

$(LIBSTATIC): $(OBJECTS) $(LIB_DEFFILE)
	$(AR) r $@ $(OBJECTS)

OTHER_CLEANFILES = $(patsubst %.dll, %.exp, $(LIBTARGET)) \
		   $(patsubst %.dll, %.ilk, $(LIBTARGET)) \
		   $(patsubst %.dll, %.lib, $(LIBTARGET)) \
		   $(patsubst %.dll, %.pdb, $(LIBTARGET))

clean:
	$(RM) $(OBJECTS) $(CSOURCES)
	$(RM) $(DEF_FILES) $(LIB_DEFFILE)
	$(RM) $(LIBTARGET) $(OTHER_CLEANFILES)
	$(RM) $(LIBSTATIC)
