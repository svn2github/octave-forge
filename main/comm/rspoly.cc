#if !defined (__RSPOLY_CC_)
#define __RSPOLY_CC_

/*
 * Copyright 2002 David Bateman
 * Maybe be used under the terms of the GNU General Public License (GPL)
 */

#include <iostream>
#include <iomanip>
#include <octave/oct.h>
#include "rsoct.h"

DEFUN_DLD (rspoly, args, ,
           " Produces the generator polynomial for a Reed-Solomon code\n"
           "\n"
	   " gen = rspoly(N,K) creates the generator polynomial of\n"
           "       codeword length N and message length K over GF(2^M)\n"
           "       where N equals 2^M -1 for the default primitive\n"
           "       polynomial\n"
	   "\n"
	   " gen = rspoly(N,K,M) Same as rspoly(2^M-1,K)\n"
           "\n"
	   " gen = rspoly(N,K,TP) explicitly supply the Galois field\n"
           "       over GF(2^M). See gftuple\n"
	   "\n"
	   " gen = rspoly(K,Poly) give the primitive polynomial where\n"
	   "       Poly is in a similar form to gftuple(A,Poly)\n"
	   "\n"
	   " gen = rspoly(K,Poly,Fcr) in addition gives the first root of\n"
	   "       the generator polynomial.\n"
	   "\n"
	   " gen = rspoly(K,Poly,Fcr,Prim) in addition to the above,\n"
	   "       gives the primitive element used to generate polynomial\n"
	   "       roots\n") {

  octave_value retval;

  struct rs *rshandle;
  int N = args(0).int_value();
  int K = 0;
  int M;

  if (args(1).is_real_scalar()) {
    K = args(1).int_value();
    if (K >= N) {
      error("rspoly: K must be less than N");
      return(retval);
    }
    if (args.length() > 2) {
      if (args(2).is_real_scalar()) {
	M = args(2).int_value();
	if (N != ((1<<M)-1)) {
	  error("rspoly: N must be of the form 2^M -1");
	  return(retval);
	}

	int indx = find_table_index(M);
	if (indx < 0) {
	  error("rspoly: No default primitive polynominal for desired symbol length");
	  return(retval);
	}
	rshandle = (rs *)init_rs_int(M, _RS_Tab[indx].genpoly,1,1, N-K);
      } else {
	Matrix tuple = args(2).matrix_value();
	N = tuple.rows() - 1;
	M = tuple.columns();
	if (N != ((1<<M)-1)) {
	  error("rspoly: Galois field matrix of incorrect form");
	  return(retval);
	}

	/* This case is a pain as the gftuple basically gives me
	 * alpha_to[] from the rshandle struct. Basically what I
	 * have to do, is find the primitive polynominal given
	 * in alpha_to[] and then use it with init_rs. Luckily
	 * alpha_to[M] always contains the primitive polynomial!!
	 */
	unsigned int gfpoly = 0;
	for (int j=0; j<M; j++)
	  gfpoly += ((int)tuple.elem(M+1,j)) << j;
	gfpoly += (1<<M);

	rshandle = (rs *)init_rs_int(M, gfpoly, 1, 1, N-K);
      }
    } else {
      M = 0;
      for (int i=0; i< (int)(8*sizeof(int)); i++) {
	if ( (N+1) & (1<<i)) {
	  if (M != 0) {
	    error("rspoly: N must be of the form 2^M -1");
	    return(retval);
	  } else
	    M = i;
	}
      }
      int indx = find_table_index(M);
      if (indx < 0) {
	error("rspoly: No default primitive polynominal for desired symbol length");
	return(retval);
      }
      rshandle = (rs *)init_rs_int(M, _RS_Tab[indx].genpoly, 1, 1, N-K);
    }
  } else {
    unsigned int gfpoly, fcr = 1, prim = 1, nroots = N-K;
    K = N;
    RowVector Pp = args(1).row_vector_value();
    M = Pp.length() - 1;
    N = (1<<M) - 1;
    if (K >= N) {
      error("rspoly: Degree of primitive polynomial too short for message length");
      return(retval);
    }
    gfpoly = 0;
    for (int i=M; i >=0; i--) {
      gfpoly = gfpoly << 1;
      gfpoly += ((unsigned int) Pp(i)) & 1;
    }
    if (args.length() > 2) {
      fcr = args(2).int_value();
      if (fcr > (unsigned int)N) {
	error("rspoly: Fcr must be less than or equal to N");
	return(retval);
      }
      if (args.length() > 3) {
	prim = args(3).int_value();
	if ((prim == 0) || (prim > (unsigned int)N)) {
	  error("rspoly: Prim must be less than or equal to N");
	  return(retval);
	}
	if (args.length() > 4) {
	  error("rspoly: Too many arguments");
	  return(retval);
	}
      }
    }
    rshandle = (rs *)init_rs_int(M, gfpoly, fcr, prim, nroots);
  }

  if (!rshandle) {
    /* NULL rshandle. This can indicate a variety of things, but the
     * main one is that the generator polynominal is not primitive
     */
    error("rspoly: Generator polynomial not primitive or allocation error");
    return(retval);
  }

  RowVector gen(N-K+1);
  for (int i=0; i < N-K+1; i++)
    gen(i) = rshandle->genpoly[i];

  free_rs_int(rshandle);
  retval = octave_value(gen);
  return(retval);
}

#endif /* __RSPOLY_CC__ */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

