
sinclude Makeconf

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif
RUN_OCTAVE=admin/run_forge $(OCTAVE) --norc

SUBMAKEDIRS = $(dir $(wildcard */Makefile))
.PHONY: subdirs clearlog $(SUBMAKEDIRS)

ifdef OCTAVE_FORGE

.PHONY: all install check icheck

all: clearlog subdirs
	@echo "Build finished."
	@if test -f build.fail ; then cat build.fail ;\
	  echo "Some functions failed to compile (search build.log for errors) but many" ;\
	  echo "other functions will still work correctly.  Run 'make check' to see" ;\
	  echo "what works.  Run 'make install' to install what has been built." ;\
          false; fi
	@echo "Please read FIXES/README before you install."

install: subdirs
	@echo " "
	@echo "Installation complete."
	@echo " "
	@echo "To use, add the following to .octaverc:"
	@echo "   LOADPATH = [ '$(OPATH):$(MPATH)//:', LOADPATH ];"
	@echo "   EXEC_PATH = [ '$(XPATH):', EXEC_PATH ];"
	@echo " "
	@echo "To uninstall, remove the following:"
	@echo "   MPATH    = $(MPATH)"
	@echo "   OPATH    = $(OPATH)"
	@echo "   XPATH    = $(XPATH)"
	@echo "   ALTMPATH = $(ALTMPATH)"
	@echo "   ALTOPATH = $(ALTOPATH)"	
	@echo " "
	@echo "Some FIXES may be out of date.  Check the scripts in:"
	@echo "   $(MPATH)/FIXES"
	@echo "   $(OPATH)"
	@echo "against those in your version of Octave."

check:
	admin/mktests.sh admin/mkpkgadd
	$(RUN_OCTAVE) -q fntests.m
	$(RUN_OCTAVE) -q batch_test.m

icheck:
	@echo 'disp("starting demos...")' > fndemos.m
	@for file in `grep -l '^%!demo' */*/*.{cc,m}` ; do \
		echo "demo('$$file');" >> fndemos.m ; done
	$(RUN_OCTAVE) -q fndemos.m
	$(RUN_OCTAVE) -q interact_test.m

run:
	$(RUN_OCTAVE)

else

.PHONY: all install

all install:
	@echo "./configure ; make ; make install"

endif

.PHONY: clean distclean dist checkindist changelog

clean: clearlog subdirs
	-$(RM) fntests.m fntests.log
	-$(RM) core octave-core octave configure.in
	-$(RM) main/*/PKG_ADD extra/*/PKG_ADD

distclean: subdirs
	-$(MAKE) clean
	-$(RM) Makeconf octinst.sh config.cache config.status config.log \
		admin/RPM/octave-forge.spec build.log build.fail *~

dist: checkindist subdirs
	-$(RM) build.log build.fail
	admin/get_authors
	./autogen.sh

checkindist:
	@if test -d CVS; then \
	    echo Follow the instructions in octave-forge/release.sh && false; \
	else true; fi

subdirs: $(SUBMAKEDIRS)
clearlog: ; @-$(RM) build.log build.fail
$(SUBMAKEDIRS):
	@echo Processing $@ | tee -a build.log
	@($(MAKE) -C $@ -k $(MAKECMDGOALS) 2>&1 || \
	   echo "$@ not complete." >>build.fail ) | tee -a build.log
