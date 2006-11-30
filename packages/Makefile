sinclude ../Makeconf

odir = $(notdir $@)
opkg = $(strip $(subst / ,/,$(wordlist 2,10000,$(subst /,/ ,$@))))

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif
RUN_OCTAVE= HOME=`pwd` $(TOPDIR)/admin/run_forge $(OCTAVE) -H -q --no-site-file
PKGDIRS = $(filter-out packages www, $(patsubst $(TOPDIR)/%/, %, $(dir $(wildcard $(TOPDIR)/*/Makefile))))
PACKAGES = $(filter $(patsubst %,%/%,$(PKGDIRS)), $(wildcard */*.tar.gz))
TESTLOG=$(TOPDIR)/packages/fntests.log
RPMDIR=RPM

.PHONY: $(PKGDIRS) install

# Construct the bundle from the individual packages
all: mkbundle

mkbundle:
	@d=`date +%Y%m%d`; \
	tar cvzf octave-forge-bundle-$$d.tar.gz $(PKGDIRS)

# Do nothing for the package target 
package:

# Assume all packages have .tar.gz extensions
mostlyclean: 
	@rm -fr $(TESTLOG) sandbox *~ *.tar.gz

clean: mostlyclean
	@rm -fr $(PKGDIRS) $(RPMDIR)

check: cleanlog $(patsubst %, checkpkg/%, $(PACKAGES))

icheck: $(patsubst %, icheckpkg/%, $(PACKAGES))

srpms: $(patsubst %, srpm/%, $(PACKAGES)) $(patsubst %, metarpm/%, $(PKGDIRS))

cleanlog:
	@rm -f $(TESTLOG)

install:
	@echo "***  INSTALLING ALL PACKAGES  ***"; \
	echo  "*** This is likely to be long ***"; \
	cmd="pkg('install'"; \
	for _pkg in $(PACKAGES); do \
	  cmd="$$cmd,'$$_pkg'"; \
	done; \
	cmd="$$cmd);"; \
	octave -H -q --eval "$$cmd;"

# No spaces in eval argument please!! Need the addpath(genpath('./'),'-end')
# as the package might include uninstalled code that has tests..
checkpkg/%: cleancheck/% mkpkg/%
	@echo "Running test code for $(opkg) and its dependencies" ; \
	cd sandbox; \
	$(TOPDIR)/admin/mktests.sh code; \
	$(RUN_OCTAVE) --eval "pkg('prefix',[pwd(),'/install']);pkg('local_list',[pwd(),'/install/.octave_packages']);pkg('global_list',[pwd(),'/install/.octave_packages']);pkg('load','all');addpath(genpath('./'),'-end');fntests" ; \
	if [ ! -e $(TESTLOG) ]; then touch $(TESTLOG); fi ; \
	cat fntests.log >> $(TESTLOG); \
	cd ..

icheckpkg/%: cleancheck/% mkpkg/%
	@echo "Running demo code for $(opkg) and its dependencies" ; \
	cd sandbox; \
	echo 'disp("starting demos...")' > fndemos.m; \
	for file in `grep -l '^%!demo' code/*/*/*.{cc,m}` ; do \
	  echo "demo('$$file');" >> fndemos.m ; done
	$(RUN_OCTAVE) -q fndemos.m

cleancheck/%:
	@if [ -d sandbox/ ]; then rm -rf sandbox; fi ; \
	mkdir sandbox;

# For now assume that there is only one version of the package for 
# dependencies. Some version check code should be added!!
mkpkg/%:
	@echo "Building $(opkg) and its dependencies"; \
	cd sandbox; \
	if [ ! -d install ]; then mkdir install; fi ; \
	if [ ! -d code ]; then mkdir code; fi; \
	cd code; tar xzf ../../$(opkg); cd ..; \
	pkgs="'../$(opkg)'"; \
	until $(RUN_OCTAVE) --eval "pkg('prefix',[pwd(),'/install']);pkg('local_list',[pwd(),'/install/.octave_packages']);pkg('global_list',[pwd(),'/install/.octave_packages']);pkg('install',$$pkgs)" 2> baddeps; do \
	  deps=`cat baddeps | grep " needs " | sed -e 's/^.*needs\s\+\(\S*\).*$$/\1/'`; \
	  ops=`cat  baddeps | grep " needs " | sed -e 's/^.*needs\s\+\S*\s\+\(\S*\).*$$/\1/'`; \
	  vers=`cat  baddeps | grep " needs " | sed -e 's/^.*\s\+\(\S*\)\s*$$/\1/'`; \
	  if [ -z $$deps ] && [ -z $$ops ] && [ -z $$vers ]; then \
	    echo "Failed to build $(opkg)!!!"; \
	    break; \
	  fi; \
	  for _dep in $$deps; do \
	    for _dir in $(PKGDIRS); do \
	      if [ -d ../$$_dir ]; then \
		_fdep=`find ../$$_dir -name "$$_dep*"`; \
		if [ -n "$$_fdep" ]; then \
		  pkgs="'$$_fdep',$$pkgs"; \
		  break 2; \
		fi; \
	      fi; \
	    done; \
	  done; \
	done; \
	cd ..

srpm/%:
	@if [ -e "/etc/mandriva-release" ] || [ -e "/etc/mandrake-release" ]; then \
	  DIST="mandriva"; \
	elif [ -e "/etc/fedora-release" ]; then \
	  DIST="fedora"; \
	elif [ -e "/etc/redhat-release" ] || [ -e "/etc/redhat_version" ]; then \
	  DIST="redhat"; \
	elif [ -e "/etc/SuSE-release" ]; then \
	  DIST="suse"; \
	elif [ -e "/etc/debian_version" ] || [ -e "/etc/debian_release" ]; then \
	  DIST="debian"; \
	elif [ -e "/etc/ubuntu-release" ]; then \
	  DIST="ubuntu"; \
	elif [ -e "/etc/slackware-release" ] || [ -e "/etc/slackware_version" ]; then \
	  DIST="slackware"; \
	elif [ -e "/etc/yellowdog-release" ]; then \
	  DIST="yellowdog"; \
	elif [ -e "/etc/gentoo-release" ]; then \
	  DIST="gentoo"; \
	elif [ `uname | grep -i mingw` ]; then \
	  DIST="mingw"; \
	elif [ `uname | grep -i cygwin` ]; then \
	  DIST="cygwin"; \
	else \
	  echo "Can not identify the platform"; \
	  exit -1; \
	fi; \
	$(TOPDIR)/admin/make_rpm $(opkg) $(TOPDIR)/admin/rpm_template.in $(RPMDIR) $$DIST

metarpm/%:
	@if [ -d $(opkg) ]; then \
	  $(TOPDIR)/admin/make_rpmmeta $(TOPDIR)/$(opkg) $(TOPDIR)/admin/meta_template.in $(RPMDIR); \
	fi

run:
	cd sandbox; \
	$(RUN_OCTAVE)
