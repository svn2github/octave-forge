include ../../Makeconf

all: lp.oct leval.oct
	cd mintoolkit && $(MAKE)

install:
	cp mintoolkit/*.oct .
	cp mintoolkit/*.m .

clean:
	-$(RM) *.o core octave-core *.oct *~
	cd mintoolkit && $(MAKE) clean
