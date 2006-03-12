sinclude ../../Makeconf

t2.9.5=datenum.m
DEPRECIATED_TARGETS=$($(word 2, $(sort t$(OCTAVE_VERSION) t2.9.5)))
PROGS=$(DEPRECIATED_TARGETS)

all: $(PROGS)

%.m : %.m.in
	-$(INSTALL) $< $@
