function resu = df_mapper2(func, df, varargin)
  %# resu = df_mapper2(func, df)
  %# small interface to iterate some vector func over the elements of a
  %# dataframe.

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

  dim =1; resu = []; vout = varargin;
  
  if !isempty(varargin) && isnumeric(varargin{1}), 
    dim = varargin{1}; 
    %# the "third" dim is the second on stored data
    if 3 == dim, vout(1) = 2; endif
  endif

  resu = df;

  switch(dim)
    case {1},
      %# remove row metadata
      resu._ridx = []; resu._name{1, 1} = []; resu._over{1, 1} = [];
      for indi = resu._cnt(2):-1:1,
	resu._data{indi} = feval(func, resu._data{indi}, vout{:});
      endfor
      resu._cnt(1) = 1;
    case {2},
      error('Operation not implemented');
    case {3},
      for indi = resu._cnt(2):-1:1;
	resu._data{indi} = feval(func, resu._data{indi}, vout{:});
      endfor
      if length(resu._cnt) > 2, resu._cnt = resu._cnt(1:2); endif
    otherwise
      error("Invalid dimension %d", dim); 
  endswitch
    
endfunction
