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

#include "make_sparse.h"
using namespace std;


//
// full
//
DEFUN_DLD (full, args, ,
"FM= full (SM)\n"
" returns a full storage matrix from a sparse one")
{
  octave_value_list retval;

  if (args.length() < 1) {
     print_usage ("full");
     return retval;
  }

  if (args(0).type_name () == "sparse") {
     const octave_value& rep = args(0).get_rep ();

     Matrix M = ((const octave_sparse&) rep) . matrix_value ();
     retval(0)= M;
  } else
  if (args(0).type_name () == "complex_sparse") {
     const octave_value& rep = args(0).get_rep ();

     ComplexMatrix M = ((const octave_sparse&) rep) . complex_matrix_value ();
     retval(0)= M;
  } else
  if (args(0).type_name () == "matrix") {
     retval(0)= args(0).matrix_value();
  } else
  if (args(0).type_name () == "complex matrix") {
     retval(0)= args(0).complex_matrix_value();
  } else
    gripe_wrong_type_arg ("full", args(0));

  return retval;
}

//
// is_sparse and friends
//
DEFUN_DLD (is_sparse, args, ,
"retval= is_sparse (X)\n"
"  Returns true (ie. 1) if X is a matrix with sparse storage\n"
"  Returns false (ie. 0) otherwise\n"
"  see also is_real_sparse , is_complex_sparse")
{
  octave_value_list retval;

  if (args.length() != 1) {
     print_usage ("is_sparse");
     return retval;
  }

  if (args(0).type_name () == "sparse" || 
      args(0).type_name () == "complex_sparse") {
     retval(0)= 1.0;
  } else
     retval(0)= 0.0;

  return retval;
}

DEFUN_DLD (is_real_sparse, args, ,
"retval= is_real_sparse (X)\n"
"  Returns true (ie. 1) if X is a real matrix with sparse storage\n"
"  Returns false (ie. 0) otherwise\n"
"  see also is_sparse , is_complex_sparse")
{
  octave_value_list retval;

  if (args.length() != 1) {
     print_usage ("is_real_sparse");
     return retval;
  }

  if (args(0).type_name () == "sparse" ) {
     retval(0)= 1.0;
  } else
     retval(0)= 0.0;

  return retval;
}

DEFUN_DLD (is_complex_sparse, args, ,
"retval= is_complex_sparse (X)\n"
"  Returns true (ie. 1) if X is a complex matrix with sparse storage\n"
"  Returns false (ie. 0) otherwise\n"
"  see also is_sparse , is_real_sparse")
{
  octave_value_list retval;

  if (args.length() != 1) {
     print_usage ("is_complex_sparse");
     return retval;
  }

  if (args(0).type_name () == "complex_sparse" ) {
     retval(0)= 1.0;
  } else
     retval(0)= 0.0;

  return retval;
}

//
// nnz
//
DEFUN_DLD (nnz, args, ,
"int= nnz (SM)\n"
" returns number of non zero elements in SM")
{
  octave_value_list retval;

  if (args.length() < 1) {
     print_usage ("nnz");
     return retval;
  }

  if (args(0).type_name () == "sparse") {
     const octave_value& rep = args(0).get_rep ();

     retval(0)= (double) ((const octave_sparse&) rep) . nnz ();
  } else
  if (args(0).type_name () == "complex_sparse") {
     const octave_value& rep = args(0).get_rep ();

     retval(0)= (double) ((const octave_complex_sparse&) rep) . nnz ();
  } else
  if (args(0).type_name () == "complex matrix") {
     const ComplexMatrix M = args(0).complex_matrix_value();
     int nnz= 0;
     for( int i=0; i< M.rows(); i++)
        for( int j=0; j< M.cols(); j++)
           if (M(i,j)!=0.) nnz++;
     retval(0)= (double) nnz;
  } else
  if (args(0).type_name () == "matrix") {
     const Matrix M = args(0).matrix_value();
     int nnz= 0;
     for( int i=0; i< M.rows(); i++)
        for( int j=0; j< M.cols(); j++)
           if (M(i,j)!=0.) nnz++;
     retval(0)= (double) nnz;
  } else
  if (args(0).type_name () == "scalar") {
     retval(0)= args(0).scalar_value() != 0.0 ? 1.0 : 0.0;
  } else
  if (args(0).type_name () == "complex scalar") {
     retval(0)= args(0).complex_value() != 0.0 ? 1.0 : 0.0;
  } else
     gripe_wrong_type_arg ("nnz", args(0));

  return retval;
}

//
// spfind - find elements in sparse matrices
//
DEFUN_DLD (spfind, args, nargout ,
  "[...] = spfind (...)\n\
SPFIND: a sparse version of the find operator\n\
   x = spfind( a )                 \n\
      is analagous to x= find(A(:)) \n\
      where A= full(a)\n\
   [i,j,v,nr,nc] = spfind( a )\n\
      give column vectors i j v such that\n\
      a= sparse(i,j,v,nr,nc)\n\
  ")
{
   octave_value_list retval;
   octave_value tmp;
   int nargin = args.length ();

   if (nargin != 1) {
      print_usage ("spfull");
      return retval;
   }
      

   bool is_sparse=      args(0).type_name () == "sparse";
   bool is_cplx_sparse= args(0).type_name () == "complex_sparse";

   if ( is_sparse || is_cplx_sparse ) {
      const octave_value& rep = args(0).get_rep ();
 
      SuperMatrix A = ((const octave_sparse&) rep) . super_matrix ();
      assert( (A).Stype == NC); 
      NCformat * NCFA= (NCformat *) (A).Store;
      int  * ridxA =          NCFA->rowind;
      int  * cidxA =          NCFA->colptr;
      int Anr= (A).nrow; 
      int Anc= (A).ncol;
      int nnz = NCFA->nnz;

      if (nargout<=1) {
         ColumnVector I (nnz);
         for (int i=0, cx=0; i< Anc; i++) {
	    OCTAVE_QUIT;
            for (int j= cidxA[i]; j< cidxA[i+1]; j++ ) 
               I( cx++ ) = (double) ( (ridxA[j]+1) + i*Anr );
	 }

         // orientation rules - 
         //   I is column unless matrix is a rowvector
         if (Anr == 1)
            retval(0)= I.transpose();
         else
            retval(0)= I;

      } else
      {
         ColumnVector I (nnz), J (nnz);

         for (int i=0,cx=0; i< Anc; i++) {
	    OCTAVE_QUIT;
            for (int j= cidxA[i]; j< cidxA[i+1]; j++ ) {
               I( cx ) = (double) ridxA[j]+1;
               J( cx ) = (double) i+1;
               cx++;
            }
	 }

         retval(0)= I;
         retval(1)= J;
         retval(3)= (double) Anr;
         retval(4)= (double) Anc;

         if (is_sparse) {
            assert( A.Dtype == _D );
            ColumnVector S (nnz);
            double * coefA = (double *) NCFA->nzval;
            for (int i=0,cx=0; i< Anc; i++) {
	       OCTAVE_QUIT;
               for (int j= cidxA[i]; j< cidxA[i+1]; j++ ) 
                  S( cx++ ) =          coefA[j];
	    }
            retval(2)= S;
         } else
         {
            assert( A.Dtype == _Z );
            ComplexColumnVector S (nnz);
            Complex * coefA = (Complex *) NCFA->nzval;
            for (int i=0,cx=0; i< Anc; i++) {
	       OCTAVE_QUIT;
               for (int j= cidxA[i]; j< cidxA[i+1]; j++ ) 
                  S( cx++ ) =          coefA[j];
	    }
            retval(2)= S;
         }

            
      } // if nargout
   }
   else
     gripe_wrong_type_arg ("spfind", args(0));

   return retval;
}

/*
 * $Log$
 * Revision 1.7  2003/07/23 17:21:54  aadler
 * modified help files
 *
 * Revision 1.6  2002/12/11 17:19:32  aadler
 * sparse .^ scalar operations added
 * improved test suite
 * improved documentation
 * new is_sparse
 * new spabs
 *
 * Revision 1.5  2002/11/27 04:46:42  pkienzle
 * Use new exception handling infrastructure.
 *
 * Revision 1.4  2002/01/04 15:53:57  pkienzle
 * Changes required to compile for gcc-3.0 in debian hppa/unstable
 *
 * Revision 1.3  2001/11/16 03:09:42  aadler
 * added spsum.m, is_sparse, is_real_sparse, is_complex_sparse
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
 * Revision 1.3  2001/04/08 20:18:19  aadler
 * complex sparse support
 *
 * Revision 1.2  2001/02/27 03:01:52  aadler
 * added rudimentary complex matrix support
 *
 * Revision 1.1  2000/12/18 03:31:16  aadler
 * Split code to multiple files
 * added sparse inverse
 *
 */
