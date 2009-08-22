sinclude ./Makeconf

JAR_FILES = jhandles.jar $(LIBPRE)gl2ps_java.$(SHLEXT)
CLASSPATH = $(JOGL_JAR)${OCTAVE_PATHSEP}$(OCTAVE_JAR)
JAVA_DIR = org/octave/graphics
JAVA_SOURCES = $(wildcard $(addprefix $(JAVA_DIR)/, *.java))

ifeq ($(HAVE_JAVA),yes)
all: $(JAR_FILES)
	@if test -f" FILES"; then \
	  rm -f FILES; \
	fi; \
	touch FILES; \
	for _f in $(JAR_FILES); do \
	  echo $$_f >> FILES; \
	done
else
all:
	@echo "Java support not compiled"
	@exit -1
endif

test:
	@echo $(JAVA_SOURCES)

jhandles.jar: $(JAVA_SOURCES)
	-rm -f $@
	$(JAVAC) -cp '$(CLASSPATH)' -source 1.3 -target 1.3 $(JAVA_SOURCES)
	$(JAR) cf $@ $(JAVA_DIR)/*.class $(JAVA_DIR)/images/*

$(LIBPRE)gl2ps_java.$(SHLEXT): gl2ps_java.o gl2ps.o
	$(DL_LD) $(DL_LDFLAGS) -o $@ gl2ps_java.o gl2ps.o $(OPENGL_LIBS)

clean:
	-rm -f FILES core octave-core *~ $(JAR_FILES) $(JAVA_DIR)/*.class *.o

%.o: %.c
	$(MKOCTFILE) -v -I. $(JAVA_INCS) -c $<

JH_DIR = org/octave/jhandles
JH_SOURCES = $(wildcard $(addprefix $(JH_DIR)/, *.java))
JH_OBJECTS = graphics-renderer.o gl-graphics-renderer.o glaxescanvas.o

jh.jar: $(JH_SOURCES) jh.dll
	-rm -f $@
	$(JAVAC) -cp '$(CLASSPATH)' -source 1.3 -target 1.3 $(JH_SOURCES)
	$(JAR) cf $@ $(JH_DIR)/*.class

jh.dll: $(JH_OBJECTS)
	$(MKOCTFILE) -o $@ $(JH_OBJECTS) $(OPENGL_LIBS)

__jhandles__.oct: __jhandles__.cc
	$(MKOCTFILE) '-I$(OCTAVE_JAVA_DIR)' $^ '-L$(OCTAVE_JAVAOCT_DIR)' -l__java__
