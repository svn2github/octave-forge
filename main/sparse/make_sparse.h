/*

Copyright (C) 1999 Andy Adler

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
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

$Id$

$Log$
Revision 1.4  2002/01/04 15:53:57  pkienzle
Changes required to compile for gcc-3.0 in debian hppa/unstable

Revision 1.3  2001/11/04 19:54:49  aadler
fix bug with multiple entries in sparse creation.
Added "summation" mode for matrix creation

Revision 1.2  2001/10/12 02:24:28  aadler
Mods to fix bugs
add support for all zero sparse matrices
add support fom complex sparse inverse

Revision 1.9  2001/04/04 02:13:46  aadler
complete complex_sparse, templates, fix memory leaks

Revision 1.8  2001/03/30 04:36:30  aadler
added multiply, solve, and sparse creation

Revision 1.7  2001/03/27 03:45:20  aadler
use templates for mul, add, sub, el_mul operations

Revision 1.6  2001/03/15 15:47:58  aadler
cleaned up duplicated code by using "defined" templates.
used default numerical conversions

Revision 1.5  2001/03/06 03:20:12  aadler
added automatic numeric_conversion_function

Revision 1.4  2001/02/27 03:01:52  aadler
added rudimentary complex matrix support

Revision 1.3  2000/12/30 03:22:58  aadler
added fatal error handling
Thanks to Paul Kienzle for his suggestions

Revision 1.2  2000/12/18 03:31:16  aadler
Split code to multiple files
added sparse inverse

Revision 1.1  2000/11/11 02:47:11  aadler
DLD functions for sparse support in octave

*/

#ifdef VERBOSE
#  define DEBUGMSG(x) printf("DEBUG:" x "\n")
#else
#  define DEBUGMSG(x) 
#endif

// Thanks to To: Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
// for help with error handling 
#define SP_FATAL_ERR(str) { error("sparse: %s", str);  \
                            jump_to_top_level ();  \
                            panic_impossible (); }

#include <octave/config.h>

#include <cstdlib>

#include <string>

class ostream;

#include <octave/lo-utils.h>
#include <octave/mx-base.h>
#include <octave/str-vec.h>

#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/gripes.h>
#include <octave/lo-mappers.h>
#include <octave/oct-obj.h>
#include <octave/ops.h>
#include <octave/ov-base.h>
#include <octave/ov-typeinfo.h>
#include <octave/ov.h>
#include <octave/ov-scalar.h>
#include <octave/ov-complex.h>
#include <octave/ov-re-mat.h>
#include <octave/ov-cx-mat.h>
#include <octave/pager.h>
#include <octave/pr-output.h>
#include <octave/symtab.h>
#include <octave/variables.h>

#include <octave/utils.h>

// this is a pain, but the
// complex and double definitions don't work together
#if    defined( SPARSE_DOUBLE_CODE )
#  include "dsp_defs.h"
#elif  defined( SPARSE_COMPLEX_CODE )
#  include "zsp_defs.h"
#else
#  include "supermatrix.h"
#endif                            

class Octave_map;
class octave_value_list;

class tree_walker;

//
// complex sparse class definition
//
class
octave_complex_sparse : public octave_base_value
{
public:

   octave_complex_sparse (SuperMatrix A );
  ~octave_complex_sparse (void);
   octave_complex_sparse (const octave_complex_sparse& S);

   octave_value *clone (void) ;
   octave_complex_sparse sparse_value (bool = false) const ;
   SuperMatrix   super_matrix (bool = false) const ;

   int rows    (void) const ;
   int columns (void) const ;
   int nnz     (void) const ;

   bool is_defined (void) const ;
   bool is_real_scalar (void) const ;

   octave_value any (void) const ;
   octave_value all (void) const ;

   bool is_real_type (void) const;
   bool is_scalar_type (void) const;
   bool is_numeric_type (void) const;
   bool valid_as_scalar_index (void) const;
   bool valid_as_zero_index (void) const;
   bool is_true (void) const;

   ComplexMatrix complex_matrix_value (bool = false) const;
   octave_value uminus (void) const ;
   octave_value hermitian (void) const ;
   octave_value transpose (void) const ;

#if 0
   octave_value extract (int r1, int c1, int r2, int c2) const ;
   octave_value_list do_multi_index_op (int, const octave_value_list& idx);

   
#endif
   void print (std::ostream& os, bool pr_as_read_syntax = false) const ;

   type_conv_fcn numeric_conversion_function (void) const;

private:
   SuperMatrix X ;

   DECLARE_OCTAVE_ALLOCATOR
   DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA

}; // class octave_complex_sparse

//
// sparse class definition
//
class
octave_sparse : public octave_base_value
{
public:

   octave_sparse (SuperMatrix A );
  ~octave_sparse (void);
   octave_sparse (const octave_sparse& S);

   octave_value *clone (void) ;
   octave_sparse sparse_value (bool = false) const ;
   SuperMatrix   super_matrix (bool = false) const ;

   octave_complex_sparse complex_sparse_value (bool = false) const;

   int rows    (void) const ;
   int columns (void) const ;
   int nnz     (void) const ;

   bool is_defined (void) const ;
   bool is_real_scalar (void) const ;

   octave_value any (void) const ;
   octave_value all (void) const ;

   bool is_real_type (void) const;
   bool is_scalar_type (void) const;
   bool is_numeric_type (void) const;
   bool valid_as_scalar_index (void) const;
   bool valid_as_zero_index (void) const;
   bool is_true (void) const;
// double double_value (bool = false) const;

   Matrix matrix_value (bool = false) const;
   octave_value uminus (void) const ;
   octave_value hermitian (void) const ;
   octave_value transpose (void) const ;

   octave_value extract (int r1, int c1, int r2, int c2) const ;
   octave_value_list do_multi_index_op (int, const octave_value_list& idx);

   void print (std::ostream& os, bool pr_as_read_syntax = false) const ;

   type_conv_fcn numeric_conversion_function (void) const;

private:
   SuperMatrix X ;

   DECLARE_OCTAVE_ALLOCATOR
   DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA

}; // class octave_sparse


#include "util.h"


//
// these functions override functions in SuperLU
//  so we need to provide them here
//
#ifdef __cplusplus
extern "C" {
#endif   
void *
oct_sparse_malloc(int size);

void
oct_sparse_fatalerr(char *msg);

void
oct_sparse_free(void * addr);
#ifdef __cplusplus
} 
#endif   

void
oct_sparse_Destroy_SuperMatrix( SuperMatrix X) ;

Matrix
oct_sparse_to_full ( SuperMatrix X ) ;

SuperMatrix
oct_sparse_transpose ( SuperMatrix X ) ;
SuperMatrix
oct_complex_sparse_transpose ( SuperMatrix X ) ;

SuperMatrix
oct_matrix_to_sparse(const Matrix & A) ;

SuperMatrix
oct_matrix_to_sparse(const ComplexMatrix & A) ;

void
oct_sparse_do_permc( int permc_spec, int perm_c[], 
                     SuperMatrix A ) ;

SuperMatrix
sp_inv_uppertriang( SuperMatrix U);

#if NDEBUG
#define oct_sparse_verify_supermatrix(X);
#else
void
oct_sparse_verify_supermatrix( SuperMatrix X);
#endif


SuperMatrix assemble_sparse( int n, int m,
                             ColumnVector& coefA,
                             ColumnVector& ridxA,
                             ColumnVector& cidxA,
                             int assemble_do_sum);

SuperMatrix assemble_sparse( int n, int m,
                             ComplexColumnVector& coefA,
                             ColumnVector& ridxA,
                             ColumnVector& cidxA,
                             int assemble_do_sum);

octave_value_list
oct_sparse_inverse( const octave_sparse& A,
                    int* perm_c,
                    int permc_spec) ;
octave_value_list
oct_sparse_inverse( const octave_complex_sparse& Asp,
                    int* perm_c,
                    int permc_spec );

octave_value_list
oct_sparse_inverse( const octave_complex_sparse& A,
                    int* perm_c,
                    int permc_spec) ;

void install_sparse_ops() ;
void install_complex_sparse_ops() ;

// functions to grow and shrink allocations

void oct_sparse_expand_bounds( int lim, int& bound,
                               int*& idx,
                               void*& coef, int varsize);

inline void
check_bounds( int lim, int& bound, int*& idx, double*& coef)
{   
   if (lim==bound) 
      oct_sparse_expand_bounds( lim, bound, idx,
                  (void *&) coef, sizeof(double));
}      

inline void
check_bounds( int lim, int& bound, int*& idx, Complex*& coef)
{   
   if (lim==bound) 
      oct_sparse_expand_bounds( lim, bound, idx,
                  (void *&) coef, sizeof(Complex));
}      


void oct_sparse_maybe_shrink( int lim, int bound,
                              int*& idx,
                              void*& coef, int varsize ) ;

inline void
maybe_shrink( int lim, int bound, int*& idx, double*& coef) {
   oct_sparse_maybe_shrink( lim, bound, idx,
                            (void *&) coef, sizeof(double));
}   

inline void
maybe_shrink( int lim, int bound, int*& idx, Complex*& coef) {
   oct_sparse_maybe_shrink( lim, bound, idx,
                            (void *&) coef, sizeof(Complex));
}   

SuperMatrix
create_SuperMatrix( int nr, int nc, int nnz,
                    double * coef,
                    int * ridx,
                    int * cidx );

SuperMatrix
create_SuperMatrix( int nr, int nc, int nnz,
                    Complex * coef,
                    int * ridx,
                    int * cidx );

void
LUextract(SuperMatrix *L, SuperMatrix *U, double *Lval, int *Lrow,
          int *Lcol, double *Uval, int *Urow, int *Ucol, int *snnzL,
          int *snnzU);
void
LUextract(SuperMatrix *L, SuperMatrix *U, Complex *Lval, int *Lrow,
          int *Lcol, Complex *Uval, int *Urow, int *Ucol, int *snnzL,
          int *snnzU);
void
sparse_LU_fact(SuperMatrix A, SuperMatrix *LC, SuperMatrix *UC,
               int * perm_c, int * perm_r, int permc_spec );
void
complex_sparse_LU_fact(SuperMatrix A, SuperMatrix *LC, SuperMatrix *UC,
                       int * perm_c, int * perm_r, int permc_spec );
void
fix_row_order( SuperMatrix X );
void
fix_row_order_complex( SuperMatrix X );

int
complex_sparse_verify_doublecomplex_type(void);

SuperMatrix
sparse_inv_uppertriang( SuperMatrix U);
SuperMatrix
complex_sparse_inv_uppertriang( SuperMatrix U);


// comparison function for sort in make_sparse
typedef struct { unsigned long val;
                 unsigned long idx; } sort_idxl;   

inline int
sidxl_comp(const void *i,const void*j )
{
   return (((sort_idxl *) i)->val) - (((sort_idxl *) j)->val) ;
}

// declare pointers from which we will build a SuperMatrix
#define DECLARE_SP_POINTERS_REAL( A ) DECLARE_SP_POINTERS( A, double )
#define DECLARE_SP_POINTERS_CPLX( A ) DECLARE_SP_POINTERS( A, Complex )

#define DECLARE_SP_POINTERS( A , type) \
   type * coef ## A ; \
   int  * ridx ## A ; \
   int  * cidx ## A ;

// check that we have a correctly typed NC SuperMatrix,
// and define pointers to the data members
#define DEFINE_SP_POINTERS_REAL( A ) DEFINE_SP_POINTERS( A, double, _D )
#define DEFINE_SP_POINTERS_CPLX( A ) DEFINE_SP_POINTERS( A, Complex , _Z )

#define DEFINE_SP_POINTERS( A, type, Dtypedef ) \
   assert( (A).Stype == NC); \
   assert( (A).Dtype == Dtypedef ); \
   NCformat * NCF ## A= (NCformat *) (A).Store; \
   type * coef ## A = (type *) NCF ## A->nzval; \
   int  * ridx ## A =          NCF ## A->rowind; \
   int  * cidx ## A =          NCF ## A->colptr; \
   int A ## nr= (A).nrow; \
   int A ## nc= (A).ncol;

#ifdef USE_DMALLOC
#include <dmalloc.h>
#endif 

// Build the permutation matrix
//  remember to add 1 because assemble_sparse is 1 based
#define BUILD_PERM_VECTORS( ridx, cidx, coef, perm, n ) \
      ColumnVector ridx(n), cidx(n), coef(n); \
      for (int i=0; i<n; i++) { \
         ridx(i)= 1.0 + i; \
         cidx(i)= 1.0 + perm[i];  \
         coef(i)= 1.0; \
      }
