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

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

$Id$

*/

#define SPARSE_DOUBLE_CODE
#include "make_sparse.h"
#include "sparse_ops.h"


SuperMatrix
create_SuperMatrix( int nr, int nc, int nnz,
                    double * coef,
                    int * ridx,
                    int * cidx )
{
   SuperMatrix  X;
   dCreate_CompCol_Matrix(&X, nr, nc, nnz,
                          coef,
                          ridx, cidx, NC, _D, GE);
   return X;
}


// assemble a sparse matrix from elements
//   called by > 1 args for sparse
// NOTE: index vectors are 1 based!
SuperMatrix assemble_sparse( int n, int m,
                             ColumnVector& coefA,
                             ColumnVector& ridxA,
                             ColumnVector& cidxA,
                             int assemble_do_sum)
{
   DEBUGMSG("sparse - assemble_sparse");
   ASSEMBLE_SPARSE( double )
   return X;
}      


//
// Octave sparse methods
//

octave_sparse::octave_sparse (SuperMatrix A )
{
      DEBUGMSG("sparse( SuperMatrix A)");
      X= A;
}

octave_sparse::~octave_sparse (void)
{
   DEBUGMSG("sparse destructor");
   oct_sparse_Destroy_SuperMatrix( X ) ;
}

//NOTE: I'm not sure when this will get called,
//      so I don't know what to do
octave_sparse::octave_sparse (const octave_sparse& S)
{
   DEBUGMSG("sparse copy-constructor");
   X= S.super_matrix();
}   

octave_value *
octave_sparse::clone (void)
{
   DEBUGMSG("sparse - clone");
   return new octave_sparse (*this);
}

octave_sparse
octave_sparse::sparse_value (bool) const {
   DEBUGMSG("sparse_value");
   return  (*this);
}

SuperMatrix
octave_sparse::super_matrix (bool) const {
   return X;
}


int octave_sparse::rows    (void) const {
   return X.nrow;
}
int octave_sparse::columns (void) const {
   return X.ncol;
}

int octave_sparse::nnz     (void) const {
   NCformat * NCF  = (NCformat * ) X.Store;
   return   NCF->nnz ;
}

Matrix
oct_sparse_to_full ( SuperMatrix X ) {
   DEBUGMSG("sparse - sparse_to_full");
   DEFINE_SP_POINTERS_REAL( X )
   
   Matrix M( Xnr, Xnc );
   for (int j=0; j< Xnc; j++) {
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
   DEBUGMSG("sparse - default_numeric_conversion_function");
   CAST_CONV_ARG (const octave_sparse&);
   return new octave_matrix (v.matrix_value ());
}
 
type_conv_fcn
octave_sparse::numeric_conversion_function (void) const
{
   DEBUGMSG("sparse - numeric_conversion_function");
   return default_numeric_conversion_function;
}

//idx_vector index_vector (void) const { return idx_vector ((double) iv); }

octave_value octave_sparse::any (void) const {
   DEBUGMSG("sparse - any");
   Matrix M= oct_sparse_to_full( X );
   return M.any();
}

octave_value octave_sparse::all (void) const {
   DEBUGMSG("sparse - all");
   Matrix M= oct_sparse_to_full( X );
   return M.all();
}

bool octave_sparse::is_defined    (void) const  { return true; }
bool octave_sparse::is_real_scalar (void) const { return false; }
bool octave_sparse::is_real_type (void) const { return true; }
bool octave_sparse::is_scalar_type (void) const { return false; }
bool octave_sparse::is_numeric_type (void) const { return true; }

bool octave_sparse::valid_as_scalar_index (void) const { return false; }

bool octave_sparse::valid_as_zero_index (void) const { return false; }

//A matrix is true if it is all non zero
bool octave_sparse::is_true (void) const {
   DEBUGMSG("sparse - is_true");
   NCformat * NCF  = (NCformat * ) X.Store;
   return (X.nrow * X.ncol == NCF->nnz );
}


// rebuild a full matrix from a sparse one
// this functionality is accessed through 'full'
Matrix
octave_sparse::matrix_value (bool) const {
   DEBUGMSG("sparse - matrix_value");
   Matrix M= oct_sparse_to_full( X );
   return M;
}

octave_value octave_sparse::uminus (void) const {
   DEFINE_SP_POINTERS_REAL( X )
   int nnz= NCFX->nnz;

   double *coefB = doubleMalloc(nnz);
   int *   ridxB = intMalloc(nnz);
   int *   cidxB = intMalloc(X.ncol+1);

   for ( int i=0; i<=Xnc; i++) 
      cidxB[i]=  cidxX[i];

   for ( int i=0; i< nnz; i++) {
      coefB[i]= -coefX[i];
      ridxB[i]=  ridxX[i];
   }
   
   SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
   return new octave_sparse ( B );
} // octave_value uminus (void) const {

UNOPDECL (uminus, a ) 
{ 
   DEBUGMSG("sparse - uminus");
   CAST_UNOP_ARG (const octave_sparse&); 
   return v.uminus();
}   

SuperMatrix
oct_sparse_transpose ( SuperMatrix X ) {
   DEFINE_SP_POINTERS_REAL( X )
   int nnz= NCFX->nnz;

   DECLARE_SP_POINTERS_REAL( B )

   dCompRow_to_CompCol( Xnc, Xnr, nnz, coefX, ridxX, cidxX,
                             &coefB, &ridxB, &cidxB);
   
   SuperMatrix B= create_SuperMatrix( Xnc, Xnr, nnz, coefB, ridxB, cidxB );
   return B;
}   

octave_value octave_sparse::transpose (void) const {
   return new octave_sparse ( oct_sparse_transpose( X ) );
} // octave_sparse::transpose (void) const {

UNOPDECL (transpose, a)
{
   DEBUGMSG("sparse - transpose");
   CAST_UNOP_ARG (const octave_sparse&); 
   return v.transpose();
} // transpose

// hermitian is same as transpose for real sparse
UNOPDECL (hermitian, a)
{
   DEBUGMSG("sparse - hermitian");
   CAST_UNOP_ARG (const octave_sparse&); 
   return v.transpose();
} // hermitian

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
   DEBUGMSG("sparse_index_oneidx");
   DEFINE_SP_POINTERS_REAL( X )
   long      ixl; 

   if (ix.is_colon() ) 
      ixl= Xnr*Xnc;
   else  
      ixl= ix.length(-1); 

   sort_idx ixp[ ixl ];
   sort_with_idx (ixp, ix, ixl);

   ColumnVector O( ixl );
   // special case if X is all zeros
   if (NCFX->nnz == 0 ) {
      for (long k=0; k< ixl; k++)
         O( k )= 0.0;
      return O;
   }

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
   DEBUGMSG("sparse_index_twoidx");
   DEFINE_SP_POINTERS_REAL( X )

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

         while ( jl < jj && ridxX[jl] < ii ) jl++;


         if ( jl<jj && ridxX[jl] == ii ) 
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

   SuperMatrix B= create_SuperMatrix( ixl, jxl, cx, coefB, ridxB, cidxB );
   return B;                          
} // sparse_index_twoidx (

octave_value_list
octave_sparse::subsref( const std::string type,
                        const SLList<octave_value_list>& idx,
                        int nargout)
{
// octave_value retval;
   octave_value_list retval;
   switch (type[0]) {
     case '(':
       retval = do_index_op (idx.front ());
       break;

     case '{':
     case '.':
     {
       std::string nm = type_name ();
       error ("%s cannot be indexed with %c", nm.c_str (), type[0]);
     }
     break;

     default:
       panic_impossible ();
   }

// return retval.next_subsref (type, idx, nargout);
   return retval;
}

octave_value
octave_sparse::do_index_op ( const octave_value_list& idx) 
{
   DEBUGMSG("sparse - index op");
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

      retval= new octave_sparse ( 
                  sparse_index_twoidx ( X, ix, jx ));
   } else
      SP_FATAL_ERR("need 1 or 2 indices for sparse indexing operations");

   return retval;
} // octave_sparse::do_index_op


octave_value
octave_sparse::extract (int r1, int c1, int r2, int c2) const {
   DEBUGMSG("sparse - extract");
   DEFINE_SP_POINTERS_REAL( X )

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

   SuperMatrix B= create_SuperMatrix( m, n, cx, coefB, ridxB, cidxB );
   return new octave_sparse ( B );
} // octave_sparse::extract (int r1, int c1, int r2, int c2) const {

void
octave_sparse::print (std::ostream& os, bool pr_as_read_syntax ) const
{
   DEBUGMSG("sparse - print");
#if 0
// I find the SuperLU print function to be ugly and clumsy
   dPrint_CompCol_Matrix("octave sparse", &X);
#else      
   DEFINE_SP_POINTERS_REAL( X )
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
// sparse by scalar  operations
//

octave_value
sparse_scalar_multiply (const octave_sparse& spar,
                        const octave_scalar& scal)
{
  DEBUGMSG("sparse - sparse_scalar_multiply");
  double s= scal.scalar_value();

  SuperMatrix X= spar.super_matrix();
  DEFINE_SP_POINTERS_REAL( X )
  int nnz= NCFX->nnz;

  double *coefB = doubleMalloc(nnz);
  int *   ridxB = intMalloc(nnz);
  int *   cidxB = intMalloc(X.ncol+1);

  for ( int i=0; i<=Xnc; i++)
     cidxB[i]=  cidxX[i];

  for ( int i=0; i< nnz; i++) {
     coefB[i]=  coefX[i] * s;
     ridxB[i]=  ridxX[i];
  }

  SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
  return new octave_sparse ( B );
}

DEFBINOP (s_n_mul, sparse, scalar) {
  CAST_BINOP_ARGS (const octave_sparse&, const octave_scalar&);
  return sparse_scalar_multiply (v1, v2);
}  

DEFBINOP (n_s_mul, scalar, sparse) {
  CAST_BINOP_ARGS (const octave_scalar&, const octave_sparse&);
  return sparse_scalar_multiply (v2, v1);
}  

DEFBINOP (s_n_div, sparse, scalar) {
  CAST_BINOP_ARGS (const octave_sparse&, const octave_scalar&);
  double d = v2.scalar_value ();
  if (d == 0) gripe_divide_by_zero ();

  return sparse_scalar_multiply (v1, 1 / d);
}  

DEFBINOP (n_s_ldiv, scalar, sparse) {
  CAST_BINOP_ARGS (const octave_scalar&, const octave_sparse&);
  double d = v1.scalar_value ();
  if (d == 0) gripe_divide_by_zero ();

  return sparse_scalar_multiply (v2, 1 / d);
}  

//
// sparse by matrix  operations
//


DEFBINOP( s_s_add, sparse, sparse)
{
   DEBUGMSG("sparse - s_s_add");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( double,  + , 1 )
   return new octave_sparse ( X );
}

DEFBINOP( s_s_sub, sparse, sparse)
{
   DEBUGMSG("sparse - s_s_sub");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( double,  - , 1 )
   return new octave_sparse ( X );
}

// only implement comparison operators >, < , and !=
// the others will return full matrices

DEFBINOP( s_s_gt, sparse, sparse)
{
   DEBUGMSG("sparse - s_s_gt");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( double,  > , 1 )
   return new octave_sparse ( X );
}

DEFBINOP( s_s_lt, sparse, sparse)
{
   DEBUGMSG("sparse - s_s_lt");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( double,  < , 1 )
   return new octave_sparse ( X );
}

DEFBINOP( s_s_ne, sparse, sparse)
{
   DEBUGMSG("sparse - s_s_ne");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = NCFA->nnz + NCFB->nnz ; // nnz must be <= nnzA + nnzB
   SPARSE_EL_OP ( double, != , 1 )
   return new octave_sparse ( X );
}

//
// Element multiply sparse by full, return a sparse matrix
//
DEFBINOP( s_f_el_mul, sparse, matrix )
{
   DEBUGMSG("sparse - s_f_el_mul");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_matrix&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   const Matrix B= v2.matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   int nnz= NCFA->nnz;
   SPARSE_MATRIX_EL_OP( double , * )
   return new octave_sparse ( X );
}   

DEFBINOP( f_s_el_mul, matrix, sparse )
{
   DEBUGMSG("sparse - f_s_el_mul");
   CAST_BINOP_ARGS (const octave_matrix&, const octave_sparse&);
   SuperMatrix  A= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   const Matrix B= v1.matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   int nnz= NCFA->nnz;
   SPARSE_MATRIX_EL_OP( double , * )
   return new octave_sparse ( X );
}   
   
//
// Element multiply sparse by sparse, return a sparse matrix
//
DEFBINOP( s_s_el_mul, sparse, sparse)
{
   DEBUGMSG("sparse - s_s_el_mul");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_sparse&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int nnz = MIN( NCFA->nnz , NCFB->nnz );
   SPARSE_EL_OP ( double,  * , 0 )
   return new octave_sparse ( X );
}


//
// Multiply sparse by full, return a full matrix
//  (I suppose it's possible that in some cases it makes
//   more sense to return a sparse matrix, but offhand,
//   I can't imagine any real examples. Email me if you can.)

DEFBINOP( s_f_mul, sparse, matrix)
{
   DEBUGMSG("sparse - s_f_mul");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_matrix&);
   SuperMatrix  A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   const Matrix B= v2.matrix_value(); int Bnr= B.rows(); int Bnc= B.cols();
   SPARSE_MATRIX_MUL( Matrix, double )
   return X;
}   

DEFBINOP( f_s_mul, matrix, sparse)
{
   DEBUGMSG("sparse - f_s_mul");
   CAST_BINOP_ARGS (const octave_matrix&, const octave_sparse&);
   const Matrix A= v1.matrix_value(); int Anr= A.rows(); int Anc= A.cols();
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   MATRIX_SPARSE_MUL( Matrix, double )
   return X;
}   


#if 0
// I would have thought this was a fairly efficient
// s_s multiply - but it's 10 times worse than the other
// TODO - figure out why

DEFBINOP( s_s_mul, sparse, sparse)
{
   DEBUGMSG("sparse - s_s_mul");

   CAST_BINOP_ARGS (const octave_sparse&, const octave_sparse&);
   SuperMatrix   T= v1.super_matrix();
   DEFINE_SP_POINTERS_REAL( T )
   DECLARE_SP_POINTERS_REAL( A )
   dCompRow_to_CompCol( Tnc, Tnr, NCFT->nnz, coefT, ridxT, cidxT,
                             &coefA, &ridxA, &cidxA);
   int Anr= Tnc; int Anc= Tnr;                             
 
   SuperMatrix   B= v2.super_matrix();
   DEFINE_SP_POINTERS_REAL( B )
   DECLARE_SP_POINTERS_REAL( X )

   assert (Anr == Bnr ); // since A = T'

// A fairly arbitrary estimate for the nnz   
   int nnz =  NCFT->nnz + NCFB->nnz ;
   ridxX = intMalloc   (nnz);
   coefX = doubleMalloc(nnz);
   cidxX = intMalloc   (Bnc+1);  cidxX[0]= 0;

   int jx= 0;
   for (int j= 0 ; j < Bnc ; j++ ) {
      for (int i= 0 ; i < Anc ; i++ ) {
         int  ja= cidxA[ i ];
         int  ja_max= cidxA[ i+1 ];
         bool ja_lt_max= ja < ja_max;
         int  ridxA_ja= ridxA[ ja ];
       
         int  jb= cidxB[ j ];
         int  jb_max= cidxB[ j+1 ];
         bool jb_lt_max= jb < jb_max;
         int  ridxB_jb= ridxB[ jb ];
       
         double tmpval= 0.0;
         while( ja_lt_max && jb_lt_max ) {
       
            if( ridxA_ja < ridxB_jb )
            {
               ja++; ridxA_ja= ridxA[ ja ]; ja_lt_max= ja < ja_max;
            } else
            if( ridxB_jb < ridxA_ja)
            {
               jb++; ridxB_jb= ridxB[ jb ]; jb_lt_max= jb < jb_max;
            } else
            {
               assert( ridxA_ja == ridxB_jb );
               tmpval+= coefA[ ja ] * coefB[ jb ];
               ja++; ridxA_ja= ridxA[ ja ]; ja_lt_max= ja < ja_max;
               jb++; ridxB_jb= ridxB[ jb ]; jb_lt_max= jb < jb_max;
            }
         } 

         if (tmpval != 0.0) {
            check_bounds( jx, nnz, ridxX, coefX );
            coefX[ jx ] = tmpval;
            ridxX[ jx ] = i;
            jx++;
         }
       
      }
      cidxX[j+1] = jx; 
   }

   maybe_shrink( jx, nnz, ridxX, coefX );
   SuperMatrix  X= create_SuperMatrix( Anc, Bnc, jx, coefX, ridxX, cidxX );
   return new octave_sparse ( X );
} // s_s_mul (const octave_value& a1, const octave_value& a2)
#endif

DEFBINOP( s_s_mul, sparse, sparse)
{
   DEBUGMSG("sparse - s_s_mul");
   CAST_BINOP_ARGS (const octave_sparse&, const octave_sparse&);
   SuperMatrix   A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   SPARSE_SPARSE_MUL( double )
   return new octave_sparse ( X );
}

// TODO: This isn't an efficient solution
//  to take the inverse and multiply,
//  on the other hand, I can rarely see this being
//  a useful thing to do anyway
DEFBINOP( f_s_ldiv, matrix, sparse) {
   DEBUGMSG("sparse - f_s_ldiv");
   CAST_BINOP_ARGS ( const octave_matrix&, const octave_sparse&);
   const Matrix A= v1.matrix_value().inverse();
   int Anr= A.rows(); int Anc= A.cols();
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   MATRIX_SPARSE_MUL( Matrix, double )
   return X;
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
// TODO: the casting here is pretty hideous
DEFBINOP( s_s_ldiv, sparse, sparse) {
   DEBUGMSG("sparse - s_s_ldiv");
   CAST_BINOP_ARGS ( const octave_sparse&, const octave_sparse&);
// SuperMatrix   S= v1.super_matrix();
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
// octave_value  B= new octave_sparse( v2.super_matrix() );
   int n = v1.columns();
   int perm_c[n];
   int permc_spec=3;
   octave_value_list Si= oct_sparse_inverse( v1, perm_c, permc_spec );
   octave_value inv= Si(0)*Si(1)*Si(2)*Si(3);
   const octave_value& rep = inv.get_rep ();
   SuperMatrix A = ((const octave_sparse&) rep) . super_matrix ();
   DEFINE_SP_POINTERS_REAL( A )
   SPARSE_SPARSE_MUL( double )
   return new octave_sparse ( X );
} // s_s_ldiv 


// This is a wrapper around the SuperLU get_perm_c function
//  that does some bug fixes and allows extra conditions
//
// Get column permutation vector perm_c[], according to permc_spec:
//   permc_spec = 0: use the natural ordering 
//   permc_spec = 1: use minimum degree ordering on structure of A'*A
//   permc_spec = 2: use minimum degree ordering on structure of A'+A
//   permc_spec = 3: use column approximate minimum degree
//    	
// my guesses on the choice of permc_spec
//           ==1 the recomended choice for arbitrary matrices,
//           ==2 for matrices close to structurally symetrical
//           ==3 what Matlab seems to use 
//
// if permc_spec== -1, then there is a user specified permc provided
//
void oct_sparse_do_permc( int permc_spec, int perm_c[], 
                     SuperMatrix A ) {
   int Anr= A.nrow;
   int Anc= A.ncol;

   if ( permc_spec < 0 ) {
      SP_FATAL_ERR("sparse solve: haven't implemented user specified permc");
//    perm_c = perm_c_in;
   } 
   else {
//
// KLUDGE: get_perm_c breaks (ie segfaults) if the Matrix is not
// sufficiently sparse. It seems that this is when nnz > 0.4*(m*n)
//
// So we check for this case and substitute a perm_c with no
// reordering (You don't really want to use Sparse Matrices in
// this case anyway, but at least the tool shouldn't break)
//
#ifdef VERBOSE   
   printf("sparse ratio %d : %d -> %f \n:", 
           ((NCformat *) A.Store)->nnz , (Anc*Anr)   ,   
  (double) ((NCformat *) A.Store)->nnz / (Anc*Anr) );
#endif // VERBOSE   

      if ( ((NCformat *) A.Store)->nnz >= 0.40*(Anc*Anr) )  {
         for (int i=0 ; i< Anc ; i++)
            perm_c[i]= i;
      } else {
         get_perm_c(permc_spec, &A, perm_c);
      }
   }
} // static int do_permc( int permc_spec, int permc[], 

// 
// Sparse \ Full solve
// TODO: SuperMatrix provides more functionality into a solvex
//       routine, but how to we implement this in octave?
//
//static octave_value
//s_f_ldiv (const octave_value& a1, const octave_value& a2)
DEFBINOP( s_f_ldiv, sparse, matrix)
{
   DEBUGMSG("sparse - s_f_ldiv");

   CAST_BINOP_ARGS ( const octave_sparse&, const octave_matrix&);
   SuperMatrix   A= v1.super_matrix();
         Matrix  M= v2.matrix_value();
   int Anr= A.nrow;
   int Anc= A.ncol;
   int Bnr= M.rows();
   int Bnc= M.cols();

   if (Anc != Bnr) {
      gripe_nonconformant ("operator \\", Anr, Anc, Bnr, Bnc);
   } else {
      assert (Anc == Bnr);
      SuperMatrix L,U,B;
      double * coef= M.fortran_vec();
   
      dCreate_Dense_Matrix(&B, Bnr, Bnc, coef, Bnr, DN, _D, GE);
   
      int permc_spec = 3;
      int perm_c[ Anc ];
      int perm_r[ Anr ];
      oct_sparse_do_permc( permc_spec, perm_c, A );
   
      int info;
      dgssv(&A, perm_c, perm_r, &L, &U, &B, &info);
   
      if (info !=0 )
         SP_FATAL_ERR("Factorization problem: dgssv");
   
      Destroy_SuperMatrix_Store( &B );
      oct_sparse_Destroy_SuperMatrix( L ) ;
      oct_sparse_Destroy_SuperMatrix( U ) ;
   }

   return M;
}

SuperMatrix oct_matrix_to_sparse(const Matrix & A) {      
   DEBUGMSG("sparse - matrix_to_sparse");
   int Anr= A.rows();
   int Anc= A.cols();
   MATRIX_TO_SPARSE( double )
   return X;
}

void install_sparse_ops() {
   //
   // unitary operations
   //
   INSTALL_UNOP  (op_transpose, octave_sparse, transpose);
   INSTALL_UNOP  (op_hermitian, octave_sparse, hermitian);
   INSTALL_UNOP  (op_uminus,    octave_sparse, uminus);

   //
   // binary operations: sparse with scalar
   //
   INSTALL_BINOP (op_mul,      octave_sparse, octave_scalar, s_n_mul);
   INSTALL_BINOP (op_mul,      octave_scalar, octave_sparse, n_s_mul);
   INSTALL_BINOP (op_el_mul,   octave_sparse, octave_scalar, s_n_mul);
   INSTALL_BINOP (op_el_mul,   octave_scalar, octave_sparse, n_s_mul);

   INSTALL_BINOP (op_div,      octave_sparse, octave_scalar, s_n_div);
   INSTALL_BINOP (op_ldiv,     octave_scalar, octave_sparse, n_s_ldiv);

   //
   // binary operations: sparse with matrix 
   //  and sparse with sparse
   //
   INSTALL_BINOP (op_gt ,      octave_sparse, octave_sparse, s_s_gt);
   INSTALL_BINOP (op_lt ,      octave_sparse, octave_sparse, s_s_lt);
   INSTALL_BINOP (op_ne ,      octave_sparse, octave_sparse, s_s_ne);

   INSTALL_BINOP (op_ldiv,     octave_sparse, octave_matrix, s_f_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_matrix, octave_sparse, f_s_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_sparse, octave_sparse, s_s_ldiv);
   INSTALL_BINOP (op_add,      octave_sparse, octave_sparse, s_s_add);
   INSTALL_BINOP (op_sub,      octave_sparse, octave_sparse, s_s_sub);
   INSTALL_BINOP (op_el_mul,   octave_matrix, octave_sparse, f_s_el_mul);
   INSTALL_BINOP (op_el_mul,   octave_sparse, octave_matrix, s_f_el_mul);
   INSTALL_BINOP (op_el_mul,   octave_sparse, octave_sparse, s_s_el_mul);
   INSTALL_BINOP (op_mul,      octave_sparse, octave_matrix, s_f_mul);
   INSTALL_BINOP (op_mul,      octave_matrix, octave_sparse, f_s_mul);
   INSTALL_BINOP (op_mul,      octave_sparse, octave_sparse, s_s_mul);
}

// functions for splu and inverse

//
// This routine converts from the SuperNodal Matrices
// L,U to the Comp Col format.
//
// It is modified from SuperLU/MATLAB/mexsuperlu.c
//
// It seems to produce badly formatted U. ie the
//   row indeces are unsorted.
// Need to call function to fix this.
//

void
LUextract(SuperMatrix *L, SuperMatrix *U, double *Lval, int *Lrow,
          int *Lcol, double *Uval, int *Urow, int *Ucol, int *snnzL,
          int *snnzU)
{
   DEBUGMSG("LUextract");
   int         i, j, k;
   int         upper;
   int         fsupc, istart, nsupr;
   int         lastl = 0, lastu = 0;
   double      *SNptr;

   SCformat * Lstore = (SCformat *) L->Store;
   NCformat * Ustore = (NCformat *) U->Store;
   Lcol[0] = 0;
   Ucol[0] = 0;
   
   /* for each supernode */
   for (k = 0; k <= Lstore->nsuper; ++k) {
       
       fsupc = L_FST_SUPC(k);
       istart = L_SUB_START(fsupc);
       nsupr = L_SUB_START(fsupc+1) - istart;
       upper = 1;
       
       /* for each column in the supernode */
       for (j = fsupc; j < L_FST_SUPC(k+1); ++j) {
           SNptr = &((double*)Lstore->nzval)[L_NZ_START(j)];

           /* Extract U */
           for (i = U_NZ_START(j); i < U_NZ_START(j+1); ++i) {
               Uval[lastu] = ((double*)Ustore->nzval)[i];
               if (Uval[lastu] != 0.0) Urow[lastu++] = U_SUB(i);
           }
           /* upper triangle in the supernode */
           for (i = 0; i < upper; ++i) {
               Uval[lastu] = SNptr[i];
               if (Uval[lastu] != 0.0) Urow[lastu++] = L_SUB(istart+i);
           }
           Ucol[j+1] = lastu;

           /* Extract L */
           Lval[lastl] = 1.0; /* unit diagonal */
           Lrow[lastl++] = L_SUB(istart + upper - 1);
           for (i = upper; i < nsupr; ++i) {
               Lval[lastl] = SNptr[i];
               if (Lval[lastl] != 0.0) Lrow[lastl++] = L_SUB(istart+i);
           }
           Lcol[j+1] = lastl;

           ++upper;
           
       } /* for j ... */
       
   } /* for k ... */

   *snnzL = lastl;
   *snnzU = lastu;
}

void
sparse_LU_fact(SuperMatrix A,
               SuperMatrix *LC,
               SuperMatrix *UC,
               int * perm_c,
               int * perm_r, 
               int permc_spec ) 
{
   DEBUGMSG("sparse_LU_fact");
   int m = A.nrow;
   int n = A.ncol;
   char   refact[1] = {'N'};
   double thresh    = 1.0;     // diagonal pivoting threshold 
   double drop_tol  = 0.0;     // drop tolerance parameter 
   int    info;
   int    panel_size = sp_ienv(1);
   int    relax      = sp_ienv(2);
   int    etree[n];
   SuperMatrix Ac;
   SuperMatrix L,U;

   StatInit(panel_size, relax);

   oct_sparse_do_permc( permc_spec, perm_c, A);
   // Apply column perm to A and compute etree.
   sp_preorder(refact, &A, perm_c, etree, &Ac);

   dgstrf(refact, &Ac, thresh, drop_tol, relax, panel_size, etree,
           NULL, 0, perm_r, perm_c, &L, &U, &info);
   if ( info < 0 )
      SP_FATAL_ERR ("LU factorization error");

   int      snnzL, snnzU;

   int      nnzL = ((SCformat*)L.Store)->nnz;
   double * Lval = (double *) oct_sparse_malloc( nnzL * sizeof(double) );
   int    * Lrow = (   int *) oct_sparse_malloc( nnzL * sizeof(   int) );
   int    * Lcol = (   int *) oct_sparse_malloc( (n+1)* sizeof(   int) );

   int      nnzU = ((NCformat*)U.Store)->nnz;
   double * Uval = (double *) oct_sparse_malloc( nnzU * sizeof(double) );
   int    * Urow = (   int *) oct_sparse_malloc( nnzU * sizeof(   int) );
   int    * Ucol = (   int *) oct_sparse_malloc( (n+1)* sizeof(   int) );

   LUextract(&L, &U, Lval, Lrow, Lcol, Uval, Urow, Ucol, &snnzL, &snnzU);
   // we need to use the snnz values (squeezed vs. unsqueezed)
   dCreate_CompCol_Matrix(LC, m, n, snnzL, Lval, Lrow, Lcol, NC, _D, GE);
   dCreate_CompCol_Matrix(UC, m, n, snnzU, Uval, Urow, Ucol, NC, _D, GE);

   fix_row_order( *LC );
   fix_row_order( *UC );
   
   oct_sparse_Destroy_SuperMatrix( L ) ;
   oct_sparse_Destroy_SuperMatrix( U ) ;
   oct_sparse_Destroy_SuperMatrix( Ac ) ;
   StatFree();

#if 0
   printf("verify A\n");  oct_sparse_verify_supermatrix( A );
   printf("verify LC\n"); oct_sparse_verify_supermatrix( *LC );
   printf("verify UC\n"); oct_sparse_verify_supermatrix( *UC );
#endif   

} // sparse_LU_fact(

FIX_ROW_ORDER_SORT_FUNCTIONS( double )

void
fix_row_order( SuperMatrix X )
{
   DEBUGMSG("fix_row_order");
   DEFINE_SP_POINTERS_REAL( X )
   FIX_ROW_ORDER_FUNCTIONS
}   

SuperMatrix
sparse_inv_uppertriang( SuperMatrix U)
{
   DEBUGMSG("sparse_inv_uppertriang");
   DEFINE_SP_POINTERS_REAL( U )
   int    nnzU= NCFU->nnz;
   SPARSE_INV_UPPERTRIANG( double )
   return create_SuperMatrix( Unr,Unc,cx, coefX, ridxX, cidxX );
}                   

/*
 * $Log$
 * Revision 1.7  2002/11/05 15:07:34  aadler
 * fixed for 2.1.39 -
 * TODO: fix complex index ops
 *
 * Revision 1.6  2002/11/05 06:03:25  pkienzle
 * remove inline and parameter initialization from external function implementation
 *
 * Revision 1.5  2002/01/04 15:53:57  pkienzle
 * Changes required to compile for gcc-3.0 in debian hppa/unstable
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
 * Revision 1.8  2001/09/23 17:46:12  aadler
 * updated README
 * modified licence to GPL plus link to opensource programmes
 *
 * Revision 1.7  2001/04/04 02:13:46  aadler
 * complete complex_sparse, templates, fix memory leaks
 *
 * Revision 1.6  2001/03/30 04:36:30  aadler
 * added multiply, solve, and sparse creation
 *
 * Revision 1.5  2001/03/27 03:45:20  aadler
 * use templates for mul, add, sub, el_mul operations
 *
 * Revision 1.4  2001/03/15 15:47:58  aadler
 * cleaned up duplicated code by using "defined" templates.
 * used default numerical conversions
 *
 * Revision 1.3  2001/03/06 03:20:12  aadler
 * added automatic numeric_conversion_function
 *
 * Revision 1.2  2001/02/27 03:01:52  aadler
 * added rudimentary complex matrix support
 *
 * Revision 1.1  2000/12/18 03:31:16  aadler
 * Split code to multiple files
 * added sparse inverse
 *
 */
