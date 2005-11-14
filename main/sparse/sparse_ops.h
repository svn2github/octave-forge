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
Revision 1.16  2005/11/14 18:24:53  aadler
Define INT64 type to properly handle large matrices

Revision 1.15  2004/11/09 23:34:49  adb014
Fix concatenation for recent octave core CVS changes

Revision 1.14  2004/08/31 15:23:45  adb014
Small build fix for the macro SPARSE_RESIZE

Revision 1.13  2004/08/25 16:13:57  adb014
Working, but inefficient, concatentaion code

Revision 1.12  2004/08/03 14:45:31  aadler
clean up ASSEMBLE_SPARSE macro

Revision 1.11  2003/12/22 15:13:23  pkienzle
Use error/return rather than SP_FATAL_ERROR where possible.

Test for zero elements from scalar multiply/power and shrink sparse
accordingly; accomodate libstdc++ bugs with mixed real/complex power.

Revision 1.10  2003/10/13 03:44:26  aadler
check for out of bounds in allocation

Revision 1.9  2003/04/03 22:06:41  aadler
sparse create bug - need to use heap for large temp vars

Revision 1.8  2003/02/20 23:03:59  pkienzle
Use of "T x[n]" where n is not constant is a g++ extension so replace it with
OCTAVE_LOCAL_BUFFER(T,x,n), and other things to keep the picky MipsPRO CC
compiler happy.

Revision 1.7  2002/12/25 01:33:00  aadler
fixed bug which allowed zero values to be stored in sparse matrices.
improved print output

Revision 1.6  2002/11/27 04:46:42  pkienzle
Use new exception handling infrastructure.

Revision 1.5  2002/01/04 15:53:57  pkienzle
Changes required to compile for gcc-3.0 in debian hppa/unstable

Revision 1.4  2001/11/04 19:54:49  aadler
fix bug with multiple entries in sparse creation.
Added "summation" mode for matrix creation

Revision 1.3  2001/10/14 03:06:31  aadler
fixed memory leak in complex sparse solve
fixed malloc bugs for zero size allocs

Revision 1.2  2001/10/12 02:24:28  aadler
Mods to fix bugs
add support for all zero sparse matrices
add support fom complex sparse inverse

Revision 1.2  2001/04/04 02:13:46  aadler
complete complex_sparse, templates, fix memory leaks

Revision 1.1  2001/03/30 04:34:23  aadler
"template" functions for sparse operations


*/

// I would like to do this with templates,
// but I don't think you can specify operators
//
// TYPX -> output type ( Complex or double)
// _OP_ -> operation to implement ( + , - , != , .* )
// A_B_INTERACT -> evaluate operations where A or B ==0 
//
// I'm assuming that compiler optimization will remove
// the if (0) and x+0 operations
#define SPARSE_EL_OP( TYPX, _OP_, A_B_INTERACT ) \
   SuperMatrix X; \
   if ( (Anc != Bnc) || (Anr != Bnr) ) { \
      gripe_nonconformant ("operator " #_OP_, Anr, Anc, Bnr, Bnc); \
   } else { \
      assert(Anr == Bnr); assert(Anc == Bnc); \
      TYPX* coefX= (TYPX*)oct_sparse_malloc( nnz  * sizeof(TYPX)); \
      int * ridxX= (int *)oct_sparse_malloc( nnz  * sizeof(int) ); \
      int * cidxX= (int *)oct_sparse_malloc((Anc+1)*sizeof(int)); cidxX[0]= 0; \
 \
      int jx= 0; \
      for (int i= 0 ; i < Anc ; i++ ) { \
         int  ja= cidxA[ i ]; \
         int  ja_max= cidxA[ i+1 ]; \
         bool ja_lt_max= ja < ja_max; \
 \
         int  jb= cidxB[ i ]; \
         int  jb_max= cidxB[ i+1 ]; \
         bool jb_lt_max= jb < jb_max; \
 \
         while( ja_lt_max || jb_lt_max ) { \
            OCTAVE_QUIT; \
            if( ( !jb_lt_max ) || \
                ( ja_lt_max && (ridxA[ja] < ridxB[jb]) ) ) \
            { \
               if (A_B_INTERACT) { \
                  ridxX[ jx ] = ridxA[ja]; \
                  coefX[ jx ] = coefA[ ja ] _OP_ 0.0; \
                  jx++; \
               } \
               ja++; ja_lt_max= ja < ja_max; \
            } else \
            if( ( !ja_lt_max ) || \
               ( jb_lt_max && (ridxB[jb] < ridxA[ja]) ) ) \
            { \
               if (A_B_INTERACT) { \
                  ridxX[ jx ] = ridxB[jb]; \
                  coefX[ jx ] = 0.0 _OP_ coefB[ jb ]; \
                  jx++; \
               } \
               jb++; jb_lt_max= jb < jb_max; \
            } else \
            { \
               assert( ridxA[ja] == ridxB[jb] ); \
               TYPX tmpval= coefA[ ja ] _OP_ coefB[ jb ]; \
               if (tmpval !=0.0) { \
                  coefX[ jx ] = tmpval; \
                  ridxX[ jx ] = ridxA[ja]; \
                  jx++; \
               } \
               ja++; ja_lt_max= ja < ja_max; \
               jb++; jb_lt_max= jb < jb_max; \
            } \
         }  \
         cidxX[i+1] = jx;  \
      } \
      maybe_shrink( jx, nnz, ridxX, coefX ); \
      X= create_SuperMatrix( Anr, Anc, jx, coefX, ridxX, cidxX ); \
   }


#define SPARSE_MATRIX_EL_OP( TYPX, _OP_ ) \
   SuperMatrix X; \
   if ( (Anc != Bnc) || (Anr != Bnr) ) { \
      gripe_nonconformant ("operator .*", Anr, Anc, Bnr, Bnc); \
   } else { \
      assert(Anr == Bnr); assert(Anc == Bnc); \
      TYPX* coefX= (TYPX*)oct_sparse_malloc( nnz  * sizeof(TYPX)); \
      int * ridxX= (int *)oct_sparse_malloc( nnz  * sizeof(int) ); \
      int * cidxX= (int *)oct_sparse_malloc((Anc+1)*sizeof(int)); cidxX[0]= 0; \
 \
      int cx= 0; \
      for (int i=0; i < Anc ; i++) { \
         for (int j= cidxA[i]  ; \
                  j< cidxA[i+1]; j++) { \
            OCTAVE_QUIT; \
            int  rowidx = ridxA[j]; \
            TYPX tmpval = B(rowidx,i); \
            if (tmpval != 0.0) { \
               ridxX[ cx ] = rowidx; \
               coefX[ cx ] = tmpval * coefA[ j ]; \
               cx++; \
            } \
         } \
         cidxX[i+1] = cx;  \
      } \
      maybe_shrink( cx, nnz, ridxX, coefX ); \
      X= create_SuperMatrix( Anr, Anc, cx, coefX, ridxX, cidxX ); \
   }

// multiply type ops
// TYPM is the output matrix type
// TYPX is the sparse matrix type
#define SPARSE_MATRIX_MUL( TYPM, TYPX) \
   TYPM X (Anr , Bnc);  \
   if (Anc != Bnr) { \
      gripe_nonconformant ("operator *", Anr, Anc, Bnr, Bnc); \
   } else { \
      assert (Anc == Bnr); \
      for (int i=0; i< Anr; i++ ) \
         for (int j=0; j< Bnc; j++ ) \
            X.elem(i,j)=0.; \
      for ( int i=0; i < Anc ; i++) { \
         for ( int j= cidxA[i]; j< cidxA[i+1]; j++) { \
            OCTAVE_QUIT; \
            int  col = ridxA[j]; \
            TYPX tmpval = coefA[j]; \
            for ( int k=0 ; k< Bnc; k++) { \
               X.elem(col , k)+= tmpval * B(i,k); \
            } \
         } \
      } \
   }

#define MATRIX_SPARSE_MUL( TYPM, TYPX ) \
   TYPM X (Anr , Bnc);  \
   if (Anc != Bnr) { \
      gripe_nonconformant ("operator *", Anr, Anc, Bnr, Bnc); \
   } else { \
      assert (Anc == Bnr); \
      for (int i=0; i< Anr; i++ ) \
         for (int j=0; j< Bnc; j++ ) \
            X.elem(i,j)=0.; \
      for ( int i=0; i < Bnc ; i++) { \
         for ( int j= cidxB[i]; j< cidxB[i+1]; j++) { \
            OCTAVE_QUIT; \
            int  col = ridxB[j]; \
            TYPX tmpval = coefB[j]; \
            for ( int k=0 ; k< Anr; k++) { \
               X(k, i)+= A(k,col) * tmpval; \
            } \
         } \
      } \
   }

//
// Multiply sparse by sparse, element by element
// This algorithm allocates a full column of the output
// matrix. Hopefully that won't be a storage problem.
//
// TODO: allocate a row or column depending on the larger
//       dimention.
//
// I'm sure there are good sparse multiplication algorithms
//   available in the litterature. I invented this one
//   to fill a gap. Tell me if you know of better ones.
//
#define SPARSE_SPARSE_MUL( TYPX ) \
   SuperMatrix X; \
   if (Anc != Bnr) { \
      gripe_nonconformant ("operator *", Anr, Anc, Bnr, Bnc); \
   } else { \
      assert (Anc == Bnr ); \
      int nnz =  NCFA->nnz + NCFB->nnz ; \
      TYPX* coefX= (TYPX*)oct_sparse_malloc( nnz  * sizeof(TYPX)); \
      int * ridxX= (int *)oct_sparse_malloc( nnz  * sizeof(int) ); \
      int * cidxX= (int *)oct_sparse_malloc((Bnc+1)*sizeof(int)); cidxX[0]= 0; \
 \
      TYPX * Xcol= (TYPX*)oct_sparse_malloc( Anr  * sizeof(TYPX)); \
      int cx= 0; \
      for ( int i=0; i < Bnc ; i++) { \
         OCTAVE_QUIT; \
         for (int k=0; k<Anr; k++) Xcol[k]= 0.; \
         for (int j= cidxB[i]; j< cidxB[i+1]; j++) { \
            int  col= ridxB[j]; \
            TYPX tmpval = coefB[j]; \
            for (int k= cidxA[col] ; k< cidxA[col+1]; k++)  \
               Xcol[ ridxA[k] ]+= tmpval * coefA[k]; \
         } \
         for (int k=0; k<Anr; k++) { \
            if ( Xcol[k] !=0. ) { \
               check_bounds( cx, nnz, ridxX, coefX ); \
               ridxX[ cx ]= k; \
               coefX[ cx ]= Xcol[k]; \
               cx++; \
            } \
         } \
         cidxX[i+1] = cx; \
      } \
      free( Xcol ); \
      maybe_shrink( cx, nnz, ridxX, coefX ); \
      X= create_SuperMatrix( Anr, Bnc, cx, coefX, ridxX, cidxX ); \
   } 

// assemble a sparse matrix from elements
//   called by > 1 args for sparse
// NOTE: index vectors are 1 based!
//
// NOTE2: be careful about when we convert ri to int,
// otherwise the maximum matrix size will be m*n < maxint/2
// 
// The OCTAVE_LOCAL_BUFFER can't be used for the sort index
//  when the requested size is too big. we need to put it on the
//  heap.
#define ASSEMBLE_SPARSE( TYPX , REJECT_OUT_OF_RANGE )  \
   int  nnz= MAX( ridxA.length(), cidxA.length() ); \
   TYPX* coefX= (TYPX*)oct_sparse_malloc( nnz  * sizeof(TYPX)); \
   int * ridxX= (int *)oct_sparse_malloc( nnz  * sizeof(int) ); \
   int * cidxX= (int *)oct_sparse_malloc( (n+1)* sizeof(int)); cidxX[0]= 0; \
 \
   bool ri_scalar = (ridxA.length() == 1); \
   bool ci_scalar = (cidxA.length() == 1); \
   bool cf_scalar = (coefA.length() == 1); \
 \
   sort_idxl* sidx = (sort_idxl *)oct_sparse_malloc( nnz* sizeof(sort_idxl) );\
   int actual_nnz=0; \
   INT64 m64= m; \
   OCTAVE_QUIT; \
   for (int i=0; i<nnz; i++) { \
      double rowidx=  ( ri_scalar ? ridxA(0) : ridxA(i) ) - 1; \
      double colidx=  ( ci_scalar ? cidxA(0) : cidxA(i) ) - 1;  \
      if (rowidx < m && rowidx >= 0 && \
          colidx < n && colidx >= 0 ) { \
         if ( coefA( cf_scalar ? 0 : i ) != 0. ) { \
            sidx[actual_nnz].val = rowidx + m64 * colidx; \
            sidx[actual_nnz].idx = i; \
            actual_nnz++; \
         } \
      } \
      else { \
	if( REJECT_OUT_OF_RANGE ) { \
	  error("sparse (row,col) index (%d,%d) out of range", rowidx,colidx);\
          actual_nnz=0; \
	  break; \
	} \
      } \
   } \
 \
   OCTAVE_QUIT; \
   qsort( sidx, actual_nnz, sizeof(sort_idxl), sidxl_comp ); \
    \
   OCTAVE_QUIT; \
   int cx= 0; \
   INT64 prev_val= -1;  \
   int ii= -1; \
   for (int i=0; i<actual_nnz; i++) { \
      OCTAVE_QUIT; \
      unsigned long idx= sidx[i].idx; \
      INT64         val= sidx[i].val; \
      if (prev_val < val) { \
         ii++; \
         coefX[ii]=   coefA( cf_scalar ? 0 : idx ); \
         double ri=   ridxA( ri_scalar ? 0 : idx ) - 1 ; \
         ridxX[ii]=   ri - (ri/m64)*m64 ; \
         double ci=   cidxA( ci_scalar ? 0 : idx ) - 1 ; \
         while( cx < ci ) cidxX[++cx]= ii; \
      } else { \
         if (assemble_do_sum) \
            coefX[ii]+= coefA( cf_scalar ? 0 : idx ); \
         else \
            coefX[ii] = coefA( cf_scalar ? 0 : idx ); \
      } \
      prev_val= val;\
   } \
   while( cx < n ) cidxX[++cx]= ii+1; \
   OCTAVE_QUIT; \
   maybe_shrink( ii+1, actual_nnz, ridxX, coefX ); \
 \
   OCTAVE_QUIT; \
   SuperMatrix X= create_SuperMatrix( m, n, ii+1, coefX, ridxX, cidxX ); \
   oct_sparse_free( sidx );

// destructively resize a sparse matrix
#define SPARSE_RESIZE( TYPX, VECTYP1, VECTYP2)			   \
  /* Special case the redimensioning to an empty matrix */ \
  if (dv.numel() == 0) \
    return new octave_sparse (create_SuperMatrix (0, 0, 0, (TYPX *)0, \
						  0, 0)); \
\
  /* Special case the redimensioning of an empty matrix */ \
  NCformat * Xstore  = (NCformat * ) X.Store; \
  if (Xstore->nnz == 0) \
    { \
      int * colptr = (int *) oct_sparse_malloc ((dv(1) + 1) * sizeof(int)); \
      for (int i = 0; i <= dv(1); i++) \
	colptr [i] = 0; \
      return new octave_sparse (create_SuperMatrix (dv(0), dv(1), 0, \
						    (TYPX *)0, 0, colptr)); \
    } \
\
  octave_value_list find_val= find(); \
  int n= (int) dv(1); \
  int m= (int) dv(0); \
  ColumnVector ridxA= find_val(0).column_vector_value(); \
  ColumnVector cidxA= find_val(1).column_vector_value(); \
  VECTYP1 ## ColumnVector coefA= find_val(2). VECTYP2 ## column_vector_value(); \
  int assemble_do_sum = 0; \
  ASSEMBLE_SPARSE( TYPX, false);

// assemble a sparse matrix from full
//   called by one arg for sparse
// start with an initial estimate for nnz and
// work with it.
#define MATRIX_TO_SPARSE( TYPX ) \
   int nnz= 100; \
   TYPX * coef = (TYPX *) oct_sparse_malloc ( nnz   * sizeof(TYPX) ); \
   int  * ridx = (int  *) oct_sparse_malloc ( nnz   * sizeof(int) ); \
   int  * cidx = (int  *) oct_sparse_malloc ((Anc+1)* sizeof(int) );  cidx[0]= 0; \
   int jx=0; \
   for (int j= 0; j<Anc ; j++ ) { \
      for (int i= 0; i<Anr ; i++ ) { \
         OCTAVE_QUIT; \
         TYPX tmpval= A(i,j); \
         if (tmpval != 0.) { \
            check_bounds( jx, nnz, ridx, coef ); \
            ridx[ jx ]= i; \
            coef[ jx ]= tmpval; \
            jx++; \
         } \
      } \
      cidx[j+1]= jx; \
   } \
   maybe_shrink( jx, nnz, ridx, coef ); \
   SuperMatrix X= create_SuperMatrix( Anr, Anc, jx, coef, ridx, cidx );


//
// Next three functions
//
// Fix the row ordering problems that
// LUExtract seems to cause
// NOTE: we don't try to fix other structural errors
//    in the generated matrices, but we bail out
//    if we find any. This should work since I 
//    haven't seen any problems other than ordering
//
// NOTE: The right way to fix this, of course, is to
//    track down the bug in the superlu codebase.

// define a struct and qsort
// comparison function to do the reordering
#define FIX_ROW_ORDER_SORT_FUNCTIONS( TYPE ) \
typedef struct { unsigned int idx; \
                 TYPE         val; } fixrow_sort; \
static inline int \
fixrow_comp( const void *i, const void *j)  \
{ \
   return  ((fixrow_sort *) i)->idx - \
           ((fixrow_sort *) j)->idx ; \
}

// this define ends function like
// void
// fix_row_order ## TYPE( SuperMatrix X )
// {
//    DEBUGMSG("fix_row_order");
//    DEFINE_SP_POINTERS_REAL( X )
//    FIX_ROW_ORDER_FUNCTIONS( TYPE )
// }

#define FIX_ROW_ORDER_FUNCTIONS \
   for ( int i=0; i < Xnr ; i++) { \
      OCTAVE_QUIT; \
      assert( cidxX[i] >= 0.); \
      assert( cidxX[i] <= NCFX->nnz); \
      assert( cidxX[i] <=  cidxX[i+1]); \
      int reorder=0; \
      for( int j= cidxX[i]; \
               j< cidxX[i+1]; \
               j++ ) { \
         assert( ridxX[j] >= 0.); \
         assert( ridxX[j] <  Xnc); \
         assert( coefX[j] !=  0.); /* don't keep zero values */ \
         if (j> cidxX[i]) \
            if ( ridxX[j-1] > ridxX[j] ) \
               reorder=1; \
      } /* for j */ \
      if(reorder) { \
         int snum= cidxX[i+1] - cidxX[i]; \
         OCTAVE_LOCAL_BUFFER (fixrow_sort, arry, snum); \
         /* copy to the sort struct */ \
         for( int k=0, \
                  j= cidxX[i]; \
                  j< cidxX[i+1]; \
                  j++ ) { \
            arry[k].idx= ridxX[j]; \
            arry[k].val= coefX[j]; \
            k++; \
         } \
         OCTAVE_QUIT; \
         qsort( arry, snum, sizeof(fixrow_sort), fixrow_comp ); \
         OCTAVE_QUIT; \
         /* copy back to the position */ \
         for( int k=0, \
                  j= cidxX[i]; \
                  j< cidxX[i+1]; \
                  j++ ) { \
            ridxX[j]= arry[k].idx; \
            coefX[j]= arry[k].val; \
            k++; \
         } \
      } \
   } // for i 
// endof FIX_ROW_ORDER_FUNCTIONS


// calculate the inverse of an 
//  upper triangular sparse matrix
//
// iUt = inv(U)
//  Note that the transpose is returned
//
// CODE:
//
//  note that the input matrix is accesses in
//  row major order, and the output is accessed
//  in column major. This is the reason that the
//  output matrix is the transpose of the input
//
// I= eye( size(A) );
// for n=1:N  # across
//    for m= n+1:N # down
//       v=0;
//       for i= m-1:-1:n
//          v=v- A(m,i)*I(i,n);
//       end
//       I(m,n)= v/A(m,m);
//    end
//    I(:,n)= I(:,n)/A(n,n);    <- for non unit norm
// end   
//   
// we need to be careful here,
// U is uppertriangular, but we're treating
// it as though it is a lower triag matrix in NR form
//
// debug code
//          printf("n=%d, m=%d, X[%d]=%7.4f U[%d]=%7.4f cXp=%d cUp=%d v=%7.4f\n", 
//                n,m, rpX, coefX[ scolXp ], rpU, coefU[ scolUp ], 
//             scolXp,scolUp, v); 
#if 0   
// this is a pain - we can't use c++ constructors because
// dmalloc complains when they're free'd
   int * ridxX = new int  [nnz]; \
   TYPE* coefX = new TYPE [nnz]; \
   int * cidxX = new int  [Unc+1]; \

#endif   

#define SPARSE_INV_UPPERTRIANG( TYPE ) \
   assert ( Unc == Unr ); \
   /* estimate inverse nnz= input nnz */ \
   int     nnz = NCFU->nnz; \
   int * ridxX = (int * ) oct_sparse_malloc ( sizeof(int) *nnz); \
   TYPE* coefX = (TYPE* ) oct_sparse_malloc ( sizeof(TYPE)*nnz); \
   int * cidxX = (int * ) oct_sparse_malloc ( sizeof(int )*(Unc+1)); \
 \
   int cx= 0; \
 \
   /* iterate accross columns of output matrix */ \
   for ( int n=0; n < Unr ; n++) { \
      OCTAVE_QUIT; \
      /* place the 1 in the identity position */ \
      int cx_colstart= cx; \
 \
      cidxX[n]= cx; \
      check_bounds( cx, nnz, ridxX, coefX ); \
      ridxX[cx]= n; \
      coefX[cx]= 1.0; \
      cx++; \
 \
      /* iterate accross columns of input matrix */ \
      for ( int m= n+1; m< Unr; m++) { \
         TYPE v=0.; \
         /* iterate to calculate sum */ \
         int colXp= cidxX[n]; \
         int colUp= cidxU[m]; \
 \
         int rpX, rpU; \
         do { \
            OCTAVE_QUIT; \
            rpX= ridxX [ colXp ]; \
            rpU= ridxU [ colUp ]; \
 \
            if (rpX < rpU) { \
               colXp++; \
            } else \
            if (rpX > rpU) { \
               colUp++; \
            } else { \
               assert(rpX == rpU); \
               assert(rpX >= n); \
 \
               v-= coefX[ colXp ]*coefU[ colUp ]; \
               colXp++;  \
               colUp++; \
            }  \
 \
         } while ((rpX<m) && (rpU<m) && (colXp<cx) && (colUp<nnzU)); \
 \
         /* get A(m,m) */ \
         colUp= cidxU[m+1]-1; \
         assert (ridxU[ colUp ] == m ); /* assert  U is upper triangular */ \
 \
         TYPE pivot= coefU[ colUp ]; \
         if (pivot == 0.) gripe_divide_by_zero (); \
 \
         if (v!=0.) { \
            check_bounds( cx, nnz, ridxX, coefX ); \
            ridxX[cx]= m; \
            coefX[cx]= v / pivot; \
            cx++; \
         } \
      } /* for m */ \
 \
      /* get A(m,m) */ \
      int colUp= cidxU[n+1]-1; \
      assert (ridxU[ colUp ] == n ); /* assert U upper triangular */ \
      TYPE pivot= coefU[ colUp ]; \
      if (pivot == 0.) gripe_divide_by_zero (); \
 \
      if (pivot!=1.0) \
         for( int i= cx_colstart; i< cx; i++)  \
            coefX[i]/= pivot; \
   } /* for n */ \
   cidxX[Unr]= cx; \
   maybe_shrink( cx, nnz, ridxX, coefX );

#ifdef HAVE_OLD_OCTAVE_CONCAT
#define DEFCATOP_SPARSE_FN(name, ret, t1, t2, e1, e2, f)	\
  CATOPDECL (name, a1, a2)	     \
  { \
    DEBUGMSG("CATOP ## name ## t1 ## t2 ## f"); \
    CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
    SuperMatrix B = f (v1.e1 (), v2.e2 (), ra_idx); \
    if (error_state) \
      return new octave_ ## ret (); \
    else \
      return new octave_ ## ret (B); \
  }

#define INSTALL_SPARSE_CATOP(t1, t2, f) INSTALL_CATOP(t1, t2, f) 
#elif defined (HAVE_OCTAVE_CONCAT)
#define DEFCATOP_SPARSE_FN(name, ret, t1, t2, e1, e2, f)	\
  CATOPDECL (name, a1, a2)	     \
  { \
    DEBUGMSG("CATOP ## name ## t1 ## t2 ## f"); \
    CAST_BINOP_ARGS (octave_ ## t1&, const octave_ ## t2&); \
    SuperMatrix B = f (v1.e1 (), v2.e2 (), ra_idx); \
    if (error_state) \
      return new octave_ ## ret (); \
    else \
      return new octave_ ## ret (B); \
  }

#define INSTALL_SPARSE_CATOP(t1, t2, f) INSTALL_CATOP(t1, t2, f) 
#else
#define DEFCATOP_SPARSE_FN(name, ret, t1, t2, e1, e2, f) 
#define INSTALL_SPARSE_CATOP(t1, t2, f)
#endif

