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
2006-05-01 Tom Holroyd
* add support for consistent winding in all dimensions; output is
* guaranteed to be simplicial.
*/

extern "C" {
#include "qhull/qhull_a.h"
}
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>

#ifdef NEED_QHULL_VERSION
char qh_version[] = "convhulln.oct 2006-05-01";
#endif
char flags[250];
const char *options;

DEFUN_DLD (convhulln, args, ,
	"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{H} =} convhulln (@var{p}[, @var{opt}])\n\
Returns an index vector to the points of the enclosing convex hull.\n\
The input matrix of size [n, dim] contains n points of dimension dim.\n\n\
If a second optional argument is given, it must be a string containing\n\
options for the underlying qhull command.  (See the Qhull\n\
documentation for the available options.)  The default options\n\
are \"s Qci Tcv\".\n\n\
@seealso{convhull, delaunayn}\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length();
  if (nargin < 1 || nargin > 2) {
    print_usage ("convhulln(p[, opt])");
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
    options = "s Qci Tcv"; // turn on some consistency checks

  Matrix p(args(0).matrix_value());

  const int dim = p.columns();
  const int n = p.rows();
  p = p.transpose();

  double *pt_array = p.fortran_vec();

  boolT ismalloc = False;

  // hmm, lots of options for qhull here
  // QJ guarantees that the output will be triangles
  snprintf(flags, sizeof(flags), "qhull QJ %s", options);

  if (!qh_new_qhull (dim,n,pt_array,ismalloc,flags,NULL,stderr)) {

    // If you want some debugging information replace the NULL
    // pointer with stdout

    vertexT *vertex,**vertexp;
    facetT *facet;
    setT *vertices;
    unsigned int nf = qh num_facets;

    Matrix idx(nf, dim);

    int j, i = 0, id = 0;
    FORALLfacets {
      j = 0;
      if (!facet->simplicial)
	error("convhulln: non-simplicial facet"); // should never happen with QJ

      if (dim == 3) {
	vertices = qh_facet3vertex (facet);
	FOREACHvertex_(vertices)
	  idx(i, j++) = 1 + qh_pointid(vertex->point);
	qh_settempfree(&vertices);
      } else {
	if (facet->toporient ^ qh_ORIENTclock) {
	  FOREACHvertex_(facet->vertices)
	    idx(i, j++) = 1 + qh_pointid(vertex->point);
	} else {
	  FOREACHvertexreverse12_(facet->vertices)
	    idx(i, j++) = 1 + qh_pointid(vertex->point);
	}
      }
      if (j < dim)
	warning("facet %d only has %d vertices",i,j); // likewise but less fatal
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
