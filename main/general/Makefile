include ../../Makeconf

BITAND_LINKS=bitor.oct bitxor.oct bitmax.oct
PROGS=bitand.oct $(BITAND_LINKS) command.oct deref.oct

all: $(PROGS)

$(BITAND_LINKS): Makefile
	-$(RM) $@
	$(LN_S) bitand.oct $@


clean:
	-$(RM) *.o *.oct core octave-core *~
