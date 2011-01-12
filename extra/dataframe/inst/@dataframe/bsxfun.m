function resu = bsxfun(func, A, B)

  %# function resu = bsxfun(func, A, B)
  %# Implements a wrapper around internal bsxfun

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

  resu = [];

  try
    singletondim = find(B._cnt < 2);
    if !isempty(singletondim), singletondim = singletondim(1); endif
    
    if !isempty(singletondim), 
      resu = A;
      %# prepare the call to subsref / subsasgn
      SA.type = '()'; SA.subs = repmat({':'}, [1 length(A._cnt)]);
      for indi = A._cnt(singletondim):-1:1,
	SA.subs{singletondim} = indi;
	resu = subsasgn(resu, SA, @bsxfun(func, subsref(A, SA), B)); 
      endfor
    else
      singletondim = find(A._cnt < 2);
      if !isempty(singletondim), singletondim = singletondim(1); endif
      
      if !isempty(singletondim), %# was isvector(B)
	resu = B;
	%# prepare the call to subsref / subsasgn
	SB.type = '()'; SB.subs = repmat({':'}, [1 length(B._cnt)]);
	for indi = B._cnt(singletondim):-1:1,
	  SB.subs{singletondim} = indi;
	  resu = subsasgn(resu, SB, @bsxfun(func, A, subsref(B, SB)));
	endfor
      else
	%# standard approach
	resu = df_func(func, A, B);
      endif
    endif
  catch
    error('bsxfun: non-compatible dimensions')
  end_try_catch
  
endfunction
