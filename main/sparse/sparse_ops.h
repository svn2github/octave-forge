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
            X.elem(i,j)=0; \
      for ( int i=0; i < Anc ; i++) { \
         for ( int j= cidxA[i]; j< cidxA[i+1]; j++) { \
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
            X.elem(i,j)=0; \
      for ( int i=0; i < Bnc ; i++) { \
         for ( int j= cidxB[i]; j< cidxB[i+1]; j++) { \
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
         for (int k=0; k<Anr; k++) Xcol[k]= 0; \
         for (int j= cidxB[i]; j< cidxB[i+1]; j++) { \
            int  col= ridxB[j]; \
            TYPX tmpval = coefB[j]; \
            for (int k= cidxA[col] ; k< cidxA[col+1]; k++)  \
               Xcol[ ridxA[k] ]+= tmpval * coefA[k]; \
         } \
         for (int k=0; k<Anr; k++)  \
            if ( Xcol[k] !=0 ) { \
               check_bounds( cx, nnz, ridxX, coefX ); \
               ridxX[ cx ]= k; \
               coefX[ cx ]= Xcol[k]; \
               cx++; \
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
#define ASSEMBLE_SPARSE( TYPX ) \
   int  nnz= MAX( ridxA.length(), cidxA.length() ); \
   TYPX* coefX= (TYPX*)oct_sparse_malloc( nnz  * sizeof(TYPX)); \
   int * ridxX= (int *)oct_sparse_malloc( nnz  * sizeof(int) ); \
   int * cidxX= (int *)oct_sparse_malloc( (n+1)* sizeof(int)); cidxX[0]= 0; \
 \
   bool ri_scalar = (ridxA.length() == 1); \
   bool ci_scalar = (cidxA.length() == 1); \
   bool cf_scalar = (coefA.length() == 1); \
 \
   sort_idxl idx[ nnz ]; \
   for (int i=0; i<nnz; i++) { \
      idx[i].val = (unsigned long) ( \
                ( ri_scalar ? ridxA(0) : ridxA(i) ) - 1 + \
           m * (( ci_scalar ? cidxA(0) : cidxA(i) ) - 1) );  \
      idx[i].idx = i; \
   } \
 \
   qsort( idx, nnz, sizeof(sort_idxl), sidxl_comp ); \
    \
   int cx= 0; \
   for (int i=0; i<nnz; i++) { \
      unsigned long ii= (int) idx[i].idx; \
      coefX[i]=      ( cf_scalar ? coefA(0) : coefA(ii) ); \
      double ri  =   ( ri_scalar ? ridxA(0) : ridxA(ii) ) - 1 ; \
      ridxX[i]= (int) (ri - ((int) (ri/m))*m ) ; \
      int ci  = (int)( ci_scalar ? cidxA(0) : cidxA(ii) ) - 1 ; \
      while( cx < ci ) cidxX[++cx]= i; \
   } \
   while( cx < n ) cidxX[++cx]= nnz; \
 \
   SuperMatrix X= create_SuperMatrix( m, n, nnz, coefX, ridxX, cidxX );

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
         TYPX tmpval= A(i,j); \
         if (tmpval != 0) { \
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
   int    nnz= NCFX->nnz; \
   for ( int i=0; i < Xnr ; i++) { \
      assert( cidxX[i] >= 0); \
      assert( cidxX[i] <  nnz); \
      assert( cidxX[i] <=  cidxX[i+1]); \
      int reorder=0; \
      for( int j= cidxX[i]; \
               j< cidxX[i+1]; \
               j++ ) { \
         assert( ridxX[j] >= 0); \
         assert( ridxX[j] <  Xnc); \
         assert( coefX[j] !=  0); /* don't keep zero values */ \
         if (j> cidxX[i]) \
            if ( ridxX[j-1] > ridxX[j] ) \
               reorder=1; \
      } /* for j */ \
      if(reorder) { \
         int snum= cidxX[i+1] - cidxX[i]; \
         fixrow_sort arry[snum]; \
         /* copy to the sort struct */ \
         for( int k=0, \
                  j= cidxX[i]; \
                  j< cidxX[i+1]; \
                  j++ ) { \
            arry[k].idx= ridxX[j]; \
            arry[k].val= coefX[j]; \
            k++; \
         } \
         qsort( arry, snum, sizeof(fixrow_sort), fixrow_comp ); \
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
         TYPE v=0; \
         /* iterate to calculate sum */ \
         int colXp= cidxX[n]; \
         int colUp= cidxU[m]; \
 \
         int rpX, rpU; \
         do { \
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
         if (pivot == 0) gripe_divide_by_zero (); \
 \
         if (v!=0) { \
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
      if (pivot == 0) gripe_divide_by_zero (); \
 \
      if (pivot!=1.0) \
         for( int i= cx_colstart; i< cx; i++)  \
            coefX[i]/= pivot; \
   } /* for n */ \
   cidxX[Unr]= cx; \
   maybe_shrink( cx, nnz, ridxX, coefX );
