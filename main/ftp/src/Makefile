sinclude Makeconf

ifndef SWIG
SWIG=~/swig/preinst-swig
endif
ifndef MKOCTFILE
MKOCTFILE=g++ -g -shared
endif

.PHONY: clean check

all: ftpobj.oct

ftpobj.oct: ftp.i ftplib_filtered.h
	$(SWIG) -octave -c++ -o ftp_wrap.cpp ftp.i
	$(MKOCTFILE) -o ftpobj.oct ftp_wrap.cpp -lftp

clean:
	-$(RM) *.o octave-core core *.oct *~ *_wrap.cpp

TEST_CASES =  \
	basic \
	empty \
	twice

NOT_BROKEN_TEST_CASES = $(TEST_CASES:=.test)
.PHONY: check
check: all $(NOT_BROKEN_TEST_CASES)
%.test:
	octave -q tests/$*.m > /dev/null

