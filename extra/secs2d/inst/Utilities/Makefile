OCTDIR=oct
OBJDIR=obj
RM=rm -f 
RMDIR=rmdir 

ccfiles  := $(wildcard *.cc)
octfiles := $(patsubst %.cc, $(OCTDIR)/%.oct, $(ccfiles) )
objfiles := $(patsubst %.cc, $(OBJDIR)/%.o,   $(ccfiles) )



all: $(octfiles)

mk_obj_dir:
	if ! [ -a $(OBJDIR)  ];\
	then mkdir $(OBJDIR);\
	fi 

$(OBJDIR)/%.o: mk_obj_dir %.cc
	mkoctfile -c $(patsubst $(OBJDIR)/%.o, %.cc, $@ ) -o $@

mk_oct_dir:
	if ! [ -a $(OCTDIR)  ];\
	then mkdir $(OCTDIR);\
	fi

$(OCTDIR)/%.oct:  $(OBJDIR)/%.o $(filter-out $<, $(objfiles) ) mk_oct_dir
	mkoctfile -s $< $(filter-out $<, $(objfiles) ) -o $@
	strip -x $@

.PRECIOUS: $(objfiles)

list:
	@echo $(ccfiles)
	@echo $(objfiles)
	@echo $(octfiles)

clean: 
	$(RM) $(objfiles)

distclean: clean
	$(RM) $(octfiles)
	if [ -a $(OBJDIR) ] ; then $(RMDIR) $(OBJDIR) ; fi
	if [ -a $(OCTDIR) ] ; then $(RMDIR) $(OCTDIR) ; fi

