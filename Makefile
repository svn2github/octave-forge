
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

.PHONY: all install packages package check icheck srpms

all: clearlog packages
	@echo "Packaging finished."
	@if test -f build.fail ; then cat build.fail ;\
	  echo "Some functions failed to be packed (search build.log for errors)." ;\
	  echo "This should not happen and if it does it is a bug in the package creation" ; \
	  echo "process."; \
          false; fi
	@echo "You can find the individual packages in the sub-directories of packages/";
	@echo "and bundles of these packages in packages/ itself. Please run 'make check' to"
	@echo "ensure that the packages are useable and that all dependencies are correct."

# Use the structure below to change MAKECMDGOALS to "package"
package: subdirs
packages:
	@$(MAKE) -k package
	@$(MAKE) -C packages mkbundle

install: installpause clearlog packages
	@$(MAKE) -C packages $(MAKECMDGOALS)
	@echo "Type \"pkg('load','all')\" at the octave prompt to start"
	@echo "using the installed packages"

installpause:
	@echo "***  The install target is deprecated and the individual  ***"
	@echo "*** packages should be installed using the Octave package ***"
	@echo "***          manager. Press any key to continue.          ***"
	@read -n 1

check:
	@$(MAKE) -C packages $(MAKECMDGOALS)

icheck:
	@$(MAKE) -C packages $(MAKECMDGOALS)

srpms: clearlog packages
	@$(MAKE) -C packages $(MAKECMDGOALS)
	@echo "*** You can find the built SRPMs in packages/RPM/SRPMS ***"

www: clearlog packages
	@$(MAKE) -C www

doxygen:
	@$(MAKE) -C www doxygen

else

.PHONY: all install srpms

all install srpms:
	@echo "./configure ; make"

endif

.PHONY: clean distclean dist checkindist changelog

clean: clearlog subdirs
	-$(RM) fntests.m fntests.log
	-$(RM) core octave-core octave configure.in

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
