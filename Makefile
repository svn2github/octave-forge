
sinclude Makeconf

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif
TEST_PATH=$(shell admin/runpath.sh)
RUN_OCTAVE=$(OCTAVE) --norc -p "$(TEST_PATH)"

SUBMAKEDIRS = $(dir $(wildcard */Makefile))

ifdef OCTAVE_FORGE

.PHONY: all install check icheck clean distclean dist $(SUBMAKEDIRS)

all: setup $(SUBMAKEDIRS)
	@echo "Build finished."
	@echo "Please read FIXES/README before you install."
	@if test -f build.fail ; then cat build.fail; false; fi

setup:
	@-$(RM) build.log build.fail

install: $(SUBMAKEDIRS)
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
	admin/mktests.sh
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

clean: $(SUBMAKEDIRS)
	-$(RM) core octave-core octave configure.in

distclean: 
	$(MAKE) clean
	-$(RM) Makeconf octinst.sh config.cache config.status config.log *~

dist: distclean
	@echo Follow the instructions in octave-forge/release.sh

$(SUBMAKEDIRS):
	@echo Processing $@
	@if cd $@ && ! $(MAKE) -k $(MAKECMDGOALS) 2>&1; then \
	   echo "$@ not complete. See $@log for details" >>../build.fail ; \
	fi | tee -a $@log

else

.PHONY: all install

all install:
	@echo "./configure ; make ; make install"

endif
