include ../../Makeconf

all: lp.oct leval.oct
	cd mintoolkit && $(MAKE)

clean:
	-$(RM) *.o core octave-core *.oct *~
	cd mintoolkit && $(MAKE) clean
