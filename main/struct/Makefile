sinclude ../../Makeconf

# struct.cc hasn't been back-ported
ifeq ($(HAVE_OCTAVE_MAP_INDEX),)
STRUCT=struct.oct
endif

all: getfield.oct setfield.oct $(STRUCT)

clean: ; -$(RM) *.o core octave-core *.oct *~
