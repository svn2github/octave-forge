octdir = $(prefix)/$(OCTDIR)/gpc

linked_oct_files = \
  gpc_clip.oct \
  gpc_write.oct \
  gpc_read.oct \
  gpc_get.oct \
  gpc_tristrip.oct \
  gpc_is_polygon.oct

oct_SCRIPTS = \
  $(linked_oct_files) \
  gpc_create.oct

m_scriptdir = $(prefix)/$(MDIR)/gpc

m_script_DATA = gpc_plot.m

CCFILES = \
  $(oct_SCRIPTS:.oct=.cc) \
  octave-gpc.cc

OBJFILES = $(CCFILES:.cc=.o)

EXTRA_DIST = \
  bootstrap.sh \
  gpc_plot.m \
  $(CCFILES) \
  octave-gpc.h

%.o: %.cc octave-gpc.h
	$(MKOCTFILE) -v -s -c $<

gpc_create.oct: $(OBJFILES)
	$(MKOCTFILE) -v -s -lgpcl -o $@ $^

%.oct: gpc_create.oct
	ln -f $< $@

install-data-hook:
	for i in $(linked_oct_files) ; \
	  do ln -f $(octdir)/gpc_create.oct $(octdir)/$$i ; \
	done

clean:
	rm -f *.oct *.o *core

.PHONY: clean
