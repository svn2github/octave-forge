include ../../Makeconf

BITAND_LINKS=bitor.oct bitxor.oct bitmax.oct
PROGS=bitand.oct $(BITAND_LINKS) command.oct deref.oct

all: $(PROGS)

$(PROGS): Makefile

$(BITAND_LINKS):
	-$(RM) $@
	$(LN_S) bitand.oct $@


clean: ; -$(RM) *.o core octave-core *.oct *~
