## Copyright (C) 2003 Tomer Altman
## Copyright (C) 2007 Muthiah Annamalai
##
## This program is free software; you can redistribute it and/or
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
## write to the Free Software Foundation,  51 Franklin Street, 
## Fifth Floor, Boston, MA  02110-1301  USA

## usage: result = map ( FUN_HANDLE, ARG1, ... )
##
## map, like Lisp's ( & numerous other language's ) function for
## iterating the result of a function applied to each of the data
## structure's elements in turn. The results are stored in the
## corresponding input's place. For now, just will work with cells and
## matrices, but support for structs are intended for future versions.
## Also, only "prefix" functions ( like "min(a,b,c,...)" ) are
## supported. FUN_HANDLE can either be a function name string or a
## function handle (recommended).
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
## octave> map(@min,A,B)
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

## Last Modified by Muthiah Annamalai

function return_type = map (fun_handle,data_struct,varargin)
  
  if (nargin >= 1)

    try
      if ( ischar(fun_handle) )
	fun_handle=eval(strcat("@",fun_handle));
      end
      fstr=typeinfo(fun_handle);
    catch
      error('Error: Cannot find function handle, or funtion doesnt exist')
    end
  end

  if (nargin<2)
    error("map: incorrect number of arguments; expecting at least two.");
  elseif ( strcmp(fstr,"function handle")==0 )
    error("map: first argument is not a valid function handle ");
  elseif ( !( isnumeric(data_struct) || iscell(data_struct) ) )
    error("map: second argument must be either a matrix or a cell object:");
  end

  [ rows, cols ] = size(data_struct);
  typecell=0;
  
  if ( iscell(data_struct) )
    typecell=1;
    return_type = cell(rows,cols);
  else
    typecell=0;
    return_type = zeros(rows,cols);
  endif
  
  otherdata = length(varargin);
  val{1:otherdata+1}=0;

  if(typecell)
    
    if(otherdata >= 1)
      
      for i=1:rows	  
	for j=1:cols
	  val{1}=data_struct{i,j};
	  for idx=2:otherdata+1
	    val{idx}=varargin{idx-1}{i,j};
	  end
  	  return_type{i,j}=apply(fun_handle,val);
	end
      end
      
    else
      
      for i=1:rows	  
	for j=1:cols	    
	  return_type{i,j}=fun_handle(data_struct{i,j});
	end
      end
      
    end
    
  else
    
    if(otherdata >= 1)
      
      for i=1:rows
	for j=1:cols
	  val{1}=data_struct(i,j);
	  for idx=2:otherdata+1
	    val{idx}=varargin{idx-1}(i,j);
	  end
  	  return_type(i,j)=apply(fun_handle,val);
	end
      end

    else

      for i=1:rows
	for j=1:cols
	  return_type(i,j)=fun_handle(data_struct(i,j));
	end
      end

    end

  end

endfunction
%!
%!assert(map(@min,[1 2 3 4 5],[5 4 3 2 1]), [1 2 3 2 1])
%!assert(map(@min,rand(1,5),[0 0 0 0 0]), [0 0 0 0 0])
%!assert(map(@(x,y) (sin(x).^2 + cos(y).^2),-pi:0.5:+pi,-pi:0.5:+pi),ones(1,13))
%!assert(map(@(x,y) (sin(x).^2 + cos(y).^2),-pi:0.5:+pi,-pi:0.5:+pi),ones(1,13))
%!
