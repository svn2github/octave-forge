sinclude ../../Makeconf

t2.9.4=print.m
DEPRECIATED_TARGETS=$($(word 2, $(sort t$(OCTAVE_VERSION) t2.9.4)))
PROGS = grab.oct gpick.oct gtext.oct gzoom.oct

ifndef OCTAVE_FORGE
	MKOCTFILE = mkoctfile
	HAVE_X = 1
	X_CFLAGS = -I/usr/X11R6/include
	X_LIBS = -L/usr/X11R6/lib
endif


%.o: %.cc ; $(MKOCTFILE) -c $(X_CFLAGS) $<

ifdef HAVE_X
all: $(PROGS) $(DEPRECIATED_TARGETS)
else
all: $(DEPRECIATED_TARGETS)
	@echo WARNING: X Windows not found on your system
endif

$(PROGS:.oct=.o): graphics.h

grab.oct: grab.o graphics.o
	$(MKOCTFILE) $< graphics.o $(X_LIBS) -o $@

gpick.oct: gpick.o graphics.o
	$(MKOCTFILE) $< graphics.o $(X_LIBS) -o $@

gtext.oct: gtext.o graphics.o
	$(MKOCTFILE) $< graphics.o $(X_LIBS) -o $@

gzoom.oct: gzoom.o graphics.o
	$(MKOCTFILE) $< graphics.o $(X_LIBS) -o $@

%.m : %.m.in
	-$(INSTALL) $< $@

clean: ; -$(RM) *.o octave-core core *~ *.oct

archive:
	tar cvzf graphics.tgz Makefile *.cc *.h *.m

