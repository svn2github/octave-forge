OCT = fl_compose.oct
SRC := $(OCT:.oct=.cc)
BASE := $(OCT:.oct=)
ifdef COMSPEC 
	ADDPARAM := -lpthreadVC2
endif

.phony: all
all: $(OCT)

%.oct: %.cc
	mkoctfile -s $< $(ADDPARAM)

.phony: clean
clean: 
	$(RM) $(PART) *.o *.oct octave-core *~
