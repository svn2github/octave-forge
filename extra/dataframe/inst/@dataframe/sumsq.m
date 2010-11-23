function resu = sumsq(df, varargin) 
  
  %# -*- texinfo -*-
  %# @deftypefn  {Function File} {} sum (@var{x})
  %# @deftypefnx {Function File} {} sum (@var{x}, @var{dim})
  %# @deftypefnx {Function File} {} sum (@dots{}, 'native')
  %# @deftypefnx {Function File} {} sum (@dots{}, 'double')
  %# @deftypefnx {Function File} {} sum (@dots{}, 'extra')
  %# Sum of elements along dimension @var{dim}.  If @var{dim} is
  %# omitted, it defaults to the first non-singleton dimension.
  %# 
  %# If the optional argument 'native' is given, then the sum is performed
  %# in the same type as the original argument, rather than in the default
  %# double type.  For example:
  %#
  %# @example
  %# @group
  %# sum ([true, true])
  %# @result{} 2
  %# sum ([true, true], 'native')
  %# @result{} true
  %# @end group
  %# @end example
  %#
  %# On the contrary, if 'double' is given, the sum is performed in double
  %# precision even for single precision inputs.
  %#
  %# For double precision inputs, 'extra' indicates that a more accurate algorithm
  %# than straightforward summation is to be used.  For single precision inputs,
  %# 'extra' is the same as 'double'.  Otherwise, 'extra' has no effect.\n\
  %# @end deftypefn 

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

  if !isa(df, 'dataframe'),
    resu = []; return;
  endif

  dim = []; 

  indi = 1; while indi <= length(varargin)
    if isnumeric(varargin{indi}),
      if !isempty(dim),
	print_usage('@dataframe/sumsq');
	resu = [];
	return
      else
	dim = varargin{indi};
      endif
    else
      print_usage('@dataframe/sumsq');
      resu = [];
      return
    endif
    indi = indi + 1;
  endwhile;
  
  if isempty(dim), dim = 1; endif;
  
  %# pre-assignation
  resu = struct(df); 
  
  switch(dim)
    case {1},
      resu._ridx = 1; resu._name{1, 1} = []; resu._over{1, 1} = [];
      for indi = 1:resu._cnt(2),
	resu._data{1, indi} = sumsq(resu._data{1, indi}, dim);
      endfor
      resu._cnt(1) = 1;
    case {2},
      error('Operation not implemented');
    case {3},
      for indi = 1:resu._cnt(2),
	resu._data{1, indi} = sumsq(resu._data{1, indi}, 2);
      endfor
      if length(resu._cnt) > 2, resu._cnt = resu._cnt(1:2); endif
    otherwise
      error("Invalid dimension %d", dim); 
  endswitch

  resu = dataframe(resu);

endfunction
