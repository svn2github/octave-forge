
sinclude Makeconf

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif

SUBMAKEDIRS = $(dir $(wildcard */Makefile))

ifdef OCTAVE_FORGE

.PHONY: all install check icheck clean distclean dist $(SUBMAKEDIRS)

all: $(SUBMAKEDIRS)
	@echo "Build complete."
	@echo "Please read FIXES/README before you install."

install: $(SUBMAKEDIRS)
	@echo " "
	@echo "Installation complete."
	@echo " "
	@echo "To use, add the following to .octaverc:"
	@echo "   LOADPATH = [ '$(OPATH):$(MPATH)//:', LOADPATH ];"
	@echo "   EXEC_PATH = [ '$(XPATH):', EXEC_PATH ];"
	@echo " "
	@echo "To uninstall, remove the following:"
	@echo "   MPATH = $(MPATH)"
	@echo "   OPATH = $(OPATH)"
	@echo "   XPATH = $(XPATH)"
	@echo " "
	@echo "Some FIXES may be out of date.  Check the scripts in:"
	@echo "   $(MPATH)/FIXES"
	@echo "   $(OPATH)"
	@echo "against those in your version of Octave."

check:
	$(OCTAVE) -q batch_test.m

icheck:
	$(OCTAVE) -q interact_test.m

clean: $(SUBMAKEDIRS)
	-$(RM) core octave-core octave configure.in

distclean: 
	$(MAKE) clean
	-$(RM) Makeconf octinst.sh config.cache config.status config.log *~

dist: distclean
	@echo Follow the instructions in octave-forge/release.sh

$(SUBMAKEDIRS):
	cd $@ && $(MAKE) $(MAKECMDGOALS)

else

.PHONY: all install

all install:
	@echo "./configure ; make ; make install"

endif
