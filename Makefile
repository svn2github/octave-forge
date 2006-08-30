
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

.PHONY: all install packages package check icheck

all: clearlog packages subdirs
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

install: subdirs
	@echo "There is no longer any install target within octave-forge's CVS"
	@echo "Please install the individual packages using the Octave package"
	@echo "Manager."
	false

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
else

.PHONY: all install

all install:
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
