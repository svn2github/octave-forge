## adapted from the communications package by David Bateman
sinclude Makeconf

TARGETS = gradinit.oct
SOURCES = ov-grad.cc grad-ops.cc 
OBJECTS = $(patsubst %.cc,%.o,$(SOURCES))
DEPENDS = $(patsubst %.cc,%.d,$(SOURCES))
DELETES = $(OBJECTS) $(DEPENDS) *~ $(TARGETS) core octave-core
DEFINES = 
MOFLAGS =

.PHONY: all dist clean realclean
.SUFFIXES:

all : $(DEPENDS) $(TARGETS)

install :
	@$(INSTALL) -d $(DESTDIR)$(MPATH)/ad

$(TARGETS) : $(DEPENDS) $(OBJECTS) 
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(OBJECTS) -o $@

ifneq (,$(DEPENDS))
  sinclude $(DEPENDS)
endif

%.oct : %.d %.o
	@echo "Linking $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(@:.oct=.o) -o $@

%.d: %.cc
	@echo "Depending $<"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -M $<

%.o:%.cc
	@echo "Compiling $@"; \
	$(MKOCTFILE) $(MOFLAGS) $(DEFINES) -c $< 

clean:
	@echo "Cleaning..."; \
	$(RM) -f $(DELETES)

realclean:
	@echo "Cleaning..."; \
	$(RM) -f $(DELETES)
