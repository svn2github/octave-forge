function resu = repmat(df, varargin) 

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

  resu = df; idx = horzcat(varargin{:});
  %# for the second dim, use either 1 either the 3rd one
  dummy = idx;
  if (length(dummy) > 2), 
    dummy(2) = []; 
  else
    dummy(2) = 1;
  endif
  %# operate on first and third dim first
  if (idx(1) > 1 || length(idx) > 2)
    resu = df_mapper(@repmat, df, dummy);
    if (!isempty(df._name{1})),
      resu._name{1} = feval(@repmat, df._name{1}, [idx(1) 1]);
      resu._over{1} = feval(@repmat, df._over{1}, [idx(1) 1]);
    endif
    resu._cnt(1) = resu._cnt(1) * idx(1);
  endif

  %# operate on ridx 
  resu._ridx = feval(@repmat, resu._ridx, dummy);
  
  %# operate on second dim
  if (length(idx) > 1 && idx(2) > 1),
    resu._data    = feval(@repmat, resu._data, [1 idx(2)]); 
    resu._name{2} = feval(@repmat, df._name{2}, [idx(2) 1]);
    resu._over{2} = feval(@repmat, df._over{2}, [1 idx(2)]);
    resu._type    = feval(@repmat, df._type, [1 idx(2)]);
    resu._cnt(2)  = resu._cnt(2) * idx(2);
  endif

  if (any([length(resu._cnt) length(idx)] > 2)),
    resu._cnt(3) = sum(cellfun('size', resu._data, 2));
  endif
      
endfunction
