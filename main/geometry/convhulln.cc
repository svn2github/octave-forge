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
29. July 2000 - Kai Habel: first release
2002-04-22 Paul Kienzle
* Use warning(...) function rather than writing to cerr
*/

extern "C" {
#include "qhull/qhull_a.h"
}
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>

char qh_version[] = "convhulln.oct 2003-12-14";
char flags[250];
const char *options;

DEFUN_DLD (convhulln, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{H} =} convhulln (@var{p}[, @var{opt}])\n\
Returns an index vector to the points of the enclosing convex hull.\n\
The input matrix of size [n, dim] contains n points of dimension dim.\n\n\
If a second optional argument is given, it must be a string containing\n\
extra options for the underlying qhull command.  (See the Qhull\n\
documentation for the available options.)\n\n\
@seealso{convhull, delaunayn}\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length();
  if (nargin < 1 || nargin > 2) {
    print_usage ("convhulln(p,[opt])");
    return retval;
  }

  if (nargin == 2) {
    if ( ! args (1).is_string () ) {
      error ("convhulln: second argument must be a string");
      return retval;
    }
    options = args (1).string_value().c_str();
  }
  else
    options = "";

  Matrix p(args(0).matrix_value());

  const int dim = p.columns();
  const int n = p.rows();
  p = p.transpose();

  double *pt_array = p.fortran_vec();

  boolT ismalloc = False;

  // hmm  lot's of options for qhull here
  sprintf(flags,"qhull s Qt Tcv %s",options);

  if (!qh_new_qhull (dim,n,pt_array,ismalloc,flags,NULL,stderr)) {

    // If you want some debugging information replace the NULL
    // pointer with stdout

    vertexT *vertex,**vertexp;
    facetT *facet;
    unsigned int n = qh num_facets;

    Matrix idx(n,dim);
    qh_vertexneighbors();

    int i=0;
    FORALLfacets {
      int j=0;
      //std::cout << "Current index " << i << "," << j << std::endl << std::flush;
      // qh_printfacet(stdout,facet);
      FOREACHvertex_ (facet->vertices) {
	// qh_printvertex(stdout,vertex);
	if (j >= dim)
	  warning("extra vertex %d of facet %d = %d",
		  j++,i,1+qh_pointid(vertex->point));
	else
	  idx(i,j++)= 1 + qh_pointid(vertex->point);
      }
      if (j < dim) warning("facet %d only has %d vertices",i,j);
      i++;
    }
    retval(0)=octave_value(idx);
  }
  qh_freeqhull(!qh_ALL);
  //free long memory
  int curlong, totlong;
  qh_memfreeshort (&curlong, &totlong);
  //free short memory and memory allocator

  if (curlong || totlong) {
    warning("convhulln: did not free %d bytes of long memory (%d pieces)",
	    totlong, curlong);
  }
  return retval;
}
