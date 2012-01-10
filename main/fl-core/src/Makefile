OCT = fl_compose.oct
SRC := $(OCT:.oct=.cc)
BASE := $(OCT:.oct=)

ifdef COMSPEC 
ifneq ($(shell uname -o),Cygwin)
	ADDPARAM := -lpthreadVC2
endif
endif

.phony: all
all: $(OCT)

%.oct: %.cc
	mkoctfile -s $< $(ADDPARAM)

.phony: clean
clean: 
	$(RM) $(PART) *.o *.oct octave-core *~
