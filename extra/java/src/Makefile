sinclude ./Makeconf
export LFLAGS

PROGS = __java__.oct octave.jar

JAVASRC = ClassHelper.java OctClassLoader.java Octave.java OctaveReference.java Matrix.java
JAVADIR = org/octave

JAVA_SOURCES = $(addprefix $(JAVADIR)/, $(JAVASRC))
JAVA_CLASSES = $(patsubst %.java, %.class, $(JAVA_SOURCES))

ifeq ($(HAVE_JAVA),yes)
all: $(PROGS)
	@if test -f" FILES"; then \
	  rm -f FILES; \
	fi; \
	touch FILES; \
	for _f in $(PROGS); do \
	  echo $$_f >> FILES; \
	done
else
all:
	@echo "Java support not compiled"
endif

__java__.oct: __java__.cc
	$(MKOCTFILE) $(JAVA_INCS) -o $@ $^ $(JAVA_LIBS)

octave.jar: $(JAVA_CLASSES)
	-rm -f $@
	$(JAR) cf $@ $(JAVA_CLASSES)

$(JAVA_CLASSES): $(JAVA_SOURCES)
	$(JAVAC) -source 1.2 -target 1.2 $(JAVA_SOURCES)

clean:
	-rm *.o core octave-core *.oct *~
	-rm octave.jar $(JAVA_CLASSES) FILES
