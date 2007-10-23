sinclude ../Makeconf


ifeq ($(PKGDIR),)
PKGDIR = ../packages/extra
else
PKGDIR += /extra
endif

# Determine which subdirectories are to be installed.  Of those, determine
# which have their own Makefile.
SUBMAKEDIRS = $(dir $(wildcard */Makefile))
NOINSTALLDIRS = $(dir $(wildcard */NOINSTALL))
BUILDDIRS = $(filter-out $(NOINSTALLDIRS), $(SUBMAKEDIRS))
INSTALLDIRS = $(filter-out $(BUILDDIRS), $(filter-out .svn/ $(NOINSTALLDIRS), $(dir $(wildcard */.))))

.PHONY: all package clean distclean $(SUBMAKEDIRS)

ifdef OCTAVE_FORGE
all: 

package: checkpkgdir $(patsubst %,dopkg/%,$(BUILDDIRS)) $(patsubst %,dopkg2/%,$(INSTALLDIRS))

checkpkgdir:
	@if [ ! -d $(PKGDIR) ]; then mkdir $(PKGDIR); fi

pkg/%:
	@if [ -e "$(opkg)/Makefile" ]; then \
	  $(MAKE) dopkg/$(opkg); \
	else \
	  $(MAKE) dopkg2/$(opkg); \
	fi

dopkg/%:
	@$(MAKE) PKGDIR=$(PKGDIR) -C $(opkg) pre-pkg
	@$(MAKE) PKGDIR=$(PKGDIR) -C $(opkg) pkg/$(opkg)
	@$(MAKE) PKGDIR=$(PKGDIR) -C $(opkg) post-pkg

dopkg2/%:
	@$(MAKE) PKGDIR=$(PKGDIR) -C $(opkg) pre-pkg -f../../Makeconf
	@$(MAKE) PKGDIR=$(PKGDIR) -C $(opkg) pkg/$(opkg) -f../../Makeconf
	@$(MAKE) PKGDIR=$(PKGDIR) -C $(opkg) post-pkg -f../../Makeconf
else
package:
	@echo not yet configured

all:
	@echo not yet configured
endif

clean: $(SUBMAKEDIRS)

# Propogate make to the subdirectory if the goal is a valid target
# in the subdirectory Makefile.
$(SUBMAKEDIRS):
	@echo Processing extra/$@
	@if test -z "$(MAKECMDGOALS)" ; then \
	    cd $@ && $(MAKE) ; \
	elif grep "^$(MAKECMDGOALS) *[:]" $@Makefile >/dev/null; then \
	    cd $@ && $(MAKE) $(MAKECMDGOALS) ; \
	fi
