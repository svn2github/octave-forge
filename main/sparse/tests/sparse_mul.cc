/*
 * Test code for sparse matrix multiplicaton algorthms:
 * Licenced under the GPL 
 * Copyright (C) 2005 Andy Adler
 * $Id$
 */

#define SPARSE_DOUBLE_CODE
#include "make_sparse.h"

#define TYPX double

// Original multiplication algorithm in octave-forge sparse
//
// This algorithm allocates a full column of the output
// matrix. Hopefully that won't be a storage problem.
//
// TODO: allocate a row or column depending on the larger
//       dimention.

octave_value mul1(const octave_sparse& v1, 
                  const octave_sparse& v2) {
   SuperMatrix   A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   SuperMatrix X;

   int nnz =  NCFA->nnz + NCFB->nnz ;

   TYPX* coefX= (TYPX*)oct_sparse_malloc( nnz  * sizeof(TYPX));
   int * ridxX= (int *)oct_sparse_malloc( nnz  * sizeof(int) );
   int * cidxX= (int *)oct_sparse_malloc((Bnc+1)*sizeof(int)); cidxX[0]= 0;

   TYPX * Xcol= (TYPX*)oct_sparse_malloc( Anr  * sizeof(TYPX));
   int cx= 0;
   for ( int i=0; i < Bnc ; i++) {
      for (int k=0; k<Anr; k++) Xcol[k]= 0.;
      for (int j= cidxB[i]; j< cidxB[i+1]; j++) {
         int  col= ridxB[j];
         TYPX tmpval = coefB[j];
         for (int k= cidxA[col] ; k< cidxA[col+1]; k++)
            Xcol[ ridxA[k] ]+= tmpval * coefA[k];
      }
      for (int k=0; k<Anr; k++) {
         if ( Xcol[k] !=0. ) {
            check_bounds( cx, nnz, ridxX, coefX );
            ridxX[ cx ]= k;
            coefX[ cx ]= Xcol[k];
            cx++;
         }
      }
      cidxX[i+1] = cx;
   }
   free( Xcol );
   maybe_shrink( cx, nnz, ridxX, coefX );
   X= create_SuperMatrix( Anr, Bnc, cx, coefX, ridxX, cidxX );
   return new octave_sparse ( X );
}

// David Bateman's algorithm: doesn't include last "maybe_shrink"
//
octave_value mul2(const octave_sparse& v1, 
                  const octave_sparse& v2) {
   SuperMatrix   A= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( A )
   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )
   SuperMatrix X;

   TYPX * Xcol= (TYPX*)oct_sparse_malloc( Anr  * sizeof(TYPX));
   int nnz= 0;
   for ( int i=0; i < Bnc ; i++) {
      for (int k=0; k<Anr; k++) Xcol[k]= 0.;
      for (int j= cidxB[i]; j< cidxB[i+1]; j++) {
         int  col= ridxB[j];
         for (int k= cidxA[col] ; k< cidxA[col+1]; k++)
            if (Xcol[ ridxA[k] ] == 0. ) {
               Xcol[ ridxA[k] ] = 1.;
               nnz++;
            }
      }
   }
// fprintf(stderr,"nnz (estimate)=%d\n",nnz);

   TYPX* coefX= (TYPX*)oct_sparse_malloc( nnz  * sizeof(TYPX));
   int * ridxX= (int *)oct_sparse_malloc( nnz  * sizeof(int) );
   int * cidxX= (int *)oct_sparse_malloc((Bnc+1)*sizeof(int)); cidxX[0]= 0;

   int cx= 0;
   for ( int i=0; i < Bnc ; i++) {
      for (int k=0; k<Anr; k++) Xcol[k]= 0.;
      for (int j= cidxB[i]; j< cidxB[i+1]; j++) {
         int  col= ridxB[j];
         TYPX tmpval = coefB[j];
         for (int k= cidxA[col] ; k< cidxA[col+1]; k++)
            Xcol[ ridxA[k] ]+= tmpval * coefA[k];
      }
      for (int k=0; k<Anr; k++) {
         if ( Xcol[k] !=0. ) {
            ridxX[ cx ]= k;
            coefX[ cx ]= Xcol[k];
            cx++;
         }
      }
      cidxX[i+1] = cx;
   }
   free( Xcol );
   maybe_shrink( cx, nnz, ridxX, coefX );
// fprintf(stderr,"nnz (calculated)=%d\n",cx);
   X= create_SuperMatrix( Anr, Bnc, cx, coefX, ridxX, cidxX );
   return new octave_sparse ( X );
}

// Loop through each element of output matrix, and calculate 
// the result. This should be most efficient for denser matrices
//
octave_value mul3(const octave_sparse& v1, 
                  const octave_sparse& v2) {
   SuperMatrix   T= v1.super_matrix(); DEFINE_SP_POINTERS_REAL( T )
   DECLARE_SP_POINTERS_REAL( A )
   dCompRow_to_CompCol( Tnc, Tnr, NCFT->nnz, coefT, ridxT, cidxT,
                             &coefA, &ridxA, &cidxA);
   int Anr= Tnc; int Anc= Tnr;  // A = T'

   SuperMatrix   B= v2.super_matrix(); DEFINE_SP_POINTERS_REAL( B )

   int nnz =  NCFT->nnz + NCFB->nnz ; // initial estimate

   TYPX* coefX= (TYPX*)oct_sparse_malloc( nnz  * sizeof(TYPX));
   int * ridxX= (int *)oct_sparse_malloc( nnz  * sizeof(int) );
   int * cidxX= (int *)oct_sparse_malloc((Bnc+1)*sizeof(int)); cidxX[0]= 0;

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
}


DEFUN_DLD (sparse_mul, args, nargout ,
"c=sparse_mul(a,b,alg_number) % c=a*b using alg #alg_number")
{
   octave_value_list retval;

   if (args.length() < 3 ||
       args(0).type_name () != "sparse"  ||
       args(1).type_name () != "sparse" ) {
      print_usage ("sparse_mul");
      return retval;
   }

   if (args(0).columns() != args(1).rows() ) {
      gripe_nonconformant ("operator *", args(0).columns() , args(0).rows(),
                                         args(1).columns() , args(1).rows() );
   }

   const octave_sparse& A = (const octave_sparse&) args(0).get_rep();
   const octave_sparse& B = (const octave_sparse&) args(1).get_rep();
   const int alg_number   = (int) args(2).double_value();

// cerr << "Sparse Multiply with alg_number #" << alg_number << "\n";
   if (alg_number == 1) {
       retval(0) = mul1(A,B);
   } else
   if (alg_number == 2) {
       retval(0) = mul2(A,B);
   } else
   if (alg_number == 3) {
       retval(0) = mul3(A,B);
   } else {
       error("alg_number not understood");
   }

   return retval;
}


DEFUN_DLD (spabsv, args, nargout , "spabsv text")
{
   octave_value_list retval;

   if (args.length() < 1) {
      print_usage ("spabs");
      return retval;
   }

   if (args(0).type_name () == "sparse" ) {
      const octave_sparse& A =
           (const octave_sparse&) args(0).get_rep();
      SuperMatrix X= A.super_matrix();

      DEFINE_SP_POINTERS_REAL( X )
      int nnz= NCFX->nnz;

      double *coefB = doubleMalloc(nnz);
      int *   ridxB = intMalloc(nnz);
      int *   cidxB = intMalloc(X.ncol+1);

      for ( int i=0; i<=Xnc; i++)
         cidxB[i]=  cidxX[i];

      for ( int i=0; i< nnz; i++) {
         coefB[i]=  fabs( coefX[i] );
         ridxB[i]=  ridxX[i];
      }

      SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
      retval(0)= new octave_sparse(B);
   } else
     gripe_wrong_type_arg ("spabsv", args(0));

   return retval;
}

/*
 * $Log$
 * Revision 1.3  2005/05/25 03:43:42  pkienzle
 * Author/Copyright consistency
 *
 * Revision 1.2  2005/03/26 19:26:34  aadler
 * test suite
 *
 * Revision 1.1  2005/03/26 18:02:39  aadler
 * sparse multiplication test code
 *
 */
