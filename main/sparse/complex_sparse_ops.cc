/*
Sparse matrix functionality for octave, based on the
   SuperLU package  
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

$Id$

*/

#define  SPARSE_COMPLEX_CODE
#include "make_sparse.h"
#include "sparse_ops.h"

//
// Utility methods
//

// test that the doublecomplex type defined
// by SuperLU is compatible with 
// the Complex type from c++?
//
// return 0 if ok
//       -ve if notok
int
complex_sparse_verify_doublecomplex_type(void) 
{
   int r= 99; int i= 98;
   Complex cv(r,i);
   doublecomplex * dc= (doublecomplex *) &cv;
   if ( (dc->r == r) &&
        (dc->i == i) )
      return 0;
   else
      return -1;
}   

SuperMatrix
create_SuperMatrix( int nr, int nc, int nnz,
                    Complex * coef,
                    int * ridx,
                    int * cidx )
{
   SuperMatrix  X;
   zCreate_CompCol_Matrix(&X, nr, nc, nnz,
                          (doublecomplex *) coef,
                          ridx, cidx, NC, _Z, GE);
   return X;
}

//
// Octave complex sparse methods
//

inline
octave_complex_sparse::octave_complex_sparse (SuperMatrix A )
{
   DEBUGMSG("complex_sparse( SuperMatrix A)");
   X= A;
}

inline
octave_complex_sparse::~octave_complex_sparse (void)
{
   DEBUGMSG("complex_sparse destructor");
   oct_sparse_Destroy_SuperMatrix( X ) ;
}

//NOTE: I'm not sure when this will get called,
//      so I don't know what to do
inline
octave_complex_sparse::octave_complex_sparse (const octave_complex_sparse& S)
{
   DEBUGMSG("complex_sparse copy-constructor");
   X= S.super_matrix();
}   

inline octave_value *
octave_complex_sparse::clone (void)
{
   DEBUGMSG("complex_sparse - clone");
   return new octave_complex_sparse (*this);
}

inline octave_complex_sparse
octave_complex_sparse::sparse_value (bool = false) const {
   DEBUGMSG("complex_sparse_value");
   return  (*this);
}

SuperMatrix
octave_complex_sparse::super_matrix (bool = false) const {
   return X;
}


int octave_complex_sparse::rows    (void) const {
   return X.nrow;
}
int octave_complex_sparse::columns (void) const {
   return X.ncol;
}

int octave_complex_sparse::nnz     (void) const {
   NCformat * NCF  = (NCformat * ) X.Store;
   return   NCF->nnz ;
}

// upconvert octave_sparse to octave_complex_sparse
octave_complex_sparse
octave_sparse::complex_sparse_value (bool = false) const {
   DEBUGMSG("sparse - complex_sparse_value");
   DEFINE_SP_POINTERS_REAL( X )
   int nnz= NCFX->nnz;

   Complex *coefB = (Complex *) doublecomplexMalloc(nnz);
   int *    ridxB =             intMalloc(nnz);
   int *    cidxB =             intMalloc(X.ncol+1);

   for ( int i=0; i<=Xnc; i++) 
      cidxB[i]=  cidxX[i];

   for ( int i=0; i< nnz; i++) {
      coefB[i]= coefX[i];
      ridxB[i]= ridxX[i];
   }
   
   SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB);
   return octave_complex_sparse ( B );
}

ComplexMatrix
oct_complex_sparse_to_full ( SuperMatrix X ) {
   DEBUGMSG("complex_sparse - sparse_to_full");
   DEFINE_SP_POINTERS_CPLX( X );
   
   ComplexMatrix M( Xnr, Xnc );
   for (int j=0; j< Xnc; j++) {
   // I think new Matrices are initialized to zero, however just in case
      for (int i=0; i< Xnr; i++) M(i,j)= 0;
   
      for (int i= cidxX[j]; i< cidxX[j+1]; i++) 
         M( ridxX[i],j)= coefX[i];
   } // for i
   return M;
}   

// type conversion functions

static octave_value *
default_numeric_conversion_function (const octave_value& a)
{
   DEBUGMSG("complex_sparse - default_numeric_conversion_function");
   CAST_CONV_ARG (const octave_complex_sparse&);
   return new octave_complex_matrix (v.complex_matrix_value ());
}
 
type_conv_fcn
octave_complex_sparse::numeric_conversion_function (void) const
{
   DEBUGMSG("complex_sparse - numeric_conversion_function");
   return default_numeric_conversion_function;
}

//idx_vector index_vector (void) const { return idx_vector ((double) iv); }

octave_value octave_complex_sparse::any (void) const {
   DEBUGMSG("complex_sparse - any");
   ComplexMatrix M= oct_complex_sparse_to_full( X );
   return M.any();
}

octave_value octave_complex_sparse::all (void) const {
   DEBUGMSG("complex_sparse - all");
   ComplexMatrix M= oct_complex_sparse_to_full( X );
   return M.all();
}

bool octave_complex_sparse::is_defined    (void) const  { return true; }
bool octave_complex_sparse::is_real_scalar (void) const { return false; }
bool octave_complex_sparse::is_real_type (void) const { return false; }
bool octave_complex_sparse::is_scalar_type (void) const { return false; }
bool octave_complex_sparse::is_numeric_type (void) const { return true; }

bool octave_complex_sparse::valid_as_scalar_index (void) const { return false; }

bool octave_complex_sparse::valid_as_zero_index (void) const { return false; }


//A matrix is true if it is all non zero
bool octave_complex_sparse::is_true (void) const {
   DEBUGMSG("complex_sparse - is_true");
   NCformat * NCF  = (NCformat * ) X.Store;
   return (X.nrow * X.ncol == NCF->nnz );
}


// rebuild a full matrix from a sparse one
// this functionality is accessed through 'full'
ComplexMatrix
octave_complex_sparse::complex_matrix_value (bool = false) const {
   DEBUGMSG("complex_sparse - complex_matrix_value");
   ComplexMatrix M= oct_complex_sparse_to_full( X );
   return M;
}


octave_value
octave_complex_sparse::uminus (void) const {
   DEFINE_SP_POINTERS_CPLX( X )
   int nnz= NCFX->nnz;

   Complex *coefB = (Complex *) doublecomplexMalloc(nnz);
   int *   ridxB  =             intMalloc(nnz);
   int *   cidxB  =             intMalloc(X.ncol+1);

   for ( int i=0; i<=Xnc; i++) 
      cidxB[i]=  cidxX[i];

   for ( int i=0; i< nnz; i++) {
      coefB[i]= -coefX[i];
      ridxB[i]=  ridxX[i];
   }
   
   SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
   return new octave_complex_sparse ( B );
} // octave_value uminus (void) const {

UNOPDECL (uminus, a ) 
{ 
   DEBUGMSG("complex_sparse - uminus");
   CAST_UNOP_ARG (const octave_complex_sparse&); 
   return v.uminus();
}   

SuperMatrix
oct_complex_sparse_transpose ( SuperMatrix X ) {
   DEFINE_SP_POINTERS_CPLX( X )
   int nnz= NCFX->nnz;

   DECLARE_SP_POINTERS_CPLX( B )

   zCompRow_to_CompCol( Xnc, Xnr, nnz,
                  (doublecomplex *) coefX, ridxX, cidxX,
                  (doublecomplex **) &coefB, &ridxB, &cidxB);
   
   SuperMatrix B= create_SuperMatrix( Xnc, Xnr, nnz, coefB, ridxB, cidxB );
   return B;
}   

octave_value octave_complex_sparse::transpose (void) const {
   return new octave_complex_sparse ( oct_complex_sparse_transpose( X ) );
} // octave_complex_sparse::transpose (void) const {

UNOPDECL (transpose, a)
{
   DEBUGMSG("complex_sparse - transpose");
   CAST_UNOP_ARG (const octave_complex_sparse&); 
   return v.transpose();
} // transpose

octave_value octave_complex_sparse::hermitian (void) const {
   SuperMatrix T= oct_complex_sparse_transpose( X );

   NCformat * NCFT= (NCformat *) T.Store; 
   doublecomplex * coefT = (doublecomplex *) NCFT->nzval;
   for ( int k=0; k< NCFT->nnz; k++) {
      double t= coefT[k].i;
      // check that imag val is not 0, 
      // otherwise we get -0 values
      if (t != 0 )
         coefT[k].i= -t;
   }

   return new octave_complex_sparse ( T );
} // octave_complex_sparse::transpose (void) const {

UNOPDECL (hermitian, a)
{
   DEBUGMSG("complex_sparse - hermitian");
   CAST_UNOP_ARG (const octave_complex_sparse&); 
   return v.hermitian();
} // hermitian

#if 0
typedef struct { long val;
                 long idx; } sort_idx;   
// comparison function for sort in index
static inline int
ixp_comp(const void *i,const void*j )
{
   return (((sort_idx *) i)->val) - (((sort_idx *) j)->val);
}

// generates a sort of idxv with the sort index
// note that sidx[] must have space for idxv.length elements
static inline void
sort_with_idx (sort_idx * sidx, const idx_vector& idxv, long ixl) 
{
   if (idxv.is_colon() ) {
      for (int i=0; i< ixl; i++) {
         sidx[i].val= i;
         sidx[i].idx= i;
      }
   }
   else {
      for (int i=0; i< ixl; i++) {
         sidx[i].val= idxv(i);
         sidx[i].idx= i;
      }

      qsort( sidx, ixl, sizeof(sort_idx), ixp_comp );
   }
}   

// Return a full vector output
// Does it make sense to output a sparse matrix here?
static ColumnVector
sparse_index_oneidx ( SuperMatrix X, const idx_vector ix) {
   DEBUGMSG("complex_sparse_index_oneidx");
   DEFINE_SP_POINTERS_CPLX( X )
   long      ixl; 

   if (ix.is_colon() ) 
      ixl= Xnr*Xnc;
   else  
      ixl= ix.length(-1); 

   sort_idx ixp[ ixl ];
   sort_with_idx (ixp, ix, ixl);

   ColumnVector O( ixl );
   long ip= -Xnr; // previous column position
   long jj=0,jl=0;
   for (long k=0; k< ixl; k++) {
      long ii  = ixp[k].val;
      long kout= ixp[k].idx;

      if ( ii<0 || ii>=Xnr*Xnc) 
         SP_FATAL_ERR("invalid matrix index");
 
      int rown= ii/Xnr;
      if ( rown > ip/Xnr ) { // we've moved to a new column
         jl= cidxX[rown];
         jj= cidxX[rown+1];
      }

      while ( ridxX[jl] < ii%Xnr && jl < jj ) jl++;

      if ( ridxX[jl] == ii%Xnr && jl<jj ) 
         O( kout ) = coefX[jl] ;
      else
         O( kout ) = 0 ;

      ip=ii;
   }
   return O;
} // sparse_index_oneidx (


static SuperMatrix
sparse_index_twoidx ( SuperMatrix X,
                      const idx_vector ix,
                      const idx_vector jx) {
   DEBUGMSG("complex_sparse_index_twoidx");
   DEFINE_SP_POINTERS_CPLX( X )

   int ixl,jxl;
   if (ix.is_colon() )      ixl= Xnr;
   else                     ixl= ix.length(-1); 

   if (jx.is_colon() )      jxl= Xnc;
   else                     jxl= jx.length(-1); 

   sort_idx ixp[ ixl ];
   sort_with_idx (ixp, ix, ixl);

   // extimate the nnz in the output matrix
   int nnz = (int) ceil( (NCFX->nnz) * (1.0*ixl / Xnr) * (1.0*jxl / Xnc) ); 

   double * coefB = doubleMalloc(nnz);
   int    * ridxB = intMalloc   (nnz);
   int    * cidxB = intMalloc   (jxl+1);  cidxB[0]= 0;

   double tcol[ixl];  // a column of the extracted matrix

   int cx= 0, ll=0;
   int ip= -Xnc; // previous column position
   for (int l=0; l< jxl; l++) {
      if (jx.is_colon() )    ll= l;
      else                   ll= jx(l);

      if ( ll<0 || ll>=Xnc) 
            SP_FATAL_ERR("invalid matrix index (x index)");

      int jl= cidxX[ll];
      int jj= cidxX[ll+1];
      for (long k=0; k< ixl; k++) {
         long ii  = ixp[k].val;
         long kout= ixp[k].idx;
   
         if ( ii<0 || ii>=Xnr) 
            SP_FATAL_ERR("invalid matrix index (x index)");

         while ( ridxX[jl] < ii && jl < jj ) jl++;


         if ( ridxX[jl] == ii && jl<jj ) 
            tcol[ kout ] = coefX[jl] ;
         else
            tcol[ kout ] = 0 ;

         ip=ii;
   
      } // for k
      for (int j=0; j<ixl; j++) {
         if (tcol[j] !=0 ) {
            check_bounds( cx, nnz, ridxB, coefB );
            ridxB[cx]= j;
            coefB[cx]= tcol[j];
            cx++;
         }
      }
      cidxB[l+1]= cx;
   } // for l

   maybe_shrink( cx, nnz, ridxB, coefB );

   SuperMatrix B;
   dCreate_CompCol_Matrix(&B, ixl, jxl, cx,
                       coefB, ridxB, cidxB, NC, _D, GE);

   return B;                          
} // sparse_index_twoidx (

// indexing operations
octave_value_list
octave_complex_sparse::do_multi_index_op (int, const octave_value_list& idx) 
{
   DEBUGMSG("complex_sparse - index op");
   octave_value retval;
   
   if ( idx.length () == 1) {
      const idx_vector ix = idx (0).index_vector ();
      ColumnVector O= sparse_index_oneidx( X, ix );

      // the rules are complicated here X(Y):
      // X is matrix: result is same shape as Y
      // X is vector: result is same orientation as X
      // X is scalar: result is column orientation

// printf("idx(0) [%d x %d]\n", idx(0).rows(), idx(0).columns() );
      if (1)  retval= O;
      else                         retval= O.transpose();
   } else
   if ( idx.length () == 2) {
      const idx_vector ix = idx (0).index_vector ();
      const idx_vector jx = idx (1).index_vector ();

      retval= new octave_complex_sparse ( 
                  sparse_index_twoidx ( X, ix, jx ));
   } else
      SP_FATAL_ERR("need 1 or 2 indices for sparse indexing operations");

   return retval;
} // octave_complex_sparse::do_index_op


octave_value
octave_complex_sparse::extract (int r1, int c1, int r2, int c2) const {
   DEBUGMSG("complex_sparse - extract");
   DEFINE_SP_POINTERS_CPLX( X )

// estimate the nnz needed is the A->nnz times the
//  fraction of the matrix selected
   if (r1 > r2) { int tmp = r1; r1 = r2; r2 = tmp; }
   if (c1 > c2) { int tmp = c1; c1 = c2; c2 = tmp; }
   int m= r1-r2+1;
   int n= c1-c2+1;

   int nnz = (int) ceil( (NCFX->nnz) * (1.0*m / Xnr)
                                     * (1.0*n / Xnc) ); 

   double * coefB = doubleMalloc(nnz);
   int    * ridxB = intMalloc   (nnz);
   int    * cidxB = intMalloc   (n+1);  cidxB[0]= 0;

   int cx= 0;
   for (int i=0, ii= c1; i < n ; i++, ii++) {
      for ( int j= cidxX[ii]; j< cidxX[ii+1]; j++) {
         int row = ridxX[ j ];
         if ( row>= r1 && row<=r2 && coefX[j] !=0 ) {
            check_bounds( cx, nnz, ridxB, coefB );
            ridxB[ cx ]= row - r1;
            coefB[ cx ]= coefX[ j ];
            cx++;
         } // if row
      } //for j

      cidxX[i+1] = cx;
   } // for ( i=0

   maybe_shrink( cx, nnz, ridxX, coefX );

   SuperMatrix B;
   dCreate_CompCol_Matrix(&B, m, n, cx,
                          coefB, ridxB, cidxB, NC, _D, GE);

   return new octave_complex_sparse ( B );
} // octave_complex_sparse::extract (int r1, int c1, int r2, int c2) const {

#endif

void
octave_complex_sparse::print (ostream& os, bool pr_as_read_syntax ) const
{
   DEBUGMSG("complex_sparse - print");
#if 0
// I find the SuperLU print function to be ugly and clumsy
   zPrint_CompCol_Matrix("octave sparse", &X);
#else      
   DEFINE_SP_POINTERS_CPLX( X )
   int nnz = NCFX->nnz;
   
   os << "Compressed Column Sparse (rows=" << Xnr <<
                                 ", cols=" << Xnc <<
                                 ", nnz=" << nnz << ")\n";
   // add one to the printed indices to go from
   //  zero-based to one-based arrays
   for (int j=0; j< Xnc; j++) 
      for (int i= cidxX[j]; i< cidxX[j+1]; i++) 
         os << "  (" << ridxX[i]+1 <<
               " , "  << j+1 << ") -> " << coefX[i] << "\n";
#endif                  
} // print

//
// sparse by complex  operations
//

octave_value
complex_sparse_complex_multiply (
            const octave_complex_sparse& spar,
            const octave_complex&        cplx)
{
  DEBUGMSG("complex_sparse - complex_sparse_complex_multiply");
  Complex c= cplx.complex_value();

  SuperMatrix X= spar.super_matrix();
  DEFINE_SP_POINTERS_CPLX( X )
  int nnz= NCFX->nnz;

  Complex *coefB = (Complex *) doublecomplexMalloc(nnz);
  int *    ridxB = intMalloc(nnz);
  int *    cidxB = intMalloc(X.ncol+1);

  for ( int i=0; i<=Xnc; i++)
     cidxB[i]=  cidxX[i];

  for ( int i=0; i< nnz; i++) {
     coefB[i]=  coefX[i] * c;
     ridxB[i]=  ridxX[i];
  }

  SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
  return new octave_complex_sparse ( B );
}

//
// complex_sparse by scalar operations
//

DEFBINOP (s_n_mul, complex_sparse, scalar) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_scalar&);
  Complex cv( v2.double_value(), 0 );
  return complex_sparse_complex_multiply (v1, cv);
}  

DEFBINOP (n_s_mul,  scalar, complex_sparse) {
  CAST_BINOP_ARGS (const octave_scalar&, const octave_complex_sparse&);
  Complex cv( v1.double_value(), 0 );
  return complex_sparse_complex_multiply (v2, cv);
}  

DEFBINOP (s_n_div, complex_sparse, scalar) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_scalar&);
  Complex cv ( v2.double_value (), 0);
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return complex_sparse_complex_multiply (v1, 1.0 / cv );
}  

DEFBINOP (n_s_ldiv, scalar, complex_sparse) {
  CAST_BINOP_ARGS (const octave_scalar&, const octave_complex_sparse&);
  Complex cv ( v1.double_value (), 0);
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return complex_sparse_complex_multiply (v2, 1.0 / cv );
}  

//
// complex_sparse by complex operations
//

DEFBINOP (s_c_mul, complex_sparse, complex) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex&);
  return complex_sparse_complex_multiply (v1, v2);
}  

DEFBINOP (c_s_mul, complex, complex_sparse) {
  CAST_BINOP_ARGS (const octave_complex&, const octave_complex_sparse&);
  return complex_sparse_complex_multiply (v2, v1);
}  

DEFBINOP (s_c_div, complex_sparse, complex) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex&);
  Complex cv= v2.complex_value();
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return complex_sparse_complex_multiply (v1, 1.0 / cv );
}  

DEFBINOP (c_s_ldiv, complex, complex_sparse) {
  CAST_BINOP_ARGS (const octave_complex&, const octave_complex_sparse&);
  Complex cv= v1.complex_value();
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return complex_sparse_complex_multiply (v2, 1.0 / cv );
}  

//
// sparse by matrix  operations
//

DEFBINOP( cs_cs_add, sparse, sparse)
{
   DEBUGMSG("complex_sparse - cs_cs_add");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, + , 1 )
   return new octave_complex_sparse ( X );
}

DEFBINOP( cs_s_add, complex_sparse, sparse)
{   
   DEBUGMSG("complex_sparse - cs_s_add");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, + , 1 )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( s_cs_add, sparse, complex_sparse)
{   
   DEBUGMSG("complex_sparse - s_cs_add");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_complex_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, + , 1 )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( cs_cs_sub, sparse, sparse)
{
   DEBUGMSG("complex_sparse - cs_cs_sub");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, - , 1 )
   return new octave_complex_sparse ( X );
}

DEFBINOP( cs_s_sub, complex_sparse, sparse)
{   
   DEBUGMSG("complex_sparse - cs_s_sub");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, - , 1 )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( s_cs_sub, sparse, complex_sparse)
{   
   DEBUGMSG("complex_sparse - s_cs_sub");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_complex_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, - , 1 )
   return new octave_complex_sparse ( X );
}   

// only implement comparison operator !=
DEFBINOP( cs_cs_ne, sparse, sparse)
{
   DEBUGMSG("complex_sparse - cs_cs_ne");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, != , 1 )
   return new octave_complex_sparse ( X );
}

DEFBINOP( cs_s_ne, complex_sparse, sparse)
{   
   DEBUGMSG("complex_sparse - cs_s_ne");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, != , 1 )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( s_cs_ne, sparse, complex_sparse)
{   
   DEBUGMSG("complex_sparse - s_cs_ne");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_complex_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( Complex, != , 1 )
   return new octave_complex_sparse ( X );
}   

//
// Element multiply sparse by sparse, return a sparse matrix
//
DEFBINOP( cs_cs_el_mul, complex_sparse, complex_sparse)
{
   DEBUGMSG("sparse - cs_cs_el_mul");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int nnz = MIN( NCFA->nnz , NCFB->nnz );
   SPARSE_EL_OP ( Complex,  * , 0 )
   return new octave_complex_sparse ( X );
}

DEFBINOP( cs_s_el_mul, complex_sparse, sparse)
{
   DEBUGMSG("sparse - cs_s_el_mul");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = MIN( NCFA->nnz , NCFB->nnz );
   SPARSE_EL_OP ( Complex,  * , 0 )
   return new octave_complex_sparse ( X );
}

DEFBINOP( s_cs_el_mul, sparse, complex_sparse)
{
   DEBUGMSG("sparse - s_cs_el_mul");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_complex_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int nnz = MIN( NCFA->nnz , NCFB->nnz );
   SPARSE_EL_OP ( Complex,  * , 0 )
   return new octave_complex_sparse ( X );
}

//
// Element multiply sparse by full, return a sparse matrix
//

DEFBINOP( cf_cs_el_mul, complex_matrix, complex_sparse )
{
   DEBUGMSG("sparse - cf_cs_el_mul");
   CAST_BINOP_ARGS (const octave_complex_matrix&, const octave_complex_sparse&);
   SuperMatrix  A= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   const ComplexMatrix B= v1.complex_matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   int nnz= NCFA->nnz;
   SPARSE_MATRIX_EL_OP( Complex , * )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( cf_s_el_mul, complex_matrix, sparse )
{
   DEBUGMSG("sparse - cf_s_el_mul");
   CAST_BINOP_ARGS (const octave_complex_matrix&, const octave_sparse&);
   SuperMatrix  A= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   const ComplexMatrix B= v1.complex_matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   int nnz= NCFA->nnz;
   SPARSE_MATRIX_EL_OP( Complex , * )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( f_cs_el_mul, matrix, complex_sparse )
{
   DEBUGMSG("sparse - f_cs_el_mul");
   CAST_BINOP_ARGS (const octave_matrix&, const octave_complex_sparse&);
   SuperMatrix  A= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   const Matrix B= v1.matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   int nnz= NCFA->nnz;
   SPARSE_MATRIX_EL_OP( Complex , * )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( cs_cf_el_mul, complex_sparse, complex_matrix)
{
   DEBUGMSG("sparse - cs_cf_el_mul");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex_matrix&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   const ComplexMatrix B= v2.complex_matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   int nnz= NCFA->nnz;
   SPARSE_MATRIX_EL_OP( Complex , * )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( s_cf_el_mul, sparse, complex_matrix)
{
   DEBUGMSG("sparse - s_cf_el_mul");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_complex_matrix&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   const ComplexMatrix B= v2.complex_matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   int nnz= NCFA->nnz;
   SPARSE_MATRIX_EL_OP( Complex , * )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( cs_f_el_mul, complex_sparse, matrix)
{
   DEBUGMSG("sparse - cs_f_el_mul");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_matrix&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   const Matrix B= v2.matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   int nnz= NCFA->nnz;
   SPARSE_MATRIX_EL_OP( Complex , * )
   return new octave_complex_sparse ( X );
}   

DEFBINOP( cs_cf_mul, complex_sparse, complex_matrix)
{
   DEBUGMSG("sparse - cs_cf_mul");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex_matrix&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   const ComplexMatrix B= v2.complex_matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   SPARSE_MATRIX_MUL( ComplexMatrix, Complex )
   return X;
}   

DEFBINOP( cs_f_mul, complex_sparse, matrix)
{
   DEBUGMSG("sparse - cs_f_mul");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_matrix&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   const Matrix B= v2.matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   SPARSE_MATRIX_MUL( ComplexMatrix, Complex )
   return X;
}   

DEFBINOP( s_cf_mul, sparse, complex_matrix)
{
   DEBUGMSG("sparse - s_cf_mul");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_complex_matrix&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   const ComplexMatrix B= v2.complex_matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   SPARSE_MATRIX_MUL( ComplexMatrix, Complex )
   return X;
}   

DEFBINOP( cf_cs_mul, complex_matrix, complex_sparse)
{
   DEBUGMSG("sparse - cf_cs_mul");
   CAST_BINOP_ARGS (const octave_complex_matrix&, const octave_complex_sparse&);
   const ComplexMatrix A= v1.complex_matrix_value(); int Anr= A.rows(); int Anc= A.cols();
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   MATRIX_SPARSE_MUL( ComplexMatrix, Complex )
   return X;
}   

DEFBINOP( f_cs_mul, matrix, complex_sparse)
{
   DEBUGMSG("sparse - f_cs_mul");
   CAST_BINOP_ARGS (const octave_matrix&, const octave_complex_sparse&);
   const Matrix A= v1.matrix_value(); int Anr= A.rows(); int Anc= A.cols();
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   MATRIX_SPARSE_MUL( ComplexMatrix, Complex )
   return X;
}   

DEFBINOP( cf_s_mul, complex_matrix, sparse)
{
   DEBUGMSG("sparse - cf_s_mul");
   CAST_BINOP_ARGS (const octave_complex_matrix&, const octave_sparse&);
   const ComplexMatrix A= v1.complex_matrix_value(); int Anr= A.rows(); int Anc= A.cols();
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   MATRIX_SPARSE_MUL( ComplexMatrix, Complex )
   return X;
}   

DEFBINOP( cs_cs_mul, complex_sparse, complex_sparse)
{
   DEBUGMSG("sparse - cs_cs_mul");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex_sparse&);
   SuperMatrix   A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   SPARSE_SPARSE_MUL( Complex )
   return new octave_complex_sparse ( X );
}

DEFBINOP( s_cs_mul, sparse, complex_sparse)
{
   DEBUGMSG("sparse - s_cs_mul");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_complex_sparse&);
   SuperMatrix   A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   SPARSE_SPARSE_MUL( Complex )
   return new octave_complex_sparse ( X );
}

DEFBINOP( cs_s_mul, complex_sparse, sparse)
{
   DEBUGMSG("sparse - cs_s_mul");
   CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_sparse&);
   SuperMatrix   A= v1.super_matrix(); DEFINE_SP_POINTERS_CPLX( A )
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   SPARSE_SPARSE_MUL( Complex )
   return new octave_complex_sparse ( X );
}

#if 0

// TODO: This isn't an efficient solution
//  to take the inverse and multiply,
//  on the other hand, I can rarely see this being
//  a useful thing to do anyway
DEFBINOP( f_s_ldiv, matrix, sparse) {
   DEBUGMSG("complex_sparse - f_s_ldiv");
   CAST_BINOP_ARGS ( const octave_matrix&, const octave_complex_sparse&);
   const Matrix  A= v1.matrix_value();
   SuperMatrix   B= v2.super_matrix();
   return f_s_multiply(A.inverse() , B);
} // f_s_ldiv 

// sparse \ sparse solve
//
// Note: there are more efficient implemetations,
//       but this works 
//
// There is a wierd problem here,
// it should be possible to multiply s=r*v2;
// but that doesn't work
//
DEFBINOP( s_s_ldiv, sparse, sparse) {
   DEBUGMSG("complex_sparse - s_s_ldiv");
   CAST_BINOP_ARGS ( const octave_complex_sparse&, const octave_complex_sparse&);
   SuperMatrix   A= v1.super_matrix();
   octave_value  B= new octave_complex_sparse( v2.super_matrix() );
   int n = A.ncol;
   int perm_c[n];
   int permc_spec=3;
   octave_value_list Ai= oct_sparse_inverse( A, perm_c, permc_spec );
   octave_value retval= Ai(0)*Ai(1)*Ai(2)*Ai(3) * B;
   
   return retval;
} // f_s_ldiv 

#endif

// 
// Sparse \ Full solve
// TODO: SuperMatrix provides more functionality into a solvex
//       routine, but how to we implement this in octave?
//
static ComplexMatrix
do_cs_cf_ldiv( SuperMatrix A, ComplexMatrix M )
{
   int Anr= A.nrow;
   int Anc= A.ncol;
   int Bnr= M.rows();
   int Bnc= M.cols();
   if (Anc != Bnr) {
      gripe_nonconformant ("operator \\", Anr, Anc, Bnr, Bnc);
   } else {
      assert (Anc == Bnr);
      SuperMatrix L,U,B;
      doublecomplex * coef= (doublecomplex *) M.fortran_vec();
   
      zCreate_Dense_Matrix(&B, Bnr, Bnc, coef, Bnr, DN, _Z, GE);
      
      int permc_spec = 3;
      int perm_c[ Anc ];
      int perm_r[ Anr ];
      oct_sparse_do_permc( permc_spec, perm_c, A );
   
      int info;
      zgssv(&A, perm_c, perm_r, &L, &U, &B, &info);
   
      if (info !=0 )
         SP_FATAL_ERR("Factorization problem: dgssv");
   
      Destroy_SuperMatrix_Store( &L );
      Destroy_SuperMatrix_Store( &U );
   }

   return M;
}

DEFBINOP( cs_cf_ldiv, complex_sparse, complex_matrix)
{
   DEBUGMSG("complex_sparse - cs_cf_ldiv");

   CAST_BINOP_ARGS ( const octave_complex_sparse&, const octave_complex_matrix&);
   SuperMatrix   A= v1.super_matrix();
   ComplexMatrix M= v2.complex_matrix_value();
   return do_cs_cf_ldiv( A, M );
}   

DEFBINOP( cs_f_ldiv, complex_sparse, matrix)
{
   DEBUGMSG("complex_sparse - cs_f_ldiv");

   CAST_BINOP_ARGS ( const octave_complex_sparse&, const octave_matrix&);
   SuperMatrix   A= v1.super_matrix();
   ComplexMatrix M= v2.complex_matrix_value();
   return do_cs_cf_ldiv( A, M );
}   

SuperMatrix assemble_sparse( int n, int m,
                             ComplexColumnVector& coefA,
                             ColumnVector& ridxA,
                             ColumnVector& cidxA )
{
   DEBUGMSG("complex_sparse - assemble_sparse");
   ASSEMBLE_SPARSE( Complex )
   return X;
}      

SuperMatrix oct_matrix_to_sparse(const ComplexMatrix & A) {      
   DEBUGMSG("complex_sparse - matrix_to_sparse");
   int Anr= A.rows();
   int Anc= A.cols();
   MATRIX_TO_SPARSE( Complex )
   return X;
}

void install_complex_sparse_ops() {
   //
   // unitary operations
   //
   INSTALL_UNOP  (op_transpose, octave_complex_sparse, transpose);
   INSTALL_UNOP  (op_hermitian, octave_complex_sparse, hermitian);
   INSTALL_UNOP  (op_uminus,    octave_complex_sparse, uminus);

   //
   // binary operations: sparse with scalar
   //

   INSTALL_BINOP (op_mul,      octave_complex_sparse, octave_scalar,         s_n_mul);
   INSTALL_BINOP (op_mul,      octave_scalar,         octave_complex_sparse, n_s_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex_sparse, octave_scalar,         s_n_mul);
   INSTALL_BINOP (op_el_mul,   octave_scalar,         octave_complex_sparse, n_s_mul);
   INSTALL_BINOP (op_div,      octave_complex_sparse, octave_scalar,         s_n_div);
   INSTALL_BINOP (op_ldiv,     octave_scalar,         octave_complex_sparse, n_s_ldiv);

   INSTALL_BINOP (op_mul,      octave_complex_sparse, octave_complex,        s_c_mul);
   INSTALL_BINOP (op_mul,      octave_complex,        octave_complex_sparse, c_s_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex_sparse, octave_complex,        s_c_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex,        octave_complex_sparse, c_s_mul);
   INSTALL_BINOP (op_div,      octave_complex_sparse, octave_complex,        s_c_div);
   INSTALL_BINOP (op_ldiv,     octave_complex,        octave_complex_sparse, c_s_ldiv);

   //
   // binary operations: sparse with matrix 
   //  and sparse with sparse
   //
   INSTALL_BINOP (op_ldiv,     octave_complex_sparse, octave_complex_matrix, cs_cf_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_complex_sparse, octave_matrix,         cs_f_ldiv);
#if 0   
   INSTALL_BINOP (op_ldiv,     octave_matrix, octave_complex_sparse, f_s_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_complex_sparse, octave_complex_sparse, s_s_ldiv);
#endif   
   INSTALL_BINOP (op_ne,       octave_complex_sparse, octave_complex_sparse, cs_cs_ne);
   INSTALL_BINOP (op_ne,       octave_complex_sparse, octave_sparse,         cs_s_ne);
   INSTALL_BINOP (op_ne,       octave_sparse,         octave_complex_sparse, s_cs_ne);

   INSTALL_BINOP (op_add,      octave_complex_sparse, octave_complex_sparse, cs_cs_add);
   INSTALL_BINOP (op_add,      octave_complex_sparse, octave_sparse,         cs_s_add);
   INSTALL_BINOP (op_add,      octave_sparse,         octave_complex_sparse, s_cs_add);

   INSTALL_BINOP (op_sub,      octave_complex_sparse, octave_complex_sparse, cs_cs_sub);
   INSTALL_BINOP (op_sub,      octave_complex_sparse, octave_sparse,         cs_s_sub);
   INSTALL_BINOP (op_sub,      octave_sparse,         octave_complex_sparse, s_cs_sub);

   INSTALL_BINOP (op_el_mul,   octave_complex_sparse, octave_complex_sparse, cs_cs_el_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex_sparse, octave_sparse,         cs_s_el_mul);
   INSTALL_BINOP (op_el_mul,   octave_sparse,         octave_complex_sparse, s_cs_el_mul);

   INSTALL_BINOP (op_el_mul,   octave_complex_matrix, octave_sparse,         cf_s_el_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex_matrix, octave_complex_sparse, cf_cs_el_mul);
   INSTALL_BINOP (op_el_mul,   octave_matrix,         octave_complex_sparse, f_cs_el_mul);

   INSTALL_BINOP (op_el_mul,   octave_complex_sparse, octave_complex_matrix, cs_cf_el_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex_sparse, octave_matrix,         cs_f_el_mul);
   INSTALL_BINOP (op_el_mul,   octave_sparse,         octave_complex_matrix, s_cf_el_mul);

   INSTALL_BINOP (op_mul,      octave_complex_sparse, octave_matrix,         cs_f_mul);
   INSTALL_BINOP (op_mul,      octave_complex_sparse, octave_complex_matrix, cs_cf_mul);
   INSTALL_BINOP (op_mul,      octave_sparse,         octave_complex_matrix, s_cf_mul);

   INSTALL_BINOP (op_mul,      octave_complex_matrix, octave_complex_sparse, cf_cs_mul);
   INSTALL_BINOP (op_mul,      octave_complex_matrix, octave_sparse,         cf_s_mul);
   INSTALL_BINOP (op_mul,      octave_matrix,         octave_complex_sparse, f_cs_mul);

   INSTALL_BINOP (op_mul,      octave_complex_sparse, octave_complex_sparse, cs_cs_mul);
   INSTALL_BINOP (op_mul,      octave_complex_sparse, octave_sparse,         cs_s_mul);
   INSTALL_BINOP (op_mul,      octave_sparse,         octave_complex_sparse, s_cs_mul);
}

/*
 * $Log$
 * Revision 1.1  2001/10/10 19:54:49  pkienzle
 * Initial revision
 *
 * Revision 1.6  2001/04/04 02:13:46  aadler
 * complete complex_sparse, templates, fix memory leaks
 *
 * Revision 1.5  2001/03/30 04:36:30  aadler
 * added multiply, solve, and sparse creation
 *
 * Revision 1.4  2001/03/27 03:45:20  aadler
 * use templates for mul, add, sub, el_mul operations
 *
 * Revision 1.3  2001/03/15 15:47:58  aadler
 * cleaned up duplicated code by using "defined" templates.
 * used default numerical conversions
 *
 * Revision 1.2  2001/03/06 03:20:12  aadler
 * added automatic numeric_conversion_function
 *
 * Revision 1.1  2001/02/27 03:01:51  aadler
 * added rudimentary complex matrix support
 *
 * Revision 1.1  2000/12/18 03:31:16  aadler
 * Split code to multiple files
 * added sparse inverse
 *
 */
