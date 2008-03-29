sinclude Makeconf

.PHONY: clean check

all: ftpobj.oct

ftpobj.oct: ftp_wrap.cpp ftplib_filtered.h
	$(MKOCTFILE) -o ftpobj.oct ftp_wrap.cpp -lftp

ifdef SWIG
ftp_wrap.cpp: ftp.i
	$(SWIG) -octave -c++ -o ftp_wrap.cpp ftp.i
endif

clean:
	-$(RM) *.o octave-core core *.oct *~

TEST_CASES =  \
	basic \
	empty \
	twice

NOT_BROKEN_TEST_CASES = $(TEST_CASES:=.test)
.PHONY: check
check: all $(NOT_BROKEN_TEST_CASES)
%.test:
	octave -q tests/$*.m > /dev/null

