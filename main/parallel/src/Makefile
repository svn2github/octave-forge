OCTS = sclose.oct  connect.oct pserver.oct  \
	recv.oct  reval.oct  send.oct


all: $(OCTS)

%.oct: %.cc
	mkoctfile -s $<

clean: ; rm *.o core octave-core *.oct *~
