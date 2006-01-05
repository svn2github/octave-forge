sinclude ../Makeconf

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
ifeq ($(INSTALLDIRS),)
	@echo installing no packages
else
	@for f in $(INSTALLDIRS) ; do \
            echo installing $$f... ; \
            ../$(INSTALLOCT) $$f $(DESTDIR)$(MPATH)/$$f \
		$(DESTDIR)$(OPATH) $(DESTDIR)$(XPATH) \
		$(DESTDIR)$(ALTMPATH)/$$f $(DESTDIR)$(ALTOPATH)/$$f ; \
        done
endif
else
all:
	@echo not yet configured
endif

clean: $(SUBMAKEDIRS)

dist: $(SUBMAKEDIRS)

# Propogate make to the subdirectory if the goal is a valid target
# in the subdirectory Makefile.
$(SUBMAKEDIRS):
	@echo Processing extra/$@
	@if test -z "$(MAKECMDGOALS)" ; then \
	    cd $@ && $(MAKE) ; \
	elif grep "^$(MAKECMDGOALS) *[:]" $@Makefile >/dev/null; then \
	    cd $@ && $(MAKE) $(MAKECMDGOALS) ; \
	fi

