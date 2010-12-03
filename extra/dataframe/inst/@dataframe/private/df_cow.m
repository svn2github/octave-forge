function [df, S] = df_cow(df, S, col, inds)

  %# function [resu, S] = df_cow(df, S, col, inds)
  %# Implements Copy-On-Write on dataframe. If one or more columns
  %# specified in inds is aliased to another one, duplicate it and
  %# adjust the repetition index to remove the aliasing

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

  if length(col) > 1,
    error("df_cow must work on a column-by-column basis");
  endif
  
  if isempty(inds), inds = 1; endif
  for indi = inds,
    dummy = df._rep{col}; dummy(indi) = 0;
    [t1, t2] = ismember(df._rep{col}(indi)(:), dummy);
    for indj = t2(find(t2)), %# Copy-On-Write
      %# determines the index for the next column
      t1 = 1+max(df._rep{col}); 
      %# duplicate the touched column
      df._data{col} = horzcat(df._data{col}, \
			      df._data{col}(:, df._rep{col}(indj)));  
      if (indi > 1)
	%# a new column has been created
	df._rep{col}(indi) = t1;
      else
	%# update repetition index aliasing this one
	dummy = find(dummy == indi);
	df._rep{col}(dummy) = t1;
      endif
      if (length(S.subs) > 1 && indi > 1),
	%# adapt the sheet index accordingly
	keyboard
	S.subs{2}(find(S.subs{2}==indi)) = t1;
      endif

    endfor
  endfor
 
  %# sanity check
  dummy = sum(cellfun(@length, df._rep));
  if dummy != df._cnt(2),
    df._cnt(3) = dummy;
  endif

endfunction
