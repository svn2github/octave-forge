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
//  m= rows, n=cols
SuperMatrix assemble_sparse( int n, int m,
                             ColumnVector& coefA,
                             ColumnVector& ridxA,
                             ColumnVector& cidxA,
                             int assemble_do_sum)
{
   DEBUGMSG("sparse - assemble_sparse");
   ASSEMBLE_SPARSE( double, true )
// oct_sparse_verify_supermatrix( X );
   return X;
}      


//
// Octave sparse methods
//

octave_sparse::octave_sparse (void )
{
  DEBUGMSG("sparse( void)");
  X = create_SuperMatrix (0, 0, 0, (double *)0, 0, 0);
}

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
octave_sparse::clone (void) const
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

int octave_sparse::cols (void) const {
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
      OCTAVE_QUIT;
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

octave_value octave_sparse::any (int dim) const {
   DEBUGMSG("sparse - any");
   Matrix M= oct_sparse_to_full( X );
   return M.any(dim);
}

octave_value octave_sparse::all (int dim) const {
   DEBUGMSG("sparse - all");
   Matrix M= oct_sparse_to_full( X );
   return M.all(dim);
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


#ifdef HAVE_OCTAVE_UPLUS
UNOPDECL (uplus, a ) 
{ 
   DEBUGMSG("sparse - uplus");
   CAST_UNOP_ARG (const octave_sparse&); 
   return new octave_sparse (v);
}   
#endif

SuperMatrix
oct_sparse_transpose ( SuperMatrix X ) {
   DEFINE_SP_POINTERS_REAL( X )
   int nnz= NCFX->nnz;

   DECLARE_SP_POINTERS_REAL( B )

   BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
   dCompRow_to_CompCol( Xnc, Xnr, nnz, coefX, ridxX, cidxX,
                             &coefB, &ridxB, &cidxB);
   END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
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
static ColumnVector
sparse_index_oneidx ( SuperMatrix X, const idx_vector ix) {
   DEBUGMSG("sparse_index_oneidx");
   DEFINE_SP_POINTERS_REAL( X )
   long      ixl; 

   if (ix.is_colon() ) 
      ixl= Xnr*Xnc;
   else  
      ixl= ix.length(-1); 

   OCTAVE_LOCAL_BUFFER (sort_idx, ixp, ixl );
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
   DEBUGMSG("sparse_index_twoidx");
   DEFINE_SP_POINTERS_REAL( X )

   int ixl,jxl;
   if (ix.is_colon() )      ixl= Xnr;
   else                     ixl= ix.length(-1); 

   if (jx.is_colon() )      jxl= Xnc;
   else                     jxl= jx.length(-1); 

   OCTAVE_LOCAL_BUFFER (sort_idx, ixp, ixl );
   sort_with_idx (ixp, ix, ixl);

   // extimate the nnz in the output matrix
   int nnz = (int) ceil( (NCFX->nnz) * (1.0*ixl / Xnr) * (1.0*jxl / Xnc) ); 

   double * coefB = doubleMalloc(nnz);
   int    * ridxB = intMalloc   (nnz);
   int    * cidxB = intMalloc   (jxl+1);  cidxB[0]= 0;

   // a column of the extracted matrix
   OCTAVE_LOCAL_BUFFER (double, tcol, ixl );  

   int cx= 0, ll=0;
   // int ip= -Xnc; // previous column position
   for (int l=0; l< jxl; l++) {
      OCTAVE_QUIT;
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

         while ( jl < jj && ridxX[jl] < ii ) jl++;


         if ( jl<jj && ridxX[jl] == ii ) 
            tcol[ kout ] = coefX[jl] ;
         else
            tcol[ kout ] = 0 ;

         // ip=ii;
   
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
   return octave_value(new octave_sparse (B));
} // sparse_index_twoidx (

octave_value_list
octave_sparse::subsref( const std::string SUBSREF_STRREF type,
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

#if defined (HAVE_OCTAVE_CONCAT) || defined (HAVE_OLD_OCTAVE_CONCAT)
octave_value 
octave_sparse::resize (const dim_vector& dv) const
{
  DEBUGMSG("sparse_resize");
  if (dv.length() > 2) {
    error ("Can not resize sparse matrix to NDArray");
    return octave_value ();
  }

  SPARSE_RESIZE (double, , )

  //dPrint_CompCol_Matrix("octave sparse", (SuperMatrix *) &X);
  return new octave_sparse (X);
}

#define SPARSE_CONCAT \
  for (int i = 0; i < An; i++) \
    { \
      if ((i < ra_idx(1)) || (Bn + ra_idx(1) <= i) || (Bnnz == 0)) \
	{ \
	  if (Annz != 0) \
	    { \
	      for (int j = Acolptr[i]; j < Acolptr[i+1]; j++, Cidx++) \
		{ \
		  Cnzval[Cidx] = Anzval[j]; \
		  Crowind[Cidx] = Arowind[j]; \
		} \
	    } \
	} \
      else \
	{ \
	  if (Annz == 0) \
	    { \
	      for (int j = Bcolptr[i]; j < Bcolptr[i+1]; j++, Cidx++) \
		{ \
		  Cnzval[Cidx] = Bnzval[j]; \
		  Crowind[Cidx] = Browind[j] + ra_idx(0); \
		} \
	    }\
	  else \
	    { \
	      for (int j = Acolptr[i], k = Bcolptr[i-ra_idx(1)]; \
		   (j < Acolptr[i+1]) || (k < Bcolptr[i+1-ra_idx(1)]); \
		   Cidx++) \
		{ \
		  if (j < Acolptr[i+1] && k < Bcolptr[i+1-ra_idx(1)]) \
		    if (Arowind [j] < Browind [k] + ra_idx(0)) \
		      { \
			Cnzval[Cidx] = Anzval[j]; \
			Crowind[Cidx] = Arowind[j++]; \
		      } \
		    else \
		      { \
			if (Arowind [j] == Browind [k] + ra_idx(0)) \
			  j++; \
			Cnzval[Cidx] = Bnzval[k]; \
			Crowind[Cidx] = Browind[k++] + ra_idx(0); \
		      } \
		  else if (j < Acolptr[i+1]) \
		    { \
		      Cnzval[Cidx] = Anzval[j]; \
		      Crowind[Cidx] = Arowind[j++]; \
		    } \
		  else \
		    { \
		      Cnzval[Cidx] = Bnzval[k]; \
		      Crowind[Cidx] = Browind[k++] + ra_idx(0); \
		    } \
		} \
	    } \
	} \
      Ccolptr[i+1] = Cidx; \
    } \
  maybe_shrink (Cidx, Annz + Bnnz, Crowind, Cnzval); \
  return create_SuperMatrix(ra.nrow, An, Cidx, Cnzval, Crowind, Ccolptr);

SuperMatrix concat (const SuperMatrix& ra,
		    const SuperMatrix& rb,
		    const Array<int>& ra_idx)
{
  DEBUGMSG("sparse - concat");

  NCformat * Astore  = (NCformat * ) ra.Store;
  int Annz = Astore->nnz;
  int * Arowind = Astore->rowind;
  int * Acolptr = Astore->colptr;
  int An = ra.ncol;

  NCformat * Bstore  = (NCformat * ) rb.Store;
  int Bnnz = Bstore->nnz;
  int * Browind = Bstore->rowind;
  int * Bcolptr = Bstore->colptr;
  int Bn = rb.ncol;

  int * Crowind = (int *) oct_sparse_malloc ((Annz + Bnnz) * sizeof(int));
  int * Ccolptr = (int *) oct_sparse_malloc ((An + 1) * sizeof(int));
  Ccolptr [0] = 0; 
  int Cidx = 0;
  
  if ((ra.Dtype == _Z) || (rb.Dtype == _Z))
    {
      Complex * Cnzval = (Complex *) oct_sparse_malloc ((Annz + Bnnz) *
							sizeof(Complex));
      if ((ra.Dtype == _Z) && (rb.Dtype == _Z))
	{
	  Complex * Anzval = (Complex *)Astore->nzval;
	  Complex * Bnzval = (Complex *)Bstore->nzval;
	  SPARSE_CONCAT;
	}
      else if (ra.Dtype == _Z)
	{
	  Complex * Anzval = (Complex *)Astore->nzval;
	  double * Bnzval = (double *)Bstore->nzval;
	  SPARSE_CONCAT;
	}
      else if (rb.Dtype == _Z)
	{
	  double * Anzval = (double *)Astore->nzval;
	  Complex * Bnzval = (Complex *)Bstore->nzval;
	  SPARSE_CONCAT;
	}
    }
  else
    {
      double * Cnzval = (double *) oct_sparse_malloc ((Annz + Bnnz) *
						      sizeof(double));
      double * Anzval = (double *)Astore->nzval;
      double * Bnzval = (double *)Bstore->nzval;
      SPARSE_CONCAT;
    }
}
#endif

#ifdef CLASS_HAS_LOAD_SAVE
bool 
octave_sparse::save_ascii (std::ostream& os, bool& infnan_warned, 
			       bool strip_nan_and_inf)
{
  DEFINE_SP_POINTERS_REAL( X )
  int nnz = NCFX->nnz;

  // TODO: how should we manage infnan warnings?
  // use 2-D way of writing matrix
  os << "# nnz: "      << nnz << "\n";
  os << "# rows: "     << Xnr << "\n";
  os << "# columns: "  << Xnc << "\n";

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
octave_sparse::load_ascii (std::istream& is)
{
  bool success = true;
  int nnz, cols, rows;
  if ( extract_keyword (is, "nnz",     nnz)  &&
       extract_keyword (is, "rows",    rows)  &&
       extract_keyword (is, "columns", cols) ) {
     Matrix tmp( nnz, 3);
     is >> tmp;
     ColumnVector ridxA= tmp.column(0);
     ColumnVector cidxA= tmp.column(1);
     ColumnVector coefA= tmp.column(2);
     X= assemble_sparse( cols, rows, coefA, ridxA, cidxA, 0);
  }
  else {
     error("load: failed to load sparse value");
     success= false;
  }

  return success;
}

bool 
octave_sparse::save_binary (std::ostream& os, bool& save_as_floats)
{
  DEFINE_SP_POINTERS_REAL( X )

  FOUR_BYTE_INT itmp;
  // Use negative value for ndims to be consistent with other formats
  itmp= -2;        os.write (X_CAST (char *, &itmp), 4);
  itmp= Xnr;       os.write (X_CAST (char *, &itmp), 4);
  itmp= Xnc;       os.write (X_CAST (char *, &itmp), 4);
  itmp= NCFX->nnz; os.write (X_CAST (char *, &itmp), 4);

  // add one to the printed indices to go from
  //  zero-based to one-based arrays
   for (int j=0; j< Xnc; j++)  {
      OCTAVE_QUIT;
      for (int i= cidxX[j]; i< cidxX[j+1]; i++) {
         itmp= ridxX[i]+1; os.write (X_CAST (char *, &itmp), 4);
         itmp= j+1;        os.write (X_CAST (char *, &itmp), 4);

	 // TODO: how to manage save_as_floats?
         os.write (X_CAST (char *, &coefX[i]), 8);
      }
   }
  return true;
}

bool 
octave_sparse::load_binary (std::istream& is, bool swap,
				 oct_mach_info::float_format fmt)
{
  FOUR_BYTE_INT nnz, cols, rows, tmp;
  if (! is.read (X_CAST (char *, &tmp), 4))
    return false;

  if (tmp != -2) {
    error("load: only 2D sparse matrices are supported");
    return false;
  }

  if (! is.read (X_CAST (char *, &rows), 4))
    return false;
  if (! is.read (X_CAST (char *, &cols), 4))
    return false;
  if (! is.read (X_CAST (char *, &nnz), 4))
    return false;

  ColumnVector ridxA( nnz ), cidxA( nnz ), coefA( nnz );
  for( int i=0; i<nnz; i++) {
     FOUR_BYTE_INT cidx, ridx;
     if (! is.read (X_CAST (char *, &ridx), 4))
       return false;
     ridxA(i)= ridx;

     if (! is.read (X_CAST (char *, &cidx), 4))
       return false;
     cidxA(i)= cidx;

     double coef;
     if (! is.read (X_CAST (char *, &coef), 8))
       return false;
     coefA(i)= coef;
  }

  X= assemble_sparse( cols, rows, coefA, ridxA, cidxA, 0);

  return true;
}
#endif


octave_value
octave_sparse::do_index_op ( const octave_value_list& idx, int) 
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

      retval= sparse_index_twoidx ( X, ix, jx );
   } else
      error("need 1 or 2 indices for sparse indexing operations");

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
      OCTAVE_QUIT;
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
   for (int j=0; j< Xnc; j++)  {
      OCTAVE_QUIT;
      for (int i= cidxX[j]; i< cidxX[j+1]; i++) {
         os << "  (" << ridxX[i]+1 <<
               " , "  << j+1 << ") -> ";
	 octave_print_internal( os, coefX[i], false );
	 os << "\n";
      }
   }
#endif
} // print

octave_value_list 
octave_sparse::find( void ) const
{
   DEBUGMSG("sparse - find");
   DEFINE_SP_POINTERS_REAL( X )
   int nnz = NCFX->nnz;

   octave_value_list retval;
   ColumnVector I(nnz), J(nnz);
   ColumnVector S(nnz);

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
  int source_nnz= NCFX->nnz;

  double *coefB = doubleMalloc(source_nnz);
  int *   ridxB = intMalloc(source_nnz);
  int *   cidxB = intMalloc(X.ncol+1);

  int nnz=0;
  int col=0;
  for ( int i=0; i< source_nnz; i++) {
     // Use volatile comparison to force zero
     volatile double v= coefX[i] * s;
     if (v==0.) continue;
     coefB[nnz]= v;
     ridxB[nnz]= ridxX[i];
     while(i>=cidxX[col]) cidxB[col++] = nnz;
     nnz++;
  }

  while(col <= Xnc) cidxB[col++] = nnz;
  maybe_shrink( source_nnz, nnz, ridxX, coefX );
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


DEFBINOP (s_n_pow, sparse, scalar) {
  CAST_BINOP_ARGS (const octave_sparse&, const octave_scalar&);
  DEBUGMSG("sparse - sparse_scalar_power");
  double s= v2.scalar_value();

  SuperMatrix X= v1.super_matrix();
  DEFINE_SP_POINTERS_REAL( X )
  int source_nnz= NCFX->nnz;

  double *coefB = doubleMalloc(source_nnz);
  int *   ridxB = intMalloc(source_nnz);
  int *   cidxB = intMalloc(X.ncol+1);
  bool power_isnot_integer= ( s != (int) s );

  int nnz=0;
  int col=0;
  int idx=0;
  for ( idx=0; idx< source_nnz; idx++) {
     if (power_isnot_integer && coefX[idx]<0) break;
     // Use volatile comparison to force zero
     volatile double v = std::pow( coefX[idx] , s);
     if (v==0.) continue;
     coefB[nnz]= v;
     ridxB[nnz]= ridxX[idx];
     while(idx>=cidxX[col]) cidxB[col++] = nnz;
     nnz++;
  }

  if (idx == source_nnz) { // successful processed all indices without breaking
     while(col <= Xnc) cidxB[col++] = nnz;
     maybe_shrink( source_nnz, nnz, ridxX, coefX );
     SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
     return new octave_sparse ( B );
  }
  
  // since the matrix has negative values, the output is
  // complex. Copy what's been done to a complex, and
  // then continue with complex output

  Complex *coefBc = new_SuperLU_Complex(source_nnz);
  for (int i=0; i< nnz; i++) {
     coefBc[i]=  coefB[i];
  }
  oct_sparse_free( coefB);

  for (int i=idx; i< source_nnz; i++) {
     // Use volatile comparison to force zero
     if (coefX[i] < 0) {
        // Note: force both args to Complex to avoid broken libstdc++
        coefBc[nnz] = std::pow( Complex(coefX[i],0) , Complex(s,0));
        volatile double re = coefBc[nnz].real();
        volatile double im = coefBc[nnz].imag();
        if (re==0. && im==0.) continue;
     }
     else {
        volatile double v = std::pow( coefX[i], s);
	if (v==0.) continue;
        coefBc[nnz] = v;
     }
     ridxB[nnz] = ridxX[i];
     while(i>=cidxX[col]) cidxB[col++] = nnz;
     nnz++;
  }

  while(col <= Xnc) cidxB[col++] = nnz;
  maybe_shrink( source_nnz, nnz, ridxX, coefX );
  SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefBc, ridxB, cidxB );
  return new octave_complex_sparse ( B );
}  

// a scalar .^ sparse has no value, as the result will be
// nearly full -> ie scal^0 = scal;
//DEFBINOP (n_s_pow, scalar, sparse) {

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
	 OCTAVE_QUIT;
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
       
	    OCTAVE_QUIT;
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
   OCTAVE_LOCAL_BUFFER (int, perm_c, n );
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
      warning("sparse solve: haven't implemented user specified permc");
      permc_spec = 0;
   } 

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
      // wrap this in the s_f_ldiv function
      // BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
      get_perm_c(permc_spec, &A, perm_c);
      // END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
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
      int permc_spec = 3;
      OCTAVE_LOCAL_BUFFER (int, perm_c, Anc );
      OCTAVE_LOCAL_BUFFER (int, perm_r, Anr );

      BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
      dCreate_Dense_Matrix(&B, Bnr, Bnc, coef, Bnr, DN, _D, GE);
   
      oct_sparse_do_permc( permc_spec, perm_c, A );
   
      int info;
      dgssv(&A, perm_c, perm_r, &L, &U, &B, &info);
   
      if (info !=0 )
	 error("sparse factorization problem: dgssv");
   
      Destroy_SuperMatrix_Store( &B );
      oct_sparse_Destroy_SuperMatrix( L ) ;
      oct_sparse_Destroy_SuperMatrix( U ) ;
      END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
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

DEFCATOP_SPARSE_FN (sm_sm, sparse, sparse, sparse, super_matrix, super_matrix,
		    concat)

void install_sparse_ops() {
   //
   // unitary operations
   //
   INSTALL_UNOP  (op_transpose, octave_sparse, transpose);
   INSTALL_UNOP  (op_hermitian, octave_sparse, hermitian);
   INSTALL_UNOP  (op_uminus,    octave_sparse, uminus);
#ifdef HAVE_OCTAVE_UPLUS
   INSTALL_UNOP  (op_uplus,     octave_sparse, uplus);
#endif

   //
   // binary operations: sparse with scalar
   //
   INSTALL_BINOP (op_mul,      octave_sparse, octave_scalar, s_n_mul);
   INSTALL_BINOP (op_mul,      octave_scalar, octave_sparse, n_s_mul);
   INSTALL_BINOP (op_el_mul,   octave_sparse, octave_scalar, s_n_mul);
   INSTALL_BINOP (op_el_mul,   octave_scalar, octave_sparse, n_s_mul);
   INSTALL_BINOP (op_el_pow,   octave_sparse, octave_scalar, s_n_pow);

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

   INSTALL_SPARSE_CATOP (octave_sparse, octave_sparse, sm_sm);
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
	   OCTAVE_QUIT;
           for (i = U_NZ_START(j); i < U_NZ_START(j+1); ++i) {
               Uval[lastu] = ((double*)Ustore->nzval)[i];
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
               if (Lval[lastl] != 0.0) Lrow[lastl++] = L_SUB(istart+i);
           }
           Lcol[j+1] = lastl;

           ++upper;
           
       } /* for j ... */
       
   } /* for k ... */

   *snnzL = lastl;
   *snnzU = lastu;
}

// factors A into LC and UC, given permultations perm_c and perm_r
// (or calculate perm_c if permc_spec indicates this)
// return value: =0 -> success
//               >0 -> matrix is singular, don't use for inverse solutions
int
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
   OCTAVE_LOCAL_BUFFER (int, etree, n);
   SuperMatrix Ac;
   SuperMatrix L,U;

   BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE;
   StatInit(panel_size, relax);

   oct_sparse_do_permc( permc_spec, perm_c, A);
   // Apply column perm to A and compute etree.
   sp_preorder(refact, &A, perm_c, etree, &Ac);

   dgstrf(refact, &Ac, thresh, drop_tol, relax, panel_size, etree,
           NULL, 0, perm_r, perm_c, &L, &U, &info);

   if (info == 0) {
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
     error ("LU factorization error");
   } else if (info > 0) {
     error ("sparse matrix is singlar to machine precision");
   }

   return info;
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
sparse_inv_uppertriang( SuperMatrix U) {
   DEBUGMSG("sparse_inv_uppertriang");
   DEFINE_SP_POINTERS_REAL( U )
   int    nnzU= NCFU->nnz;
   SPARSE_INV_UPPERTRIANG( double )
   return create_SuperMatrix( Unr,Unc,cx, coefX, ridxX, cidxX );
}                   

/*
 * $Log$
 * Revision 1.29  2004/11/16 10:31:58  adb014
 * HAVE_OCTAVE_UPLUS config option for backwards compatiability
 *
 * Revision 1.28  2004/11/15 10:26:55  adb014
 * Add unary plus operators as no-op, due to recent change in octave
 *
 * Revision 1.27  2004/11/09 23:34:49  adb014
 * Fix concatenation for recent octave core CVS changes
 *
 * Revision 1.26  2004/08/31 15:23:45  adb014
 * Small build fix for the macro SPARSE_RESIZE
 *
 * Revision 1.25  2004/08/25 16:13:57  adb014
 * Working, but inefficient, concatentaion code
 *
 * Revision 1.24  2004/08/03 14:45:31  aadler
 * clean up ASSEMBLE_SPARSE macro
 *
 * Revision 1.23  2004/08/02 18:46:57  aadler
 * some code for concat operators
 *
 * Revision 1.22  2004/08/02 16:35:41  aadler
 * saving to the octave -binary format
 *
 * Revision 1.21  2004/08/02 15:46:33  aadler
 * tests for sparse saving
 *
 * Revision 1.20  2004/07/27 20:56:44  aadler
 * first steps to concatenation working
 *
 * Revision 1.19  2004/07/27 18:24:10  aadler
 * save_ascii
 *
 * Revision 1.18  2004/07/27 16:05:55  aadler
 * simplify find
 *
 * Revision 1.17  2003/12/22 15:13:23  pkienzle
 * Use error/return rather than SP_FATAL_ERROR where possible.
 *
 * Test for zero elements from scalar multiply/power and shrink sparse
 * accordingly; accomodate libstdc++ bugs with mixed real/complex power.
 *
 * Revision 1.16  2003/11/23 14:21:39  adb014
 * Octave CVS now requires void constructors for register_type
 *
 * Revision 1.15  2003/08/29 20:46:53  aadler
 * fixed bug in indexing
 *
 * Revision 1.14  2003/08/29 19:40:56  aadler
 * throw error rather than segfault for singular matrices
 *
 * Revision 1.13  2003/03/05 15:31:54  pkienzle
 * Backport to octave-2.1.36
 *
 * Revision 1.12  2003/02/20 23:03:58  pkienzle
 * Use of "T x[n]" where n is not constant is a g++ extension so replace it with
 * OCTAVE_LOCAL_BUFFER(T,x,n), and other things to keep the picky MipsPRO CC
 * compiler happy.
 *
 * Revision 1.11  2003/01/03 05:49:20  aadler
 * mods to support 2.1.42
 *
 * Revision 1.10  2002/12/25 01:33:00  aadler
 * fixed bug which allowed zero values to be stored in sparse matrices.
 * improved print output
 *
 * Revision 1.9  2002/12/11 17:19:32  aadler
 * sparse .^ scalar operations added
 * improved test suite
 * improved documentation
 * new is_sparse
 * new spabs
 *
 * Revision 1.8  2002/11/27 04:46:42  pkienzle
 * Use new exception handling infrastructure.
 *
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
