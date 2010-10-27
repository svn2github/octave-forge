function resu = subsref(df, S)
  %# function resu = subsref(df, S)
  %# This function returns a subpart of a dataframe. It is invoked when
  %# calling df.field, df(value), or df{value}. In case of fields,
  %# returns either the content of the container with the same name,
  %# either the column with the same name, priority being given to the
  %# container. In case of range, selection may occur on name or order
  %# (not rowidx for rows). If the result is homogenous, it is
  %# downclassed. In case an extra field is given, is it used to
  %# determine the class of the return value. F.i., 
  %# df(1, 2, 'dataframe') 
  %# does not return a scalar but a dataframe, keeping all the meta-information

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
  %# $Id: subsref.m 1034 2010-08-03 16:22:09Z dupuis $
  %#
  
  %# what kind of object should we return ?
  asked_output_type = ''; asked_output_format = [];

  if strcmp(S(1).type, '.'), %# struct access
    indi = strmatch(S(1).subs, 'as');
    if ~isempty(indi) 
      if length(S) < 2 || ~strcmp(S(2).type, '.'),
	error("The output format qualifier 'as' must be followed by a type");
      endif
      asked_output_format = S(2).subs; S = S(3:end);
    else
      indi = strmatch(S(1).subs, char('df', class(df)));
      if ~isempty(indi),
	%# requiring a dataframe
	if 1 == indi, %# 'df' = short for 'dataframe'
	  asked_output_type = 'dataframe';
	else
	  asked_output_type =  S(1).subs;
	endif
	S = S(2:end);
	if isempty(S) && strcmp(asked_output_type, class(df)),
	  resu = df; return; 
	endif
      else
	indi = strmatch(S(1).subs, 'cell');
	if ~isempty(indi),
	  asked_output_type =  S(1).subs;
	  S = S(2:end);
	else
	  %# access as a pseudo-struct
	  resu = struct(df); %# avoid recursive calls  
	  if 1 == strfind(S(1).subs, '_'), %# its an internal field name
	    %# FIXME: this should only be called from class members and friends
	    %# FIXME -- in case many columns are asked, horzcat them
	    resu = horzcat(builtin('subsref', resu, S));
	  else
	    %# direct access through the exact column name
	    indi = strmatch(S(1).subs, resu._name{2}, "exact");
	    if ~isempty(indi),
	      resu = df._data{indi}; %# extract colum;
	      if strcmp(df._type{indi}, 'char') ...
		    && 1 == size(df._data{indi}, 2),
		resu = char(resu);
	      endif 
	      if length(S) > 1,
		dummy = S(2:end); S = S(1);
		switch dummy(1).type
		  case '()'
		    if isa(dummy(1).subs{1}, "char"),
		      [indr, nrow, dummy(1).subs{1}] = ...
			  df_name2idx(df._name{1}, dummy(1).subs{1}, df._cnt(1), 'row');
		    endif
		    resu = builtin('subsref', resu, dummy);
		  otherwise
		    error("Invalid column access");
		endswitch
	      endif
	    else %# access of an attribute
	      dummy = S(2:end); S = S(1);
	      postop = ''; further_deref = false;
	      %# translate the external to internal name
	      switch S(1).subs
		case "rownames"
		  S(1).subs = "_name";
		  S(2).type = "{}"; S(2).subs{1}= 1;
		  postop = @(x) char(x); 
		case "colnames"
		  S(1).subs = "_name";
		  S(2).type = "{}"; S(2).subs{1}= 2;
		  postop = @(x) char(x); further_deref = true;
		case "rowcnt"
		  S(1).subs = "_cnt";
		  S(2).type = "()"; S(2).subs{1}= 1;
		case "colcnt"
		  S(1).subs = "_cnt";
		  S(2).type = "()"; S(2).subs{1}= 2;
		case "rowidx"
		  S(1).subs = "_ridx"; further_deref = true;
		case "types"	%# this one should be accessed as a matrix
		  S(1).subs = "_type"; further_deref = true;
		otherwise
		  error("Unknown column name: %s", S(1).subs);
	      endswitch
	      if !isempty(dummy),
		if ~further_deref,
		  error("Invalid sub-dereferencing");
		endif
		if isa(dummy(1).subs{1}, "char"),
		  [indc, ncol, dummy(1).subs{1}] = ...
		      df_name2idx(df._name{2}, dummy(1).subs{1}, ...
				  df._cnt(2), 'column');
		  if isempty(indc), 
		    %# should be already catched  inside df_name2idx
		    error("Unknown column name: %s",  dummy(1).subs{1});
		  endif
		endif
		if !strcmp(dummy(1).type, '()'),
		  error("Invalid internal field name sub-access, use () instead");
		endif
	      endif
	      %# workaround around bug 30921, fixed in hg changeset 10937
	      %# if !isempty(dummy),
	      S = [S dummy];
	      %# endif
	      resu = builtin('subsref', resu, S);
	      if !isempty(postop),
		resu = postop(resu);
	      endif
	    endif
	  endif
	  return
	endif
      endif
    endif
  endif
  
  %#  disp('line 103 '); keyboard

  IsFirst = true;
  while 1, %# avoid recursive calls on dataframe sub-accesses
    
    %# a priori, performs whole accesses
    nrow = df._cnt(1); indr = 1:nrow;
    ncol = df._cnt(2); indc = 1:ncol;
   
    %# iterate over S, sort out strange constructs as x()()(1:10, 1:4)
    while length(S) > 0,
      if strcmp(S(1).type, '{}'),
	if !IsFirst || !isempty(asked_output_format),
	  error("Illegal dataframe dereferencing");
	endif
	[asked_output_type, asked_output_format] = deal('cell');
      elseif !strcmp(S(1).type, '()'),
	%#   disp(S); keyboard
	error("Illegal dataframe dereferencing");
      endif
      if isempty(S(1).subs), %# process calls like x()
	if isempty(asked_output_type),
	  asked_output_type = class(df);
	endif
	if length(S) <= 1, 
	  if strcmp(asked_output_type, class(df)),
	    resu = df; return; %# whole access without conversion
	  endif
	  break; %# no dimension specified -- select all, the
	  %# asked_output_type was set in a previous iteration
	else
	  %# avoid recursive calls
	  S = S(2:end); 
	  IsFirst = false; continue;
	endif      
      endif
      %# generic access
      if isempty(S(1).subs{1}),
	error('subsref: first dimension empty ???');
      endif
      if length(S(1).subs) > 1,
	if isempty(S(1).subs{2}),
	  error('subsref: second dimension empty ???');
	endif
	[indr, nrow, S(1).subs{1}] = ...
	    df_name2idx(df._name{1}, S(1).subs{1}, df._cnt(1), 'row');      
	if !isa(indr, 'char') && max(indr) > df._cnt(1),
	  error("Accessing dataframe past end of lines");
	endif
	[indc, ncol, S(1).subs{2}] = ...
	    df_name2idx(df._name{2}, S(1).subs{2}, df._cnt(2), 'column');
	if max(indc) > df._cnt(2),
	  error("Accessing dataframe past end of columns");
	endif
      else
	%# one single dim -- probably something like df(:)
	switch class(S(1).subs{1})
	  case {'char'} %# one dimensional access, disallow it if not ':' 
	    if strcmp(S(1).subs{1}, ':'),
	      fullindr = []; fullindc = [];	 
	    else
	      error(["Accessing through single dimension and name " ...
		     S(1).subs{1} " not allowed\n-- use variable(:, 'name') instead"]);
	    endif
	  otherwise
	    [fullindr, fullindc] = ind2sub(df._cnt, S(1).subs{1});
	    indr = unique(fullindr); indc = unique(fullindc);
	    nrow = length(indr); ncol = length(indc);
	    if !isempty(asked_output_type) && ncol > 1,
	      %# verify that the extracted values form a square matrix
	      dummy = zeros(indr(end), indc(end));
	      for indi = 1:ncol,
		indj = find(fullindc == indc(indi));
		dummy(fullindr(indj), indc(indi)) = 1;
	      endfor
	      dummy = dummy(indr(1):indr(end), indc(1):indc(end));
	      if any(any(dummy!= 1)),
		error("Vector-like selection is not rectangular for the asked output type");
	      else
		fullindr = []; fullindc = [];
	      endif
	    endif 
	endswitch
      endif
      %# at this point, S is either empty, either contains further dereferencing
      break;
    endwhile
    
    %# we're ready to extract data
    %# disp('line 211 '); keyboard
    
    if !isempty(asked_output_type),
      %# override the class of the return value
      output_type = asked_output_type;
    else
      %# can the data be merged ?
      output_type = df._type{indc(1)}; 
      dummy = isnumeric(df._data{indc(1)}); 
      for indi = 2:ncol,
	dummy = dummy & isnumeric(df._data{indc(indi)});
	if ~strcmp(output_type, df._type{indc(indi)}),
	  if dummy, continue; endif
	  %# unmixable args -- falls back to type of parent container 
	  error("Selected columns not compatible with cat() -- use 'cell' as output format");
	  %# dead code -- suppress previous line for switching automagically the output format to df
	  output_type = class(df); 
	  break;
	endif
      endfor
    endif
    if any(strcmp({output_type, asked_output_type}, class(df))),
      if !isempty(S) && 1 == length(S(1).subs),
	if ncol > 1 
	  if strcmp(asked_output_type, class(df))
	    error("Vector-like access not implemented for 'dataframe' output format");
	  endif
	  error("Selected columns not compatible with cat() -- use 'cell' as output format");
	endif
      endif
    endif
    
    indt = {}; %# in case we have to mix matrix of different width
    if !isempty(S) && length(S(1).subs) > 1, %# access-as-matrix
      if  length(S(1).subs) > 2,
	inds = S(1).subs{3};
	if isa(inds, 'char'),
	  nseq = max(cellfun('size', df._data(indc), 2));
	  indt(1, 1:df._cnt(2)) = inds;
	else
	  %# generate a specific index for each column
	  nseq = length(inds);
	  dummy = cellfun('size', df._data(indc), 2);
	  indt(1, 1:df._cnt(2)) = inds;
	  indt(1==dummy) = 1; 
	endif
      elseif all(cellfun('isclass', S(1).subs, 'char')),
	inds = ':'; indt(1, 1:df._cnt(2)) = inds;
	nseq = max(cellfun('size', df._data(indc), 2));
      else
	inds = 1; indt(1, 1:df._cnt(2)) = inds; nseq = 1;
      endif
    endif
    
    if strcmp(output_type, class(df)),
      %# disp('line 295 ')
      %# export the result as a dataframe
      resu = dataframe([]);
      resu._cnt(1) = nrow; resu._cnt(2) = ncol;
      for indi = 1:ncol,
	resu._data{indi} =  df._data{indc(indi)}...
	    (indr, indt{indc(indi)}); 
	resu._name{2}(indi, 1) = df._name{2}(indc(indi));
	resu._over{2}(1, indi) = df._over{2}(indc(indi));
	resu._type{indi} = df._type{indc(indi)};
      endfor
      resu._ridx = df._ridx(indr, inds); 
      if length(df._name{1}) >= max(indr),
	resu._name{1}(1:nrow, 1) = df._name{1}(indr);
	resu._over{1}(1, 1:nrow) = df._over{1}(indr);
      endif
      dummy = sum(cellfun('size', resu._data, 2));
      if (dummy > resu._cnt(2)),
	resu._cnt(3) = dummy;
      else
	resu._cnt = resu._cnt(1:2);
      endif
      if length(S) > 1, %# perform further access, if required
	df = resu;
	S = S(2:end); 	%# avoid recursive calls
	continue; 	%# restart the loop around line 150
      endif
      return;
      
    elseif strcmp(output_type, 'cell'),
      %# export the result as a cell array
      if isempty(asked_output_format),
	resu = cell(2+nrow, 2+ncol); resu(1:end, 1:2) = {''};
	resu(2, 3:end) = df._type(indc);			%column type
	row_offs = 2; col_offs = 2;
	for indi = 1:ncol,
	  resu{1, 2+indi} = df._name{2}{indc(indi)}; 		% column name
	endfor
	resu(3:end, 1) =  mat2cell(df._ridx(indr), ones(nrow, 1), 1);
	if length(df._name{1}) >= max(indr),
	  resu(3:end, 2) = df._name{1}{indr};
	endif	  	
      else
	resu = cell(nrow, ncol);
	row_offs = 0; col_offs = 0;
      endif
      for indi = 1:ncol,
	switch df._type{indc(indi)}				% cell content
	  case {'char' }
	    dummy = cellstr(df._data{indc(indi)}(indr, :));
	    resu(1+row_offs:end, indi+col_offs) = dummy;
	  otherwise
	    dummy = df._data{indc(indi)}(indr, :);
	    resu(1+row_offs:end, indi+col_offs) = \
		mat2cell(dummy, ones(nrow, 1), 1);
	endswitch
      endfor

      %# did we arrive here by x.cell ?
      if 0 == length(S), return; endif
      
      %# perform the selection on the content, keeping the header
      if length(S) > 1, %# perform further access, if required
	if ~strcmp(S(2).type, '()'),
	  error("Illegal dataframe-as-cell sub-dereferencing");
	endif
	if !isempty(asked_output_format),
	  resu = builtin('subsref', resu, S(2:end));
	else	
	  if length(S(2).subs) != 1,
	    %# normal, two-dimensionnal access apply the selection on the
	    %# zone containing the data
	    dummy = S;
	    if !isempty(dummy(2).subs),
	      dummy(2).subs{2} = ':';
	    endif
	    resuf = cat(2, ...
			%# reselect indexes
			builtin('subsref', resu(3:end, 1),
				dummy(2:end)), ...
			%# reselect rownames
			builtin('subsref', resu(3:end, 2),
				dummy(2:end)), ...
			%# extract - reorder - whatever
			builtin('subsref', resu(3:end, 3:end), S(2:end))
			...
			);
	    dummy = S;
	    if !isempty(dummy(2).subs),
	      dummy(2).subs{1} =  [1 2];
	    endif
	    resuf =  cat(1, ...
			 %# reselect column names and types
			 [cell(2, 2) builtin('subsref', resu(1:2,
							     3:end), ...
					     dummy(2:end))], ...
			 resuf ...
			 );
	    resuf(1:2, 1:2) = {''}; resu = resuf;
	  else
	    %# one dimensionnal access of the whole 2D cell array -- you
	    %# asked it, you got it
	    resu = builtin('subsref', resu(:), S(2:end));
	    if !isa(S(2).subs{1}, 'char') ...
		  && size(S(2).subs{1}, 2) > 1,
	      resu = resu.';
	    endif
	  endif
	endif
      elseif 1 == length(S(1).subs),
	resu = resu(:);
	if !isa(S(1).subs{1}, 'char') ...
	      && size(S(1).subs{1}, 2) > 1,
	  resu = resu.';
	endif
      endif
      return; %# no more iteration required
  
    else
      %# export the result as a vector/matrix. Rules:
      %# * x(:, :, :) returns a 3D matrix 
      %# * x(:, n:m, :) returns a 3D matrix 
      %# * x(:, :) returns a horzcat of the third dimension 
      %# * x(:, n:m) select only the first sequence 
      %# * x(:) returns a vertcat of the columns of x(:, :)
      %# disp('line 403 '); keyboard
      if length(S(1).subs) > 1, %# access-as-matrix
	if ~isempty(asked_output_format), %# force a conversion
	  if strmatch(asked_output_format, 'cell'),
	    extractfunc = @(x) mat2cell(df._data{indc(x)}, \
					ones(df._cnt(1), 1));
	  else
	    extractfunc = @(x) cast(df._data{indc(x)}, asked_output_format);
	  endif
	else %# let the usual downclassing occur
	  extractfunc = @(x) df._data{indc(x)};
	endif
	dummy = extractfunc(1);
	if ncol > 1,
	  %# dynamic allocation with the final type
	  if size(dummy, 2) > 1,
	    resu = repmat(dummy(indr, inds(1)), [1 ncol nseq]);
	    %# "turn" the extracted matrix
	    resu(:, 1, :) = dummy(indr, inds);
	  else
	    resu = repmat(dummy(indr), [1 ncol nseq]);
	  endif
	  for indi = 2:ncol,
	    dummy = extractfunc(indi);
	    if 1 == size(dummy, 2),
	      if 1 == nseq,
		resu(:, indi) = dummy(indr);
	      else
		resu(:, indi, :) = repmat(dummy(indr),  [1 1 nseq]);
	      endif
	    else
	      %# "turn" the extracted matrix
	      resu(:, indi, :) = dummy(indr, inds);
	    endif
	  endfor
	else
	  if strcmp(df._type{indc(1)}, 'char'),
	    resu = char(dummy(indr, inds));
	  else
	    resu = dummy(indr, inds);
	  endif
	endif
	if 2 == length(S(1).subs) ...
	      && all(cellfun('isclass', S(1).subs, 'char')),
	  resu = reshape(resu, nrow, ncol*nseq);
	endif
      else %# access-as-vector
	if !isempty(fullindr),
	  indj = find(fullindc == indc(1));
	  resu = df._data{indc(1)}(fullindr(indj));
	  switch df._type{indc(1)}
	    case {'char'}
	      for indi = 2:ncol,
		indj = find(fullindc == indc(indi));
		resu = char(resu, df._data{indc(indi)}(fullindr(indj)));
	      endfor
	    otherwise
	      for indi = 2:ncol,
		indj = find(fullindc == indc(indi));
		resu = cat(1, resu, \
			   df._data{indc(indi)}(fullindr(indj)));
	      endfor
	  endswitch
	else
	  disp('line 389') %# FIXME
	  resu = df._data{indc(1)}(indr);
	  switch df._type{indc(1)}
	    case {'char'}
	      for indi = 2:ncol,
		resu = char(resu, df._data{indc(indi)}(indr));
	      endfor
	    otherwise
	      for indi = 2:ncol,
		resu = cat(1, resu, df._data{indc(indi)}(indr));
	      endfor
	  endswitch
	endif
	if !isa(S(1).subs{1}, 'char') ...
	      && size(S(1).subs{1}, 2) > 1,
	  resu = resu.';
	endif
      endif
      if length(S) > 1, %# perform further access, if required
	 %# disp('line 442 '); keyboard
	resu = builtin('subsref', resu, S(2:end));
      endif
    endif
    return; %# no more iteration required
  endwhile

  %# disp("line 343 !?!"); keyboard
  return  
  
endfunction
