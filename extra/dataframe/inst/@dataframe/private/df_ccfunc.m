function resu = df_func(func, A, B, varargin);

  %# function resu = df_ccfunc(func, A, B)
  %# Implements an column vs column iterator to apply some func when at
  %# least one argument is a dataframe. The output is a dataframe with
  %# the same metadata, types may be altered, like f.i. double=>logical.

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
  %# $Id: df_func.m 7947 2010-11-24 21:57:16Z cdemills $
  %#

  [A, B, resu] = df_basecomp(A, B);
  
  if (isa(B, 'dataframe'))
    if (!isa(A, 'dataframe')),
      if (isscalar(A) || ismatrix(A)), 
	resu._data = cellfun(@(x) feval(func, A, x, varargin{:}), B._data, \
			     "UniformOutput", false);
      else
	error("Function %s not implemented for %s by %s", \
	      func2str(func), class(A), class(B));
      endif
    else
      resu._data = cellfun(@(x, y) feval(func, x, y, varargin{:}), A._data, \
			   B._data, "UniformOutput", false);
    endif  
  else
    if (isscalar(B) || ismatrix(B)),
      resu._data = cellfun(@(x) feval(func, x, B, varargin{:}), A._data, \ 
			   "UniformOutput", false);    
    else
      error("Function %s not implemented for %s by %s", \
	    func2str(func), class(A), class(B));
    endif
  endif

  resu._type = cellfun(@class, resu._data, "UniformOutput", false); 
  %# sanity check
  dummy = sum(cellfun('size', resu._data, 2));
  if dummy != resu._cnt(2),
    resu._cnt(3) = dummy;
  endif

endfunction
