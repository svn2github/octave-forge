sinclude ../Makeconf

odir = $(notdir $@)
opkg = $(strip $(subst / ,/,$(wordlist 2,10000,$(subst /,/ ,$@))))

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif
RUN_OCTAVE= HOME=`pwd` $(TOPDIR)/admin/run_forge $(OCTAVE) -H -q --no-site-file
PKGDIRS = $(filter-out packages, $(patsubst ../%/, %, $(dir $(wildcard ../*/Makefile))))
PACKAGES = $(filter $(patsubst %,%/%,$(PKGDIRS)), $(wildcard */*.tar.gz))
TESTLOG=$(TOPDIR)/packages/fntests.log
RPMDIR=RPM

.PHONY: $(PKGDIRS) install

# Construct the bundles from the individual packages
all: $(patsubst %,mkbundle/%,$(PKGDIRS))

mkbundle/%:
	@d=`date +%Y%m%d`; \
	cd $(odir); \
	tar cvzf ../octave-forge-$(odir)-$$d.tar.gz ../README *

# Do nothing for the package target 
package:

# Assume all packages have .tar.gz extensions
mostlyclean: 
	@rm -fr $(TESTLOG) sandbox *~ *.tar.gz

clean: mostlyclean
	@rm -fr $(PKGDIRS) $(RPMDIR)

check: cleanlog $(patsubst %, checkpkg/%, $(PACKAGES))

icheck: $(patsubst %, icheckpkg/%, $(PACKAGES))

srpms: $(patsubst %, srpm/%, $(PACKAGES))

cleanlog:
	@rm $(TESTLOG)

install:
	@echo "***  INSTALLING ALL PACKAGES  ***"; \
	echo  "*** This is likely to be long ***"; \
	cmd="pkg('install'"; \
	for _pkg in $(PACKAGES); do \
	  cmd="$$cmd,'$$_pkg'"; \
	done; \
	cmd="$$cmd);"; \
	octave -H -q --eval "$$cmd;"

# No spaces in eval argument please!!
checkpkg/%: cleancheck mkpkg/%
	@echo "Running test code for $(opkg) and its dependencies" ; \
	cd sandbox; \
	$(TOPDIR)/admin/mktests.sh code; \
	$(RUN_OCTAVE) --eval "pkg('load','all');fntests" ; \
	if [ ! -e ../fntests.log ]; then touch ../fntests.log; fi ; \
	cat fntests.log >> $(TESTLOG); \
	cd ..

icheckpkg/%: clencheck mkpkg/%
	@echo "Running demo code for $(opkg) and its dependencies" ; \
	cd sandbox; \
	echo 'disp("starting demos...")' > fndemos.m; \
	for file in `grep -l '^%!demo' code/*/*/*.{cc,m}` ; do \
	  echo "demo('$$file');" >> fndemos.m ; done
	$(RUN_OCTAVE) -q fndemos.m

cleancheck:
	@if [ -d sandbox/ ]; then rm -rf sandbox; fi ; \
	mkdir sandbox; \
	cd sandbox; \
	echo "global OCTAVE_PACKAGE_PREFIX;" > .octaverc ; \
	echo "OCTAVE_PACKAGE_PREFIX=[pwd() '/install'];" >> .octaverc ; \
	cd ..

# For now assume that there is only one version of the package for 
# dependencies. Some version check code should be added!!
mkpkg/%:
	@echo "Building $(opkg) and its dependencies"; \
	cd sandbox; \
	if [ ! -d install ]; then mkdir install; fi ; \
	if [ ! -d code ]; then mkdir code; fi; \
	cd code; tar xzf ../../$(opkg); cd ..; \
	pkgs="'../$(opkg)'"; \
	until $(RUN_OCTAVE) --eval "pkg('install',$$pkgs)" 2> baddeps; do \
	  deps=`cat baddeps | grep " needs " | sed -e 's/^.*needs\s\+\(\S*\).*$$/\1/'`; \
	  ops=`cat  baddeps | grep " needs " | sed -e 's/^.*needs\s\+\S*\s\+\(\S*\).*$$/\1/'`; \
	  vers=`cat  baddeps | grep " needs " | sed -e 's/^.*\s\+\(\S*\)\s*$$/\1/'`; \
	  for _dep in $$deps; do \
	    for _dir in $(PKGDIRS); do \
	      if [ -d ../$$_dir ]; then \
		_fdep=`find ../$$_dir -name "$$_dep*"`; \
		if [ -n "$$_fdep" ]; then \
		  pkgs="'$$_fdep',$$pkgs"; \
		  cd code; tar xzf ../$$_fdep; cd ..; \
		  break 2; \
		fi; \
	      fi; \
	    done; \
	  done; \
	done; \
	cd ..

srpm/%:
	@$(TOPDIR)/admin/make_rpm $(opkg) $(TOPDIR)/admin/rpm_template.in $(RPMDIR)

run:
	cd sandbox; \
	$(RUN_OCTAVE)
