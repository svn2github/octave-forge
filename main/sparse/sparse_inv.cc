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

$Id$

*/

#define SPARSE_DOUBLE_CODE
#include "make_sparse.h"


//
// perform a sanity check on calculated SuperMatrices
//
#ifndef NDEBUG
void
oct_sparse_verify_supermatrix( SuperMatrix X) 
{  
   DEBUGMSG("verify_supermatrix");
   DEFINE_SP_POINTERS_REAL( X )
   int    nnz= NCFX->nnz;
   int    cx=0;
   for ( int i=0; i < Xnr ; i++) {
      assert( cidxX[i] >= 0);
      assert( cidxX[i] <  nnz);
      assert( cidxX[i] <=  cidxX[i+1]);
      for( int j= cidxX[i];
               j< cidxX[i+1];
               j++ ) {
         assert( ridxX[j] >= 0);
         assert( ridxX[j] <  Xnc);
         assert( coefX[j] !=  0); // don't keep zero values
         if (j> cidxX[i])
            assert( ridxX[j-1] < ridxX[j] );
         cx++;
      } // for j
   } // for i
   assert (cx==nnz);
}   
#endif // NDEBUG         

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
typedef struct { unsigned int idx;
                 double       val; } fixrow_sort;

static inline int
fixrow_comp( const void *i, const void *j) 
{
   return  ((fixrow_sort *) i)->idx -
           ((fixrow_sort *) j)->idx ;
}   

void
fix_row_order( SuperMatrix X )
{
   DEBUGMSG("fix_row_order");
   DEFINE_SP_POINTERS_REAL( X )
   int    nnz= NCFX->nnz;

   for ( int i=0; i < Xnr ; i++) {
      assert( cidxX[i] >= 0);
      assert( cidxX[i] <  nnz);
      assert( cidxX[i] <=  cidxX[i+1]);
      int reorder=0;
      for( int j= cidxX[i];
               j< cidxX[i+1];
               j++ ) {
         assert( ridxX[j] >= 0);
         assert( ridxX[j] <  Xnc);
         assert( coefX[j] !=  0); // don't keep zero values
         if (j> cidxX[i])
            if ( ridxX[j-1] > ridxX[j] )
               reorder=1;
      } // for j
      if(reorder) {
         int snum= cidxX[i+1] - cidxX[i];
         fixrow_sort arry[snum];
         // copy to the sort struct
         for( int k=0,
                  j= cidxX[i];
                  j< cidxX[i+1];
                  j++ ) {
            arry[k].idx= ridxX[j];
            arry[k].val= coefX[j];
            k++;
         }
         qsort( arry, snum, sizeof(fixrow_sort), fixrow_comp );
         // copy back to the position
         for( int k=0,
                  j= cidxX[i];
                  j< cidxX[i+1];
                  j++ ) {
            ridxX[j]= arry[k].idx;
            coefX[j]= arry[k].val;
            k++;
         }
      }
   } // for i
}   

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

static void
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

static void
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
   double * Lval = (double *) malloc( nnzL * sizeof(double) );
   int    * Lrow = (   int *) malloc( nnzL * sizeof(   int) );
   int    * Lcol = (   int *) malloc( (n+1)* sizeof(   int) );

   int      nnzU = ((NCformat*)U.Store)->nnz;
   double * Uval = (double *) malloc( nnzU * sizeof(double) );
   int    * Urow = (   int *) malloc( nnzU * sizeof(   int) );
   int    * Ucol = (   int *) malloc( (n+1)* sizeof(   int) );

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
SuperMatrix
sp_inv_uppertriang( SuperMatrix U)
{
   DEBUGMSG("sp_inv_uppertriang");
   DEFINE_SP_POINTERS_REAL( U )
   int    nnzU= NCFU->nnz;
   // we need to be careful here,
   // U is uppertriangular, but we're treating
   // it as though it is a lower triag matrix in NR form

// if ( Unc != Unr) SP_FATAL_ERR("sp_inv_uppertriang: nr!=nc");
   assert ( Unc == Unr );

   SuperMatrix   X;
   DECLARE_SP_POINTERS_REAL( X )

   // estimate inverse nnz= input nnz
   int    nnz = NCFU->nnz;
   ridxX = intMalloc   (nnz);
   coefX = doubleMalloc(nnz);
   cidxX = intMalloc   (Unc+1);

   int cx= 0;

   // iterate accross columns of output matrix
   for ( int n=0; n < Unr ; n++) {
      // place the 1 in the identity position
      int cx_colstart= cx;

      cidxX[n]= cx;
      check_bounds( cx, nnz, ridxX, coefX );
      ridxX[cx]= n;
      coefX[cx]= 1.0;
      cx++;

      // iterate accross columns of input matrix
      for ( int m= n+1; m< Unr; m++) {
         double v=0;
         // iterate to calculate sum
         int colXp= cidxX[n];
         int colUp= cidxU[m];

         int rpX, rpU;
         do {
            rpX= ridxX [ colXp ];
            rpU= ridxU [ colUp ];

#if 0
            int scolXp=colXp;
            int scolUp=colUp;
#endif            
            if (rpX < rpU) {
               colXp++;
            } else
            if (rpX > rpU) {
               colUp++;
            } else {
               assert(rpX == rpU);
               assert(rpX >= n);

               v-= coefX[ colXp ]*coefU[ colUp ];
               colXp++; 
               colUp++;
            } 
#if 0            
            printf("n=%d, m=%d, X[%d]=%7.4f U[%d]=%7.4f cXp=%d cUp=%d v=%7.4f\n",
                  n,m, rpX, coefX[ scolXp ], rpU, coefU[ scolUp ],
               scolXp,scolUp, v);
#endif            

         } while ((rpX<m) && (rpU<m) && (colXp<cx) && (colUp<nnzU));

         // get A(m,m)
         colUp= cidxU[m+1]-1;
//       if (ridxU[ colUp ] != m) SP_FATAL_ERR("sp_inv_uppertriang: not Utriang input");
         // assert fails if U is not upper triangular
         assert (ridxU[ colUp ] == m );

         double pivot= coefU[ colUp ];
         if (pivot == 0) gripe_divide_by_zero ();

         if (v!=0) {
            check_bounds( cx, nnz, ridxX, coefX );
            ridxX[cx]= m;
            coefX[cx]= v / pivot;
            cx++;
         }
      } // for m

      // get A(m,m)
      int colUp= cidxU[n+1]-1;
//    if (ridxU[ colUp ] != n) SP_FATAL_ERR("sp_inv_uppertriang: not Utriang input");
      // assert fails if U is not upper triangular
      assert (ridxU[ colUp ] == n );
      double pivot= coefU[ colUp ];
      if (pivot == 0) gripe_divide_by_zero ();

      if (pivot!=1.0)
         for( int i= cx_colstart; i< cx; i++) 
            coefX[i]/= pivot;

   } // for n
   cidxX[Unr]= cx;

   maybe_shrink( cx, nnz, ridxX, coefX );
   dCreate_CompCol_Matrix(&X, Unr, Unc, cx,
                          coefX, ridxX, cidxX, NC, _D, GE);
   return X;
}                   


DEFUN_DLD (splu, args, nargout ,
  "[L,U,Prow, Pcol] = splu( a ,p);\n\
SPLU : Sparse Matrix LU factorization\n\
\n\
With one input and two or three outputs, SPLU has the same effect as LU,\n\
Except that row and column permutations are returned\n\
\n\
[L,U,Pr,Pc] = splu(A) \n\
          returns unit lower triangular L, upper triangular U,\n\
          and permutation matrices Pr,Pc with Pr*A*Pc' = L*U.\n\
[Lp,Up] = superlu(A) returns permuted triangular L and upper triangular U\n\
          with A = L*U.\n\
          here Pr*Lp = L  and Up*Pc = U
\n\
Note: 2nd input funcionality has not been verified\n\
With a second input, the columns of A are permuted before factoring:\n\
\n\
[L,U,P] = superlu(A,psparse) returns triangular L and U and permutation\n\
          prow with P*A(:,psparse) = L*U.\n\
[L,U] = superlu(A,psparse) returns permuted triangular L and triangular U\n\
          with A(:,psparse) = L*U.\n\
Here psparse will normally be a user-supplied permutation matrix or vector\n\
to be applied to the columns of A for sparsity. \n\
  ")
{
   octave_value_list retval;
   octave_value tmp;
   int nargin = args.length ();

   if (args.length() < 1) {
      print_usage ("splu");
      return retval;
   }
 
   if (args(0).type_name () == "sparse") {
      const octave_value& rep = args(0).get_rep ();
 
      SuperMatrix A = ((const octave_sparse&) rep) . super_matrix ();
      SuperMatrix L, U;
      int m = A.nrow;
      int n = A.ncol;
      if (m != n)
         SP_FATAL_ERR("Input matrix must be square");

      int perm_c[n];
      int permc_spec=3;
      if (nargin ==2) {

         ColumnVector permcidx = args(1).column_vector_value();
         for( int i= 0; i< n ; i++ ) 
            perm_c[i]= (int) permcidx(i) - 1;
         permc_spec= -1; //permc is perselected
      }

      int perm_r[m];
      sparse_LU_fact( A, &L, &U, perm_c, perm_r, permc_spec);

      octave_value LS= new octave_sparse( L );
      octave_value US= new octave_sparse( U );

// Build the permutation matrix
//  remember to add 1 because assemble_sparse is 1 based
      ColumnVector ridxPr(m), cidxPr(m), coefPr(m);
      for (int i=0; i<m; i++) {
         ridxPr(i)= (double) i + 1;
         cidxPr(i)= (double) perm_r[i] + 1; 
         coefPr(i)= 1.0;
      }

      ColumnVector ridxPc(n), cidxPc(n), coefPc(n);
      for (int i=0; i<m; i++) {
         ridxPc(i)= (double) i + 1;
         cidxPc(i)= (double) perm_c[i] + 1; 
         coefPc(i)= 1.0;
      }
      
      if (nargout ==2 ) {
         octave_value PrT= new octave_sparse (
               assemble_sparse( m, m, coefPr, ridxPr, cidxPr ) );
         octave_value Pc = new octave_sparse (
               assemble_sparse( n, n, coefPc, cidxPc, ridxPc ) );
         retval(0)= PrT*LS;
         retval(1)= US*Pc ;
      } else
      if (nargout >2 ) {
         //build PS backwards to get the transpose
         octave_value Pr = new octave_sparse (
               assemble_sparse( m, m, coefPr, cidxPr, ridxPr ) );
         octave_value Pc = new octave_sparse (
               assemble_sparse( n, n, coefPc, cidxPc, ridxPc ) );
         retval(0)= LS;
         retval(1)= US;
         retval(2)= Pr;
         retval(3)= Pc;
      }
   }
   else
     gripe_wrong_type_arg ("splu", args(0));

   return retval;
}


//
// calculate the pieces of the sparse_inverse
//
// Math: 
//  Since A= PrT*LS*US*Pc
//  inv(A)= inv(Pc)*inv(US)*inv(LS)*inv(PrT)
//  inv(a)=   PcT * inv(US)*inv(LS)* Pr
//
//  output is { PcT, inv(US), inv(LS) , Pr }
//
// The simplest way to call this is:
//    int n = A.ncol;
//    int perm_c[n];
//    int permc_spec=3;
//    oct_sparse_inverse( A, perm_c, perm_c_spec )
//
octave_value_list
oct_sparse_inverse( SuperMatrix A,
                    int* perm_c,
                    int permc_spec
      ) {
   octave_value_list retval;
   SuperMatrix L, U;

   if (A.ncol != A.nrow) SP_FATAL_ERR("Input matrix must be square");

   int n= A.ncol;
   int m= A.nrow;
   assert(n == m);

   int perm_r[m];
   sparse_LU_fact( A, &L, &U, perm_c, perm_r, permc_spec);

// Build the permutation matrix
//  remember to add 1 because assemble_sparse is 1 based
   ColumnVector ridxPr(m), cidxPr(m), coefPr(m);
   for (int i=0; i<m; i++) {
      ridxPr(i)= (double) i + 1;
      cidxPr(i)= (double) perm_r[i] + 1; 
      coefPr(i)= 1.0;
   }

   ColumnVector ridxPc(n), cidxPc(n), coefPc(n);
   for (int i=0; i<m; i++) {
      ridxPc(i)= (double) i + 1;
      cidxPc(i)= (double) perm_c[i] + 1; 
      coefPc(i)= 1.0;
   }
   
   octave_value Pr = new octave_sparse (
         assemble_sparse( m, m, coefPr, cidxPr, ridxPr ) );
   octave_value PcT= new octave_sparse (
         assemble_sparse( n, n, coefPc, ridxPc, cidxPc ) );

   SuperMatrix Lt= oct_sparse_transpose( L );
   SuperMatrix iL= sp_inv_uppertriang( Lt );
   SuperMatrix iUt= sp_inv_uppertriang( U );
   SuperMatrix iU= oct_sparse_transpose( iUt );

   oct_sparse_Destroy_SuperMatrix( L);
   oct_sparse_Destroy_SuperMatrix( Lt);
   oct_sparse_Destroy_SuperMatrix( U);
   oct_sparse_Destroy_SuperMatrix( iUt);

   octave_value iLS =  new octave_sparse( iL );
   octave_value iUS =  new octave_sparse( iU );

   retval(0)= PcT;
   retval(1)= iUS;
   retval(2)= iLS;
   retval(3)= Pr;

   return retval;
}   

   
#ifdef VERBOSE   
// this is for debugging memory leaks
DEFUN_DLD (spdump, args, , "dump sparse")
{
   octave_value_list retval;
   if (args(0).type_name () == "sparse") {
      const octave_value& rep = args(0).get_rep ();
      SuperMatrix A = ((const octave_sparse&) rep) . super_matrix ();

      printf("A->%08X<-\n", (unsigned int) ((NCformat *)A.Store)->rowind );
      printf("A->%08X<-\n", (unsigned int) ((NCformat *)A.Store)->colptr );
      printf("A->%08X<-\n", (unsigned int) ((NCformat *)A.Store)->nzval );
      printf("A->%08X<-\n", (unsigned int) A.Store );
   }
   return retval;
}   
#endif


DEFUN_DLD (spinv, args, nargout ,
  "[ainv] = spinv( a );\n\
SPINV : Sparse Matrix inverse\n\
    ainv is the inverse of a\n\
or
   [ainv] = spinv( a,p );\n\
where p is a specified permutation for the columns of a\n\
Here psparse will normally be a user-supplied permutation matrix or vector\n\
to be applied to the columns of A for sparsity. \n\
\n\
Note: 2nd input funcionality has not been verified\n\
With a second input, the columns of A are permuted before factoring:\n\
\n\
Note 2: It is significantly more accurate and faster to do
    x=a\\b\n\
rather than
    x=spinv(a)*b\n\
  ")
{
   octave_value_list retval;
   octave_value tmp;
   int nargin = args.length ();

   if (args.length() < 1) {
      print_usage ("spinv");
      return retval;
   }
 
   if (args(0).type_name () == "sparse") {
      const octave_value& rep = args(0).get_rep ();
 
      SuperMatrix A = ((const octave_sparse&) rep) . super_matrix ();

      int n = A.ncol;

      int perm_c[n];
      int permc_spec=3;

      if (nargin ==2) {
         ColumnVector permcidx ( args(1).vector_value() );
         for( int i= 0; i< n ; i++ ) 
            perm_c[i]= (int) permcidx(i) - 1;
         permc_spec= -1; //permc is preselected
      }

      octave_value_list Ai =
         oct_sparse_inverse( A, perm_c, permc_spec );

      retval(0)= Ai(0) * Ai(1) * Ai(2) * Ai(3);

   }
   else
     gripe_wrong_type_arg ("spinv", args(0));

   return retval;
}

/*
 * $Log$
 * Revision 1.1  2001/10/10 19:54:49  pkienzle
 * Initial revision
 *
 * Revision 1.3  2001/04/04 02:13:46  aadler
 * complete complex_sparse, templates, fix memory leaks
 *
 * Revision 1.2  2001/02/27 03:01:52  aadler
 * added rudimentary complex matrix support
 *
 * Revision 1.1  2000/12/18 03:31:16  aadler
 * Split code to multiple files
 * added sparse inverse
 *
 */
