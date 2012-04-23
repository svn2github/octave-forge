// Copyright (C) 2006 Torsten Finke <fi@igh-essen.com>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

#include <octave/oct.h>
#include <octave/lo-ieee.h>

#include "partint.h"

unsigned long * pcnt(unsigned long n) 
{
    unsigned long *s = new unsigned long[n];
    unsigned long *x = new unsigned long[n*n];
    unsigned long **p = new unsigned long*[n];
    for (unsigned long k=0; k<n; ++k)  {
        p[k] = x + (k*n);
        s[k] = 0;
    }
    for (unsigned long k=0; k<n*n; ++k)  x[k] = 0;
    p[0][0] = 1;
    for (unsigned long k=1; k<n; ++k)
    {
        // p[N][j] == numpart of N with max summand j
        for (unsigned long j=1; j<=k; ++j) {
            p[k][j] = p[k-1][j-1] + p[k-j][j];
        }
        for (unsigned long j=1; j<=k; ++j) {
            s[k] += p[k][j]; // S(k) = numpart(n)
        }
    }
    return s;
}

DEFUN_DLD (partcnt, args, ,
"-*- texinfo -*-\n\
@deftypefn{Loadable Function} {@var{p} =} partcnt(@var{n})\n\
\n\
@cindex partition count\n\
\n\
Calculate integer partition count. Argument @var{n} be scalar, vector\n\
or matrix of non-negative numbers. A partition is the sum decomposition \n\
of integers. \n\
\n\
Example:\n\
@example \n\
partcnt([1, 5; 17 -3])\n\
@end example\n\
@noindent\n\
returns\n\
@example\n\
ans =\n\
    1     7\n\
  297   NaN\n\
@end example\n\
\n\
Reference:\n\
Joerg Arndt: Algorithms for programmers (http://www.jjj.de), 2006.\n\n\
@end deftypefn\n\
@seealso{partint}\n\
")
{
    octave_value r;
    
    int nargin = args.length ();
    if (nargin != 1) {
        error("partcnt accepts exactly one argument");
        return r; 
    }
    if ( ! args(0).is_numeric_type()) {
        error("partcnt only accepts a numeric argument");
        return r;
    }

    NDArray f(args(0).matrix_value());
    RowVector m(f.max());
    double mmax = m.max();
    if ( mmax < 1 ) {
        error("partcnt is only defined for non-negative arguments");
        return r;
    }

    unsigned long n = (unsigned long) mmax + 1;
    unsigned long *s = pcnt(n);
    unsigned long fr = (unsigned long) f.rows();
    unsigned long fc = (unsigned long) f.columns();
    for (unsigned long i=0; i<fr; i++) {
        for (unsigned long k=0; k<fc; k++) {
            unsigned long idx = (unsigned long) f(i, k);
            if (0 < idx && idx < n) {
                f(i, k) = s[idx];
            } else {
                f(i, k) = lo_ieee_nan_value();
            }
        }
    }
    r = f;
    return r;
}

/*

%!assert(partcnt(1), 1);
%!assert(partcnt(17), 297);
%!fail("partcnt()", "partcnt");
%!fail("partcnt(1,2)", "partcnt");
%!fail("partcnt('xyz')", "partcnt");
%!demo
%! p = partcnt([1, 5; 17 -5])

*/

DEFUN_DLD (partint, args, ,
"-*- texinfo -*-\n\
@deftypefn{Loadable Function} {@var{p} =} partint(@var{n})\n\
\n\
@cindex partition\n\
\n\
Calculate all integer partitions. Argument @var{n} be \n\
a positive number. A partition is the sum decomposition \n\
of integers. \n\
\n\
Example:\n\
@example \n\
partint(4)\n\
@end example\n\
@noindent\n\
returns\n\
@example\n\
ans =\n\
  4  0  0  0\n\
  2  1  0  0\n\
  0  2  0  0\n\
  1  0  1  0\n\
  0  0  0  1\n\
@end example\n\
\n\
This means\n\n\
@iftex\n\
@tex\n\
$$\eqalign{4 & = 4 \\cdot 1 \\cr\n\
 & = 2 \\cdot 1 + 1 \\cdot 2 \\cr\n\
 & = 2 \\cdot 2 \\cr\n\
 & = 1 \\cdot 1 + 1 \\cdot 3 \\cr\n\
 & = 1 \\cdot 1 \\cr\n\
\\cr}$$\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
@example\n\
4 = 4 * 1\n\
  = 2 * 1 + 1 * 2\n\
  =         2 * 2\n\
  = 1 * 1         + 1 * 3\n\
  =                 1 * 4\n\
@end example\n\
@end ifinfo\n\
\n\
Note:\n\
\n\
partint(n) * [1:n]' == n\n\
\n\
Reference:\n\
Joerg Arndt: Algorithms for programmers (http://www.jjj.de), 2006.\n\n\
@end deftypefn\n\
@seealso{partcnt}\n\
")
{
    octave_value r;
    
    int nargin = args.length ();
    if (nargin != 1 || 
        ! args(0).is_scalar_type() ||
        ! args(0).is_numeric_type()
        ) {
        error("partint only accepts one scalar positive integer argument");
        return r;
    }
    double arg0 = args(0).double_value();
    if ( arg0 < 1 ) {
        error("partint is only defined for positive integer arguments");
        return r;
    }

    unsigned long n = (unsigned long) arg0;
    unsigned long *s = pcnt(n+1);
    unsigned long k = s[n];
    Matrix pa(k, n, 0);
    int_partition p(n);
    unsigned long i = 0;
    do {
        const unsigned long *d = p.data();
        for (unsigned long j=0; j<n; j++) {
            pa(i, j) = (unsigned long)d[j+1];
        }
        i ++;
    } while (p.next());
    r = pa;
    return r;
}

/*

%!assert(partint(1), 1);
%!assert(all(partint(n=17) * [1:n]' == n) - 1, 0); 
%!test
%! expected = [4,0,0,0; 2,1,0,0; 0,2,0,0; 1,0,1,0; 0,0,0,1];
%! assert(partint(4), expected);
%!fail("partint()", "partint");
%!fail("partint(1,2)", "partint");
%!fail("partint('xyz')", "partint");
%!demo
%! p = partint(4)

*/
