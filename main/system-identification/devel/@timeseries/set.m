%% Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} set (@var{obj}, @var{fieldname},@var{value})
%% @deftypefnx {Function File} set (@var{obj}, @var{fieldname},@var{value},@dots)
%% Set the value of a field of the timeseries object.
%%
%% If @var{fieldname} is a cell so must be @var{value}, it sets the values of
%% all matching fields.
%%
%% The function also accepts property-value pairs.
%%
%% @end deftypefn

function obj = set (obj, varargin)

  if numel (varargin) == 2 && iscell (varargin{1}) && iscell (varargin{2})
  %% The arguments are two cells, expecting fields and values.
    fieldname = varargin{1};
    value = varargin{2};
  else
    fieldname = {varargin{1:2:end}};
    value = {varargin{2:2:end}};
  end


  if numel (fieldname) != numel (value)
    error ('timeseries:set:InvalidArgument', ...
           'FIELDS and VALUES must have the same number of elements.');
  end

  tf        = ismember (fieldname, fieldnames(obj));
  not_found = {fieldname{!tf}};

  if !isempty (not_found)
    msg = @(x) warning("Field '%s' not found in object timeseries.\n",x);
    cellfun (msg, not_found);
  end

  fieldname = {fieldname{tf}};
  value = {value{tf}};

  %% Check data consistency
  [tf idx] = ismember ({'Time','Data'},fieldname);
  if tf(1) && !tf(2)
    if length(value{idx(1)}) != size(obj.Data , 1)
      error ('timeseries:set:InvalidArgument', ...
             ["Time vector must have lenght equal to the first dimension" ...
              "of Data (%d)\n"], ...
               size(obj.Data , 1));
    end
  elseif !tf(1) && tf(2)
    if length(obj.Time) != size(value{idx(2)}, 1)
      warning ('timeseries:set:InvalidArgument', ...
               ["Data vector of different size as Time vector (%d)." ...
                " Time vector will be reseted."], length(obj.Time));
      fieldname{end+1} = 'Time';
      value{end+1} = 0:1:(size(value{idx(2)}, 1)-1);
    end
  elseif tf(1) && tf(2)
    if length(value{idx(1)}) != size(value{idx(2)}, 1)
      error ('timeseries:set:InvalidArgument', ...
             ["Time vector must have lenght equal to the first dimension" ...
              "of Data (%d)\n"], ...
               size(value{idx(2)}, 1));
    end
  end

  if tf(1)
    fieldname{end+1} = 'Length';
    value{end+1} = length(value{idx(1)});
  end

  %% Set values
  % Can't avoid the loop with cellfun, cause the handle to cellfun is treated as
  % a external function.
  for i = 1:numel(fieldname)
   obj.(fieldname{i}) = value{i};
  end

endfunction
