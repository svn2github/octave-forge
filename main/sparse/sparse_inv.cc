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

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

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
      OCTAVE_QUIT;
      assert( cidxX[i] >= 0);
      assert( cidxX[i] <= nnz);
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
          here Pr*Lp = L  and Up*Pc = U\n\
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
 
   if (args(0).type_name () == "sparse" || 
       args(0).type_name () == "complex_sparse") {

      const octave_value& rep = args(0).get_rep ();
      int m = args(0).rows(); //A.nrow;
      int n = args(0).columns(); //A.ncol;
      if (m != n)
         SP_FATAL_ERR("splu: input matrix must be square");
 
      int perm_c[n];
      int perm_r[m];
      int permc_spec=3;
      if (nargin ==2) {

         ColumnVector permcidx = args(1).column_vector_value();
         for( int i= 0; i< n ; i++ ) 
            perm_c[i]= (int) permcidx(i) - 1;
         permc_spec= -1; //permc is perselected
      }

      octave_value LS, US;
     
      if (args(0).type_name () == "sparse" ) {
         SuperMatrix A = ((const octave_sparse&) rep) . super_matrix ();
         SuperMatrix L, U;
         sparse_LU_fact( A, &L, &U, perm_c, perm_r, permc_spec);
         LS= new octave_sparse( L );
         US= new octave_sparse( U );
      }
      else {
         SuperMatrix A = ((const octave_complex_sparse&) rep) . super_matrix ();
         SuperMatrix L, U;
         complex_sparse_LU_fact( A, &L, &U, perm_c, perm_r, permc_spec);
         LS= new octave_complex_sparse( L );
         US= new octave_complex_sparse( U );
      }

      BUILD_PERM_VECTORS( ridxPr, cidxPr, coefPr, perm_r, n )
      BUILD_PERM_VECTORS( ridxPc, cidxPc, coefPc, perm_c, m )
      
      if (nargout ==2 ) {
         octave_value PrT= new octave_sparse (
               assemble_sparse( m, m, coefPr, ridxPr, cidxPr, 0 ) );
         octave_value Pc = new octave_sparse (
               assemble_sparse( n, n, coefPc, cidxPc, ridxPc, 0 ) );
         retval(0)= PrT*LS;
         retval(1)= US*Pc ;
      } else
      if (nargout >2 ) {
         //build PS backwards to get the transpose
         octave_value Pr = new octave_sparse (
               assemble_sparse( m, m, coefPr, cidxPr, ridxPr, 0 ) );
         octave_value Pc = new octave_sparse (
               assemble_sparse( n, n, coefPc, cidxPc, ridxPc, 0 ) );
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
oct_sparse_inverse( const octave_sparse& Asp,
                    int* perm_c,
                    int permc_spec
      ) {
   DEBUGMSG("oct_sparse_inverse (sparse)");
   octave_value_list retval;

   SuperMatrix A= Asp.super_matrix();
   SuperMatrix L, U;

   int n= A.ncol;
   int m= A.nrow;
   assert(n == m);

   int perm_r[m];
   sparse_LU_fact( A, &L, &U, perm_c, perm_r, permc_spec);

   BUILD_PERM_VECTORS( ridxPr, cidxPr, coefPr, perm_r, m )
   BUILD_PERM_VECTORS( ridxPc, cidxPc, coefPc, perm_c, n )
   
   octave_value Pr = new octave_sparse (
         assemble_sparse( m, m, coefPr, cidxPr, ridxPr, 0 ) );
   octave_value PcT= new octave_sparse (
         assemble_sparse( n, n, coefPc, ridxPc, cidxPc, 0 ) );

   SuperMatrix Lt= oct_sparse_transpose( L );
   SuperMatrix iL= sparse_inv_uppertriang( Lt );
   SuperMatrix iUt= sparse_inv_uppertriang( U );
   SuperMatrix iU= oct_sparse_transpose( iUt );

   oct_sparse_Destroy_SuperMatrix( L);
   oct_sparse_Destroy_SuperMatrix( Lt);
   oct_sparse_Destroy_SuperMatrix( iUt);
   oct_sparse_Destroy_SuperMatrix( U);

   octave_value iLS =  new octave_sparse( iL );
   octave_value iUS =  new octave_sparse( iU );

   retval(0)= PcT;
   retval(1)= iUS;
   retval(2)= iLS;
   retval(3)= Pr;

   return retval;
}   

octave_value_list
oct_sparse_inverse( const octave_complex_sparse& Asp,
                    int* perm_c,
                    int permc_spec
      ) {
   DEBUGMSG("oct_sparse_inverse (complex_sparse)");
   octave_value_list retval;

   SuperMatrix A= Asp.super_matrix();
   SuperMatrix L, U;

   int n= A.ncol;
   int m= A.nrow;
   assert(n == m);

   int perm_r[m];
   complex_sparse_LU_fact( A, &L, &U, perm_c, perm_r, permc_spec);

   BUILD_PERM_VECTORS( ridxPr, cidxPr, coefPr, perm_r, m )
   BUILD_PERM_VECTORS( ridxPc, cidxPc, coefPc, perm_c, n )
   
   octave_value Pr = new octave_sparse (
         assemble_sparse( m, m, coefPr, cidxPr, ridxPr, 0 ) );
   octave_value PcT= new octave_sparse (
         assemble_sparse( n, n, coefPc, ridxPc, cidxPc, 0 ) );

   SuperMatrix Lt= oct_complex_sparse_transpose( L );
   SuperMatrix iL= complex_sparse_inv_uppertriang( Lt );
   SuperMatrix iUt= complex_sparse_inv_uppertriang( U );
   SuperMatrix iU= oct_complex_sparse_transpose( iUt );

   oct_sparse_Destroy_SuperMatrix( L);
   oct_sparse_Destroy_SuperMatrix( Lt);
   oct_sparse_Destroy_SuperMatrix( U);
   oct_sparse_Destroy_SuperMatrix( iUt);

   octave_value iLS =  new octave_complex_sparse( iL );
   octave_value iUS =  new octave_complex_sparse( iU );

   retval(0)= PcT;
   retval(1)= iUS;
   retval(2)= iLS;
   retval(3)= Pr;

   return retval;
}   

DEFUN_DLD (spinv, args, nargout ,
  "[ainv] = spinv( a );\n\
SPINV : Sparse Matrix inverse\n\
    ainv is the inverse of a\n\
or\n\
   [ainv] = spinv( a,p );\n\
where p is a specified permutation for the columns of a\n\
Here psparse will normally be a user-supplied permutation matrix or vector\n\
to be applied to the columns of A for sparsity. \n\
\n\
Note: 2nd input funcionality has not been verified\n\
With a second input, the columns of A are permuted before factoring:\n\
\n\
Note 2: It is significantly more accurate and faster to do\n\
    x=a\\b\n\
rather than\n\
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

   int n = args(0).columns();
   if (n != args(0).rows()) SP_FATAL_ERR("spinv: Input matrix must be square");

   int perm_c[n];
   int permc_spec=3;

   if (nargin ==2) {
      ColumnVector permcidx ( args(1).vector_value() );
      for( int i= 0; i< n ; i++ ) 
         perm_c[i]= (int) permcidx(i) - 1;
      permc_spec= -1; //permc is preselected
   }
 
   if (args(0).type_name () == "sparse" ) {
      const octave_sparse& A =
           (const octave_sparse&) args(0).get_rep();
      octave_value_list Ai = oct_sparse_inverse( A, perm_c, permc_spec );
      retval(0)= Ai(0) * Ai(1) * Ai(2) * Ai(3);
   } else
   if ( args(0).type_name () == "complex_sparse" ) {
      const octave_complex_sparse& A =
           (const octave_complex_sparse&) args(0).get_rep();
      octave_value_list Ai = oct_sparse_inverse( A, perm_c, permc_spec );
      retval(0)= Ai(0) * Ai(1) * Ai(2) * Ai(3);
   } else
     gripe_wrong_type_arg ("spinv", args(0));

   return retval;
}

DEFUN_DLD (spabs, args, nargout ,
  "real_a = spabs( a );\n\
SPINV : Absolute value of a sparse matrix\n\
  ")
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
   if ( args(0).type_name () == "complex_sparse" ) {
      const octave_sparse& A =
           (const octave_sparse&) args(0).get_rep();
      SuperMatrix X= A.super_matrix();

      DEFINE_SP_POINTERS_CPLX( X )
      int nnz= NCFX->nnz;

      double *coefB = doubleMalloc(nnz);
      int *   ridxB = intMalloc(nnz);
      int *   cidxB = intMalloc(X.ncol+1);

      for ( int i=0; i<=Xnc; i++)
         cidxB[i]=  cidxX[i];

      for ( int i=0; i< nnz; i++) {
         coefB[i]=  abs( coefX[i] );
         ridxB[i]=  ridxX[i];
      }

      SuperMatrix B= create_SuperMatrix( Xnr, Xnc, nnz, coefB, ridxB, cidxB );
      retval(0)= new octave_sparse(B);
   } else
     gripe_wrong_type_arg ("spabs", args(0));

   return retval;
}

/*
 * $Log$
 * Revision 1.8  2002/12/25 01:33:00  aadler
 * fixed bug which allowed zero values to be stored in sparse matrices.
 * improved print output
 *
 * Revision 1.7  2002/12/11 17:19:32  aadler
 * sparse .^ scalar operations added
 * improved test suite
 * improved documentation
 * new is_sparse
 * new spabs
 *
 * Revision 1.6  2002/11/27 04:46:42  pkienzle
 * Use new exception handling infrastructure.
 *
 * Revision 1.5  2002/11/13 15:28:09  pkienzle
 * Keep gcc 3.2 happy.
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
 * Revision 1.4  2001/09/23 17:46:12  aadler
 * updated README
 * modified licence to GPL plus link to opensource programmes
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
