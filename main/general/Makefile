include ../../Makeconf

BITAND_LINKS=bitor.oct bitxor.oct bitmax.oct
PROGS=bitand.oct $(BITAND_LINKS) command.oct deref.oct mark_for_deletion.oct

all: $(PROGS)

$(PROGS): Makefile

$(BITAND_LINKS):
	-$(RM) $@
	$(LN_S) bitand.oct $@

bitand.oct : bitand.cc
	$(MKOCTFILE) $(HAVE_ND_ARRAYS) $<

clean: ; -$(RM) *.o core octave-core *.oct *~
