# assumptions:
#   build happens in /c/src/cygwin/octave-2.1.xx
#   source is in /c/src/octave-2.1.xx
#   octave-forge is in /c/src/octave-forge
#   install into /opt/octave-2.1.xx
ROOT=/c/src
OCTVER=2.1.58
BUILD=$(ROOT)/cygwin/octave-$(OCTVER)
SOURCE=$(ROOT)/octave-$(OCTVER)
FORGE=$(ROOT)/octave-forge
ADMIN=$(FORGE)/admin/Windows
DEST=/opt/octave-$(OCTVER)

$(warning ADMIN=$(ADMIN))
$(warning SOURCE=$(SOURCE))
$(warning BUILD=$(BUILD))
$(warning DEST=$(DEST))
$(warning OCTVER=$(OCTVER))

EXTERNAL_PACKAGES=fftw3 hdf5 lapack gnuplot gsl ginac image qhull
PACKAGE_TARGETS=$(patsubst %,$(DEST)/unpack.%,$(EXTERNAL_PACKAGES))

# cygkey and regkey must be exactly the same length
cygkey=Cygnus Solutions
regkey=GNUoctave $(OCTVER)

.PHONY: all setup stdc++ ranlibhack confighack config build check install strip docs cygwin forge

all: build check install cygwin forge strip docs
	@echo "Done octave build: test using $(DEST)/bin/octave"


# ==== create install directory, unpack dependencies, and generate stdc++ dll
setup: $(DEST) stdc++ $(PACKAGE_TARGETS)
$(DEST): 
	@echo "Preparing $(DEST) environment"
	-mkdir $(DEST)
	-mkdir $(DEST)/bin
	-mkdir $(DEST)/lib
	-mkdir $(DEST)/doc

$(DEST)/unpack.% : /opt/%.tar.bz2 ; tar xjf $< -C $(DEST) ; touch $@

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

config: config.octave
config.octave: setup ranlibhack confighack $(ADMIN)/octave-config
	@echo "Configuring octave $(OCTVER): results in config.octave"
	cd $(BUILD) && $(ADMIN)/octave-config > $(ADMIN)/config.octave 2>&1

# ==== build octave
build: build.octave
build.octave: config
	@echo "Building $(OCTVER): results in build.octave"
	cd $(BUILD) && $(MAKE) -k > $(ADMIN)/build.octave 2>&1

check: check.octave
check.octave: build
	@echo "Checking $(OCTVER): results in check.octave"
	cd $(BUILD) && PATH=$(DEST)/bin:$(PATH) $(MAKE) check > $(ADMIN)/check.octave 2>&1

install: install.octave
install.octave: build
	# omit_deps=1 for faster install
	# don't use install-strip for now since it strips the libs
	@echo "Installing $(OCTVER): results in install.octave"
	cd $(BUILD) && make omit_deps=1 install > $(ADMIN)/install.octave 2>&1

# ==== strip octave
strip: install
	@echo "Stripping binaries for smaller distribution"
	strip $(DEST)/bin/*
	strip $(DEST)/base/oct/*
	strip $(DEST)/site/oct/*/*

# ==== install documentation
docs: build
	@echo "Installing documentation"
	cd $(BUILD)/doc/refcard && dvipdf refcard-letter.dvi
	mkdir $(DEST)/doc
	cp $(BUILD)/doc/refcard/refcard-letter.pdf $(DEST)/doc
	mkdir $(DEST)/interpreter
	cp $(BUILD)/interpreter/*.html $(DEST)/doc/interpreter

# ==== generate a cygwin environment
cygwin: cygwin.octave
# Octave requires a hacked version of the cygwin dll so
# that it doesn't conflict with an existing cygwin installation.
# These are stored in the cygwin directory of the installation
# which gets mounted as /bin in the installed system.  The bin
# directory itself gets mounted as /usr/bin in the installed
# system.  By keeping these separate, it is possible to run
# octave from either the hacked cygwin or the users own cygwin,
# assuming the cygwin1.dll API hasn't changed.
cygwin.octave: in=/bin
cygwin.octave: out=$(DEST)/cygwin
cygwin.octave: setup $(DEST)/cygwin/cygwin1.dll
	@echo "Building cygwin support"
	-mkdir $(out)
    
	# Runtime support
	cd $(in)&& cp -a cygpcre.dll cygncurses6.dll cygreadline5.dll $(out)

	# Terminal support
	# cd $(in)&& cp -a run.exe rxvt.exe libW11.dll $(out)

	# Utility functions --- we need a lot more these; see for
	# example the list of commands in the Linux Standard Base
	# specification at http://www.linuxbase.org
	cd $(in)&& cp -a mount.exe umount.exe mkdir.exe rmdir.exe mkfifo.exe mknod.exe $(out)
	cd $(in)&& cp -a basename.exe expr.exe mv.exe rm.exe ln.exe ls.exe ps.exe sed.exe sh.exe touch.exe $(out)

	# Cygwin specific utility functions
	cd $(in)&& cp -a cygpath.exe regtool.exe $(out)

	# help and pager
	cd $(in)&& cp -a info.exe infokey.exe makeinfo.exe less.exe lessecho.exe lesskey.exe $(out)

	# These don't seem to be used:
	# cd $(in) && cp {cygz,cygncurses++6}.dll $(out)
	# cd $(in) && cp {mkpasswd,cygserver}.exe $(out)
	touch $(ADMIN)/cygwin.octave

# program to substitute one string for another of the same length
# in a binary file.
$(ADMIN)/bsubst: $(ADMIN)/bsubst.c
	$(CC) -O2 -o $< $@

$(DEST)/cygwin/cygwin1.dll: /bin/cygwin1.dll $(ADMIN)/bsubst
	@echo "Copy cygwin1.dll to $(DEST)/cygwin with registry key <$(octkey)>"
	$(ADMIN)/bsubst /bin/cygwin1.dll $(DEST)/cygwin/cygwin1.dll $(cygkey) $(octkey)

# ==== build octave-forge
forge: config.forge build.forge check.forge install.forge

clean.forge:
	@echo "Cleaning octave-forge"
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

