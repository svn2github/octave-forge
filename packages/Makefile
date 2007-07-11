sinclude ../Makeconf

odir = $(notdir $@)
opkg = $(strip $(subst / ,/,$(wordlist 2,10000,$(subst /,/ ,$@))))

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif
RUN_OCTAVE= HOME=`pwd` $(TOPDIR)/admin/run_forge $(OCTAVE) -H -q --no-site-file
PKGDIRS = $(filter-out packages doc, $(patsubst $(TOPDIR)/%/, %, $(dir $(wildcard $(TOPDIR)/*/Makefile))))
PACKAGES = $(filter $(patsubst %,%/%,$(PKGDIRS)), $(wildcard */*.tar.gz))
TESTLOG=$(TOPDIR)/packages/fntests.log
RPMDIR := $(TOPDIR)/packages/RPM
SPECS = $(wildcard $(RPMDIR)/SPECS/*.spec)
MD5FILE=packages.md5
M4 := m4
MACRO_FILE := ../doc/macros.m4
M4_OPTIONS := --prefix-builtin
PACKAGES_MD5 := http://octave.sourceforge.net/packages.md5

.PHONY: $(PKGDIRS) install

# Construct the bundle from the individual packages
all: compare mkbundle md5

mkbundle:
	@rm -fr $(wildcard octave-forge-bundle-*); \
	d=`date +%Y%m%d`; \
	mkdir octave-forge-bundle-$$d; \
	for pkgdir in $(PKGDIRS); do \
	  ln -s ../$$pkgdir octave-forge-bundle-$$d/$$pkgdir; \
	done; \
	tar czhf octave-forge-bundle-$$d.tar.gz octave-forge-bundle-$$d; \
	rm -fr octave-forge-bundle-$$d

md5: cleanmd5 $(patsubst %, domd5/%, $(PACKAGES)) md5bundle
	@$(M4) $(M4_OPTIONS) $(MACRO_FILE) $(MD5FILE) > $(MD5FILE).tmp; \
	mv -f $(MD5FILE).tmp ../doc/htdocs/$(MD5FILE)

cleanmd5:
	@rm -f $(MD5FILE) $(MD5FILE).tmp

domd5/%:
	@ver=`echo $(opkg) | sed -e "s/.tar.gz$$//" | sed -e "s/^.*-//"`; \
	name=`echo $(opkg) | sed -e "s|^.*/||" | sed -e "s/^\(.*\)-.*.tar.gz$$/\1/"`; \
	dir=`echo $(opkg) | sed -e "s|^\(.*\)/.*$$|\1|"`; \
	file=`echo $(opkg) | sed -e "s|^.*/\(.*\)$$|\1|"`; \
	md5=`cd $$dir; md5sum "$$file"`; \
	echo "$$name $$ver $$md5" | sed -e "s|$$file|__PACKAGE__/$$file?download|" >> $(MD5FILE)

md5bundle:
	@bundle=$(wildcard octave-forge-bundle-*.tar.gz); \
	ver=`echo $$bundle | sed -e "s/.tar.gz$$//" | sed -e "s/^.*-//"`; \
	name=`echo $$bundle | sed -e "s|^.*/||" | sed -e "s/^\(.*\)-.*.tar.gz$$/\1/"`; \
	md5=`md5sum $$bundle`; \
	echo "$$name $$ver $$md5" | sed -e "s|$$bundle|__PACKAGE__/$$bundle?download|" >> $(MD5FILE)

compare: prepare_compare real_compare move_compare

move_compare:
	@for pkgdir in $(PKGDIRS); do \
	  cp -pf compare/toupload/$${pkgdir}/* $${pkgdir}; \
	done

prepare_compare:
	@if [ -d  compare ]; then rm -rf compare; fi; \
	mkdir compare
	@cd compare; \
	wget $(PACKAGES_MD5); \
	url=`cat packages.md5 | grep "bundle" | sed -e "s/^.*\(http[^\S]*\).*$$/\1/"`; \
	wget $$url; \
	bundle=`echo $$url | sed -e "s|^.*/\(.*\).*$$|\1|"`; \
	bundle=`echo $$bundle | sed -e "s|\?download||"`; \
	tar xzf $$bundle;

real_compare:
	@cd compare; \
	if [ -d toupload ]; then rm -fr toupload; fi; \
	mkdir toupload; \
	for _dir in $(PKGDIRS); do \
	  mkdir toupload/$$_dir; \
	done; \
	url=`cat packages.md5 | grep "bundle" | sed -e "s/^.*\(http[^\S]*\).*$$/\1/"`; \
	bundle=`echo $$url | sed -e "s|^.*/\(.*\).*$$|\1|"`; \
	bundle=`echo $$bundle | sed -e "s|\?download||" -e "s|\.tar\.gz||"`; \
	pkgs=`cd ..; find $(PKGDIRS) -name "*.tar.gz"`; \
	for newpkg in $$pkgs; do \
	  newdir=`echo $$newpkg | sed -e "s|^.*/||" | sed -e "s/\.tar.*$$//"`; \
	  newname=`echo $$newdir | sed -e "s/^\(.*\)-.*$$/\1/"`; \
	  oldpkg=`find $$bundle -name "$$newname*" | sort | tail -1`; \
	  if [ "X$${oldpkg}"X = "XX" ]; then \
	    cp -p ../$$newpkg toupload/$$newpkg; \
	    echo "$$newpkg is new"; \
	    upload=yes; \
	  else \
	    olddir=`echo $$oldpkg | sed -e "s|^.*/||" | sed -e "s/\.tar.*$$//"`; \
	    tar xzf $$oldpkg; \
	    mv $$olddir $${olddir}.orig; \
	    tar xzf ../$$newpkg; \
	    if diff -Nrq $$olddir.orig $$newdir >& /dev/null; then \
	      cp -p $$oldpkg toupload/$$newpkg; \
	    else \
	      cp -p ../$$newpkg toupload/$$newpkg; \
	      upload=yes; \
	      oldver=`cat $${olddir}.orig/DESCRIPTION | grep Version | sed -e "s/^.*:\s*\(.*\)\s*$$/\1/"`; \
	      newver=`cat $${newdir}/DESCRIPTION | grep Version | sed -e "s/^.*:\s*\(.*\)\s*$$/\1/"`; \
	      if [ "$$oldver" = "$$newver" ]; then \
	        samever=yes; \
	        echo "*** $$newpkg differs from uploaded version but has same version"; \
	      else \
	        echo "$$newpkg differs from uploaded version"; \
              fi; \
	    fi; \
	  fi; \
	  rm -fr $$olddir.orig $$newdir; \
	done; \
	if [ "X$${samever}"X = "XX" ]; then \
	  if [ "X$${upload}X" = "XX" ]; then \
	    echo "Nothing to do"; \
	  else \
	    echo "Please upload packages/files in directories: $(PKGDIRS)"; \
	  fi; \
	else \
	  echo "*** Please fix the version numbering noted above before proceding"; \
	  exit -1; \
	fi;

# Do nothing for the package target 
package:

# Assume all packages have .tar.gz extensions
mostlyclean: 
	@rm -fr $(TESTLOG) sandbox *~ *.tar.gz compare

clean: mostlyclean
	@rm -fr $(PKGDIRS) $(RPMDIR) $(MD5FILE)

check: cleanlog $(patsubst %, checkpkg/%, $(PACKAGES))

icheck: $(patsubst %, icheckpkg/%, $(PACKAGES))

srpms: $(patsubst %, srpm/%, $(PACKAGES)) $(patsubst %, metarpm/%, $(PKGDIRS))

# If you want this target to work, you'll have to remoce the SPEC files that
# won't build on your platform. Typically these are the platform specific
# packages such as octave_windows.spec or octave_macosx.spec
rpms: rpmdirs $(patsubst %, rpm/%, $(SPECS)) 

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

# No spaces in eval argument please!! Need the addpath([pwd(),"/code"],'-end')
# as the package might include uninstalled code that has tests..
checkpkg/%: cleancheck/% mkpkg/%
	@echo "Running test code for $(opkg) and its dependencies" ; \
	cd sandbox; \
	if [ ! -d code ]; then mkdir code; fi; \
	cd code; tar xzf ../../$(opkg); cd ..; \
	$(TOPDIR)/admin/mktests.sh code; \
	$(RUN_OCTAVE) --eval "pkg('unload','all');addpath(genpath([pwd(),'/code']),'-end');pkg('prefix',[pwd(),'/install']);pkg('local_list',[pwd(),'/install/.octave_packages']);pkg('global_list',[pwd(),'/install/.octave_packages']);pkg('load','all');fntests" ; \
	if [ ! -e $(TESTLOG) ]; then touch $(TESTLOG); fi ; \
	cat fntests.log >> $(TESTLOG); \
	cd ..

icheckpkg/%: cleancheck/% mkpkg/%
	@echo "Running demo code for $(opkg) and its dependencies" ; \
	cd sandbox; \
	if [ ! -d code ]; then mkdir code; fi; \
	cd code; tar xzf ../../$(opkg); cd ..; \
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
	pkgs="'../$(opkg)'"; \
	until $(RUN_OCTAVE) --eval "pkg('unload','all');pkg('prefix',[pwd(),'/install']);pkg('local_list',[pwd(),'/install/.octave_packages']);pkg('global_list',[pwd(),'/install/.octave_packages']);pkg('install',$$pkgs)" 2> baddeps; do \
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

rpmdirs:
	@if [ ! -d  $(RPMDIR)/BUILD ]; then mkdir $(RPMDIR)/BUILD; fi; \
	if [ ! -d  $(RPMDIR)/RPMS ]; then mkdir $(RPMDIR)/RPMS; fi; \
	if [ ! -d  $(RPMDIR)/TMP ]; then mkdir $(RPMDIR)/TMP; fi; \
	for rpmdir in athlon i386 i486 i586 i686 noarch; do \
	  if [ ! -d  $(RPMDIR)/RPMS/$$rpmdir ]; then \
	    mkdir $(RPMDIR)/RPMS/$$rpmdir; \
          fi; \
	done;

rpm/%:
	rpm -bb --define '_topdir $(RPMDIR)' --define '_tmppath $(RPMDIR)/TMP' $(opkg)

metarpm/%:
	@if [ -d $(opkg) ]; then \
	  $(TOPDIR)/admin/make_rpmmeta $(TOPDIR)/$(opkg) $(TOPDIR)/admin/meta_template.in $(RPMDIR); \
	fi

run:
	cd sandbox; \
	$(RUN_OCTAVE)
