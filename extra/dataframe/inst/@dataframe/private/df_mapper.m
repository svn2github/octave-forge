function resu = df_mapper(func, df, varargin)
  %# resu = df_mapper(func, df)
  %# small interface to iterate some func over the elements of a dataframe.

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

  resu = df_allmeta(df);
  for indi = df._cnt(2):-1:1,
    resu._data{indi} = feval(func, df._data{indi}, varargin{:});
  endfor
    
  %# sanity check
  dummy = sum(cellfun('size', resu._data, 2));
  if dummy != resu._cnt(2),
    resu._cnt(3) = dummy;
  endif

endfunction
