/*
  Copyright (C) 2009 Carlo de Falco
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  
  Author: Carlo de Falco <cdf _AT_ users _DOT_ sourceforge _DOT_ net>
  Created: 2009-06-01
  
*/


#include <octave/oct.h>

DEFUN_DLD(mgorth,args,nargout,"")
{
  
  octave_value_list retval;
  int nargin = args.length();

  if (nargin != 2)
    {
      print_usage ();
    }
  else 
    {
      ColumnVector x;
      Matrix V;

      x  = args(0).column_vector_value ();
      V  = args(1).matrix_value ();
      
      ColumnVector h (V.columns ());
      if (! error_state)
        {
          for (octave_idx_type j(0); j < V.columns (); j++)
            {
              h(j) = V.column (j).transpose () * x;
              x   -= h(j) * V.column (j);
            }
          retval(1) = octave_value (h);
          retval(0) = octave_value (x);
        }
    }
  return retval;
}
