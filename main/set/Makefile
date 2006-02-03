sinclude ../../Makeconf

t2.9.0=ismember.m setdiff.m unique.m
DEPRECIATED_TARGETS=$($(word 2, $(sort t$(OCTAVE_VERSION) t2.9.0)))

all : $(DEPRECIATED_TARGETS)

clean: ; -$(RM) core octave-core $(DEPRECIATED_TARGETS) *~

%.m: %.m.in
	-$(INSTALL) $< $@

