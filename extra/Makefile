include ../Makeconf

# Determine which subdirectories are to be installed.  Of those, determine
# which have their own Makefile.
SUBMAKEDIRS = $(dir $(wildcard */Makefile))
NOINSTALLDIRS = $(dir $(wildcard */NOINSTALL))
BUILDDIRS = $(filter-out $(NOINSTALLDIRS), $(SUBMAKEDIRS))
INSTALLDIRS = $(filter-out CVS/ $(NOINSTALLDIRS), $(dir $(wildcard */.)))

.PHONY: all install clean distclean $(SUBMAKEDIRS)

ifdef OCTAVE_FORGE
all: $(BUILDDIRS)

install: $(BUILDDIRS)
	@test -z "$(NOINSTALLDIRS)" || echo skipping $(NOINSTALLDIRS)
	@for f in $(INSTALLDIRS) ; do \
	    echo installing $$f... ; \
	    ../$(INSTALLOCT) $$f $(MPATH)/$$f $(OPATH) $(XPATH) ; \
	done
else
all:
	@echo not yet configured
endif

clean: $(SUBMAKEDIRS)

# Propogate make to the subdirectory if the goal is a valid target
# in the subdirectory Makefile.
$(SUBMAKEDIRS):
	@if test -z $(MAKECMDGOALS) ; then \
	    cd $@ && $(MAKE) ; \
	elif grep -q "^$(MAKECMDGOALS) *[:]" $@Makefile ; then \
	    cd $@ && $(MAKE) $(MAKECMDGOALS) ; \
	fi

