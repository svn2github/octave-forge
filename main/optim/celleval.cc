// Copyright (C) 2004   Michael Creel   <michael.creel@uab.es>
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

// a descendant of "leval", by Etienne Grossman

#include "config.h"
#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-mappers.h>

DEFUN_DLD (celleval, args, nargout, "celleval (name, cell_array)\n\
Evaluate the function named \"name\".  All the elements in cell_array\n\
are passed on to the named function.\n\
Example:\n\
function a = f(b,c)\n\
	a = b + c;\n\
endfunction\n\
celleval(\"f\", {1,2,\"this\"})\n\
ans = 3\n\
")
{
	octave_value_list retval;
	int nargin = args.length ();
	if (!(nargin == 2))
	{
		error("celleval: you must supply exactly 2 arguments");
		return octave_value_list();
	}
	if (!args(0).is_string())
	{
		error ("celleval: first argument must be a string");
		return octave_value_list();
	}
	if (!args(1).is_cell())
	{
		error ("celleval: second argument must be a cell");
		return octave_value_list();
	}
	
	std::string name = args(0).string_value ();
	Cell f_args_cell = args(1).cell_value ();
	int k = f_args_cell.length();
	int i;
	// a list to copy the cell contents into, so feval can be used
	octave_value_list f_args(k,1);
	
	// copy contents over
	for (i = 0; i<k; i++) f_args(i) = f_args_cell(i);
	
	// evaluate the function
	retval = feval (name, f_args, nargout);
	
	return retval;
}

