sinclude ../../Makeconf

PROGS = ginput.oct grab.oct gtext.oct gzoom.oct

ifndef OCTAVE_FORGE
	MKOCTFILE = mkoctfile
	HAVE_X = 1
	X_CFLAGS = -I/usr/X11R6/include
	X_LIBS = -L/usr/X11R6/lib
endif

%.o: %.cc ; $(MKOCTFILE) -c $(X_CFLAGS) $< -o $@

%.oct: %.o ; $(MKOCTFILE) $< graphics.o $(X_LIBS) -o $@

ifdef HAVE_X
all: $(PROGS)
else
all:
	@echo WARNING: X Windows not found on your system
endif

$(PROGS:.oct=.o): graphics.h
$(PROGS): graphics.o

clean: ; -$(RM) *.o octave-core core *~ *.oct

archive:
	tar cvzf graphics.tgz Makefile *.cc *.h *.m

