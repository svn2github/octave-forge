sinclude Makeconf

ifeq ($(HAVE_ARPACK),yes)
  PROGS:=eigs.oct
endif

all: $(PROGS)

eigs.oct: eigs.cc
	$(MKOCTFILE) -DHAVE_CONFIG_H -DHAVE_ARPACK $< $(ARPACK_LIBS)

clean: ; -$(RM) *.o core octave-core *.oct *~
