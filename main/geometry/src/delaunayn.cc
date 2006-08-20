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

  6. June 2006: Changes by Alexander Barth <abarth@marine.usf.edu>

  * triangulate non-simplicial facets 
  * allow options to be specified as cell array of strings
  * change the default options (for compatibility with matlab)
*/

#include "config.h"

extern "C" {
#include "qhull/qhull_a.h"
}

#include <iostream>
#include <string>

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>
#include "ov-cell.h"

#ifdef NEED_QHULL_VERSION
char qh_version[] = "delaunayn.oct 2003-12-14";
#endif
FILE *outfile = stdout;
FILE *errfile = stderr;
char flags[250];

DEFUN_DLD (delaunayn, args, ,
	   "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{T}=} delaunayn (@var{P}[, @var{opt}])\n\
Form the Delaunay triangulation for a set of points.\n\
The Delaunay triangulation is a tessellation of the convex hull of the\n\
points such that no n-sphere defined by the n-triangles contains\n\
any other points from the set.\n\n\
The input matrix @var{P} of size [n, dim] contains n points in a space of dimension dim.\n\
The return matrix @var{T} has the size [m, dim+1]. It contains for\n\
each row a set of indices to the points, which describes a simplex of\n\
dimension dim.  For example, a 2d simplex is a triangle and 3d simplex is a tetrahedron.\n\n\
Extra options for the underlying Qhull command can be specified by the second  \
argument. This argument is a cell array of strings. The default options depend on the dimension \
of the input: \n\
@itemize \n\
@item  2D and 3D: @var{opt} = @{'Qt','Qbb','Qc'@}  \
@item  4D and higher: @var{opt} = @{'Qt','Qbb','Qc','Qz'@} \
@end itemize \n\n\
If @var{opt} is [], then the default arguments are used. \
If @var{opt} is @{'@w{}'@}, then none of the default arguments are used by Qhull. \n\
See the Qhull documentation for the available options. \n\n\
All options can also be specified as single string, for example 'Qt Qbb Qc Qz'. \n\n\
NOTE: The default options of delaunayn have changed. Use \n\
@var{OPT}= @{'Qbb','T0'@} to reproduce the output of previous version. \
@end deftypefn")

{
  octave_value_list retval;
  retval(0) = 0.0;
  std::string options = "";

  int nargin = args.length();
  if (nargin < 1 || nargin > 2) {
    print_usage ();
    return retval;
  }

  Matrix p(args(0).matrix_value());
  const int dim = p.columns();
  const int n = p.rows();

  // default options
  if (dim <= 3)
    options = "Qt Qbb Qc";
  else
    options = "Qt Qbb Qc Qx";


  if (nargin == 2) {
    if (args(1).is_empty() ) {
      // keep default options
    }
    else if ( args(1).is_string () ) {
      // option string is directly provided
      options = args(1).string_value();
    }
    else if ( args(1).is_cell () ) {
      options = "";

      Cell c =  args(1).cell_value();
      for (int i=0; i < c.numel(); i++) {

        if (!c.elem(i).is_string()) {
          error ("delaunayn: all options must be strings");
          return retval;
	}

        options = options + c.elem(i).string_value() + " ";
      }
    }
    else {
      error ("delaunayn: second argument must be a string, cell of stringsor empty");
      return retval;
    }
  } 

  //octave_stdout << "options " << options << std::endl;

  if (n > dim) {

    p = p.transpose();
    double *pt_array = p.fortran_vec();
    boolT ismalloc = False;

    sprintf(flags,"qhull d %s",options.c_str());

    /*If you want some debugging information replace the NULL
      pointer with outfile.
    */

    int exitcode =  qh_new_qhull (dim, n, pt_array, ismalloc,flags, NULL, errfile);

    if (exitcode) {
      error("delaunayn: qhull failed.");
      return retval;
    }

    // triangulate non-simplicial facets

    qh_triangulate(); 

    facetT *facet;
    vertexT *vertex, **vertexp;
    int nf=0,i=0;

    FORALLfacets {
      if (!facet->upperdelaunay) nf++;

      // Double check
      if (!facet->simplicial) {
       	error("delaunayn: Qhull returned non-simplicial facets. Try delaunayn with different options.");
	break;
      }
    }

    if (!error_state) {
      Matrix simpl(nf,dim+1);
      FORALLfacets {
        if (!facet->upperdelaunay) {
          int j=0;
          FOREACHvertex_ (facet->vertices) {

	    // if delaunayn crashes, enable this check

#           if 0
            if (j > dim) {
               error("delaunayn: internal error. Qhull returned non-simplicial facets.");
               return retval;
 	    }
#           endif

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
