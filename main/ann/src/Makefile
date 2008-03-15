sinclude Makeconf

.PHONY: all check

all:
	$(MAKE) -C ann linux-g++
	$(MAKE) -C ann/bindings bindings-octave SWIG="$(SWIG)" MKOCTFILE="$(MKOCTFILE)"
	cp ann/bindings/ann.oct .

check:
	$(MAKE) -C ann/bindings check

clean:
	-$(RM) *.o octave-core core *.oct *~
	$(MAKE) -C ann clean
	$(MAKE) -C ann/bindings clean
