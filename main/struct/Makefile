sinclude ../../Makeconf

# struct.cc hasn't been back-ported
ifeq ($(HAVE_OCTAVE_MAP_INDEX),)
STRUCT=struct.oct
endif
ifeq ($(HAVE_BUILTIN_STRUCT),1)
STRUCT=
endif

all: getfields.oct setfields.oct $(STRUCT)

clean: ; -$(RM) *.o core octave-core *.oct *~
