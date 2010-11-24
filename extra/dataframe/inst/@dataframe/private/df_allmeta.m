function resu = df_allmeta(df)

  %# function resu = df_allmeta(df)
  %# Returns a new dataframe, initalised with the allthe
  %# meta-information but with empty data

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
  %# $Id: df_func.m 7943 2010-11-24 15:33:54Z cdemills $
  %#

  resu = dataframe([]);
  
  resu._cnt(1:2) = df._cnt(1:2);
  resu._name = df._name;
  resu._over = df._over;
  resu._ridx = df._ridx;
  resu._type = df._type;
  %# init it with the right orientation
  resu._data = cell(size(df._data));
  resu._src  = df._src;

endfunction
