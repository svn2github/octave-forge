NAME = arpack

LIBTARGET = lib$(NAME).dll
LIBIMPLIB  = $(NAME).lib

CC = cc-msvc
CFLAGS = -MD -O2

F2C = f2c

FSOURCES = $(wildcard SRC/*.f) $(wildcard UTIL/*.f)
CSOURCES = $(patsubst %.f,%.c, $(FSOURCES))
OBJECTS = $(patsubst %.f,%.o, $(FSOURCES))

DEF_FILES = $(patsubst %.f,%.def, $(FSOURCES))
LIB_DEFFILE = $(patsubst %.dll,%.def, $(LIBTARGET))

all: $(LIBTARGET)

.SUFFIXES: .f .c .o .def

%.c : %.f
	$(F2C) -ISRC < $< > $@

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
	$(CC) -shared -o $@ $(OBJECTS) -lf2c -lblas -llapack -Wl,-def:$(LIB_DEFFILE) -Wl,-implib:$(LIBIMPLIB)

OTHER_CLEANFILES = $(patsubst %.dll, %.exp, $(LIBTARGET)) \
		   $(patsubst %.dll, %.ilk, $(LIBTARGET)) \
		   $(patsubst %.dll, %.lib, $(LIBTARGET)) \
		   $(patsubst %.dll, %.pdb, $(LIBTARGET))

clean:
	$(RM) $(OBJECTS) $(CSOURCES)
	$(RM) $(DEF_FILES) $(LIB_DEFFILE)
	$(RM) $(LIBTARGET) $(OTHER_CLEANFILES)
