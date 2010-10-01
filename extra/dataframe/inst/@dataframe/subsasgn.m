function resu = subasgn(df, S, RHS)
  %# function resu = subasgn(df, S, RHS)
  %# This is the assignement operator for a dataframe object, taking
  %# care of all the housekeeping of meta-info.

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
  %# $Id: subsasgn.m 1035 2010-08-03 16:22:58Z dupuis $
  %#

  switch(S(1).type)
    case '{}'
      error('Invalid dataframe as cell assignement');
    case '.'
      resu = df;
      %# translate the external to internal name
      switch S(1).subs
	case "rownames"
	  if !isnull(RHS) && isempty(df._name{1}),
	    df._name{1}(1:df._cnt(1), 1) = {''};
	    df._over{1}(1, 1:df._cnt(1)) = true;
	  endif
	  [resu._name{1}, resu._over{1}] = df_strset\
	      (df._name{1}, df._over{1}, S(2:end), RHS);
	  return
	
	case "colnames"
	  if isnull(RHS), error("Colnames can't be nulled"); endif
	  [resu._name{2}, resu._over{2}] = df_strset\
	      (df._name{2}, df._over{2}, S(2:end), RHS, '_');
	  return
	  
	case "types"
	  if isnull(RHS), error("Types can't be nulled"); endif
	  if 1 == length(S),
	    for indi = 1:df_cnt(2),
	      %# perform explicit cast on each column
	      resu._data{indi} = cast(resu._data{indi}, RHS);
	      resu._type{indi} = RHS;
	    endfor
	  else
	    if !strcmp(S(2).type, '()'),
	      error("Invalid internal type sub-access, use () instead");
	    endif 
	    if length(S) > 2 || length(S(2).subs) > 1,
	      error("Types can only be changed as a whole");
	    endif
	    if !isnumeric(S(2).subs{1}),
	      [indj, ncol, S(2).subs{1}] = df_name2idx\
		  (df._name{2}, S(2).subs{1}, df._cnt(2), 'column');
	    else
	      indj = S(2).subs{1}; ncol = length(indj);
	    endif
	    for indi = 1:length(indj),
	      %# perform explicit cast on selected columns
	      resu._data{indj(indi)} = cast(resu._data{indj(indi)}, RHS);
	      resu._type{indj(indi)} = RHS;
	    endfor 
	  endif
	  return
	  
	otherwise
	  if !ischar(S(1).subs),
	    error("Congratulations. I didn't see how to produce this error");
	  endif
	  %# translate the name to column
	  [indc, ncol] = df_name2idx(df._name{2}, S(1).subs, \
				     df._cnt(2), 'column');
    	  if length(S) > 1,
	    if 1 == length(S(2).subs), %# add column reference
	      S(2).subs{2} = indc;
	    else
	      S(2).subs(2:3) = {indc, S(2).subs{2}};
	    endif
	  else
	    %# full assignement
	    S(2).type = '()'; S(2).subs = { '', indc, ':' };
	    if length(size(RHS)) < 3,
	      if isnull(RHS),
		S(2).subs = {':', indc};
	      elseif 1 == size(RHS, 2),
		S(2).subs = { '', indc };
	      elseif 1 == ncol && 1 == size(df._data{indc}, 2),
		%# force the padding of the vector to a matrix 
		S(2).subs = {'', indc, [1:size(RHS, 2)]};
	      endif
	    endif
	  endif
	  %# do we need to "rotate" RHS ?
	  if 1 == ncol && length(size(RHS)) < 3 \
		&& size(RHS, 2) > 1,
	    RHS = reshape(RHS, [size(RHS, 1), 1, size(RHS, 2)]);
	  endif

	  resu = df_matassign(df, S(2), indc, ncol, RHS);
      endswitch
      
    case '()'
      [indr, nrow, S(1).subs{1}] = df_name2idx(df._name{1}, S(1).subs{1}, \
					       df._cnt(1), 'row');
      [indc, ncol, S(1).subs{2}] = df_name2idx(df._name{2}, S(1).subs{2}, \
				 df._cnt(2), 'column');
      resu = df_matassign(df, S, indc, ncol, RHS);
 
  endswitch
  
  %# disp("end of subasgn"); keyboard
  
endfunction

function df = df_matassign(df, S, indc, ncol, RHS)
  %# auxiliary function: assign the dataframe as if it was a matrix

  if isnull(RHS),
    if 1 == ncol,
      if sum(~strcmp(S.subs, ':')) > 2,
	error("A null assignment can only have one non-colon index.");
      endif
    elseif sum(~strcmp(S.subs, ':')) > 1,
      error("A null assignment can only have one non-colon index.");
    endif
    
    if strcmp(S.subs(1), ':'),  %# removing column/matrix
      RHS = S; RHS.subs(2) = [];
      for indi = 1:ncol, %# loop over columns
	df._data{indc(indi)} = builtin('subsasgn', df._data{indc(indi)}, \
				       RHS, []);
      endfor
      %# remove empty elements
      indi = cellfun('isempty', df._data);
      if any(indi), %# nothing left, remove this column
	df._cnt(2) = df._cnt(2) - sum(indi);
	indi = ~indi; %# vector of kept data
	df._name{2} = df._name{2}(indi);
	df._over{2} = df._over{2}(indi);
	df._type = df._type(indi);
	df._data = df._data(indi);
      endif
    endif
    if strcmp(S.subs(2), ':'),  %# removing rows
      indr = S.subs{1}; 
      if !isempty(df._name{1}),
	df._name{1}(indr, :) = []; 
      endif	
      df._over{1}(indr) = []; df._ridx(indr) = [];
      %# to remove a line, iterate on each column
      for indi = 1:df._cnt(2),
	dummy =  df._data{indi};
	dummy(indr, :) = [];
	df._data{indi} = dummy;
      endfor
      if isa(indr, 'char')
	 df._cnt(1) = 0;
       else
	 df._cnt(1) = df._cnt(1) - length(indr);
       endif
    endif
    dummy = sum(cellfun('size', df._data, 2));
    if dummy != df._cnt(2),
      df._cnt(3) = dummy;
    else
      df._cnt = df._cnt(1:2);
    endif
    return;
  endif

  indc_was_set = ~isempty(indc);
  if ~indc_was_set, %# initial dataframe was empty
    ncol = size(RHS, 2); indc = 1:ncol;
  endif
  indr = S.subs{1, 1}; 
  indr_was_set = ~isempty(indr); 
  %# initial dataframe was empty ?
  if ~indr_was_set || strcmp(indr, ':'),
    if iscell(RHS),
      nrow = max(sum(cellfun('size', RHS, 1)));
    else
      if isvector(RHS),
	if 0 == df._cnt(1),
	  nrow = length(RHS); %# try to produce row vectors
	else
	  nrow = df._cnt(1);  %# limit to df numbner of rows
	endif 
      else
	%# deduce limit from RHS 
      	nrow = size(RHS, 1);
      endif
    endif
    indr = 1:nrow;
  elseif !isempty(indr) && isnumeric(indr),
    nrow = length(indr);
  endif
  rname = cell(0, 0); rname_width = max(1, size(df._name{2}, 2)); 
  ridx = []; cname = rname; ctype = rname;

  if iscell(RHS),
    if (length(indc) == df._cnt(2) && size(RHS, 2) >=  df._cnt(2)) \
	  || 0 == df._cnt(2) || isempty(S.subs{1}),
      %# providing too much information -- remove extra content
      if size(RHS, 1) > 1,
	%# at this stage, verify that the first line doesn't contain
	%# chars only; use them for column names
	dummy = cellfun('class', \
			RHS(1, ~cellfun('isempty', RHS(1, :))), \
			'UniformOutput', false);
	dummy = strcmp(dummy, 'char');
	if all(dummy),
	  if length(df._over{2}) >= max(indc) \
		&& !all(df._over{2}(indc)),
	    warning("Trying to overwrite colum names");
	  endif
	  cname = RHS(1, :).'; RHS = RHS(2:end, :);
	  if ~indr_was_set, 
	    nrow = nrow - 1; indr = 1:nrow;
	  endif
	endif
	%# at this stage, verify that the first line doesn't contain
	%# chars only; use them for column types
	dummy = cellfun('class', \
			RHS(1, ~cellfun('isempty', RHS(1, :))), \
			'UniformOutput', false);
	dummy = strcmp(dummy, 'char');
	if all(dummy),
	  if length(df._over{2}) >= max(indc) \
		&& !all(df._over{2}(indc)),
	    warning("Trying to overwrite colum names");
	  endif
	  ctype = RHS(1, :); RHS = RHS(2:end, :);
	  if ~indr_was_set,
	    nrow = nrow - 1; indr = 1:nrow;
	  endif
	endif
      endif
      
      %# more elements than df width -- try to use the first two as
      %# row index and/or row name
      if size(RHS, 1) > 1,
	dummy = all(cellfun('isnumeric', \
			    RHS(~cellfun('isempty', RHS(:, 1)), 1)));
      else
	dummy =  isnumeric(RHS{1, 1});
      endif
      dummy = dummy && (!isempty(cname) && size(cname{1}, 2) < 1);
      if dummy,
	ridx = cell2mat(RHS(:, 1));
	%# can it be converted to a list of unique numbers ?
	if length(unique(ridx)) == length(ridx),
	  ridx = RHS(:, 1); RHS = RHS(:, 2:end);
	  if length(df._name{2}) == df._cnt(2) + ncol,
	    %# columns name were pre-filled with too much values
	    df._name{2}(end) = [];
	    df._over{2}(end) = [];
	    if size(RHS, 2) < ncol, 
	      ncol = size(RHS, 2); indc = 1:ncol;
	    endif
	  elseif !indc_was_set, 
	    ncol = ncol - 1;  indc = 1:ncol; 
	  endif 
	  if !isempty(cname), cname = cname(2:end); endif
	  if !isempty(ctype), ctype = ctype(2:end); endif
	else
	  ridx = [];
	endif
      endif

      if size(RHS, 2) >  df._cnt(2),
	%# verify the the first row doesn't contain chars only, use them
	%# for row names
	dummy = cellfun('class', \
			RHS(~cellfun('isempty', RHS(:, 1)), 1), \
			'UniformOutput', false);
	dummy = strcmp(dummy, 'char') \
	    && (!isempty(cname) && size(cname{1}, 2) < 1);
	if all(dummy), 
	  if length(df._over{1}) >= max(indr) \
		&& !all(df._over{1}(indr)),
	    warning("Trying to overwrite row names");
	  else
	    rname = RHS(:, 1); 
	  endif
	  rname_width = max([1; cellfun('size', rname, 2)]); 
	  RHS = RHS(:, 2:end); 
	  if length(df._name{2}) == df._cnt(2) + ncol,
	    %# columns name were pre-filled with too much values
	    df._name{2}(end) = [];
	    df._over{2}(end) = [];
	    if size(RHS, 2) < ncol, 
	      ncol = size(RHS, 2); indc = 1:ncol;
	    endif
	  elseif !indc_was_set, 
	    ncol = ncol - 1;  indc = 1:ncol; 
	  endif
	  if !isempty(cname), cname = cname(2:end); endif
	  if !isempty(ctype), ctype = ctype(2:end); endif
	endif
      endif
    endif
  endif
  
  %# perform row resizing now
  if !isempty(indr) && isnumeric(indr),
    if max(indr) > df._cnt(1),
      df = df_pad(df, 1, max(indr)-df._cnt(1), rname_width);
    endif
  endif
  
  if iscell(RHS), %# we must pad on a column-by-column basis
    %# verify that each cell contains a non-empty vector, and that sizes
    %# are compatible
    %# dummy = cellfun('size', RHS(:), 2);
    %# if any(dummy < 1),
    %#   error("cells content may not be empty");
    %# endif
    
    %# dummy = cellfun('size', RHS, 1);
    %# if any(dummy < 1),
    %#   error("cells content may not be empty");
    %# endif
    %# if any(diff(dummy) > 0),
    %#   error("cells content with unequal length");
    %# endif
    %# if 1 < size(RHS, 1) && any(dummy > 1),
    %#   error("cells may only contain scalar");
    %# endif
    
    %# the real assignement
    if 1 == size(RHS, 1), %# each cell contains one vector
      fillfunc = @(x) RHS{x};
      idxOK = logical(indr);
    else %# use cell2mat to pad on a column-by-column basis
      fillfunc = @(x) cell2mat(RHS(:, x));
    endif
    
    indj = 1;
    for indi = 1:ncol,
      if indc(indi) > df._cnt(2),
	%# perform dynamic resizing one-by-one, to get type right
	if isempty(ctype) || length(ctype) < indc(indi),
	  df = df_pad(df, 2, indc(indi)-df._cnt(2), class(RHS{1, indj}));
	else
	  df = df_pad(df, 2, indc(indi)-df._cnt(2), ctype{indj});
	endif
      endif
      if nrow == df._cnt(1),
	%# whole assignement
	try 
	  if size(RHS, 1) <= 1,
	    switch df._type{indc(indi)}
	      case {'char' } %# use a cell array to hold strings
		dummy = RHS(:, indj);
	      case {'double' }
		dummy = fillfunc(indj);
	      otherwise
		dummy = cast(fillfunc(indj), df._type{indc(indi)});
	    endswitch
	  else
	    %# keeps indexes in sync as cell elements may be empty
	    idxOK = ~cellfun('isempty', RHS(:, indj));
	    %# intialise dummy so that it can receive "anything"
	    dummy = [];
	    switch df._type{indc(indi)}
	      case {'char' } %# use a cell array to hold strings
		dummy = RHS(:, indj);
	      case {'double' }
		dummy(idxOK, :) = fillfunc(indj);
	      otherwise
		dummy(idxOK, :) = cast(fillfunc(indj), df._type{indc(indi)});
	    endswitch
	  endif
	catch
	  dummy = \
	      sprintf("Assignement failed for colum %d, of type %s and length %d,\nwith new content\n%s", \
		      indj, df._type{indc(indi)}, length(indr), disp(RHS(:, indj)));
	  error(dummy);
	end_try_catch
	if size(dummy, 1) < df._cnt(1),
	  dummy(end+1:df._cnt(1), :) = NA;
	endif
      else
	%# partial assignement -- extract actual data and update
	dummy = df._data{indc(indi)}; 
	try     
	  switch df._type{indc(indi)}
	    case {'char' } %# use a cell array to hold strings
	      dummy(indr, 1) = RHS(:, indj);
	    case {'double' }
	      dummy(indr, :) = fillfunc(indj);
	    otherwise
	      dummy(indr, :) = cast(fillfunc(indj), df._type{indc(indi)});
	  endswitch
	catch
	  dummy = \
	      sprintf("Assignement failed for colum %d, of type %s and length %d,\nwith new content\n%s", \
		      indj, df._type{indc(indi)}, length(indr), disp(RHS(:, indj)));
	  error(dummy);
	end_try_catch
      endif
      df._data{indc(indi)} = dummy; indj = indj + 1;
    endfor
    
  else 
    %# RHS is either a numeric, either a df
    if any(indc > df._cnt(2)),
       df = df_pad(df, 2, max(indc-df._cnt(2)), class(RHS));
    endif
    if isa(RHS, 'dataframe'),
      for indi = 1:length(indc),
	if 1 == size(RHS._data{indc(indi)}, 2),
	  if strcmp(df._type(indc(indi)), \
		    RHS._type(indc(indi))),
	    df._data{indc(indi)}(indr, 1)  = RHS._data{indc(indi)};
	  else
	    df._data{indc(indi)}(indr, 1)  = cast(RHS._data{indc(indi)}, \
						  df._type(indc(indi)));
	  endif
	else
	  if strcmp(df._type(indc(indi)), \
		    RHS._type(indc(indi))),
	    df._data{indc(indi)}(indr, :)  = RHS._data{indc(indi)};
	  else
	    df._data{indc(indi)}(indr, :)  = cast(RHS._data{indc(indi)}, \
						  df._type(indc(indi)));
	  endif
	endif
      endfor
      if 1 == size(RHS._ridx, 2)
	df._ridx(indr, :) = NA;
	df._ridx(indr, 1) = RHS._ridx;
      else
	df._ridx(indr, :) = RHS._ridx;
      endif
      df._name{1}(indr) = RHS._name{1};
      df._over{1}(indr) = RHS._over{1};
    else
      %# RHS is homogenous, pad at once
      S.subs(2) = []; %# ignore 'column' dimension
      if isvector(RHS), %# scalar - vector
	if isempty(S.subs),
	  fillfunc = @(x, y) RHS;
	else 
	  if length(indc) > 1 && length(RHS) > 1,
	    %# set a row from a vector
	    fillfunc = @(x, y) builtin('subsasgn', x, S, RHS(y));
	  else   
	    fillfunc = @(x, y) builtin('subsasgn', x, S, RHS);
	  endif
	endif
	for indi = 1:length(indc),
	  df._data{indc(indi)} = fillfunc(df._data{indc(indi)}, indi);
	endfor
      else %# 2D - 3D matrix
	%# rotate slices in dim 1-3 to slices in dim 1-2
	if isempty(S.subs{1}),
	  fillfunc = @(x, y) squeeze(RHS(:, y, :));
	else
	  fillfunc = @(x, y) builtin('subsasgn', x, S, squeeze(RHS(:, y, :)));
	endif
	for indi = 1:length(indc),
	  %# disp('line 454 '); keyboard
	  df._data{indc(indi)} = fillfunc(df._data{indc(indi)}, indi);
	endfor
      endif
      if indi < size(RHS, 2),
	warning(' not all columns of RHS used');
      endif
    endif
  endif

  %# adjust ridx and rnames, if required
  if !isempty(ridx),
    dummy = df._ridx;
    if 1 == size(RHS, 1),
      dummy(indr) = ridx{1};
    else
      for indi = 1:nrow,
	dummy(indr(indi)) = ridx{indi};
      endfor
    endif
    if length(unique(dummy)) != length(dummy), %# || \
	  %# any(diff(dummy) <= 0),
      error("row indexes are not unique or not ordered");
    endif
    df._ridx = dummy;
  endif
  
  if !isempty(rname) && (length(df._over{1}) < max(indr) || \
	all(df._over{1}(indr))),
    df._name{1}(indr, 1) = rname;
    df._over{1}(1, indr) = false;
  endif
  if !isempty(cname) && (length(df._over{2}) < max(indc) || \
	all(df._over{2}(indc))),
    df._name{2}(indc, 1) = cname;
    df._over{2}(1, indc) = false;
  endif
  
  dummy = sum(cellfun('size', df._data, 2));
  if (dummy > df._cnt(2)) || length(df._cnt) > 2,
    df._cnt(3) = dummy;
  endif

  %# catch
  %#   dummy = lasterr();
  %#   if isempty(dummy),
  %# 	error("Not enough values in RHS");
  %#   else
  %# 	error(dummy);
  %#   endif
  %# end_try_catch
  %# else
  %#   keyboard
  %#   error("either row, either column index empty  - should not happen");
  %# endif
  
endfunction
