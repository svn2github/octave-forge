# Makefile and README for octave SuperLU routines
# $Id$
#
# $Log$
# Revision 1.3  2001/10/14 03:06:31  aadler
# fixed memory leak in complex sparse solve
# fixed malloc bugs for zero size allocs
#
# Revision 1.2  2001/10/12 02:24:28  aadler
# Mods to fix bugs
# add support for all zero sparse matrices
# add support fom complex sparse inverse
#
# Revision 1.1.1.1  2001/10/10 19:54:49  pkienzle
# revised heirarchy
#
# Revision 1.7  2001/04/04 02:13:46  aadler
# complete complex_sparse, templates, fix memory leaks
#
# Revision 1.6  2001/03/30 04:36:30  aadler
# added multiply, solve, and sparse creation
#
# Revision 1.5  2001/03/15 15:47:58  aadler
# cleaned up duplicated code by using "defined" templates.
# used default numerical conversions
#
# Revision 1.4  2001/03/06 03:20:12  aadler
# added automatic numeric_conversion_function
#
# Revision 1.3  2001/02/27 03:01:51  aadler
# added rudimentary complex matrix support
#
# Revision 1.2  2000/12/18 03:31:16  aadler
# Split code to multiple files
# added sparse inverse
#
# Revision 1.1  2000/11/11 02:47:11  aadler
# DLD functions for sparse support in octave
#
# Revision 1.2  2000/05/02 00:10:34  andy
# mods to work with 2.1.30
#
#
# INSTRUCTIONS
#
# 0. Check that you have the following files:
#   a Makefile
#   b make_sparse.cc
#   c make_sparse.h
#   d sp_test.m
#   e fem_test.m
#   f superlu2.0patch.diff
#   
# 0a. This is tested to work with octave-2.1.32
#     It works with >2.1.30 if you apply the mkoctfile patch
#     at
# 
# 0b. If you already have a SuperLU subdirectory with
#     SuperLU/SRC and SuperLU/CBLAS then ignore 
#     steps 1-3
# 
# 1. Download SuperLU from one of the following sites
#                          http://www.netlib.org/scalapack/prototype
#                          ftp://ftp.cs.berkeley/pub/src/lapack/SuperLU
#                          http://www.nersc.gov/~xiaoye/SuperLU/
#
# 2. Unpack SuperLU into the directory you'll be building the
#     octave sparse functions from
#
# 3. Apply the patch
#           patch -p0 < superlu2.0patch.diff
#
# 4. Build the octave sparse functions
#           make    in the octave sparse functions directory
#           NOTE: do not run the SuperLU makefiles - 
#                it doesn't build the right objects into the library
#
# This makefile assumes that the SuperLU package has been unpacked
#  in this directory. It compiles files directly from their locations
#  in the SuperLU source. You do not need to use SuperLU makefiles.
#
# SuperLU is available from http://www.netlib.org/scalapack/prototype
#                           ftp://ftp.cs.berkeley/pub/src/lapack/SuperLU
#
# 
# AUTHOR:  Andy Adler <adler@ncf.ca>
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

sinclude ../../Makeconf

NAME     =   make_sparse
OBJLINKS =   spfind.oct sparse.oct full.oct splu.oct nnz.oct spinv.oct
SUPERLU  =   SuperLU
OCTVER   =  # -2.1.32
OCTAVE   =   octave$(OCTVER)
ifndef MKOCTFILE
MKOCTFILE=   mkoctfile$(OCTVER)
endif

AR       =   ar
CPP      =   c++
CC       =   gcc
STRIP    =  strip

S_INC=   -I$(SUPERLU)/SRC/ \
         -I$(SUPERLU)/CBLAS

# CCDEFS = -DVERBOSE 
# CCDEFS = -DVERBOSE -DUSE_DMALLOC -DANDYS_SEGFAULT_OVERRIDE -DVERBOSE
# DLIBS = -ldmallocxx -ldmalloc
# CCDEFS = -DVERBOSE -v
# CCDEFS = -v
# CCDEFS = -DANDYS_SEGFAULT_OVERRIDE -DVERBOSE



# Special defines for SuperLU
# 1. we need to define Add_ so that blas links up with the
#     octave definitions
# 2. we need to override USER_ABORT(msg), USER_MALLOC(size)
#         and USER_FREE(addr) to provide our own implemetations
SUPERLU_DEFS = -DAdd_ -O3  \
               -D"USER_MALLOC(size)=oct_sparse_malloc(size)" \
               -D"USER_ABORT(msg)=oct_sparse_fatalerr(msg)" \
               -D"USER_FREE(addr)=oct_sparse_free(addr)"

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

all: $(NAME).oct # test

$(S_DOUBLE):%.o:%.c
	$(CC) $(S_INC) $(CDEFS) $(SUPERLU_DEFS) -c $< -o $@

$(OCTOBJ): make_sparse.h
sparse_ops.o complex_sparse_ops.o: sparse_ops.h

$(OCTOBJ): %.o: %.cc
	$(MKOCTFILE) -c $< $(S_INC) $(CCDEFS) -o $@

$(LIBSUPERLU): $(S_DOUBLE)
	$(AR) -r $(LIBSUPERLU) $(S_DOUBLE)

$(NAME).oct: $(OCTOBJ) $(LIBSUPERLU)
	$(MKOCTFILE)  $(OCTOBJ) -o $(NAME).oct  -lsuperlu -L. $(DLIBS)
	$(STRIP) $(NAME).oct
	for i in $(OBJLINKS); do ln -sf $(NAME).oct $$i ; done

test: $(NAME).oct
	#export DMALLOC_OPTIONS=debug=0x4f47d03,inter=100,log=logfile
	@echo 
	@echo "Testing sparse functions ..."
	@echo 
	$(OCTAVE) -qf sp_test.m 2>/dev/null
	@echo 
	@echo "Testing sparse solution for a Finite Element Model ..." 
	@echo 
	$(OCTAVE) -qf fem_test.m

clean:
	-$(RM) $(NAME).oct $(OBJLINKS) $(OCTOBJ) $(S_DOUBLE) $(LIBSUPERLU) octave-core core *~

