/*
Sparse matrix functionality for octave, based on the SuperLU package  
Copyright (C) 1998-2000 Andy Adler

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

$Id$

2001-12-04 Paul Kienzle <pkienzle@users.sf.net>
* sparse(i,j,s,...) now checks that the lengths of i,j,s match

*/

#define  SPARSE_COMPLEX_CODE
#include "make_sparse.h"
//
//   These functions override those in SuperLU/SRC/util.c
//


void *
oct_sparse_malloc(int size) {
   // avoid zero byte alloc requests, request a minimum of
   // 1 byte - this is ok becuause free should handle it
   size= MAX(size,1);
#ifdef USE_DMALLOC   
   return _malloc_leap(__FILE__, __LINE__, size);
#else   
   return malloc( MAX(size,1) );
#endif   
#if 0   
   void * vp= malloc( size );
   printf ("allocated %04X : %d\n", (int) vp, size);
   return vp;
#endif   
}  

void
oct_sparse_fatalerr(char *msg) {
   SP_FATAL_ERR( msg );
}  


void
oct_sparse_free(void * addr) {
#ifdef USE_DMALLOC   
   if(addr) _free_leap(__FILE__, __LINE__, addr);
#else   
   if (addr) free( addr );
#endif   
#if 0
   DEBUGMSG("sparse - oct_sparse_free");
   printf ("freeing %04X\n", (int) addr );
   free( addr );
#endif   
}  

// This is required to link properly,
// but isn't necessary for the code
int dtrsv_(char *uplo, char *trans, char *diag, int *n,
        double *a, int *lda, double *x, int *incx)
{
   oct_sparse_fatalerr("DTRSV_ isn't defined: shouldn't get here");
   return 0;
}   

//
// Utility methods for sparse ops
//

void
oct_sparse_expand_bounds( int lim, int& bound,
                          int*& idx,
                          void*& coef, int varsize)
{   
   const int mem_expand = 2;

   DEBUGMSG("growing bounds"); 
   bound*= mem_expand;
   int *   t_idx = (int  *) oct_sparse_malloc((bound) * sizeof(int)); 
   void * t_coef = (void *) oct_sparse_malloc((bound) * varsize    ); 
   if ((t_idx==NULL) || (t_coef == NULL) ) 
      SP_FATAL_ERR("memory error in check_bounds");
 
   memcpy( t_idx , idx , lim*sizeof(int) );
   memcpy( t_coef, coef, lim*varsize     );

   free( idx);
   idx= t_idx;
   free( coef);
   coef= t_coef;
}      


void
oct_sparse_maybe_shrink( int lim, int bound,
                         int*& idx,
                         void*& coef, int varsize) {
   if ( (lim < bound) && (lim > 0) ) {
      idx = (int    *) realloc( idx,  lim*sizeof(int) );
      coef= (void   *) realloc( coef, lim*varsize );
      assert (idx != NULL);
      assert (coef != NULL);
   }
   else if (lim==0) {      
      free( idx ); idx= NULL;
      free( coef); coef=NULL;
   }
}   

void
oct_sparse_Destroy_SuperMatrix( SuperMatrix X) {
   switch( X.Stype ) { 
      case NC:  Destroy_CompCol_Matrix(&X);   break;
      case DN:  Destroy_Dense_Matrix(&X);     break;
      case SC:  Destroy_SuperNode_Matrix(&X); break;
      case NCP: Destroy_CompCol_Permuted(&X); break;
      default:  SP_FATAL_ERR("Bad SuperMatrix Free"); 
   }
}

#ifdef ANDYS_SEGFAULT_OVERRIDE
#include <signal.h>
#endif

DEFUN_DLD (sparse, args, ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{sparse_val} =} sparse (...)\n\
SPARSE: create a sparse matrix\n\
\n\
sparse can be called in the following ways:\n\
\n\
@enumerate\n\
@item @var{S} = sparse(@var{A})  where @var{A} is a full matrix\n\
\n\
@item @var{S} = sparse(@var{i},@var{j},@var{s},@var{m},@var{n},@var{nzmax})  where\n\
   @itemize @w \n\
@var{i},@var{j}   are integer index vectors (1 x nnz) @* \n\
@var{s}     is the vector of real or complex entries (1 x nnz) @* \n\
@var{m},@var{n}   are the scalar dimentions of S @* \n\
@var{nzmax} is ignored (here for compatability with Matlab) @* \n\
\n\
        if multiple values are specified with the same @var{i},@var{j}\n\
        position, the corresponding values in @var{s} will be added\n\
   @end itemize\n\
\n\
@item The following usages are equivalent to (2) above:\n\
   @itemize @w \n\
@var{S} = sparse(@var{i},@var{j},@var{s},@var{m},@var{n})@*\n\
@var{S} = sparse(@var{i},@var{j},@var{s},@var{m},@var{n},'summation')@*\n\
@var{S} = sparse(@var{i},@var{j},@var{s},@var{m},@var{n},'sum')@*\n\
   @end itemize\n\
\n\
@item @var{S} = sparse(@var{i},@var{j},@var{s},@var{m},@var{n},'unique')@*\n\
\n\
   @itemize @w \n\
same as (2) above, except that rather than adding,\n\
if more than two values are specified for the same @var{i},@var{j}\n\
position, then the last specified value will be kept\n\
   @end itemize\n\
\n\
@item @var{S}=  sparse(@var{i},@var{j},@var{sv})          uses @var{m}=max(@var{i}), @var{n}=max(@var{j})\n\
\n\
@item @var{S}=  sparse(@var{m},@var{n})            does sparse([],[],[],@var{m},@var{n},0)\n\
\n\
@var{sv}, and @var{i} or @var{j} may be scalars, in\n\
which case they are expanded to all have the same length\n\
@end enumerate\n\
@seealso{full}\n\
@end deftypefn")
{
#ifdef ANDYS_SEGFAULT_OVERRIDE
signal( SIGSEGV, SIG_DFL );
#endif
   
   static bool sparse_type_loaded         = false;
   static bool complex_sparse_type_loaded = false;

   octave_value retval;

   int nargin= args.length();
   if (nargin < 1 || nargin == 4 || nargin > 6) {
      print_usage ("sparse");
      return retval;
   }

// note: sparse_type needs to be loaded in all cases,
// because complex_sparse * sparse operations need to be defined
   if (! sparse_type_loaded) {
      octave_sparse::register_type ();

#ifdef VERBOSE
      cout << "installing sparse type at type-id = "
           << octave_sparse::static_type_id () << "\n";
#endif          
      install_sparse_ops() ;
      sparse_type_loaded= true;
   }

   bool use_complex = false;
   if (nargin > 2)
      use_complex= args(2).is_complex_type();
   else
      use_complex= args(0).is_complex_type();


   if (use_complex) {
      if (! complex_sparse_type_loaded) {
         octave_complex_sparse::register_type ();

#ifdef VERBOSE
         cout << "installing complex sparse type at type-id = "
              << octave_complex_sparse::static_type_id () << "\n";
#endif          
         install_complex_sparse_ops() ;
         complex_sparse_type_loaded= true;

         assert( 0==complex_sparse_verify_doublecomplex_type() );
      }
   }

   if (nargin == 1) {
      if (use_complex) {
         ComplexMatrix A(args(0).complex_matrix_value ());
	 if (error_state) return retval;
         SuperMatrix sm= oct_matrix_to_sparse( A ) ;
         retval = new octave_complex_sparse ( sm );
      } else {
         Matrix A(args(0).matrix_value ());
	 if (error_state) return retval;
         SuperMatrix sm= oct_matrix_to_sparse( A ) ;
         retval = new octave_sparse ( sm );
      }
   }
   else {
      int m=0,n=0;
      ColumnVector coefA, ridxA, cidxA;
      ComplexColumnVector coefAC;
      int assemble_do_sum=1; // this is now the default in matlab6

      if (nargin == 2) {
         m= (int) args(0).double_value();
         n= (int) args(1).double_value();
	 if (error_state) return retval;
         cidxA = ColumnVector ();
         ridxA = ColumnVector ();
         coefA = ColumnVector ();
      }
      else {
// 
//  I use this clumsy construction so that we can use
//  any orientation of args
         {
             ColumnVector x( args(0).vector_value(false,true) );
             if (error_state) return retval;
             ridxA= x;
         }
         { 
             ColumnVector x( args(1).vector_value(false,true) );
             if (error_state) return retval;
             cidxA= x;
         }
         if (use_complex) {
             ComplexColumnVector x( args(2).complex_vector_value(false,true) );
             coefAC= x;
         }
         else {
             ColumnVector x( args(2).vector_value(false,true) );
             coefA= x;
         }
	 if (error_state) return retval;

	 // Confirm that i,j,s all have the same number of elements
	 int ns;
	 if (use_complex) {
	    ns = coefAC.length();
	 } else {
	    ns = coefA.length();
         }
	 int ni = ridxA.length();
	 int nj = cidxA.length();
	 int nnz = MAX(ni,nj);
	 if ( ( ns != 1 && ns != nnz ) ||
              ( ni != 1 && ni != nnz ) ||
              ( nj != 1 && nj != nnz ) )
	    SP_FATAL_ERR ("i, j and s must have the same length");

         if (nargin == 3) {
            m= (int) ridxA.max();
            n= (int) cidxA.max();
         } else {
            m= (int) args(3).double_value();
            n= (int) args(4).double_value();
	    if (error_state) return retval;

            if (nargin >= 6) {
               // if args(5) is not string, then ignore the value
               // otherwise check for summation or unique
               if ( args(5).is_string()) {
                  string vv= args(5).string_value();
		  if (error_state) return retval;

                  if ( vv== "summation" ||
                       vv== "sum" ) 
                     assemble_do_sum=1;
                  else
                  if ( vv== "unique" )
                     assemble_do_sum=0;
                  else
                     SP_FATAL_ERR("must specify sum or unique");
               }

            }
         }
      }

      if (use_complex) 
         retval = new octave_complex_sparse (
               assemble_sparse( n, m, coefAC, ridxA, cidxA, assemble_do_sum) );
      else
         retval = new octave_sparse (
               assemble_sparse( n, m, coefA, ridxA, cidxA, assemble_do_sum) );
   }

   return retval;
}

DEFUN_DLD (spreal, args, nargout ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{abs_a} =} spreal( @var{a} );\n\
SPREAL : real part of a complex sparse matrix\n\
@seealso{sparse, spabs, spimag}\n\
@end deftypefn")
{
   octave_value_list retval;

   if (args.length() < 1) {
      print_usage ("spreal");
      return retval;
   }

   if (args(0).type_name () == "sparse" ) {
       retval(0)= args(0);
   } else
   if ( args(0).type_name () == "complex_sparse" ) {
      const octave_sparse& A =
           (const octave_sparse&) args(0).get_rep();
      SuperMatrix X= A.super_matrix();

      DEFINE_SP_POINTERS_CPLX( X )
      int nnz= NCFX->nnz;

      double *coefB = doubleMalloc(nnz);
      int *   ridxB = intMalloc(nnz);
      int *   cidxB = intMalloc(X.ncol+1);

      for ( int i=0; i<=Xnc; i++)
         cidxB[i]=  cidxX[i];

      for ( int i=0; i< nnz; i++) {
         doublecomplex * dc= (doublecomplex *) &coefX[i];
         coefB[i]=  dc->r;
         ridxB[i]=  ridxX[i];
      }

      SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
      retval(0)= new octave_sparse(B);
   } else
     gripe_wrong_type_arg ("spreal", args(0));

   return retval;
}

DEFUN_DLD (spimag, args, nargout ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{abs_a} =} spimag( @var{a} );\n\
SPIMAG : imaginary part of a complex sparse matrix\n\
@seealso{sparse, spabs, spreal}\n\
@end deftypefn")
{
   octave_value_list retval;

   if (args.length() < 1) {
      print_usage ("spimag");
      return retval;
   }

   if (args(0).type_name () == "sparse" ) {
      ColumnVector empty;
      retval(0)= new octave_sparse( assemble_sparse(
                   args(0).columns(), args(0).rows(), empty, empty, empty, 0));
   } else
   if ( args(0).type_name () == "complex_sparse" ) {
      const octave_sparse& A =
           (const octave_sparse&) args(0).get_rep();
      SuperMatrix X= A.super_matrix();

      DEFINE_SP_POINTERS_CPLX( X )
      int nnz= NCFX->nnz;

      double *coefB = doubleMalloc(nnz);
      int *   ridxB = intMalloc(nnz);
      int *   cidxB = intMalloc(X.ncol+1);

      for ( int i=0; i<=Xnc; i++)
         cidxB[i]=  cidxX[i];

      for ( int i=0; i< nnz; i++) {
         doublecomplex * dc= (doublecomplex *) &coefX[i];
         coefB[i]=  dc->i;
         ridxB[i]=  ridxX[i];
      }

      SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
      retval(0)= new octave_sparse(B);
   } else
     gripe_wrong_type_arg ("spimag", args(0));

   return retval;
}


DEFINE_OCTAVE_ALLOCATOR (octave_sparse);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_sparse, "sparse");

DEFINE_OCTAVE_ALLOCATOR (octave_complex_sparse);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_complex_sparse, "complex_sparse");
/*
 * $Log$
 * Revision 1.13  2003/10/27 15:24:13  aadler
 * doc bug
 *
 * Revision 1.12  2003/10/18 04:55:47  aadler
 * spreal spimag and new tests
 *
 * Revision 1.11  2003/10/18 01:13:00  aadler
 * texinfo for documentation strings
 *
 * Revision 1.10  2003/04/03 22:06:39  aadler
 * sparse create bug - need to use heap for large temp vars
 *
 * Revision 1.9  2003/02/14 03:50:34  aadler
 * mods to make 'sum' the default
 *
 * Revision 1.8  2003/01/02 18:19:03  pkienzle
 * more robust input handling
 *
 * Revision 1.7  2002/02/19 21:21:48  aadler
 * Modifications to _dtrsv stub to compile.
 * Modifications to makefile to define AR and RANLIB
 *
 * Revision 1.6  2002/02/16 22:16:04  aadler
 * added dtrsv stub to compile statically
 *
 * Revision 1.5  2001/12/04 19:13:42  pkienzle
 * sparse(i,j,s,...) now check that lengths of i,j,s match
 *
 * Revision 1.4  2001/11/04 19:54:49  aadler
 * fix bug with multiple entries in sparse creation.
 * Added "summation" mode for matrix creation
 *
 * Revision 1.3  2001/10/14 03:06:31  aadler
 * fixed memory leak in complex sparse solve
 * fixed malloc bugs for zero size allocs
 *
 * Revision 1.2  2001/10/12 02:24:28  aadler
 * Mods to fix bugs
 * add support for all zero sparse matrices
 * add support fom complex sparse inverse
 *
 * Revision 1.7  2001/09/23 17:46:12  aadler
 * updated README
 * modified licence to GPL plus link to opensource programmes
 *
 * Revision 1.6  2001/04/04 02:13:46  aadler
 * complete complex_sparse, templates, fix memory leaks
 *
 * Revision 1.5  2001/03/30 04:36:30  aadler
 * added multiply, solve, and sparse creation
 *
 * Revision 1.4  2001/03/15 15:47:58  aadler
 * cleaned up duplicated code by using "defined" templates.
 * used default numerical conversions
 *
 * Revision 1.3  2001/02/27 03:01:52  aadler
 * added rudimentary complex matrix support
 *
 * Revision 1.2  2000/12/18 03:31:16  aadler
 * Split code to multiple files
 * added sparse inverse
 *
 */
