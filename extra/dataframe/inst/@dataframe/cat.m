function resu = cat(dim, A, varargin)
  %# function resu = cat(dim, A, varargin)
  %# This is the concatenation operator for a dataframe object. "Dim"
  %# has the same meaning as ordinary cat. Next arguments may be
  %# dataframe, vector/matrix, or two elements cells. First one is taken
  %# as row/column name, second as data.

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
  %# $Id: cat.m 1025 2010-08-02 08:55:55Z dupuis $
  %#

  switch dim
    case 1
      resu = A;
          
      for indi=1:length(varargin),
	B = varargin{indi};
	if !isa(B, 'dataframe'),
	  if iscell(B) && 2 == length(B),
	    B = dataframe(B{2}, 'rownames', B{1});
	  else
	    B = dataframe(B, 'colnames', inputname(2+indi));
	  endif
	endif
	if resu._cnt(2) != B._cnt(2),
	  error('Different number of columns in dataframes');
	endif
	%# do not duplicate empty names
	if !isempty(resu._name{1}) || !isempty(B._name{1}),
	  if length(resu._name{1}) < resu._cnt(1),
	    resu._name{1}(end+1:resu._cnt(1), 1) = {''};
	  endif
	  if length(B._name{1}) < B._cnt(1),
	    B._name{1}(end+1:B._cnt(1), 1) = {''};
	  endif
	  resu._name{1} = vertcat(resu._name{1}(:),  B._name{1}(:));
	  resu._over{1} = [resu._over{1} B._over{1}];
	endif
	resu._cnt(1) = resu._cnt(1) + B._cnt(1);
	resu._ridx = [resu._ridx(:); B._ridx(:)];
	%# find data with same column names
	indr = logical(ones(1, resu._cnt(2)));
	indb = logical(ones(1, resu._cnt(2)));
	indi = 1;
	while indi <= resu._cnt(2),
	  indj = strmatch(resu._name{2}(indi), B. _name{2});
	  if ~isempty(indj),
	    indj = indj(1);
	    if ~strcmp(resu._type{indi}, B._type{indj}),
	      error("Trying to mix columns of different types");
	    endif
	    resu._data{indi} = [resu._data{indi}; B._data{indj}];
	    indr(indi) = false; indb(indj) = false;
	  endif
	  indi = indi + 1;
	endwhile
	if any(indr) || any(indb)
	  error('Different number/names of columns in dataframe');
	endif
      endfor
      
    case 2
      resu = A;
      for indi=1:length(varargin),
	B = varargin{indi};
	if !isa(B, 'dataframe'),
	  if iscell(B) && 2 == length(B),
	    B = dataframe(B{2}, 'colnames', B{1});
	  else
	    B = dataframe(B, 'colnames', inputname(2+indi));
	  endif
	  B._ridx = resu._ridx; %# make them compatibles
	endif
	if resu._cnt(1) != B._cnt(1),
	  error('Different number of rows in dataframes');
	endif
	if any(resu._ridx(:) - B._ridx(:))
	  error('dataframes row indexes not matched');
	endif
	resu._name{2} = vertcat(resu._name{2}, B._name{2});
	resu._over{2} = [resu._over{2} B._over{2}];
	indj = resu._cnt(2) + 1;
	for indi = 1:B._cnt(2),
	  resu._data{indj} = B._data{indi};
	  resu._type{indj} = B._type{indi};
	  indj = indj + 1;
	endfor
	resu._cnt(2) = resu._cnt(2) + B._cnt(2);	
      endfor
      
    case 3
      resu = A;
      
      for indi=1:length(varargin),
	B = varargin{indi};
	if !isa(B, 'dataframe'),
	  if iscell(B) && 2 == length(B),
	    B = dataframe(B{2}, 'rownames', B{1});
	  else
	    B = dataframe(B, 'colnames', inputname(2+indi));
	  endif
	endif
	if resu._cnt(1) != B._cnt(1),
	  disp('line 124 '); keyboard
	  error('Different number of rows in dataframes');
	endif
	if resu._cnt(2) != B._cnt(2),
	  error('Different number of columns in dataframes');
	endif
	%# to be merged against 3rd dim, rownames must be equals, if
	%# non-empty. Columns are merged based upon their name; columns
	%# with identic content are kept.

	resu._ridx = [resu._ridx B._ridx(:)];
	%# find data with same column names
	indr = logical(ones(1, resu._cnt(2)));
	indb = logical(ones(1, resu._cnt(2)));
	indi = 1;
	while indi <= resu._cnt(2),
	  indj = strmatch(resu._name{2}(indi), B. _name{2});
	  if ~isempty(indj),
	    indj = indj(1);
	    if ~strcmp(resu._type{indi}, B._type{indj}),
	      error("Trying to mix columns of different types");
	    endif
	    if all([isnumeric(resu._data{indi}) isnumeric(B._data{indj})]),
	      try
		dummy =  all(abs(resu._data{indi} - B._data{indj}) <= eps);
		if dummy,
		  %# two numeric columns with same content -- skip
		  indr(indi) = false; indb(indj) = false;
		  indi = indi+1; continue;
		endif
	      catch
		%# things are not substractible
	      end_try_catch
	    endif
	    %# pad
	    resu._data{indi} = [resu._data{indi} B._data{indj}];
	    indr(indi) = false; indb(indj) = false;
	  endif
	  indi = indi + 1;
	endwhile
	if any(indr) || any(indb)
	  error('Different number/names of columns in dataframe');
	endif
      endfor
      dummy = sum(cellfun('size', resu._data, 2));
      if dummy != resu._cnt(2),
	resu._cnt(3) = dummy;
      else
	resu._cnt = resu._cnt(1:2);
      endif
      
    otherwise
      error('Incorrect call to cat');
  endswitch
  
  %#  disp('End of cat'); keyboard
endfunction
