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
Revision 1.1  2001/10/10 19:54:49  pkienzle
Initial revision

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
      TYPX* coefX= (TYPX*)malloc( nnz  * sizeof(TYPX)); \
      int * ridxX= (int *)malloc( nnz  * sizeof(int) ); \
      int * cidxX= (int *)malloc((Anc+1)*sizeof(int)); cidxX[0]= 0; \
 \
      int jx= 0; \
      for (int i= 0 ; i < Anc ; i++ ) { \
         int  ja= cidxA[ i ]; \
         int  ja_max= cidxA[ i+1 ]; \
         bool ja_lt_max= ja < ja_max; \
         int  ridxA_ja= ridxA[ ja ]; \
 \
         int  jb= cidxB[ i ]; \
         int  jb_max= cidxB[ i+1 ]; \
         bool jb_lt_max= jb < jb_max; \
         int  ridxB_jb= ridxB[ jb ]; \
 \
         while( ja_lt_max || jb_lt_max ) { \
            if( ( !jb_lt_max ) || \
                ((ridxA_ja < ridxB_jb) && ja_lt_max ) ) \
            { \
               if (A_B_INTERACT) { \
                  ridxX[ jx ] = ridxA_ja; \
                  coefX[ jx ] = coefA[ ja ] _OP_ 0.0; \
                  jx++; \
               } \
               ja++; ridxA_ja= ridxA[ ja ]; ja_lt_max= ja < ja_max; \
            } else \
            if( ( !ja_lt_max ) || \
               ((ridxB_jb < ridxA_ja) && jb_lt_max ) ) \
            { \
               if (A_B_INTERACT) { \
                  ridxX[ jx ] = ridxB_jb; \
                  coefX[ jx ] = 0.0 _OP_ coefB[ jb ]; \
                  jx++; \
               } \
               jb++; ridxB_jb= ridxB[ jb ]; jb_lt_max= jb < jb_max; \
            } else \
            { \
               assert( ridxA_ja == ridxB_jb ); \
               TYPX tmpval= coefA[ ja ] _OP_ coefB[ jb ]; \
               if (tmpval !=0.0) { \
                  coefX[ jx ] = tmpval; \
                  ridxX[ jx ] = ridxA_ja; \
                  jx++; \
               } \
               ja++; ridxA_ja= ridxA[ ja ]; ja_lt_max= ja < ja_max; \
               jb++; ridxB_jb= ridxB[ jb ]; jb_lt_max= jb < jb_max; \
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
      TYPX* coefX= (TYPX*)malloc( nnz  * sizeof(TYPX)); \
      int * ridxX= (int *)malloc( nnz  * sizeof(int) ); \
      int * cidxX= (int *)malloc((Anc+1)*sizeof(int)); cidxX[0]= 0; \
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
      TYPX* coefX= (TYPX*)malloc( nnz  * sizeof(TYPX)); \
      int * ridxX= (int *)malloc( nnz  * sizeof(int) ); \
      int * cidxX= (int *)malloc((Bnc+1)*sizeof(int)); cidxX[0]= 0; \
 \
      TYPX * Xcol= (TYPX*)malloc( Anr  * sizeof(TYPX)); \
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
   TYPX* coefX= (TYPX*)malloc( nnz  * sizeof(TYPX)); \
   int * ridxX= (int *)malloc( nnz  * sizeof(int) ); \
   int * cidxX= (int *)malloc( (n+1)* sizeof(int)); cidxX[0]= 0; \
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
   TYPX * coef = (TYPX *) malloc ( nnz   * sizeof(TYPX) ); \
   int  * ridx = (int  *) malloc ( nnz   * sizeof(int) ); \
   int  * cidx = (int  *) malloc ((Anc+1)* sizeof(int) );  cidx[0]= 0; \
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

