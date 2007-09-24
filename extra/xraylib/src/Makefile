all: xraylib_stamp
	mkoctfile -I./xraylib/src xraylib.cc -L./xraylib/src -lxrl

xraylib_stamp:
	$(MAKE) -C xraylib/src inline
	touch xraylib_stamp
clean:
	$(MAKE) -C xraylib/src clean
	-rm *.o *.oct *~ xraylib_stamp
