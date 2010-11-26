function resu = subsindex(df, base)
  %# function resu = subsindex(df)
  %# This function convert a dataframe to an index

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
    base = -1.0; 
  else
    base = base - 1.0;
  endif
  
  resu = [];
  for indi = 1:length(df._data),
    %# transform each column to an index
    switch(df._type{indi})
      case 'logical'
	resu = vertcat(resu, find(df._data{indi}) - base);
      otherwise
	resu = vertcat(resu, double(df._data{indi}) - base);
    endswitch
  endfor
  
endfunction
