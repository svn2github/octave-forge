include ../../Makeconf

PROGS=bitand.oct bitor.oct bitxor.oct bitmax.oct command.oct

all: $(PROGS)

bitor.oct: bitand.oct
	-$(RM) $@
	$(LN_S) $< $@

bitxor.oct: bitand.oct
	-$(RM) $@
	$(LN_S) $< $@

bitmax.oct: bitand.oct
	-$(RM) $@
	$(LN_S) $< $@


clean:
	-$(RM) *.o *.oct core octave-core *~
