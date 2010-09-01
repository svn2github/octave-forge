function df = dataframe(x = [], varargin)
  
  %# -*- texinfo -*-
  %#  @deftypefn {Function File} @var{df} = dataframe(@var{x = []}, ...)
  %# This is the default constructor for a dataframe object, which is
  %# similar to R 'data.frame'. It's a way to group tabular data, then
  %# accessing them either as matrix or by column name.
  %# Input argument x may be: @itemize
  %# @item a dataframe => use @var{varargin} to pad it with suplemental
  %# columns
  %# @item a matrix => create column names from input name; each column
  %# is used as an entry
  %# @item a cell matrix => try to infer column names from the first row,
  %#   and row indexes and names from the two first columns;
  %# @item a file name => import data into a dataframe;
  %# @item a matrix of char => initialise colnames from them.
  %# @item a two-element cell: use the first as column as column to
  %# append to,  and the second as initialiser for the column(s)
  %# @end itemize
  %# If called with an empty value, or with the default argument, it
  %# returns an empty dataframe which can be further populated by
  %# assignement, cat, ... If called without any argument, it should
  %# return a dataframe from the whole workspace. 
  %# @*Variable input arguments are first parsed as pairs (options, values).
  %# Recognised options are: @itemize
  %# @item rownames : take the values as initialiser for row names
  %# @item colnames : take the values as initialiser for column names
  %# @item seeked : a filed value which triggers start of processing.
  %# Each preceeding line is silently skipped. Default: none
  %# @item unquot: a logical switch telling wheter or not strings should
  %# be unquoted before storage, default = true;
  %# @end itemize
  %# The remaining data are concatenanted (right-appended) to the existing ones.
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
  %# $Id: dataframe.m 1036 2010-08-03 16:24:01Z dupuis $
  %#

if 0 == nargin
  disp('FIXME -- should create a dataframe from the whole workspace')
  return
endif

if isempty(x),
  %# default constructor: initialise the fields in the right order
  df._cnt = [0 0];
  df._name = {cell(0, 1), cell(1, 0)}; %# rows - cols 
  df._over = cell(1, 2);
  df._ridx = [];  
  df._data = cell(0, 0); 
  df._type = cell(0, 0);
  df = class(df, 'dataframe');
  return
endif

if isa(x, 'dataframe')
  df = x;
elseif isa(x, 'struct'),
  df = class(x, 'dataframe'); return
else
  df = dataframe([]); %# get the right fields
endif

seeked = []; unquot = true; 

if length(varargin) > 0,
  indi = 1;
  %# loop over possible arguments
  while indi <= size(varargin, 2),
    switch(varargin{indi})
      case 'rownames'
	switch class(varargin{indi+1})
	  case {'cell'}
	    df._name{1} = varargin{indi+1};
	  case {'char'}
	    df._name{1} = cellstr(varargin{indi+1});
	  otherwise
	    df._name{1} = cellstr(num2str(varargin{indi+1}));
	endswitch
	df._over{1}(1, 1:length(df._name{1})) = false;
	df._cnt(1) = size(df._name{1}, 1);
	df._ridx = (1:df._cnt(1))';
	varargin(indi:indi+1) = [];
      case 'colnames'
	switch class(varargin{indi+1})
	  case {'cell'}
	    df._name{2} = varargin{indi+1};
	  case {'char'}
	    df._name{2} = cellstr(varargin{indi+1});
	  otherwise
	    df._name{2} = cellstr(num2str(varargin{indi+1}));
	endswitch
	%# detect assignment - functions calls - ranges
	dummy = cellfun('size', cellfun(@(x) strsplit(x, ':=('), df._name{2}, \
					"UniformOutput", false), 2);
	if any(dummy > 1),
	  warning('dataframe colnames taken literally and not interpreted');
	endif
	df._over{2}(1, 1:length(df._name{2})) = false;
	varargin(indi:indi+1) = [];
      case 'seeked',
	seeked = varargin{indi + 1};
	varargin(indi:indi+1) = [];
      case 'unquot',
	unquot = varargin{indi + 1};
	varargin(indi:indi+1) = [];
      otherwise %# FIXME: just skip it for now
	indi = indi + 1;
    endswitch
  endwhile
endif

indi = 0; 
while indi <= size(varargin, 2),
  indi = indi + 1;
  if ~isa(x, 'dataframe')
    if isa(x, 'char') && size(x, 1) < 2,
      %# read the data frame from a file
      try
	x = load(tilde_expand(x));
      catch
        UTF8_BOM = char([0xEF 0xBB 0xBF]);
	unwind_protect
	  fid = fopen(tilde_expand(x));
	  dummy = fgetl(fid);
	  if !strcmp(dummy, UTF8_BOM),
	    frewind(fid);
	  endif
	  in = fscanf(fid, "%c"); %# slurps everything
	unwind_protect_cleanup
	  fclose(fid);
	end_unwind_protect
	lines = regexp(in,'(^|\n)([^\n]+)', 'match'); %# cut into lines
	%# a field either starts at a word boundary, either by + - . for
	%# a numeric data, either by ' for a string. 
	content = cellfun(@(x) regexp(x, '(\b|[-+\.''])[^,]+(''|\b)', 'match'), \
			  lines, 'UniformOutput', false); %# extract fields
	indl = 1; indj = 1; %# disp('line 151 '); keyboard
	if ~isempty(seeked),
	  while indl <= length(lines),
	    dummy = content{indl};
	    if strcmp(dummy{1}, seeked)
	      break;
	    endif
	    indl = indl + 1;
	  endwhile
	else
	  dummy = content{indl};
	endif
	x = cell(1+length(lines)-indl, size(dummy, 2)); 
	while indl <= length(lines),
	  dummy = content{indl};
	  %# try to convert to float
	  the_line = cellfun(@(x) sscanf(x, "%f"), dummy, ...
			     'UniformOutput', false);
	  for indk = 1: size(the_line, 2),
	    if isempty(the_line{indk}) || any(size(the_line{indk}) > 1), 
	      %#if indi > 1 && indk > 1, disp('line 117 '); keyboard; endif
	      if unquot,
		try
		  x(indj, indk) = regexp(dummy{indk}, '[^''].*[^'']', 'match'){1};
		catch
		  %# if the previous test fails, try a simpler one
		  in = regexp(dummy{indk}, '[^'']+', 'match');
		  if !isempty(in),
		    x(indj, indk) = in{1};
		  else
		    x(indj, indk) = [];
		  endif
		end_try_catch
	      else
		x(indj, indk) = dummy{indk}; %# no conversion possible
	      endif
	    else
	      x(indj, indk) = the_line{indk}; 
	    endif
	  endfor
	  indl = indl + 1; indj = indj + 1;
	endwhile
	clear UTF8_BOM fid in lines indl the_line content
      end_try_catch
    endif
    
    %# fallback, avoiding a recursive call
    idx.type = '()';
    indj = df._cnt(2)+(1:size(x, 2));
    
    if iscell(x),
      if 2 == length(x),
	%# use the intermediate value as destination column
	[indc, ncol] = df_name2idx(df._name{2}, x{1}, df._cnt(2), "column");
	if ncol != 1,
	  error(["With two-elements cell, the first should resolve " ...
		 "to a single column"]);
	endif
	try
	  dummy = cellfun('class', x{2}(2, :), 'UniformOutput', false);
	catch
	  dummy = cellfun('class', x{2}(1, :), 'UniformOutput', false);
	end_try_catch
	df = df_pad(df, 2, [length(dummy) indc], dummy);
	x = x{2}; 
	indj =  indc + (1:size(x, 2)); 	%# redefine target range
      else
	if isa(x{1}, 'cell'),
	  x = x{1}; %# remove one cell level
	endif
      endif
      if length(df._name{2}) < indj(1) || isempty(df._name{2}(indj)),
	[df._name{2}(indj, 1),  df._over{2}(1, indj)] ...
	    = df_colnames(inputname(indi), indj);
      endif
      %# allow overwriting of column names
      df._over{2}(1, indj) = true;
    else
      if length(df._name{2}) < indj(1) || isempty(df._name{2}(indj)),
	[df._name{2}(indj, 1),  df._over{2}(1, indj)] ...
	    = df_colnames(inputname(indi), indj);
      endif
    endif
    idx.subs = {'', indj};
    %# use direct assignement
    df = subsasgn(df, idx, x);
  elseif indi > 1,
    error('Concatenating dataframes: use cat instead');
  endif

  try
    %# loop over next variable argument
    x = varargin{1, indi};   
  catch
    %#   disp('line 197 ???');
  end_try_catch

endwhile

endfunction

function [x, y] = df_colnames(base, num)
  %# small auxiliary function to generate column names. This is required
  %# here, as only the constructor can use inputname()
  if any([index(base, "=")]),
    %# takes the left part as base
    x = strsplit(base, "=");
    x = deblank(x{1}); y = false;
  elseif any([index(base, '''')]),
    %# base is most probably a filename
    x =  regexp(base, '[^''].*[^'']', 'match'){1}; y = true;
  elseif any([index(base, "(") index(base, ":")]),
    x = 'X'; y = true; %# this is a default value, may be changed
  else
    x = base; y = false;
  endif

  if numel(num) > 1,
    x = repmat(x, numel(num), 1);
    x = cstrcat(x, strjust(num2str(num(:)), 'left'));
    y = repmat(y, 1, numel(num));
  endif
  
  x = cellstr(x);
    
endfunction
