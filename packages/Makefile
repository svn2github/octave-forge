sinclude ../Makeconf

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif
HOME=`pwd`
RUN_OCTAVE= HOME=$(HOME) ../admin/run_forge $(OCTAVE) -H -q --no-site-file
BUNDLE = octave-forge.tar.gz
PACKAGES = $(filter-out $(BUNDLE), $(wildcard *.tar.gz))

.PHONY: $(PACKAGES)

# Do nothing for the all target 
all:

# Assume all packages have .tar.gz extensions
clean:
	rm *.tar.gz *~ build-stamp .octave-packages
	rm -fr install

check: build-stamp
	../admin/run_forge

build-stamp: $(PACKAGES)
	touch build-stamp

# No spaces in eval argumnet please!!
$(PACKAGES) :
	if [! -d octave/ ]; then mkdir octave; fi
	$(RUN_OCTAVE) --eval "pkg('install','$@')"
