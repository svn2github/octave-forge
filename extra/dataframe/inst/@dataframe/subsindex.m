function resu = subsindex(df, base)
  %# function resu = subsindex(df)
  %# This function convert a dataframe to an index. Do not expect a
  %# meaningfull result when mixing numeric and logical columns.

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
  
  if nargin < 2, 
    base = 1.0; 
  else
    base = base - 1.0;
  endif
  
  %# extract all values at once
  dummy = df_whole(df); 
  if isa(dummy, 'logical'),
    resu = sort(find(dummy)-base);
  else
    resu = dummy - base;
  endif

endfunction
