sinclude ../../Makeconf

BITAND_LINKS=$(patsubst %,%$(OCTLINK), bitor bitxor bitmax)
BITFCNS_DOT_M=bitcmp.m bitget.m bitset.m bitshift.m  
t2.1.58=bitand.oct $(BITAND_LINKS) $(BITFCNS_DOT_M)
DEPRECIATED_TARGETS=$($(word 2, $(sort t$(OCTAVE_VERSION) t2.1.58)))
PROGS=$(DEPRECIATED_TARGETS) command.oct deref.oct mark_for_deletion.oct

all: $(PROGS)

$(PROGS): Makefile

$(BITAND_LINKS):
	-$(RM) $@
	$(MKOCTLINK) bitand.oct $@

bitand.oct : bitand.cc
	$(MKOCTFILE) $(HAVE_ND_ARRAYS) $<

clean: ; -$(RM) *.o core octave-core *.oct $(BITFCNS_DOT_M) *~

%.m: %.m.in
	-$(INSTALL) $< $@

