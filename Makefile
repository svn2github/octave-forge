
include Makeconf

ifeq ($(MPATH),$(OPATH))
  LOADPATH = $(MPATH)//:
else
  LOADPATH = $(MPATH)//:$(OPATH)//:
endif

all:
	@cd main && $(MAKE)
	@cd extra && $(MAKE)
	@cd nonfree && $(MAKE)
	@cd FIXES && $(MAKE)

install:
	@chmod a+x $(INSTALLOCT)
	@if test -f FIXES/NOINSTALL ; then \
	    echo skipping FIXES ; \
	else \
	    echo installing FIXES to $(MPATH)/FIXES ; \
	    ./$(INSTALLOCT) FIXES $(MPATH)/FIXES $(OPATH) $(XPATH) ; \
	fi
	@cd main && $(MAKE) install
	@cd extra && $(MAKE) install
	@cd nonfree && $(MAKE) install
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

clean:
	-$(RM) octave-core octave *~ configure.in
	@cd main && $(MAKE) clean
	@cd extra && $(MAKE) clean
	@cd nonfree && $(MAKE) clean
	@cd FIXES && $(MAKE) clean

distclean: clean
	-$(RM) Makeconf octinst.sh config.cache config.status config.log

dist: distclean
	@echo Follow the instructions in octave-forge/release.sh

#	find . -name CVS -print > /tmp/octave-forge.CVS
#	tar czf ../octave-forge-`date +%Y.%m.%d`.tar.gz -X /tmp/octave-forge.CVS -C .. octave-forge
#	-$(RM) /tmp/octave-forge.CVS
