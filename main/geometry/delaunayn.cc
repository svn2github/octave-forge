/* Copyright (C) 2000  Kai Habel
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 
*/

/*
16. July 2000 - Kai Habel: first release

25. September 2002 - Changes by Rafael Laboissiere <rafael@laboissiere.net>

 * Added Qbb option to normalize the input and avoid crashes in Octave.
 * delaunayn accepts now a second (optional) argument that must be a string
   containing extra options to the qhull command.
 * Fixed doc string.  The dimension of the result matrix is [m, dim+1], and
   not [n, dim-1].
*/

#include "config.h"

extern "C" { 
  #include "qhull/qhull_a.h"
}

#include <iostream>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>

char qh_version[] = "delaunayn.oct 08. August 2000";
FILE *outfile = stdout;
FILE *errfile = stderr;
char flags[250];
const char *options;

DEFUN_DLD (delaunayn, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{T}=} delaunayn (@var{P}[, @var{opt}])\n\
Form the Delaunay triangulation for a set of points.\n\
The Delaunay trianugulation is a tessellation of the convex hull of the\n\
points such that no n-sphere defined by the n-triangles contains\n\
any other points from the set.\n\n\
The input matrix of size [n, dim] contains n points of dimension dim.\n\
The return matrix @var{T} has the size [m, dim+1]. It contains for\n\
each row a set of indices to the points, which describes a simplex of\n\
dimension dim.  The 3d simplex is a tetrahedron.\n\n\
If a second optional argument is given, it must be a string containing\n\
extra options for the underlying qhull command.  In particular, \"QJ\"\n\
may be useful for joggling the input to cope with non-simplicial cases.\n\
(See the Qhull documentation for the available options.) @end deftypefn")

{
  octave_value_list retval;
  retval(0) = 0.0;
    
  int nargin = args.length();
  if (nargin < 1 || nargin > 2) {
    print_usage ("delaunayn(p,[opt])");
    return retval;
  }

  if (nargin == 2) {
    if ( ! args (1).is_string () ) {
      error ("delaunayn: second argument must be a string");
      return retval;
    }
    options = args (1).string_value().c_str();
  }
  else
    options = "";
  
  Matrix p(args(0).matrix_value());

  const int dim = p.columns();
  const int n = p.rows();

  if (n > dim) {    

    p = p.transpose();
    double *pt_array = p.fortran_vec();
    boolT ismalloc = False;

    sprintf(flags,"qhull d Qbb T0 %s",options);
    if (!qh_new_qhull (dim, n, pt_array, ismalloc, flags, NULL, errfile)) {

      /*If you want some debugging information replace the NULL
      pointer with outfile.
      */

      facetT *facet;
      vertexT *vertex, **vertexp;
      int nf=0,i=0;

      FORALLfacets {
        if (!facet->upperdelaunay) nf++;
      }

      Matrix simpl(nf,dim+1);
      FORALLfacets {
        if (!facet->upperdelaunay) {
          int j=0;
          FOREACHvertex_ (facet->vertices) {
            simpl(i,j++)=1 + qh_pointid(vertex->point);
          }
          i++;
        }
      }
      retval(0) = simpl;
    }
    qh_freeqhull(!qh_ALL);
      //free long memory

    int curlong, totlong;
    qh_memfreeshort (&curlong, &totlong);
      //free short memory and memory allocator
    
    if (curlong || totlong) {
	warning("delaunay: did not free %d bytes of long memory (%d pieces)",
	        totlong, curlong);
    }
  } else if (n == dim + 1) {
    // one should check if nx points span a simplex
    // I will look at this later.
    RowVector vec(n);
    for (int i=0;i<n;i++) {
      vec(i)=i+1.0;
    } 
    retval(0) = vec;
  }
  return retval;
}
