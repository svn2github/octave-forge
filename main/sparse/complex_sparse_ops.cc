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

// this is required so that code that can't include
// complex sparse headers (because they conflict)
// can still access this
Complex * new_SuperLU_Complex( int size ) {
    return (Complex *) doublecomplexMalloc( size );
}

//
// Octave complex sparse methods
//

octave_complex_sparse::octave_complex_sparse (SuperMatrix A )
{
   DEBUGMSG("complex_sparse( SuperMatrix A)");
   X= A;
}

octave_complex_sparse::octave_complex_sparse (void )
{
   DEBUGMSG("complex_sparse( void)");
}

octave_complex_sparse::~octave_complex_sparse (void)
{
   DEBUGMSG("complex_sparse destructor");
   oct_sparse_Destroy_SuperMatrix( X ) ;
}

//NOTE: I'm not sure when this will get called,
//      so I don't know what to do
octave_complex_sparse::octave_complex_sparse (const octave_complex_sparse& S)
{
   DEBUGMSG("complex_sparse copy-constructor");
   X= S.super_matrix();
}   

octave_value *
octave_complex_sparse::clone (void) const
{
   DEBUGMSG("complex_sparse - clone");
   return new octave_complex_sparse (*this);
}

octave_complex_sparse
octave_complex_sparse::sparse_value (bool) const {
   DEBUGMSG("complex_sparse_value");
   return  (*this);
}

SuperMatrix
octave_complex_sparse::super_matrix (bool) const {
   return X;
}


int octave_complex_sparse::rows    (void) const {
   return X.nrow;
}
int octave_complex_sparse::columns (void) const {
   return X.ncol;
}
int octave_complex_sparse::cols (void) const {
   return X.ncol;
}

int octave_complex_sparse::nnz     (void) const {
   NCformat * NCF  = (NCformat * ) X.Store;
   return   NCF->nnz ;
}

// upconvert octave_sparse to octave_complex_sparse
octave_complex_sparse
octave_sparse::complex_sparse_value (bool) const {
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
      OCTAVE_QUIT;
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

octave_value octave_complex_sparse::any (int dim) const {
   DEBUGMSG("complex_sparse - any");
   ComplexMatrix M= oct_complex_sparse_to_full( X );
   return M.any(dim);
}

octave_value octave_complex_sparse::all (int dim) const {
   DEBUGMSG("complex_sparse - all");
   ComplexMatrix M= oct_complex_sparse_to_full( X );
   return M.all(dim);
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
octave_complex_sparse::complex_matrix_value (bool) const {
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

   BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
   zCompRow_to_CompCol( Xnc, Xnr, nnz,
                  (doublecomplex *) coefX, ridxX, cidxX,
                  (doublecomplex **) &coefB, &ridxB, &cidxB);
   END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
   
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
   BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
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
   END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
}   

// Return a full vector output
// Does it make sense to output a sparse matrix here?
static ComplexColumnVector
sparse_index_oneidx ( SuperMatrix X, const idx_vector ix) {
   DEBUGMSG("complex_sparse_index_oneidx");
   DEFINE_SP_POINTERS_CPLX( X )
   long      ixl; 

   if (ix.is_colon() ) 
      ixl= Xnr*Xnc;
   else  
      ixl= ix.length(-1); 

   OCTAVE_LOCAL_BUFFER (sort_idx, ixp, ixl );
   sort_with_idx (ixp, ix, ixl);

   ComplexColumnVector O( ixl );
   long ip= -Xnr; // previous column position
   long jj=0,jl=0;
   for (long k=0; k< ixl; k++) {
      OCTAVE_QUIT;
      long ii  = ixp[k].val;
      long kout= ixp[k].idx;

      if ( ii<0 || ii>=Xnr*Xnc) {
         error("sparse index out of range");
	 return O;
      }
 
      int rown= ii/Xnr;
      if ( rown > ip/Xnr ) { // we've moved to a new column
         jl= cidxX[rown];
         jj= cidxX[rown+1];
      }

      while ( jl < jj && ridxX[jl] < ii%Xnr ) jl++;

      if ( jl<jj && ridxX[jl] == ii%Xnr ) 
         O( kout ) = coefX[jl] ;
      else
         O( kout ) = 0 ;

      ip=ii;
   }
   return O;
} // sparse_index_oneidx (


static octave_value
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

   OCTAVE_LOCAL_BUFFER (sort_idx, ixp, ixl );
   sort_with_idx (ixp, ix, ixl);

   // extimate the nnz in the output matrix
   int nnz = (int) ceil( (NCFX->nnz) * (1.0*ixl / Xnr) * (1.0*jxl / Xnc) ); 

   Complex * coefB = (Complex *) doublecomplexMalloc(nnz);
   int    * ridxB = intMalloc   (nnz);
   int    * cidxB = intMalloc   (jxl+1);  cidxB[0]= 0;

   OCTAVE_LOCAL_BUFFER (Complex, tcol, ixl );  // a column of the extracted matrix

   int cx= 0, ll=0;
   int ip= -Xnc; // previous column position
   for (int l=0; l< jxl; l++) {
      if (jx.is_colon() )    ll= l;
      else                   ll= jx(l);

      if ( ll<0 || ll>=Xnc) {
	 // XXX FIXME XXX memory leak coefB,cidxB,ridxB
	 error("sparse column index out of range");
	 return octave_value();
      }

      int jl= cidxX[ll];
      int jj= cidxX[ll+1];
      for (long k=0; k< ixl; k++) {
	 OCTAVE_QUIT;
         long ii  = ixp[k].val;
         long kout= ixp[k].idx;
   
         if ( ii<0 || ii>=Xnr) {
	   // XXX FIXME XXX memory leak coefB,cidxB,ridxB
	   error("sparse row index out of range");
	   return octave_value();
	 }

         while ( ridxX[jl] < ii && jl < jj ) jl++;


         if ( ridxX[jl] == ii && jl<jj ) 
            tcol[ kout ] = coefX[jl] ;
         else
            tcol[ kout ] = 0 ;

         ip=ii;
   
      } // for k
      for (int j=0; j<ixl; j++) {
         if (tcol[j] != Complex(0) ) {
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

   zCreate_CompCol_Matrix(&B, ixl, jxl, cx,
         (doublecomplex *) coefB, ridxB, cidxB, NC, _D, GE);

   return octave_value(new octave_complex_sparse(B));
} // sparse_index_twoidx (


octave_value_list
octave_complex_sparse::subsref( const std::string SUBSREF_STRREF type,
                        const LIST<octave_value_list>& idx,
                        int nargout)
{
   octave_value_list retval;
   switch (type[0]) {
     case '(':
       retval = do_index_op (idx.front (), 0);
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

   if (idx.LISTSIZE () > 1)
       retval = retval(0).next_subsref (type, idx);

   return retval;
}

#if HAVE_OCTAVE_CONCAT
octave_complex_sparse&
octave_complex_sparse::insert( const octave_complex_sparse& b, int r, int c)
{
  printf("doing sp_cat with r=%d c=%d", r, c);
  return *this;
}
#endif

#ifdef CLASS_HAS_LOAD_SAVE
bool 
octave_complex_sparse::save_ascii (std::ostream& os, bool& infnan_warned, 
			       bool strip_nan_and_inf)
{
  DEFINE_SP_POINTERS_CPLX( X )
  int nnz = NCFX->nnz;

  // use N-D way of writing matrix
  os << "# nnz: "      << nnz << "\n";
  os << "# rows: "     << Xnr << "\n";
  os << "# columns: "  << Xnc << "\n";

  os << "\n# sparse: vert-idx, horz-idx, value\n";
  // add one to the printed indices to go from
  //  zero-based to one-based arrays
   for (int j=0; j< Xnc; j++)  {
      OCTAVE_QUIT;
      for (int i= cidxX[j]; i< cidxX[j+1]; i++) {
         os << ridxX[i]+1 << " "  << j+1 << " "
	    << coefX[i]   << "\n";
      }
   }
  
  return true;
}

bool
octave_complex_sparse::load_ascii (std::istream& is)
{
  int mord, prim, mdims;
  bool success = true;
  return success;
}
#endif

octave_value
octave_complex_sparse::do_index_op ( const octave_value_list& idx, int resize_ok) 
{
   DEBUGMSG("complex_sparse - index op");
   octave_value retval;
   
   if ( idx.length () == 1) {
      const idx_vector ix = idx (0).index_vector ();
      ComplexColumnVector O= sparse_index_oneidx( X, ix );

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

      retval= sparse_index_twoidx ( X, ix, jx );
   } else
      error("need 1 or 2 indices for sparse indexing operations");

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

   Complex * coefB = (Complex *) doublecomplexMalloc(nnz);
   int    * ridxB = intMalloc   (nnz);
   int    * cidxB = intMalloc   (n+1);  cidxB[0]= 0;

   int cx= 0;
   for (int i=0, ii= c1; i < n ; i++, ii++) {
      OCTAVE_QUIT;
      for ( int j= cidxX[ii]; j< cidxX[ii+1]; j++) {
         int row = ridxX[ j ];
         if ( row>= r1 && row<=r2 && coefX[j] != Complex(0) ) {
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
   zCreate_CompCol_Matrix(&B, m, n, cx,
        (doublecomplex *) coefB, ridxB, cidxB, NC, _D, GE);

   return new octave_complex_sparse ( B );
} // octave_complex_sparse::extract (int r1, int c1, int r2, int c2) const {


void
octave_complex_sparse::print (std::ostream& os, bool pr_as_read_syntax ) const
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
     for (int i= cidxX[j]; i< cidxX[j+1]; i++) {
         OCTAVE_QUIT;
         os << "  (" << ridxX[i]+1 <<
               " , "  << j+1 << ") -> ";
	 octave_print_internal( os, coefX[i], false );
	 os << "\n";
     }
#endif                  
} // print

octave_value_list 
octave_complex_sparse::find( void ) const
{
   DEBUGMSG("complex_sparse - find");
   DEFINE_SP_POINTERS_CPLX( X )
   int nnz = NCFX->nnz;

   octave_value_list retval;
   ColumnVector I(nnz), J(nnz);
   ComplexColumnVector S(nnz);

   for (int i=0,cx=0; i< Xnc; i++) {
      OCTAVE_QUIT;
      for (int j= cidxX[i]; j< cidxX[i+1]; j++ ) {
         I( cx ) = (double) ridxX[j]+1;
         J( cx ) = (double) i+1;
         S( cx ) =          coefX[j];
         cx++;
      }
   }

   retval(0)= I;
   retval(1)= J;
   retval(2)= S;
   retval(3)= (double) Xnr;
   retval(4)= (double) Xnc;
   return retval;
}

//
// sparse by complex  operations
//

octave_value
complex_sparse_complex_multiply (
            const octave_complex_sparse& spar,
            const octave_complex&        cplx)
{
  DEBUGMSG("complex_sparse - complex_sparse_complex_multiply");
  Complex s= cplx.complex_value();

  SuperMatrix X= spar.super_matrix();
  DEFINE_SP_POINTERS_CPLX( X )
  int source_nnz= NCFX->nnz;

  Complex *coefB = (Complex *) doublecomplexMalloc(source_nnz);
  int *    ridxB = intMalloc(source_nnz);
  int *    cidxB = intMalloc(X.ncol+1);

  int nnz=0;
  int col=0;
  for ( int i=0; i< source_nnz; i++) {
     Complex v= coefX[i] * s;
     if (v==0.) continue;
     coefB[nnz]= v;
     ridxB[nnz]= ridxX[i];
     while(i>=cidxX[col]) cidxB[col++] = nnz;
     nnz++;
  }

  while(col <= Xnc) cidxB[col++] = nnz;
  maybe_shrink( source_nnz, nnz, ridxX, coefX );
  SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
  return new octave_complex_sparse ( B );
}

//
// complex_sparse by scalar operations
//

DEFBINOP (cs_n_mul, complex_sparse, scalar) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_scalar&);
  Complex cv( v2.double_value(), 0 );
  return complex_sparse_complex_multiply (v1, cv);
}  

DEFBINOP (n_cs_mul,  scalar, complex_sparse) {
  CAST_BINOP_ARGS (const octave_scalar&, const octave_complex_sparse&);
  Complex cv( v1.double_value(), 0 );
  return complex_sparse_complex_multiply (v2, cv);
}  

DEFBINOP (cs_n_div, complex_sparse, scalar) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_scalar&);
  Complex cv ( v2.double_value (), 0);
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return complex_sparse_complex_multiply (v1, 1.0 / cv );
}  

DEFBINOP (n_cs_ldiv, scalar, complex_sparse) {
  CAST_BINOP_ARGS (const octave_scalar&, const octave_complex_sparse&);
  Complex cv ( v1.double_value (), 0);
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return complex_sparse_complex_multiply (v2, 1.0 / cv );
}  

//
// sparse by complex operations
//

octave_value
sparse_complex_multiply (
            const octave_sparse&  spar,
            const octave_complex& cplx)
{
  DEBUGMSG("complex_sparse - sparse_complex_multiply");
  Complex s = cplx.complex_value();

  SuperMatrix X= spar.super_matrix();
  DEFINE_SP_POINTERS_REAL( X )
  int source_nnz= NCFX->nnz;

  Complex *coefB = (Complex *) doublecomplexMalloc(source_nnz);
  int *    ridxB = intMalloc(source_nnz);
  int *    cidxB = intMalloc(X.ncol+1);

  int nnz=0;
  int col=0;
  for ( int i=0; i< source_nnz; i++) {
     coefB[nnz]=  coefX[i] * s;
     // Use volatile comparison to force zero
     volatile double re = coefB[nnz].real();
     volatile double im = coefB[nnz].imag();
     if (re==0. && im==0.) continue;
     ridxB[nnz] = ridxX[i];
     while(i>=cidxX[col]) cidxB[col++] = nnz;
     nnz++;
  }

  while(col <= Xnc) cidxB[col++] = nnz;
  maybe_shrink( source_nnz, nnz, ridxX, coefX );
  SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
  return new octave_complex_sparse ( B );
}

DEFBINOP (s_c_mul, sparse, complex) {
  CAST_BINOP_ARGS (const octave_sparse&, const octave_complex&);
  return sparse_complex_multiply (v1, v2);
}  

DEFBINOP (c_s_mul, complex, sparse) {
  CAST_BINOP_ARGS (const octave_complex&, const octave_sparse&);
  return sparse_complex_multiply (v2, v1);
}  

DEFBINOP (s_c_div, sparse, complex) {
  CAST_BINOP_ARGS (const octave_sparse&, const octave_complex&);
  Complex cv= v2.complex_value();
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return sparse_complex_multiply (v1, 1.0 / cv );
}  

DEFBINOP (c_s_ldiv, complex, sparse) {
  CAST_BINOP_ARGS (const octave_complex&, const octave_sparse&);
  Complex cv= v1.complex_value();
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return sparse_complex_multiply (v2, 1.0 / cv );
}  

//
// complex_sparse by complex operations
//

DEFBINOP (cs_c_mul, complex_sparse, complex) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex&);
  return complex_sparse_complex_multiply (v1, v2);
}  

DEFBINOP (c_cs_mul, complex, complex_sparse) {
  CAST_BINOP_ARGS (const octave_complex&, const octave_complex_sparse&);
  return complex_sparse_complex_multiply (v2, v1);
}  

DEFBINOP (cs_c_div, complex_sparse, complex) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex&);
  Complex cv= v2.complex_value();
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return complex_sparse_complex_multiply (v1, 1.0 / cv );
}  

DEFBINOP (c_cs_ldiv, complex, complex_sparse) {
  CAST_BINOP_ARGS (const octave_complex&, const octave_complex_sparse&);
  Complex cv= v1.complex_value();
  if (cv == Complex(0,0) ) gripe_divide_by_zero ();
  return complex_sparse_complex_multiply (v2, 1.0 / cv );
}  

// complex exponentition

octave_value
complex_sparse_complex_power (
            const octave_complex_sparse& spar,
            const octave_complex&        cplx)
{
  DEBUGMSG("complex_sparse - complex_sparse_complex_power");
  Complex s= cplx.complex_value();

  SuperMatrix X= spar.super_matrix();
  DEFINE_SP_POINTERS_CPLX( X )
  int source_nnz= NCFX->nnz;

  Complex *coefB = (Complex *) doublecomplexMalloc(source_nnz);
  int *    ridxB = intMalloc(source_nnz);
  int *    cidxB = intMalloc(X.ncol+1);

  int nnz=0;
  int col=0;
  for ( int i=0; i< source_nnz; i++) {
     // Use volatile comparison to force zero
     coefB[nnz] = std::pow( coefX[i] , s);
     volatile double re = coefB[nnz].real();
     volatile double im = coefB[nnz].imag();
     if (re==0. && im==0.) continue;
     ridxB[nnz]= ridxX[i];
     while(i>=cidxX[col]) cidxB[col++] = nnz;
     nnz++;
  }

  while(col <= Xnc) cidxB[col++] = nnz;
  maybe_shrink( source_nnz, nnz, ridxX, coefX );
  SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
  return new octave_complex_sparse ( B );
}

DEFBINOP (cs_n_pow, complex_sparse, scalar) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_scalar&);
  Complex cv( v2.double_value(), 0 );
  return complex_sparse_complex_power (v1, cv);
}  

DEFBINOP (cs_c_pow, complex_sparse, complex) {
  CAST_BINOP_ARGS (const octave_complex_sparse&, const octave_complex&);
  return complex_sparse_complex_power (v1, v2);
}  

octave_value
sparse_complex_power (
            const octave_sparse&   spar,
            const octave_complex&  cplx)
{
  DEBUGMSG("complex_sparse - sparse_complex_power");
  Complex c= cplx.complex_value();

  SuperMatrix X= spar.super_matrix();
  DEFINE_SP_POINTERS_REAL( X )
  int nnz= NCFX->nnz;

  Complex *coefB = (Complex *) doublecomplexMalloc(nnz);
  int *    ridxB = intMalloc(nnz);
  int *    cidxB = intMalloc(X.ncol+1);

  for ( int i=0; i<=Xnc; i++)
     cidxB[i]=  cidxX[i];

  for ( int i=0; i< nnz; i++) {
     Complex cv( coefX[i], 0 );
     coefB[i]=  std::pow (cv , c);
     ridxB[i]=  ridxX[i];
  }

  SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
  return new octave_complex_sparse ( B );
}

DEFBINOP (s_c_pow, sparse, complex) {
  CAST_BINOP_ARGS (const octave_sparse&, const octave_complex&);
  return sparse_complex_power (v1, v2);
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

DEFBINOP( f_cs_ldiv, matrix, complex_sparse) {
   DEBUGMSG("complex_sparse - f_cs_ldiv");
   CAST_BINOP_ARGS ( const octave_matrix&, const octave_complex_sparse&);
   const Matrix A= v1.matrix_value().inverse(); int Anr= A.rows(); int Anc= A.cols();
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   MATRIX_SPARSE_MUL( ComplexMatrix, Complex )
   return X;
} // f_cs_ldiv 

DEFBINOP( cf_cs_ldiv, complex_matrix, complex_sparse) {
   DEBUGMSG("complex_sparse - cf_cs_ldiv");
   CAST_BINOP_ARGS ( const octave_complex_matrix&, const octave_complex_sparse&);
   const ComplexMatrix A= v1.complex_matrix_value().inverse(); int Anr= A.rows(); int Anc= A.cols();
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   MATRIX_SPARSE_MUL( ComplexMatrix, Complex )
   return X;
} // cf_cs_ldiv 

DEFBINOP( cf_s_ldiv, complex_matrix, sparse) {
   DEBUGMSG("complex_sparse - cf_s_ldiv");
   CAST_BINOP_ARGS ( const octave_complex_matrix&, const octave_sparse&);
   const ComplexMatrix A= v1.complex_matrix_value().inverse(); int Anr= A.rows(); int Anc= A.cols();
   SuperMatrix  B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   MATRIX_SPARSE_MUL( ComplexMatrix, double )
   return X;
} // cf_s_ldiv 


DEFBINOP( s_cs_ldiv, sparse, complex_sparse) {
   DEBUGMSG("sparse - s_cs_ldiv");
   CAST_BINOP_ARGS ( const octave_sparse&, const octave_complex_sparse&);
   int n = v1.columns();
   OCTAVE_LOCAL_BUFFER (int, perm_c, n );
   int permc_spec=3;
   octave_value_list Si= oct_sparse_inverse( v1, perm_c, permc_spec );
   octave_value inv= Si(0)*Si(1)*Si(2)*Si(3);
   const octave_value& rep = inv.get_rep ();
   SuperMatrix A = ((const octave_sparse&) rep) . super_matrix ();
   DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix B = v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   SPARSE_SPARSE_MUL( Complex )
   return new octave_complex_sparse ( X );
} // s_cs_ldiv 

DEFBINOP( cs_s_ldiv, complex_sparse, sparse) {
   DEBUGMSG("sparse - cs_s_ldiv");
   CAST_BINOP_ARGS ( const octave_complex_sparse&, const octave_sparse&);
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   int n = v1.columns();
   OCTAVE_LOCAL_BUFFER (int, perm_c, n );
   int permc_spec=3;
   octave_value_list Si= oct_sparse_inverse( v1, perm_c, permc_spec );
   octave_value inv= Si(0)*Si(1)*Si(2)*Si(3);
   const octave_value& rep = inv.get_rep ();
   SuperMatrix A = ((const octave_complex_sparse&) rep) . super_matrix ();
   DEFINE_SP_POINTERS_CPLX( A )
   SPARSE_SPARSE_MUL( Complex )
   return new octave_complex_sparse ( X );
} // s_s_ldiv 

DEFBINOP( cs_cs_ldiv, complex_sparse, complex_sparse) {
   DEBUGMSG("sparse - cs_cs_ldiv");
   CAST_BINOP_ARGS ( const octave_complex_sparse&, const octave_complex_sparse&);
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_CPLX( B )
   int n = v1.columns();
   OCTAVE_LOCAL_BUFFER (int, perm_c, n );
   int permc_spec=3;
   octave_value_list Si= oct_sparse_inverse( v1, perm_c, permc_spec );
   octave_value inv= Si(0)*Si(1)*Si(2)*Si(3);
   const octave_value& rep = inv.get_rep ();
   SuperMatrix A = ((const octave_complex_sparse&) rep) . super_matrix ();
   DEFINE_SP_POINTERS_CPLX( A )
   SPARSE_SPARSE_MUL( Complex )
   return new octave_complex_sparse ( X );
} // cs_cs_ldiv 

// 
// Sparse \ Full solve
// TODO: SuperMatrix provides more functionality into a solvex
//       routine, but how to we implement this in octave?
//
//static ComplexMatrix
// note Matrix M is modified in this routine
void
do_cs_cf_ldiv( SuperMatrix A, ComplexMatrix& M )
{
   int Anr= A.nrow;
   int Anc= A.ncol;
   int Bnr= M.rows();
   int Bnc= M.cols();
   if (Anc != Bnr) {
      gripe_nonconformant ("operator \\", Anr, Anc, Bnr, Bnc);
   } else {
      int permc_spec = 3;
      OCTAVE_LOCAL_BUFFER (int, perm_c, Anc );
      OCTAVE_LOCAL_BUFFER (int, perm_r, Anr );
      BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
      assert (Anc == Bnr);
      SuperMatrix L,U,B;
      doublecomplex * coef= (doublecomplex *) M.fortran_vec();
   
      zCreate_Dense_Matrix(&B, Bnr, Bnc, coef, Bnr, DN, _Z, GE);
      
      oct_sparse_do_permc( permc_spec, perm_c, A );
   
      int info;
      zgssv(&A, perm_c, perm_r, &L, &U, &B, &info);
   
      if (info !=0 ) 
	 error("sparse factorization problem: dgssv");
   
      Destroy_SuperMatrix_Store( &B );
      oct_sparse_Destroy_SuperMatrix( L ) ;
      oct_sparse_Destroy_SuperMatrix( U ) ;
      END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
   }

//   return M;
}

DEFBINOP( cs_cf_ldiv, complex_sparse, complex_matrix)
{
   DEBUGMSG("complex_sparse - cs_cf_ldiv");

   CAST_BINOP_ARGS ( const octave_complex_sparse&, const octave_complex_matrix&);
   SuperMatrix   A= v1.super_matrix();
   ComplexMatrix M= v2.complex_matrix_value();
   do_cs_cf_ldiv( A, M );
   return M;
}   

DEFBINOP( cs_f_ldiv, complex_sparse, matrix)
{
   DEBUGMSG("complex_sparse - cs_f_ldiv");

   CAST_BINOP_ARGS ( const octave_complex_sparse&, const octave_matrix&);
   SuperMatrix   A= v1.super_matrix();
   ComplexMatrix M= v2.complex_matrix_value();
   do_cs_cf_ldiv( A, M );
   return M;
}   

SuperMatrix assemble_sparse( int n, int m,
                             ComplexColumnVector& coefA,
                             ColumnVector& ridxA,
                             ColumnVector& cidxA,
                             int assemble_do_sum)
{
   DEBUGMSG("complex_sparse - assemble_sparse");
   ASSEMBLE_SPARSE( Complex )
// oct_sparse_verify_supermatrix( X );
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

   INSTALL_BINOP (op_mul,      octave_complex_sparse, octave_scalar,         cs_n_mul);
   INSTALL_BINOP (op_mul,      octave_scalar,         octave_complex_sparse, n_cs_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex_sparse, octave_scalar,         cs_n_mul);
   INSTALL_BINOP (op_el_mul,   octave_scalar,         octave_complex_sparse, n_cs_mul);
   INSTALL_BINOP (op_div,      octave_complex_sparse, octave_scalar,         cs_n_div);
   INSTALL_BINOP (op_ldiv,     octave_scalar,         octave_complex_sparse, n_cs_ldiv);
   INSTALL_BINOP (op_el_pow,   octave_complex_sparse, octave_scalar,         cs_n_pow);

   INSTALL_BINOP (op_mul,      octave_complex_sparse, octave_complex,        cs_c_mul);
   INSTALL_BINOP (op_mul,      octave_complex,        octave_complex_sparse, c_cs_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex_sparse, octave_complex,        cs_c_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex,        octave_complex_sparse, c_cs_mul);
   INSTALL_BINOP (op_div,      octave_complex_sparse, octave_complex,        cs_c_div);
   INSTALL_BINOP (op_ldiv,     octave_complex,        octave_complex_sparse, c_cs_ldiv);
   INSTALL_BINOP (op_el_pow,   octave_complex_sparse, octave_complex,        cs_c_pow);

   INSTALL_BINOP (op_mul,      octave_sparse,         octave_complex,        s_c_mul);
   INSTALL_BINOP (op_mul,      octave_complex,        octave_sparse,         c_s_mul);
   INSTALL_BINOP (op_el_mul,   octave_sparse,         octave_complex,        s_c_mul);
   INSTALL_BINOP (op_el_mul,   octave_complex,        octave_sparse,         c_s_mul);
   INSTALL_BINOP (op_div,      octave_sparse,         octave_complex,        s_c_div);
   INSTALL_BINOP (op_ldiv,     octave_complex,        octave_sparse,         c_s_ldiv);
   INSTALL_BINOP (op_el_pow,   octave_sparse,         octave_complex,        s_c_pow);

   //
   // binary operations: sparse with matrix 
   //  and sparse with sparse
   //
   INSTALL_BINOP (op_ldiv,     octave_complex_sparse, octave_complex_matrix, cs_cf_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_complex_sparse, octave_matrix,         cs_f_ldiv);

   INSTALL_BINOP (op_ldiv,     octave_matrix,         octave_complex_sparse, f_cs_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_complex_matrix, octave_complex_sparse, cf_cs_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_complex_matrix, octave_sparse        , cf_s_ldiv);

   INSTALL_BINOP (op_ldiv,     octave_complex_sparse, octave_complex_sparse, cs_cs_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_sparse,         octave_complex_sparse, s_cs_ldiv);
   INSTALL_BINOP (op_ldiv,     octave_complex_sparse, octave_sparse,         cs_s_ldiv);

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
LUextract(SuperMatrix *L, SuperMatrix *U, Complex *Lval, int *Lrow,
          int *Lcol, Complex *Uval, int *Urow, int *Ucol, int *snnzL,
          int *snnzU)
{
   DEBUGMSG("LUextract-complex");
   int         i, j, k;
   int         upper;
   int         fsupc, istart, nsupr;
   int         lastl = 0, lastu = 0;
   Complex     *SNptr;

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
           SNptr = &((Complex*)Lstore->nzval)[L_NZ_START(j)];

           /* Extract U */
	   OCTAVE_QUIT;
           for (i = U_NZ_START(j); i < U_NZ_START(j+1); ++i) {
               Uval[lastu] = ((Complex*)Ustore->nzval)[i];
               if (Uval[lastu] != 0.0) Urow[lastu++] = U_SUB(i);
           }
           /* upper triangle in the supernode */
	   OCTAVE_QUIT;
           for (i = 0; i < upper; ++i) {
               Uval[lastu] = SNptr[i];
               if (Uval[lastu] != 0.0) Urow[lastu++] = L_SUB(istart+i);
           }
           Ucol[j+1] = lastu;

           /* Extract L */
	   OCTAVE_QUIT;
           Lval[lastl] = 1.0; /* unit diagonal */
           Lrow[lastl++] = L_SUB(istart + upper - 1);
           for (i = upper; i < nsupr; ++i) {
               Lval[lastl] = SNptr[i];
                /* Matlab doesn't like explicit zero. */
               if (Lval[lastl] != 0.0) Lrow[lastl++] = L_SUB(istart+i);
           }
           Lcol[j+1] = lastl;

           ++upper;
           
       } /* for j ... */
       
   } /* for k ... */

   *snnzL = lastl;
   *snnzU = lastu;
}

int
complex_sparse_LU_fact(SuperMatrix A,
                       SuperMatrix *LC,
                       SuperMatrix *UC,
                       int * perm_c,
                       int * perm_r, 
                       int permc_spec ) 
{
   DEBUGMSG("complex_sparse_LU_fact");
   int m = A.nrow;
   int n = A.ncol;
   char   refact[1] = {'N'};
   double thresh    = 1.0;     // diagonal pivoting threshold 
   double drop_tol  = 0.0;     // drop tolerance parameter 
   int    info;
   int    panel_size = sp_ienv(1);
   int    relax      = sp_ienv(2);
   OCTAVE_LOCAL_BUFFER (int, etree, n );

   BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
   SuperMatrix Ac;
   SuperMatrix L,U;

   StatInit(panel_size, relax);

   oct_sparse_do_permc( permc_spec, perm_c, A);
   // Apply column perm to A and compute etree.
   sp_preorder(refact, &A, perm_c, etree, &Ac);

   zgstrf(refact, &Ac, thresh, drop_tol, relax, panel_size, etree,
           NULL, 0, perm_r, perm_c, &L, &U, &info);
   if (info == 0) {
      int      snnzL, snnzU;
 
      int       nnzL = ((SCformat*)L.Store)->nnz;
      Complex * Lval = (Complex *) oct_sparse_malloc( nnzL * sizeof(Complex) );
      int     * Lrow = (    int *) oct_sparse_malloc( nnzL * sizeof(    int) );
      int     * Lcol = (    int *) oct_sparse_malloc( (n+1)* sizeof(    int) );
 
      int       nnzU = ((NCformat*)U.Store)->nnz;
      Complex * Uval = (Complex *) oct_sparse_malloc( nnzU * sizeof(Complex) );
      int     * Urow = (    int *) oct_sparse_malloc( nnzU * sizeof(    int) );
      int     * Ucol = (    int *) oct_sparse_malloc( (n+1)* sizeof(    int) );
 
      LUextract(&L, &U, Lval, Lrow, Lcol, Uval, Urow, Ucol, &snnzL, &snnzU);
      // we need to use the snnz values (squeezed vs. unsqueezed)
      zCreate_CompCol_Matrix(LC, m, n, snnzL, (doublecomplex*) Lval, Lrow, Lcol, NC, _Z, GE);
      zCreate_CompCol_Matrix(UC, m, n, snnzU, (doublecomplex*) Uval, Urow, Ucol, NC, _Z, GE);
 
      fix_row_order_complex( *LC );
      fix_row_order_complex( *UC );
   }
   
   oct_sparse_Destroy_SuperMatrix( L ) ;
   oct_sparse_Destroy_SuperMatrix( U ) ;
   oct_sparse_Destroy_SuperMatrix( Ac ) ;
   StatFree();
   END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
#if 0
   printf("verify A\n");  oct_sparse_verify_supermatrix( A );
   printf("verify LC\n"); oct_sparse_verify_supermatrix( *LC );
   printf("verify UC\n"); oct_sparse_verify_supermatrix( *UC );
#endif   

   if ( info < 0 ) {
     error ("sparse LU factorization error");
   } else if (info > 0) {
     error ("sparse matrix is singlar to machine precision");
   }

   return info;
} // complex_sparse_LU_fact(

FIX_ROW_ORDER_SORT_FUNCTIONS( Complex )

void
fix_row_order_complex( SuperMatrix X )
{
   DEBUGMSG("fix_row_order_complex");
   DEFINE_SP_POINTERS_CPLX( X )
   FIX_ROW_ORDER_FUNCTIONS
}   

SuperMatrix
complex_sparse_inv_uppertriang( SuperMatrix U)
{
   DEBUGMSG("sparse_inv_uppertriang");
   DEFINE_SP_POINTERS_CPLX( U )
   int    nnzU= NCFU->nnz;
   SPARSE_INV_UPPERTRIANG( Complex )
   return create_SuperMatrix( Unr,Unc,cx, coefX, ridxX, cidxX );
}                   


/*
 * $Log$
 * Revision 1.25  2004/07/27 18:24:10  aadler
 * save_ascii
 *
 * Revision 1.24  2004/07/27 16:05:55  aadler
 * simplify find
 *
 * Revision 1.23  2003/12/22 15:13:23  pkienzle
 * Use error/return rather than SP_FATAL_ERROR where possible.
 *
 * Test for zero elements from scalar multiply/power and shrink sparse
 * accordingly; accomodate libstdc++ bugs with mixed real/complex power.
 *
 * Revision 1.22  2003/12/11 22:50:29  pkienzle
 * ... again ... remove duplicate install of ldiv (were there two?)
 *
 * Revision 1.21  2003/12/11 21:49:35  pkienzle
 * Remove duplicate installation of c_cs_ldiv
 *
 * Revision 1.20  2003/11/23 14:21:38  adb014
 * Octave CVS now requires void constructors for register_type
 *
 * Revision 1.19  2003/10/18 04:55:47  aadler
 * spreal spimag and new tests
 *
 * Revision 1.18  2003/08/29 21:21:15  aadler
 * mods to fix bugs for empty sparse
 *
 * Revision 1.17  2003/08/29 20:46:53  aadler
 * fixed bug in indexing
 *
 * Revision 1.16  2003/08/29 19:40:56  aadler
 * throw error rather than segfault for singular matrices
 *
 * Revision 1.15  2003/03/05 15:31:53  pkienzle
 * Backport to octave-2.1.36
 *
 * Revision 1.14  2003/02/20 23:03:58  pkienzle
 * Use of "T x[n]" where n is not constant is a g++ extension so replace it with
 * OCTAVE_LOCAL_BUFFER(T,x,n), and other things to keep the picky MipsPRO CC
 * compiler happy.
 *
 * Revision 1.13  2003/01/03 05:49:20  aadler
 * mods to support 2.1.42
 *
 * Revision 1.12  2002/12/25 01:33:00  aadler
 * fixed bug which allowed zero values to be stored in sparse matrices.
 * improved print output
 *
 * Revision 1.11  2002/12/11 17:19:31  aadler
 * sparse .^ scalar operations added
 * improved test suite
 * improved documentation
 * new is_sparse
 * new spabs
 *
 * Revision 1.10  2002/11/27 04:46:42  pkienzle
 * Use new exception handling infrastructure.
 *
 * Revision 1.9  2002/11/16 20:38:20  pkienzle
 * Windows dll and gcc 3.2 problems
 *
 * Revision 1.8  2002/11/05 19:21:07  aadler
 * added indexing for complex_sparse. added tests
 *
 * Revision 1.7  2002/11/05 15:07:33  aadler
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
