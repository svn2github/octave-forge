all: is_real_array.oct

# helper
is_real_array.oct: is_real_array.cc
	mkoctfile is_real_array.cc

clean:
	rm -rf *.o core octave-core *.oct *~

realclean: clean
	rm -rf *.a