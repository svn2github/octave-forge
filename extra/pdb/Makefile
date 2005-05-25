include ../../Makeconf

all: creadpdb.oct plotpdb.m

plotpdb.m: plotpdb.m.in
	sed -e "s:@OFORGEXPATH@:$(XPATH):" plotpdb.m.in > plotpdb.m

clean: ; -$(RM) plotpdb.m *.o core octave-core *.oct *~
