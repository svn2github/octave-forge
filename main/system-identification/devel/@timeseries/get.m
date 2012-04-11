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
%% @deftypefn {Function File} {@var{field} = } get (@var{obj}, @var{fieldname})
%% Get the value of a field of the timeseries object.
%%
%% If @var{fieldname} is a cell, it returns a structure containing the fields
%% retrieved.
%%
%% @end deftypefn

function field = get (obj, fieldname)

  if !iscell (fieldname)
    fieldname = {fieldname};
  end

  tf        = ismember (fieldname, fieldnames(obj));
  not_found = {fieldname{!tf}};

  if !isempty (not_found)
    msg = @(x) warning("Field '%s' not found in object timeseries.\n",x);
    cellfun (msg, not_found);
  end

  fieldname = {fieldname{tf}};
  func      = @(x) getfield (struct (obj), x);
  f         = cellfun (func, fieldname, 'UniformOutput', false);
  field     = cell2struct (f, fieldname, 2);

  if numel(fieldname) == 1
    field = field.(fieldname{1});
  end
endfunction
