# Makefile and README for octave SuperLU routines
# $Id$
#
# AUTHOR:  Andy Adler <adler AT ncf DOT ca>
# 
# COPYRIGHT:
# Copyright (C) 1998-2000 Andy Adler
# 
#    This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#    This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#    You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Special Build Instructions:
#
# BUILD WITH DMALLOC CHECKING
# 0. Install dmalloc from dmalloc.org
# 1.  CCDEFS = -DVERBOSE -DUSE_DMALLOC -DANDYS_SEGFAULT_OVERRIDE -DVERBOSE
# 2.  DLIBS = -ldmallocxx -ldmalloc
# 
# running test
#export DMALLOC_OPTIONS=debug=0x4f47d03,inter=100,log=logfile
# rm logfile;  run octave code ; clear variables ; exit
# look at logfile


# CCDEFS = -DVERBOSE
# CCDEFS = -DVERBOSE -DUSE_DMALLOC -DANDYS_SEGFAULT_OVERRIDE
# DLIBS = -ldmallocxx -ldmalloc
# DLIBS = -lefence
# CCDEFS = -DVERBOSE -v
# CCDEFS = -v
# CCDEFS = -DANDYS_SEGFAULT_OVERRIDE -DVERBOSE -DDEBUG
  CCDEFS = -DNDEBUG
sinclude ../../Makeconf

ifndef OCTAVE_FORGE

    OCTAVE   =   octave$(OCTVER)
    MKOCTFILE= mkoctfile$(OCTVER) 
    AR= ar
    RANLIB=ranlib
    MKOCTLINK = ln -s
    HAVE_ND_ARRAYS = -DHAVE_ND_ARRAYS
    TYPEID_HAS_CLASS = -DTYPEID_HAS_CLASS
    CLASS_HAS_LOAD_SAVE = -DCLASS_HAS_LOAD_SAVE
    HAVE_OCTAVE_CONCAT = -DHAVE_OCTAVE_CONCAT
    HAVE_OCTAVE_UPLUS = -DHAVE_OCTAVE_UPLUS

endif

# Use same C compiler and options as mkoctfile
CC       =  $(shell $(MKOCTFILE) -p CC)
CFLAGS   =  $(shell $(MKOCTFILE) -p CFLAGS) 
CPICFLAG =  $(shell $(MKOCTFILE) -p CPICFLAG)

NAME     =   make_sparse
OBJLINKS = $(patsubst %,%$(OCTLINK), \
	spfind sparse full splu nnz spinv is_sparse spabs \
	is_real_sparse is_complex_sparse spimag spreal)
SUPERLU  =   SuperLU
S_INC=   -I$(SUPERLU)/SRC/ -I$(SUPERLU)/CBLAS

# Special defines for SuperLU
# 1. we need to define Add_ so that blas links up with the
#     octave definitions
# 2. we need to override USER_ABORT(msg), USER_MALLOC(size)
#         and USER_FREE(addr) to provide our own implemetations
SUPERLU_DEFS = -DAdd_  \
               -D"USER_MALLOC=oct_sparse_malloc" \
               -D"USER_ABORT=oct_sparse_fatalerr" \
               -D"USER_FREE=oct_sparse_free"

OCT_DEFS= $(CCDEFS) $(HAVE_ND_ARRAYS) \
          $(TYPEID_HAS_CLASS) $(CLASS_HAS_LOAD_SAVE) \
	  $(HAVE_OCTAVE_CONCAT) $(HAVE_OCTAVE_UPLUS)

OCTOBJ= sparse_ops.o make_sparse.o sparse_full.o sparse_inv.o \
        complex_sparse_ops.o

LIBSUPERLU = libsuperlu.a

S_SRC  = $(SUPERLU)/SRC
S_CBLAS= $(SUPERLU)/CBLAS

ALLAUX = $(S_SRC)/superlu_timer.o   $(S_SRC)/lsame.o \
         $(S_SRC)/util.o            $(S_SRC)/memory.o \
         $(S_SRC)/get_perm_c.o      $(S_SRC)/mmd.o \
         $(S_SRC)/sp_coletree.o     $(S_SRC)/sp_preorder.o \
         $(S_SRC)/sp_ienv.o         $(S_SRC)/relax_snode.o \
         $(S_SRC)/xerbla.o          $(S_SRC)/colamd.o

DZLAUX = $(S_SRC)/dlamch.o \
         $(S_CBLAS)/dmyblas2.o $(S_CBLAS)/zmyblas2.o

DLUSRC = $(S_SRC)/dgssv.o           $(S_SRC)/dgssvx.o \
         $(S_SRC)/dsp_blas2.o       $(S_SRC)/dsp_blas3.o \
         $(S_SRC)/dgscon.o          $(S_SRC)/dlacon.o \
         $(S_SRC)/dlangs.o          $(S_SRC)/dgsequ.o \
         $(S_SRC)/dlaqgs.o          $(S_SRC)/dpivotgrowth.o \
         $(S_SRC)/dgsrfs.o          $(S_SRC)/dgstrf.o \
         $(S_SRC)/dgstrs.o          $(S_SRC)/dcopy_to_ucol.o \
         $(S_SRC)/dsnode_dfs.o      $(S_SRC)/dsnode_bmod.o \
         $(S_SRC)/dpanel_dfs.o      $(S_SRC)/dpanel_bmod.o \
         $(S_SRC)/dreadhb.o         $(S_SRC)/dcolumn_dfs.o \
         $(S_SRC)/dcolumn_bmod.o    $(S_SRC)/dpivotL.o \
         $(S_SRC)/dpruneL.o         $(S_SRC)/dmemory.o \
         $(S_SRC)/dutil.o

ZLUSRC = $(S_SRC)/zgssv.o           $(S_SRC)/zgssvx.o \
         $(S_SRC)/zsp_blas2.o       $(S_SRC)/zsp_blas3.o \
         $(S_SRC)/zgscon.o          $(S_SRC)/zlacon.o \
         $(S_SRC)/zlangs.o          $(S_SRC)/zgsequ.o \
         $(S_SRC)/zlaqgs.o          $(S_SRC)/zpivotgrowth.o \
         $(S_SRC)/zgsrfs.o          $(S_SRC)/zgstrf.o \
         $(S_SRC)/zgstrs.o          $(S_SRC)/zcopy_to_ucol.o \
         $(S_SRC)/zsnode_dfs.o      $(S_SRC)/zsnode_bmod.o \
         $(S_SRC)/zpanel_dfs.o      $(S_SRC)/zpanel_bmod.o \
         $(S_SRC)/zreadhb.o         $(S_SRC)/zcolumn_dfs.o \
         $(S_SRC)/zcolumn_bmod.o    $(S_SRC)/zpivotL.o \
         $(S_SRC)/zpruneL.o         $(S_SRC)/zmemory.o \
         $(S_SRC)/zutil.o           $(S_SRC)/dcomplex.o

S_DOUBLE= $(DLUSRC) $(ALLAUX) $(DZLAUX) $(ZLUSRC)

all: $(NAME).oct $(OBJLINKS) sptest.m 

sptest.m: buildtests.sh
	${SHELL} buildtests.sh preset

sprandomtest.m: buildtests.sh
	${SHELL} buildtests.sh random

$(S_DOUBLE):%.o:%.c
	$(CC) $(CFLAGS) $(CPICFLAG) $(S_INC) $(SUPERLU_DEFS) -c $< -o $@

$(OCTOBJ): make_sparse.h
sparse_ops.o complex_sparse_ops.o: sparse_ops.h

$(OCTOBJ): %.o: %.cc
	$(MKOCTFILE) -c $< $(S_INC) $(OCT_DEFS) -o $@

$(LIBSUPERLU): $(S_DOUBLE)
	$(AR) $(ARFLAGS) $(LIBSUPERLU) $(S_DOUBLE)
	$(RANLIB) $(LIBSUPERLU)

$(NAME).oct: $(OCTOBJ) $(LIBSUPERLU)
	$(MKOCTFILE)  $(OCTOBJ) -o $(NAME).oct  -lsuperlu -L. $(DLIBS)

$(OBJLINKS):
	$(MKOCTLINK) $(NAME).oct $@

test: $(NAME).oct sptest.m
	#export DMALLOC_OPTIONS=debug=0x4f47d03,inter=100,log=logfile
	@echo 
	@echo "Testing sparse functions ..."
	@echo 
	echo sptest | $(OCTAVE) -qf
	@echo 
	@echo "Testing sparse solution for a Finite Element Model ..." 
	@echo 
	$(OCTAVE) -qf fem_test.m

mostlyclean:
	-$(RM) $(NAME).oct $(OBJLINKS) $(OCTOBJ) sptest.log

clean:
	-$(RM) $(NAME).oct $(OBJLINKS) $(OCTOBJ) $(S_DOUBLE) $(LIBSUPERLU) octave-core core *~ sptest.log sptest.m

