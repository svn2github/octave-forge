sinclude ../../Makeconf

# extra functions defined in __grcmd__.oct
gr_LINKS=$(patsubst %,%$(OCTLINK), __grcla__\
 __grclf__\
 __grexit__\
 __grfigure__\
 __grgetstat__\
 __grhold__\
 __grinit__\
 __grishold__\
 __grnewset__\
 __grsetgraph__)

# all compiled functions
PROGS=__grcmd__.oct $(gr_LINKS)

all: $(PROGS) grace_octave_path.m

$(PROGS): Makefile

grace_octave_path.m: grace_octave_path.m.in
	cat grace_octave_path.m.in | sed -e "s:@ALTMPATH@:$(ALTMPATH)/$(GRDESTDIR):" > grace_octave_path.m

$(gr_LINKS):
	-$(RM) $@
	$(MKOCTLINK) __grcmd__.oct $@

clean: ; -$(RM) *.o core octave-core *.oct *~ grace_octave_path.m 
