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
20. Augiust 2000 - Kai Habel: first release
*/

extern "C" { 
	#include "qhull/qhull_a.h"
}

#include <iostream>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>

char qh_version[] = "__voronoi__.oct 20. August 2000";
FILE *outfile = stdout;
FILE *errfile = stderr;
char flags[250];

DEFUN_DLD (__voronoi__, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{tri}=} __voronoi__ (@var{point})\n\
Internal function for voronoi.\n\
@end deftypefn")
{
	octave_value_list retval;
	retval(0) = 0.0;
    
	int nargin = args.length();
	if (nargin != 1) {
		print_usage ("__voronoi__ (points)");
		return retval;
	}

	Matrix p(args(0).matrix_value());

	const int dim = p.columns();
	const int np = p.rows();
  p = p.transpose();

  double *pt_array = p.fortran_vec();
	/*double  pt_array[dim * np];
	for (int i = 0; i < np; i++) {
		for (int j = 0; j < dim; j++) {
			pt_array[j+i*dim] = p(i,j);
		}
	}*/

	boolT ismalloc = False;

	// hmm  lot's of options for qhull here
	sprintf(flags,"qhull v Fv T0");
	if (!qh_new_qhull (dim, np, pt_array, ismalloc, flags, NULL, errfile)) {

		/*If you want some debugging information replace the NULL
		pointer with outfile.
		*/

		facetT *facet;
		vertexT *vertex;
		unsigned int i=0,n=0,k=0,ni[np],m=0,fidx=0,j=0,r=0;
		for (int i=0;i<np;i++) ni[i]=0;
		qh_setvoronoi_all(); 
		bool infinity_seen = false;
		facetT *neighbor,**neighborp;
		coordT *voronoi_vertex;
		FORALLfacets {
			facet->seen = False;
		}
		FORALLvertices {
			if (qh hull_dim == 3)
				qh_order_vertexneighbors(vertex);
			FOREACHneighbor_(vertex) {
				if (!neighbor->upperdelaunay) {
					if (!neighbor->seen) {
						n++;
						neighbor->seen=True;
					}
					ni[k]++;
				}
			}
			k++;
		}

		Matrix v(n,dim);
		ColumnVector AtInf(np);
		for (int i=0;i < np;i++) AtInf(i)=0;
		octave_value_list F;
		k=0;
		FORALLfacets {
			facet->seen = False;
		}
		FORALLvertices {
			if (qh hull_dim == 3)
				qh_order_vertexneighbors(vertex);
			infinity_seen = false;
			RowVector facet_list(ni[k++]);
			m = 0;
			FOREACHneighbor_(vertex) {
				if (neighbor->upperdelaunay) {
					if (!infinity_seen) {
						infinity_seen = true;
						AtInf(j) = 1;
					}
				} else {
					if (!neighbor->seen) {
						voronoi_vertex = neighbor->center;
						fidx = neighbor->id;
						for (int d=0; d<dim; d++) {
							v(i,d) = *(voronoi_vertex++);
						}
						i++;
						neighbor->seen = True;
						neighbor->visitid = i;
					}
					facet_list(m++)=neighbor->visitid;
				}
			}
			F(r++)=facet_list;
			j++;	
		}

		retval(0) = v;
		retval(1) = F;
		retval(2) = AtInf;
	
		qh_freeqhull(!qh_ALL);
			//free long memory

		int curlong, totlong;
		qh_memfreeshort (&curlong, &totlong);
			//free short memory and memory allocator
		
		if (curlong || totlong) {
    		    warning("__voronoi__: did not free %d bytes of long memory (%d pieces)", totlong, curlong);
		}
	}
	return retval;
}
