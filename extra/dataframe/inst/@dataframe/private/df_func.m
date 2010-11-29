function resu = df_func(func, A, B, itercol=true, whole=logical([0 0]));

  %# function resu = df_func(func, A, B, whole)
  %# Implements an iterator to apply some func when at
  %# least one argument is a dataframe. The output is a dataframe with
  %# the same metadata, types may be altered, like f.i. double=>logical.
  %# When itercol is 'true', the default, LHS is iterated by columns,
  %# otherwise by rows. 'Whole' is a two-elements logical vector with
  %# the meaning that LHS and or RHS must be iterated at once or not

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

  [A, B, resu] = df_basecomp(A, B, itercol, func);
 
  if (isa(B, 'dataframe'))
    if (!isa(A, 'dataframe')),
      if (isscalar(A)),
 	for indi = resu._cnt(2):-1:1,
	  switch resu._type{indi}
	    case "char"
	      resu._data{indi} = feval(func, A, char(B._data{indi}));
	    otherwise
	      resu._data{indi} = feval(func, A, B._data{indi});
	  endswitch
	endfor
      else
	if (whole(1) && !whole(2)),
	  for indi = resu._cnt(2):-1:1,
	    switch resu._type{indi}
	      case "char"
		resu._data{indi} = feval(func, A, char(B._data{indi}));
	      otherwise
		resu._data{indi} = feval(func, A, B._data{indi});
	    endswitch
	  endfor
	elseif (itercol && !whole(2)),
	  for indi = resu._cnt(2):-1:1,
	    switch resu._type{indi}
	      case "char"
		resu._data{indi} = feval(func, A(:, indi), char(B._data{indi}));
	      otherwise
		resu._data{indi} = feval(func, A(:, indi), B._data{indi});
	    endswitch
	  endfor
	elseif (!whole(2)),
	  for indi = resu._cnt(2):-1:1,
	    switch resu._type{indi}
	      case "char"
		resu._data{indi} = feval(func, A(indi, :), char(B._data{indi}));
	      otherwise
		resu._data{indi} = feval(func, A(indi, :), B._data{indi});
	    endswitch
	  endfor
	else
	  dummy = feval(func, A, horzcat(B._data {:}));
	  for indi = resu._cnt(2):-1:1, %# store column-wise
	    resu._data{indi} = dummy(:, indi);
	    resu._type{indi} = class(dummy);
	  endfor
	endif
      endif
    else
      if (itercol),
	for indi = resu._cnt(2):-1:1,
	  switch resu._type{indi}
	    case "char"
	      resu._data{indi} = feval(func, char(A._data{indi}), char(B._data{indi}));
	    otherwise
	      resu._data{indi} = feval(func, A._data{indi}, B._data{indi});
	  endswitch
	endfor
      else
	dummy = horzcat(A._data {:});
	if whole(1),
	  for indi = resu._cnt(2):-1:1,
	    switch resu._type{indi}
	      case "char"
		resu._data{indi} = feval(func, dummy, char(B._data{indi}));
	      otherwise
		resu._data{indi} = feval(func, dummy, B._data{indi});
	    endswitch
	  endfor
	elseif (!whole(2)),
	  for indi = resu._cnt(2):-1:1,
	    switch resu._type{indi}
	      case "char"
		resu._data{indi} = feval(func, dummy(indi, :), char(B._data{indi}));
	      otherwise
		resu._data{indi} = feval(func, dummy(indi, :), B._data{indi});
	    endswitch
	  endfor
	else
	  dummy = feval(func, dummy, horzcat(B._data{:}));
	  for indi = resu._cnt(2):-1:1, %# store column-wise
	    resu._data{indi} = dummy(:, indi);
	    resu._type{indi} = class(dummy);
	  endfor
	endif
      endif
    endif  
  else %# B is not a dataframe
    if (isscalar(B)),
      for indi = resu._cnt(2):-1:1,
	switch resu._type{indi}
	  case "char"
	    resu._data{indi} = feval(func, char(A._data{indi}), B);
	  otherwise
	    resu._data{indi} = feval(func, A._data{indi}, B);
	endswitch
      endfor
    else
      if (itercol),
	if (whole(2)),
	  for indi = resu._cnt(2):-1:1,
	    switch resu._type{indi}
	      case "char"
		resu._data{indi} = feval(func, char(A._data{indi}), B);
	      otherwise
		resu._data{indi} = feval(func, A._data{indi}, B);
	    endswitch
	  endfor
	else
	  for indi = resu._cnt(2):-1:1,
	    switch resu._type{indi}
	      case "char"
		resu._data{indi} = feval(func, char(A._data{indi}), \
					 B(:, indi));
	      otherwise
		resu._data{indi} = feval(func, A._data{indi}, B(:, indi));
	    endswitch
	  endfor
	endif
      else
	dummy = horzcat(A._data {:});
	if whole(1),
	  for indi = columns(B):-1:1,
	    resu._data{indi} = feval(func, dummy, B(:, indi));
	  endfor
	else
	  if !whole(2),
	    for indi = resu._cnt(1):-1:1,
	      resu._data{indi} = feval(func, dummy(indi, :), B(:, indi));
	    endfor
	  else
	    for indi = resu._cnt(1):-1:1, %# in place computation
	      dummy(indi, :) = feval(func, dummy(indi, :), B);
	    endfor
	    for indi = resu._cnt(2):-1:1, %# store column-wise
	      resu._data{indi} = dummy(:, indi);
	    endfor
	  endif
	endif
	%# verify that sizes match, this is required for "\"
	resu._cnt(2) = length(resu._data);
	resu._cnt(1) = max(cellfun('size', resu._data, 1));
	if (length(resu._ridx) < resu._cnt(1)),
	  if (1 == length(resu._ridx)),
	    resu._ridx(end+1:resu._cnt(1), 1) = resu._ridx(1);
	  else
	    resu._ridx(end+1:resu._cnt(1), 1) = NA;
	  endif
	endif
	if (length(resu._name{2}) < resu._cnt(2)),
	  if (1 == length(resu._name{2})),
	    resu._name{2}(end+1:resu._cnt(2), 1) = resu._name{2};
	    resu._over{2}(end+1:resu._cnt(2), 1) = resu._over{2};
	  else
	    resu._name{2}(end+1:resu._cnt(2), 1) = '_';
	    resu._over{2}(end+1:resu._cnt(2), 1) = true;
	  endif
	endif
      endif
    endif
  endif

  resu._type = cellfun(@class, resu._data, "UniformOutput", false); 
  %# sanity check
  dummy = sum(cellfun('size', resu._data, 2));
  if dummy != resu._cnt(2),
    resu._cnt(3) = dummy;
  endif

endfunction
