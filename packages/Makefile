sinclude ../Makeconf

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif
HOME=`pwd`
RUN_OCTAVE= HOME=$(HOME) ../admin/run_forge $(OCTAVE) -H -q --no-site-file
#PACKAGES = $(filter-out $(BUNDLE), $(wildcard *.tar.gz))
PKGDIRS = $(filter-out packages, $(patsubst ../%/, %, $(dir $(wildcard ../*/Makefile))))

.PHONY: $(PACKAGES) $(PKGDIRS)

# Construct the bundles from the individual packages
all: $(PKGDIRS)

$(PKGDIRS):
	d=`date +%Y%m%d`; \
	cd $@; \
	tar cvzf ../octave-forge-$@-$$d.tar.gz ../README *

# Do nothing for the package target 
package:

# Assume all packages have .tar.gz extensions
mostlyclean: 
	@rm -fr install *~ build-stamp .octave_packages *.tar.gz

clean: mostlyclean
	@rm -fr $(PKGDIRS)

check: build-stamp
	../admin/run_forge

build-stamp: $(PACKAGES)
	@touch build-stamp

# No spaces in eval argument please!!
$(PACKAGES) :
	@echo "build $@"; \
	if [ ! -d install ]; then mkdir install; fi; \
	$(RUN_OCTAVE) --eval "pkg('install','$@')"
