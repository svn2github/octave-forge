sinclude ../../Makeconf

ifndef MKOCTFILE
MKOCTFILE = mkoctfile
HAVE_X = 1
X_CFLAGS = -I/usr/X11R6/include
X_LIBS = -L/usr/X11R6/lib
endif

MOFLAGS = $(X_CFLAGS) $(X_LIBS)

TARGETS = graphics.o ginput.oct grab.oct gtext.oct gzoom.oct

ifdef HAVE_X
all: $(TARGETS)
else
all:
	@echo WARNING: X Windows not found on your system
endif

ginput.oct: graphics.o
grab.oct: graphics.o
gtext.oct: graphics.o
gzoom.oct: graphics.o

%.o: %.cc
	$(MKOCTFILE) $(MOFLAGS) $< -o $@

%.oct: %.cc
	$(MKOCTFILE) $(MOFLAGS) graphics.o $< -o $@
	$(RM) $(@:.oct=.o)

clean:
	$(RM) *.o *~

purge: clean
	$(RM) -f *.oct

archive:
	tar cvzf graphics.tgz Makefile *.cc *.h *.m

