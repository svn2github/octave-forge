# assumptions:
#   build happens in /c/src/cygwin/octave-2.1.xx
#   source is in /c/src/octave-2.1.xx
#   octave-forge is in /c/src/octave-forge
#   install into /opt/octave-2.1.xx
ROOT=/c/src
ifeq (,$(OCTVER))
  $(error usage: OCTVER=2.1.xx make)
endif
ifneq (,$(minor))
  nsis_minor=/DMINOR=$minor
endif
BUILD=$(ROOT)/cygwin/octave-$(OCTVER)
SOURCE=$(ROOT)/octave-$(OCTVER)
FORGE=$(ROOT)/octave-forge
ADMIN=$(FORGE)/admin/Windows
DEST=/opt/octave-$(OCTVER)
WINDEST=C:\\opt\\octave-$(OCTVER)
NSIS="/c/Program Files/NSIS/makensis" 
NSISPARS=/DVERSION=$(OCTVER) $(nsis_minor) /DROOT=$(WINDEST)
PACKAGEDIR=/opt

$(warning ADMIN=$(ADMIN))
$(warning SOURCE=$(SOURCE))
$(warning BUILD=$(BUILD))
$(warning DEST=$(DEST))
$(warning OCTVER=$(OCTVER))

EXTERNAL_PACKAGES=fftw3 hdf5 lapack gnuplot gsl ginac image qhull epstk
PACKAGE_TARGETS=$(patsubst %,$(DEST)/unpack.%,$(EXTERNAL_PACKAGES))

# cygkey and octkey must be exactly the same length
cygkey=Cygnus Solutions
octkey=GNUoctave $(OCTVER)

.PHONY: all setup stdc++ ranlibhack confighack config build check \
	install strip docs forge epstk cygwin dist mklinks

all: build check install forge epstk strip docs
	@echo "Done octave build: test using $(DEST)/bin/octave"


# ==== create install directory, unpack dependencies, and generate stdc++ dll
setup: $(DEST) $(BUILD) stdc++ $(PACKAGE_TARGETS)
$(DEST): 
	@echo "Preparing install directory $(DEST)"
	-mkdir $(DEST)
	-mkdir $(DEST)/bin
	-mkdir $(DEST)/lib
	-mkdir $(DEST)/doc
$(BUILD):
	@echo "Preparing build directory $(BUILD)"
	-mkdir $(BUILD)

$(DEST)/unpack.% : $(PACKAGEDIR)/%.tar.bz2 ; tar xjf $< -C $(DEST) ; touch $@

stdc++: $(DEST)/lib/libstdc++.dll.a
$(DEST)/lib/libstdc++.dll.a:
	@echo "Making shared stdc++ in $(DEST)"
	mkdir dll
	cd dll && ar x /usr/lib/libstdc++.a
	gcc -shared -o$(DEST)/bin/stdc++.dll dll/*.o \
		-Wl,--enable-auto-image-base,--out-implib,$(DEST)/lib/libstdc++.dll.a
	$(RM) -rf dll

# ==== octave configure
ranlibhack: ranlibhack.octave
ranlibhack.octave:
	@echo "Moving ranlib/setgmn.f to setgmn.f-orig if necessary"
	if test -f $(SOURCE)/libcruft/ranlib/setgmn.f; then \
	    mv $(SOURCE)/libcruft/ranlib/setgmn.f \
		$(SOURCE)/libcruft/ranlib/setgmn.f-orig; \
	fi
	touch ranlibhack.octave

confighack: confighack.octave
confighack.octave:
	@echo "Changing LAPACK tests from single to double precision if necessary"
	if grep -q cheev $(SOURCE)/configure; then \
	    mv $(SOURCE)/configure $(SOURCE)/configure-orig; \
	    sed -e 's/cheev/zheev/g;s/CHEEV/ZHEEV/g;s/sgemm/dgemm/g;s/SGEMM/DGEMM/g' \
		< $(SOURCE)/configure-orig > $(SOURCE)/configure; \
	fi
	touch confighack.octave

config: setup ranlibhack confighack config.octave
config.octave: $(ADMIN)/octave-config
	@echo "Configuring octave $(OCTVER): results in config.octave"
	cd $(BUILD) && $(ADMIN)/octave-config > $(ADMIN)/config.octave 2>&1

# ==== build octave
build: config build.octave
build.octave: 
	@echo "Building $(OCTVER): results in build.octave"
	cd $(BUILD) && $(MAKE) -k > $(ADMIN)/build.octave 2>&1

check: build check.octave
check.octave: 
	@echo "Checking $(OCTVER): results in check.octave"
	-cd $(BUILD) && PATH=$(DEST)/bin:$(PATH) $(MAKE) check > $(ADMIN)/check.octave 2>&1

install: build install.octave
install.octave: 
	# omit_deps=1 for faster install
	# don't use install-strip for now since it strips the libs
	@echo "Installing $(OCTVER): results in install.octave"
	cd $(BUILD) && make omit_deps=1 install > $(ADMIN)/install.octave 2>&1

# ==== strip octave
strip: install
	@echo "Stripping binaries for smaller distribution"
	strip $(DEST)/bin/*.dll
	strip $(DEST)/bin/*.exe
	strip $(DEST)/base/oct/*.oct
	strip $(DEST)/site/oct/*/*.oct

# ==== install documentation
docs: build
	@echo "Installing documentation"
	cd $(BUILD)/doc/refcard && dvipdf refcard-letter.dvi
	mkdir $(DEST)/doc
	cp $(BUILD)/doc/refcard/refcard-letter.pdf $(DEST)/doc
	mkdir $(DEST)/interpreter
	cp $(BUILD)/interpreter/*.html $(DEST)/doc/interpreter

# ==== generate a cygwin environment
# Octave requires a hacked version of the cygwin dll so
# that it doesn't conflict with an existing cygwin installation.
# This is stored in the cygwin directory of the installation
# which gets mounted as /bin in the installed system.  The octave
# bin directory gets mounted as /usr/bin in the installed
# system.  By keeping these separate, it should be possible to run
# octave from either the hacked cygwin or the users own cygwin,
# assuming the cygwin1.dll API hasn't changed.

# Runtime support DLLs
CYGDLL := $(CYGDLL) cygwin1 cygpcre cygncurses6 cygreadline5

# Terminal support
CYGBIN := $(CYGBIN) run rxvt 
CYGDLL := $(CYGDLL) libW11

# Utility functions --- we need a lot more these; see for
# example the list of commands in the Linux Standard Base
# specification at http://www.linuxbase.org
CYGBIN := $(CYGBIN) mount umount mkdir rmdir mkfifo \
	            mknod basename expr mv rm ln ls ps sed sh touch

# Cygwin specific utility functions
CYGBIN := $(CYGBIN) cygpath regtool

# help and pager
CYGBIN := $(CYGBIN) info infokey makeinfo less lessecho lesskey

# These don't seem to be used:
# CYGDLL := $(CYGDLL) cygz cygncurses++6
# CYGBIN := $(CYGBIN) mkpasswd cygserver

# Tag support files with directory and extension
CYGDIR := $(DEST)/cygwin
CYGSUP := $(patsubst %,$(CYGDIR)/%.dll,$(CYGDLL)) \
	  $(patsubst %,$(CYGDIR)/%.exe,$(CYGBIN))

# Rule to copy things from /bin to /opt/octave-x.x.xx/cygwin
$(CYGDIR)/%: /bin/% ; cp $< $@

cygwin: setup $(CYGDIR) $(CYGSUP)

# program to substitute one string for another of the same length
# in a binary file.
$(ADMIN)/bsubst.exe: $(ADMIN)/bsubst.c
	$(CC) -O2 -o $@ $<

$(CYGDIR)/cygwin1.dll: /bin/cygwin1.dll $(ADMIN)/bsubst.exe
	@echo "Copy cygwin1.dll to $(DEST) with registry key <$(octkey)>"
	$(ADMIN)/bsubst /bin/cygwin1.dll $(CYGDIR)/cygwin1.dll \
		"$(cygkey)" "$(octkey)"

$(CYGDIR):
	-mkdir $(DEST)/cygwin

# ==== build octave-forge
dist: forge cygwin mklinks
	$(NSIS) $(NSISPARS)

mklinks:
	cd $(DEST)/site/oct/octave-forge && ls -l | grep ^l \
		| sed -e "s,^.* \([^ ]*\) -> *\(.*\)$,ln -s \\2 \\1," \
		> mklinks.sh
	cd $(BUILD)/src && $(SOURCE)/src/mk-oct-links -p \
		`cd $(SOURCE)/src/DLD-FUNCTIONS&&ls *.cc|sed -e"s/cc$/df/g"` \
		| sed -e "s,^,ln -s ," > $(DEST)/base/oct/mklinks.sh

# ==== build octave-forge
forge: install config.forge build.forge check.forge install.forge

clean.forge:
	@echo "Cleaning octave-forge"
	-rm config.forge build.forge check.forge install.forge
	cd $(FORGE) && make clean

config.forge:
	@echo "Configuring octave-forge --- I hope it is cleaned and refreshed"
	cd $(FORGE) && ./autogen.sh
	cd $(FORGE) && OCTAVE=$(DEST)/bin/octave MKOCTFILE=$(DEST)/bin/mkoctfile \
		./configure --prefix=$(DEST) > $(ADMIN)/config.forge 2>&1

build.forge: config.forge
	@echo "Building octave-forge"
	cd $(FORGE) && make -k > $(ADMIN)/build.forge 2>&1

check.forge: build.forge
	@echo "Checking octave-forge"
	cd $(FORGE) && make check > $(ADMIN)/check.forge 2>&1

install.forge: build.forge
	@echo "Installing octave-forge"
	cd $(FORGE) && make install > $(ADMIN)/install.forge 2>&1

run.forge:
	@echo "Running with an octave-forge environment"
	cd $(FORGE) && make run
