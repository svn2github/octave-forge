/* Copyright (C) 2013 Marco Vassallo
  
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <dolfin.h>
#include <octave/oct.h>
#include <octave/oct-map.h>

DEFUN_DLD(xml2oct,args,nargout,"xml2oct [mesh] = xml2oct(mesh.xml.gz) \n return a mesh in the [p,e,t] format loaded from the specified file\n")
{
  int nargin = args.length();
  octave_value_list retval;

  if (nargin != 1)
    print_usage ();
  else{

    std::string mesh_to_read = args(0).string_value();
    dolfin::Mesh mesh(mesh_to_read);

    uint D = mesh.topology().dim();

    //Matrix p for the coordinates of vertices
    std::size_t num_v = mesh.num_vertices();
    std::vector<double> my_coord = mesh.coordinates();
    int n_coord = my_coord.size();
    Matrix p(D,num_v);
    std::size_t n=0;

    for(octave_idx_type j=0; j < num_v; ++j){
      for(octave_idx_type i =0; i < D; ++i,++n){
	p(i,j) = my_coord[n];
      }
    }

    //Matrix e for boundary elements
    mesh.init(D - 1, D);
    std::size_t num_f = mesh.num_facets();
    Matrix e;
    if( D == 2) e.resize(7,num_f);
    if( D == 3) e.resize(10,num_f);
    octave_idx_type l=0,m=0;

    for (dolfin::FacetIterator f(mesh); !f.end(); ++f){
      if( (*f).exterior() == true){
	l = 0;
	for (dolfin::VertexIterator v(*f); !v.end(); ++v,++l){ 
	  e(l,m) = (*v).index()+1 ;
	}
	++m;
      }   
    }

    if( D == 2) {
      e.resize(7,m);
      e.fill(1,6,0,6,m-1);
    }
    if( D == 3) {
      e.resize(10,m);
      e.fill(1,9,0,9,m-1);
    }
  
    //Matrix t for defining cells 
    std::size_t num_c = mesh.num_cells();
    std::vector<unsigned int> my_cells = mesh.cells();
    Matrix t(D+2,num_c);
    t.fill(1.0);
    n=0;

    for(octave_idx_type j=0; j < num_c; ++j){
      for(octave_idx_type i =0; i < D+1; ++i,++n){
	t(i,j) += my_cells[n];
      }
    }  

    Octave_map a;
    a.assign("p",octave_value(p));
    a.assign("e",octave_value(e));
    a.assign("t",octave_value(t));
    retval = octave_value(a);
  }

  return retval;
}

/*

#! mesh = xml2oct("dolfin_fine.xml.gz" );
#! msh2p_mesh(mesh);

 */
