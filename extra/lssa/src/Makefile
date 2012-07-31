MKOCTFILE ?= mkoctfile

all: fastlscomplex.oct #\
#     fastlsreal.oct

fastlscomplex.oct: fastlscomplex.cc
	$(MKOCTFILE) fastlscomplex.cc

# fastlsreal compilation is disabled for the time being
#fastlsreal.oct: fastlsreal.cc
#	$(MKOCTFILE) fastlsreal.cc

# helper function just in case
clean:
	rm *.o *.oct *~ octave-core
