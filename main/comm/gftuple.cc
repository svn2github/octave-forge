#if !defined (__GFTUPLE_CC_)
#define __GFTUPLE_CC_

/*
 * Copyright 2002 David Bateman
 * Maybe be used under the terms of the GNU General Public License (GPL)
 */

#include <iostream>
#include <iomanip>
#include <octave/oct.h>
#include "rsoct.h"


DEFUN_DLD (gftuple, args, ,
           " Creates the elements of a Galois field\n"
           "\n"
           " tp = gftuple(A,M) returns the elements of the Galois field\n"
           "      for the elements of the matrix A. It is assumed that\n"
           "      P is equal to 2. The primitive polynomial of GF(P^M)\n"
           "      is used. If A is a column vector, then the elements\n"
           "      of A should be between 0 and P^M-1. Negative values\n"
           "      of A are treated as zero, while values larger then\n"
           "      P^M-1 are treated mod(P^M-1). If A is a matrix then the\n"
           "      elements of A must be between 0 and P-1 and each row of\n"
           "      A is used as the polynomial format of a single value\n"
           "\n"
           " tp = gftuple(A,M,P) As above, but P is explicitly defined\n"
           "      For now only P=2 is valid\n"
           "\n"
           " tp = gftuple(A,Poly) Poly is a row vector of length M+1 that\n"
           "      defines explicitly the primitive polynomial of degree M\n"
           "       over GF(2^M)\n"
           "\n"
           " tp = gftuple(A,Poly,P) Poly is a row vector of length M+1 that\n"
           "      defines explicitly the primitive polynomial of degree M\n"
           "       over GF(P^M)\n"
	   "\n"
           " tp = gftuple(A,Poly,P,Chk) As above but request to check that\n"
           "      the polynomial is indeed primitive over GF(P^M). The\n"
	   "      polynomial is always tested for its primitiveness, and\n"
	   "      an error will always be generated, so this test is\n"
           "      redundant but kept for compatiability with Matlab\n") {
  octave_value retval;
  struct rs * rshandle;
  int N = 0, M, i, j;
  int P = 2;
  Matrix A = args(0).matrix_value();
  ColumnVector ExpForm;

  if (args(1).is_real_scalar()) {
    M = args(1).int_value();
    if (args.length() > 2) {
      P = args(2).int_value();
      if (P != 2) {
	error("gftuple: P must equal 2 for now");
	return(retval);
      }
    }

    int indx = find_table_index(M);
    if (indx < 0) {
      error("gftuple: No default primitive polynominal for desired symbol length");
      return(retval);
    }
    rshandle = (rs *)init_rs_int(M, _RS_Tab[indx].genpoly, 1, 1, 1);
  } else {
    RowVector Pp = args(1).row_vector_value();
    M = Pp.length() - 1;
    int gfpoly = 0;
    for (int i=M; i >=0; i--) {
      gfpoly = gfpoly << 1;
      gfpoly += ((unsigned int) Pp(i)) & 1;
    }
    if (args.length() > 2) {
      P = args(2).int_value();
      if (P != 2) {
 	error("gftuple: P must equal 2 for now");
	return(retval);
      }
    }
    rshandle = (rs *)init_rs_int(M, gfpoly, 1, 1, 32);

    if (!rshandle) {
      if (args.length() > 3) {
	/* Ok, we've been asked to check that the polynomial is primitive. */
	int sr = 1;
	for (int i = 0; i < N; i++) {
	  sr <<= 1;
	  if (sr & (N+1))
	    sr ^= gfpoly;
	  sr &= N;
	}
	if (sr != 1)
	  error("gftuple: Generator polynomial is not primitive");
	else
	  error("gftuple: Memory allocation error");
      } else
	error("gftuple: Internal error... Is the generator polynomial primitive?");
    }
  }

  if (!rshandle) {
    /* NULL rshandle. This can indicate a variety of things, but the
     * main one is that the generator polynominal is not primitive.
     * The others are memory allocation errors, and invalid args. As
     * we use default args here that should always be good, we are
     * left only with non-primitive polynomial or the memory error.
     * So if you get here even though your polynomial is primitive you
     * have memory allocation errors and thus lots of other problems :-)
     */
    error("gftuple: Internal error... Is the generator polynomial primitive?");
    return(retval);
  }


  N = (1<<M) - 1;

  if (A.columns() > 1) {
    for (i=0; i<A.rows(); i++) {
      ExpForm(i) = 0;
      for (j=0; j<A.columns(); j++) {
	if (A(i,j))
	  ExpForm(i) += (1<j);
      }
    }
  } else {
    ExpForm = A.column(0);
  }

  Matrix gftuple(A.length(),M);
  for (i=0; i<ExpForm.length();i++) {
    for (j=0;j<M;j++) {
      if (ExpForm(i) < 0)
	gftuple(i,j) = 0;
      else
	gftuple(i,j) = (rshandle->alpha_to[((int)ExpForm(i) & N)] &
			(1<<j) ? 1 : 0);
    }
  }

  retval = octave_value(gftuple);
  free_rs_int(rshandle);
  return(retval);
}

#endif /* __GFTUPLE_CC__ */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
