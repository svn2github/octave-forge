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
*/

extern "C" { 
	#include "qhull/qhull_a.h"
}
#include <iostream>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>

char qh_version[] = "convhulln.oct 08. August 2000";
char flags[250];

DEFUN_DLD (convhulln, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{H} =} convhulln (@var{p})\n\
Returns an index vector to the points of the enclosing convex hull.\n\
The input matrix of size [dim, n] contains n points of dimension dim.\n\
@seealso{convhull, delaunayn}\n\
@end deftypefn")
{
	octave_value_list retval;
    retval(0) = 0.0;

	int nargin = args.length();
	if (nargin != 1) {
		print_usage ("convhulln(p)");
		return retval;
	}

	Matrix p(args(0).matrix_value());

	const int dim = p.columns();
	const int n = p.rows();
  p = p.transpose();

  double *pt_array = p.fortran_vec();
	/*double  pt_array[dim * n];
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < dim; j++) {
			pt_array[j+i*dim] = p(i,j);
		}
	}*/

	boolT ismalloc = False;

	// hmm  lot's of options for qhull here
	sprintf(flags,"qhull s Tcv");
	
	if (!qh_new_qhull (dim,n,pt_array,ismalloc,flags,NULL,stderr)) {
	
		// If you want some debugging information replace the NULL
		// pointer with stdout
	
		vertexT *vertex,**vertexp;
		facetT *facet;
		unsigned int i=0,j=0,n = qh num_facets;

		Matrix idx(n,dim);
		qh_vertexneighbors();
		setT *curr_vtc;

		FORALLfacets {
			//qh_printfacet(stdout,facet);
			curr_vtc = facet->vertices;
			FOREACHvertex_ (curr_vtc) {
				//qh_printvertex(stdout,vertex);
				idx(i,j++)= 1 + qh_pointid(vertex->point);
			}
			i++;j=0;
		}
		retval(0)=idx;
	}
	qh_freeqhull(!qh_ALL);
		//free long memory
	int curlong, totlong;
	qh_memfreeshort (&curlong, &totlong);
		//free short memory and memory allocator

	if (curlong || totlong) {
    	cerr << "qhull internal warning (delaunay): did not free ";
		cerr << totlong << " bytes of long memory (";
		cerr << curlong << " pieces)" << endl;
	}
	return retval;
}
