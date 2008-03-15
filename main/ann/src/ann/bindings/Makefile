#SWIG=~/swig/preinst-swig

bindings-octave: ann.oct
ann.oct: ann.i ../include/ANN/ANN.h ../include/ANN/ANNperf.h ../include/ANN/ANNx.h
	$(SWIG) -c++ -octave -o ann_wrap.cpp ann.i
	$(MKOCTFILE) -o ann.oct -I../include -L../lib -lANN ann_wrap.cpp

clean:
	rm -f *.oct *.o *_wrap* *~ octave-core 


OCTAVE_TEST_CASES =   \
	basic \
	bd_tree \
	empty \
	fatal \
	kd_tree

NOT_BROKEN_OCTAVE_TEST_CASES = $(OCTAVE_TEST_CASES:=.octave-test)
.PHONY: check
check: $(NOT_BROKEN_OCTAVE_TEST_CASES)
%.octave-test:
	octave -q tests/octave/$*.m > /dev/null

