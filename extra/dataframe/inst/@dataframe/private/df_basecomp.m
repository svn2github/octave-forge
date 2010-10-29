function [A, B] = df_basecomp(A, B);

  %# function [A, B] = df_basecomp(A, B)
  %# Basic size verifcation for binary operations on dataframe. Returns
  %# a scalar, a matrix, or a dataframe. Cell arrays are converted to df.

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

  if isscalar(A)  || isscalar(B)
    return
  endif

  if iscell(A), 
    A = dataframe(A); 
  elseif iscell(B), 
    B =  dataframe(B);
  endif
  
  if any(size(A) - size(B)),
    error("Non compatible sizes");
  endif
  if !isa(A, 'dataframe') || !isa(B, 'dataframe'),
    return; %# don't go further with names/indexes comparisons
  endif

  if any(A._ridx-B._ridx),
    error("Non compatible indexes");
  endif
  if !isempty(A._name{1}) && !isempty(B._name{1})
    if !any(strcmp(cellstr(A._name{1}), cellstr(B._name{1}))),
      error("Incompatible row names");
    endif
  endif
  if !isempty(A._name{2}) && !isempty(B._name{2})
    if !any(strcmp(cellstr(A._name{2}), cellstr(B._name{2}))),
      error("Incompatible column names");
    endif
  endif

endfunction
