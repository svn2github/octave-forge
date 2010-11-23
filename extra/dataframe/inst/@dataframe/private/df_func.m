function resu = df_func(func, A, B);

  %# function resu = df_func(func, A, B)
  %# Implements an iterator to apply some func when at least one
  %# argument is a dataframe

  %% Copyright (C) 2009-2010 Pascal Dupuis <Pascal.Dupuis@uclouvain.be>
  %%
  %% This file is part of Octave.
  %%
  %% Octave is free software; you can redistribute it and/or
  %% modify it under the terms of the GNU General Public
  %% License as published by the Free Software Foundation;
  %% either version 2, or (at your option) any later version.
  %%
  %% Octave is distributed in the hope that it will be useful,
  %% but WITHOUT ANY WARRANTY; without even the implied
  %% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  %% PURPOSE.  See the GNU General Public License for more
  %% details.
  %%
  %% You should have received a copy of the GNU General Public
  %% License along with Octave; see the file COPYING.  If not,
  %% write to the Free Software Foundation, 59 Temple Place -
  %% Suite 330, Boston, MA 02111-1307, USA.
  
  %#
  %# $Id$
  %#

  [A, B] = df_basecomp(A, B);

  if isa(B, 'dataframe')
    if !isa(A, 'dataframe'),
      if isscalar(A) 
	resu = cellfun(@(x) feval(func, A, x), B._data, "UniformOutput", false);
      elseif ismatrix(A),
	resu = cellfun(@(x, y) feval(func, x, y), num2cell(A, 1),  B._data, \
		       "UniformOutput", false);
      else
	error("Function %s not implemented", func2str(func));
      endif
    else
      resu = cellfun(@(x, y) feval(func, x, y), A._data,  B._data, \
		     "UniformOutput", false);
    endif
  else
    if isscalar(B),
      resu = cellfun(@(x) feval(func, x, B), A._data, "UniformOutput", false);
    elseif ismatrix(B),
      resu = cellfun(@(x, y) feval(func, x, y), A._data, num2cell(B, 1), \
		     "UniformOutput", false);
    else
      error("Operator < not implemented");
    endif
  endif
        
endfunction
