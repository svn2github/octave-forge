#if !defined (__GFPRIMDF_CC__)
#define __GFPRIMDF_CC__

/*
 * Copyright 2002 David Bateman
 * Maybe be used under the terms of the GNU General Public License (GPL)
 */

#include <iostream>
#include <iomanip>
#include <octave/oct.h>
#include "rsoct.h"

DEFUN_DLD (gfprimdf, args, ,
           " Returning the default primitive polynomials for a Galois Field\n"
           "\n"
	   " POL = gfprimdf(M) returns the default primitive polynomial POL\n"
           "       in GF(2^M)\n"
           "\n"
	   " POL = gfprimdf(M,P) returns the default primitive polynomial\n"
	   "       POL\n"
           "\n"
           " At the moment P must be 2 and M less than 16\n"
           "\n"
           " See Lin & Costello, Appendix A and Lin & Messerschmitt p. 453\n") {
  octave_value retval;
  int m = args(0).int_value();
  int p = 2;

  if (args.length() > 1) {
    p = args(1).int_value();
  }

  if (args.length() > 2) {
    print_usage("gfprimdf");
    return(retval);
  }

  int indx = find_table_index(m);

  if ((p < 2) || (indx < 0)) {
    error("gfprimdf: Invalid args or args out of stored range");
    return(retval);
  }

  RowVector Pp(m+1);

  for (int i=0; i<=m; i++)
    Pp(i) = ((_RS_Tab[indx].genpoly & (1<<i)) > 0 ? 1 : 0);

  retval = octave_value(Pp);
  return(retval);
}

#endif /* __GFPRIMDF_CC__ */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
