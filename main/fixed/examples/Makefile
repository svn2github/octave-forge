sinclude ../src/Makeconf

LINKTARGETS = fifft.oct
LINKSOURCE = ffft.oct
SOURCES = $(wildcard *.cc)
TARGETS = $(patsubst %.cc,%.oct,$(SOURCES)) $(LINKTARGETS)
OBJECTS = $(patsubst %.cc,%.o,$(SOURCES))
DEPENDS = $(patsubst %.cc,%.d,$(SOURCES))
INCLUDES = -I../src
DEFINES = 

ifeq (,$(findstring cygwin,$(canonical_host_type)))
 ifeq (,$(findstring mingw,$(canonical_host_type)))
   ifneq (,$(findstring msdosmsvc,$(canonical_host_type)))
    MOFLAGS = $(INCLUDES) -L../src -lfixed
   else
    MOFLAGS = $(INCLUDES)
   endif
 else
   MOFLAGS = $(INCLUDES) -L../ -loctave_fixed
 endif
endif

.PHONY: all clean count
%.oct : %.cc 
.SUFFIXES:
.SUFFIXES: .cc .oct .o .h
# This stuff doesn't build on OS X at the moment. Till someone
# fixes it, disable the build...
ifeq (,$(findstring darwin,$(canonical_host_type)))
all: $(DEPENDS) $(OBJECTS) $(TARGETS)
else
all:
	@echo "****** WARNING: Building of examples disabled for Darwin";
endif

ifneq (,$(wildcard *.d))
include $(wildcard *.d)
endif

$(LINKTARGETS) :
	@echo "Symbolic linking $@ to $(LINKSOURCE)"; \
	$(RM) $@; \
	$(LN_S) $(LINKSOURCE) $@

%.oct: %.d %.o
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(@:.oct=.o) -o $@

%.d: %.cc
	@echo "Depending $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -M $<

%.o: %.cc
	@echo "Compiling $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -c $< 

clean:
	@echo "Cleaning..."; \
	$(RM) $(OBJECTS) $(DEPENDS) $(TARGETS) *~ octave-core *.ps

count:
	wc *{.cc,.h}

