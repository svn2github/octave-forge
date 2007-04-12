all: xraylib_stamp
	mkoctfile -I./xraylib/src xraylib.cc -L./xraylib/src -lxrl

xraylib_stamp:
	make -C xraylib/src inline
	touch xraylib_stamp
clean:
	make -C xraylib/src clean
	-rm *.o *.oct *~ xraylib_stamp
