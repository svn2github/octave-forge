function return_type = map (fun_str,data_struct,varargin)

  ## Copyright (C) 2003 Tomer Altman
  ##
  ## Octave is free software; you can redistribute it and/or
  ## modify it under the terms of the GNU General Public
  ## License as published by the Free Software Foundation;
  ## either version 2, or (at your option) any later version.
  ##
  ## Octave is distributed in the hope that it will be useful,
  ## but WITHOUT ANY WARRANTY; without even the implied
  ## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  ## PURPOSE.  See the GNU General Public License for more
  ## details.
  ##
  ## You should have received a copy of the GNU General Public
  ## License along with Octave; see the file COPYING.  If not,
  ## write to the Free Software Foundation, 59 Temple Place -
  ## Suite 330, Boston, MA 02111-1307, USA.

  ## usage: result = map ( FUN_STR, ARG1, ... )
  ##
  ## map, like LISP's ( & numerous other language's ) function for
  ## iterating the result of a function applied to each of the data
  ## structure's elements in turn. The results are stored in the
  ## corresponding input's place. For now, just will work with cells and
  ## matrices, but support for structs are intended for future versions.
  ## Also, only "prefix" functions ( like "min(a,b,c,...)" ) are
  ## supported.
  ##
  ## Example:
  ##
  ## octave> A
  ## A 
  ## {
  ##   [1,1] = 0.0096243
  ##   [2,1] = 0.82781
  ##   [1,2] = 0.052571
  ##   [2,2] = 0.84645
  ## }
  ## octave> B
  ## B =
  ## {
  ##   [1,1] = 0.75563
  ##   [2,1] = 0.84858
  ##   [1,2] = 0.16765
  ##   [2,2] = 0.85477
  ## }
  ## octave> map("min",A,B)
  ## ans =
  ## {
  ##   [1,1] = 0.0096243
  ##   [2,1] = 0.82781
  ##   [1,2] = 0.052571
  ##   [2,2] = 0.84645
  ## }
 
  ## Author: Tomer Altman
  ## Keywords: map matrix cell 
  ## Maintainer: Tomer Altman
  ## Created: November 15, 2003
  ## Version: 0.1
  
  if (nargin<2)

    error("map: incorrect number of arguments; expecting at least two.");

  elseif ( !isstr(fun_str) )

    error("map: first argument must be a string: ", fun_str);

  elseif ( !exist(fun_str) )

    error("map: first argument is not a valid function name.");

  elseif ( !( isnumeric(data_struct) || iscell(data_struct) ) )

    error("map: second argument must be either a matrix or a cell object:");

  else

    [ rows, cols ] = size(data_struct);

    if ( iscell(data_struct) )

      index_str = "{i,j}";

      return_type = cell(rows,cols);

    else

      index_str = "(i,j)";

      return_type = zeros(rows,cols);

    endif
      
    ## List-o-infix-operators: +, -, /, *, &, &&, |, ||, \, ^, **, <, <=,
    ## >, >=, ==, !=, ~=, <>, = 

    for i=1:rows
	
      for j=1:cols
	
	##return_type{i,j} = feval( fun_str, data_struct{i,j} );
	
	LHS = ["return_type",index_str," = "];
	
	funcall = [fun_str, " ( "];
	
	data = ["data_struct",index_str,", "];
	
	otherdata = columns(varargin);
	
	for k=1:(otherdata-1)
	  
	  data = [data,"varargin{1,",int2str(k),"}",index_str,", "];
	  
	endfor
	
	data = [data,"varargin{1,",int2str(otherdata),"}",index_str," ); "];
	
	map_str = [LHS,funcall,data];
	
	error_str = ["error(\"map: ",error_text,"\n\" )"];
	
	eval(map_str,error_str);
		 
      endfor

    endfor

    data_struct = {};

  endif

endfunction