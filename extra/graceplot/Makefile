sinclude ../../Makeconf

# extra functions defined in __grcmd__.oct
gr_LINKS=__grcla__.oct\
 __grclf__.oct\
 __grexit__.oct\
 __grfigure__.oct\
 __grgetstat__.oct\
 __grhold__.oct\
 __grinit__.oct\
 __grishold__.oct\
 __grnewset__.oct\
 __grsetgraph__.oct

# all compiled functions
PROGS=__grcmd__.oct $(gr_LINKS)

all: $(PROGS) grace_octave_path.m

$(PROGS): Makefile

grace_octave_path.m: grace_octave_path.m.in
	cat grace_octave_path.m.in | sed -e "s:@ALTMPATH@:$(ALTMPATH)/$(GRDESTDIR):" > grace_octave_path.m

$(gr_LINKS):
	-$(RM) $@
	$(LN_S) __grcmd__.oct $@

clean: ; -$(RM) *.o core octave-core *.oct *~ grace_octave_path.m 
