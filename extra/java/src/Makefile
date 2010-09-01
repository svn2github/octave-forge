sinclude ./Makeconf
export LFLAGS

IMPORT_LIBS = __java__.lib
PROGS = __java__.oct __java__.h octave.jar


JAVASRC = ClassHelper.java OctClassLoader.java Octave.java OctaveReference.java Matrix.java \
          JDialogBox.java DlgListener.java TeXtranslator.java TeXcode.java
JAVADIR = org/octave
RSCDIR  = org/octave/images
IMAGES  = question.png error.png warning.png information.png octave.png

JAVA_SOURCES = $(addprefix $(JAVADIR)/, $(JAVASRC))
JAVA_CLASSES = $(patsubst %.java, %.class, $(JAVA_SOURCES))
JAVA_RSC     = $(addprefix $(RSCDIR)/, $(IMAGES))

ifeq ($(HAVE_JAVA),yes)
all: $(PROGS)
	@if test -f" FILES"; then \
	  rm -f FILES; \
	fi; \
	touch FILES; \
	for _f in $(PROGS); do \
	  echo $$_f >> FILES; \
	done; \
	for _f in $(IMPORT_LIBS); do \
	  if [ -e $$_f ]; then \
	    echo $$_f >> FILES; \
	  fi; \
	done
else
all:
	@echo "Java support not compiled"
endif

__java__.oct: __java__.cc __java__.h
	if [ "X$(JAVA_ARCH)X" = "XX" ]; then \
		$(MKOCTFILE) -DJAVAPKG_BUILD $(JAVA_INCS) -o $@ __java__.cc $(JAVA_LIBS); \
	else \
		$(MKOCTFILE) -DJAVAPKG_BUILD -DJAVA_ARCH=\\\"$(JAVA_ARCH)\\\" -DJAVA_HOME=\\\"$(JAVA_HOME)\\\" $(JAVA_INCS) -o $@ __java__.cc $(JAVA_LIBS); \
	fi

octave.jar: $(JAVA_CLASSES)
	-rm -f $@
	$(JAR) cf $@ $(JAVA_CLASSES) $(JAVA_RSC)

$(JAVA_CLASSES): $(JAVA_SOURCES)
	$(JAVAC) -source 1.3 -target 1.3 $(JAVA_SOURCES)

clean:
	-rm *.o core octave-core *.oct *~
	-rm octave.jar $(JAVA_CLASSES) FILES

distclean realclean : clean
	-rm -r configure config.status config.log autom4te.cache Makeconf
