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


  try

    [A, B, resu] = df_basecomp(A, B, true);

    itercol = false;
    dummy = min(length(A._cnt), length(B._cnt));
    if length(A._cnt(1:dummy)) == length(B._cnt(1:dummy)),
      %# we can iterate on colums iff 
      %# one matrix, without its colum dimension, becomes a scalar
      %# both matrix, except for column dimension, have the same size
      
      dummy = 1:dummy; dummy(2) = [];
      if (all(A._cnt(dummy) == B._cnt(dummy))),
	itercol = true;
      else
	dummy = B._cnt; dummy(2) = [];
	if (all(1 == dummy)), %# B is reducible to a scalar
	  itercol = true;
	else
	  dummy = A._cnt; dummy(2) = [];
	  if (all(1 == dummy)), %# we can perform colum iterations
	    itercol = true;
	  endif
	endif
      endif
    endif

    if (itercol),
      %# optimised computation
      singletondim = 2; 
      if (A._cnt(2) >= B._cnt(2)),
	if (length(A._cnt) > 2 && A._cnt(3) > 1),
	  SA.type = '()'; SA.subs = repmat({':'}, [1 length(A._cnt)]);  
	  for indi = 1:resu._cnt(2),
	    SA.subs{singletondim} = indi; 
	    dummy = min(indi, B._cnt(2))
	    for indj = 1:length(resu._rep{indi}),
	      [resu, S] = df_cow(resu, SA, indj);
	      resu._data{indi}(:, resu._rep{indj}) = \
		  feval(func, A._data{indi}(:, A._rep{indi}), \
			B._data{dummy}(:, B._rep{dummy}))
	    endfor
	  endfor
	else
	  for indi = 1:resu._cnt(2),
	    dummy = min(indi, B._cnt(2));
	    resu._data{indi}(:, resu._rep{indi}) = \
		feval(func, A._data{indi}(:, A._rep{indi}), \
		      B._data{dummy}(:, B._rep{dummy}));
	  endfor
	endif
      else
	resu = B; keyboard
	if (length(B._cnt) > 2 && B._cnt(3) > 1),
	  SB.type = '()'; SB.subs = repmat({':'}, [1 length(B._cnt)]);
	  for indi = 1:resu._cnt(2),
	    SB.subs{singletondim} = indi; 
	    dummy = min(indi, A._cnt(2));
	    for indj = 1:length(resu._rep{indi}),
	      [resu, S] = df_cow(resu, SB, indj);
keyboard
	      resu._data{indi}(:, resu._rep{indj}) = \
		  feval(func, A._data{dummy}(:, A._rep{dummy}), \
			resu._data{indi}(:, resu._rep{indi}));
	    endfor
	  endfor
	else
	  
	  for indi = 1:resu._cnt(2),
	    dummy = min(indi, A._cnt(2));
	    resu._data{indi}(:, resu._rep{indi}) = \
		feval(func, A._data{dummy}(:, A._rep{dummy}), \
		      resu._data{indi}(:, resu._rep{indi}));
	  endfor
	endif
      endif
    else
      %# try to find a singleton dim in B
      singletondim = find(B._cnt < 2);
      if !isempty(singletondim), singletondim = singletondim(1); endif
      if !isempty(singletondim), 
	%# prepare the call to subsref / subsasgn
	SA.type = '()'; SA.subs = repmat({':'}, [1 length(A._cnt)]);
	for indi = A._cnt(singletondim):-1:1,
	  SA.subs{singletondim} = indi; 
	  resu = subsasgn(resu, SA, feval(func, subsref(A, SA), B)); 
	endfor
      else
	%# try to find a singleton dim in A
	singletondim = find(A._cnt < 2);
	if !isempty(singletondim), singletondim = singletondim(1); endif
	
	if !isempty(singletondim), %# was isvector(B)
	  resu = B;
	  %# prepare the call to subsref / subsasgn
	  SB.type = '()'; SB.subs = repmat({':'}, [1 length(B._cnt)]);
	  for indi = B._cnt(singletondim):-1:1,
	    SB.subs{singletondim} = indi;
	    %#	  resu = subsasgn(resu, SB, @bsxfun(func, A, subsref(B, SB)));
	    resu = subsasgn(resu, SB, feval(func, A, subsref(B, SB)));
	  endfor
	else
	  %# standard approach
	  resu = df_func(func, A, B);
	endif
      endif
    endif
    
  catch
    disp('line 107 '); keyboard
    error('bsxfun: non-compatible dimensions')
  end_try_catch
  
endfunction
