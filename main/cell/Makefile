sinclude ../../Makeconf

t2.9.4=cellfun.oct cell2mat.m
DEPRECIATED_TARGETS=$($(word 2, $(sort t$(OCTAVE_VERSION) t2.9.4)))

all: $(DEPRECIATED_TARGETS)

%.m : %.m.in
	-$(INSTALL) $< $@

clean: ; -$(RM) *.o core octave-core *.oct *~ $(t2.9.4)
