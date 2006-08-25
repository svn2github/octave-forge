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

.PHONY: $(PACKAGES) .tar.gz

# Do nothing for the all target 
all:

# Assume all packages have .tar.gz extensions
mostlyclean: 
	@rm -fr install *~ build-stamp .octave_packages

clean: mostlyclean
	@rm -f *.tar.gz

check: build-stamp
	../admin/run_forge

build-stamp: $(PACKAGES)
	@touch build-stamp

# No spaces in eval argumnet please!!
$(PACKAGES) :
	@echo "build $@"; \
	if [ ! -d install ]; then mkdir install; fi; \
	$(RUN_OCTAVE) --eval "pkg('install','$@')"
