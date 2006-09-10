sinclude ../Makeconf

odir = $(notdir $@)
opkg = $(strip $(subst / ,/,$(wordlist 2,10000,$(subst /,/ ,$@))))

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif
HOME=`pwd`
RUN_OCTAVE= HOME=$(HOME) $(TOPDIR)/admin/run_forge $(OCTAVE) -H -q --no-site-file
PKGDIRS = $(filter-out packages, $(patsubst ../%/, %, $(dir $(wildcard ../*/Makefile))))
PACKAGES = $(filter $(patsubst %,%/%,$(PKGDIRS)), $(wildcard */*.tar.gz))
TESTLOG=$(TOPDIR)/packages/fntests.log

.PHONY: $(PKGDIRS)

# Construct the bundles from the individual packages
all: $(patsubst %,mkbundle/%,$(PKGDIRS))

mkbundle/%:
	d=`date +%Y%m%d`; \
	cd $(odir); \
	tar cvzf ../octave-forge-$(odir)-$$d.tar.gz ../README *

# Do nothing for the package target 
package:

# Assume all packages have .tar.gz extensions
mostlyclean: 
	@rm -fr $(TESTLOG) sandbox *~ build-stamp .octave_packages *.tar.gz

clean: mostlyclean
	@rm -fr $(PKGDIRS)

check: cleanlog $(patsubst %, checkpkg/%, $(PACKAGES))

cleanlog:
	rm $(TESTLOG)

# No spaces in eval argument please!!
checkpkg/%: cleancheck checkdep/% mkpkg/%
	@echo "Running test code for $(opkg) and its dependencies" ; \
	cd sandbox; \
	$(TOPDIR)/admin/mktests.sh code; \
	$(RUN_OCTAVE) --eval "pkg('load','all');fntests" ; \
	if [ ! -e ../fntests.log ]; then touch ../fntests.log; fi ; \
	cat fntests.log >> $(TESTLOG); \
	cd ..

cleancheck:
	@if [ -d sandbox/ ]; then rm -rf sandbox; fi ; \
	mkdir sandbox; \
	cd sandbox; \
	echo "global OCTAVE_PACKAGE_PREFIX;" > .octaverc ; \
	echo "OCTAVE_PACKAGE_PREFIX=[pwd() '/install'];" >> .octaverc ; \
	cd ..

# FIXME: This does not do any dependency checking yet!!
checkdep/%:
	@echo "Checking dependencies of $(opkg)"; \
	cd sandbox; mkdir tmp; cd tmp; \
	tar xzf ../../$(opkg) ; \
	echo " **** Add dependency checking code here! ****"; \
	if [ ! -d ../code ]; then mkdir ../code; fi;  \
	mv * ../code; \
	cd ../; rm -fr tmp/; \
	cd code; \
	tar czf ../bundle.tar.gz * ; \
	cd ../..

# No spaces in eval argument please!!
mkpkg/%:
	@echo "Building $(opkg) and its dependencies"; \
	cd sandbox; \
	if [ ! -d install ]; then mkdir install; fi ; \
	$(RUN_OCTAVE) --eval "pkg('install','bundle.tar.gz')" ; \
	cd ..

run:
	cd sandbox; \
	$(RUN_OCTAVE)
