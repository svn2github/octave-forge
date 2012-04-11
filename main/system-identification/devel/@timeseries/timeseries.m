## Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.


## -*- texinfo -*-
## @deftypefn {Function File} {@var{obj} =} timeseries ()
## @deftypefnx {Function File} {@var{obj} =} timeseries (@var{data})
## @deftypefnx {Function File} {@var{obj} =} timeseries (@var{data},@var{time})
## @deftypefnx {Function File} {@var{obj} =} timeseries (@dots,@var{Property},@var{Value})
## Create object of the timeseries class.
##
## If no input argument is provided the object is empty.
## If the @var{data} argument is present, creates the timeseries object using the specified data.
## If @var{data} and @var{time} are provided, creates the timeseries object using the specified data and time.
## Property-value pairs can be specified to set several properties of the object.
##
## @end deftypefn

function timeseries = timeseries(Data=[],Time=[],varargin)

  timeseries = struct ();

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "timeseries";
  parser = addParamValue (parser,'Data', Data, @ismatrix);
  parser = addParamValue (parser,'DataInfo', ...
                                  struct ('Unit', '', 'UserData','',...
                                  'Interpolation', ...
                                  struct ('Fhandle', [], 'Name', 'linear')), ...
                          @isstruct);
  func = @(x) arrayfun ( ...
            @(x)sprintf('Series %d',x), 1:size(Data,2), 'UniformOutput', false);
  parser = addParamValue (parser,'Name', func(), @iscell);
  parser = addParamValue (parser,'Time', Time, @ismatrix);
  parser = parse(parser,varargin{:});

  %% Data
  %% Timeseries data, where each data sample corresponds to a specific time
  %% The data can be a scalar, a vector, or a multidimensional array. The first
  %% dimension of the data must align with Time (this is less general than MATLAB implementation).
  %% By default, NA represent missing or unspecified data.
  %% Though it is not handled properly yet.
  timeseries.Data = parser.Results.Data;

  %% Length
  %% Length of the time vector in the timeseries object. Internal use.
  timeseries.Length = size (timeseries.Data, 1);

  %% DataInfo
  %% Contains fields for storing contextual information about Data:
  %% Unit — String that specifies data units
  %% Interpolation — A struct that specifies the interpolation method for this
  %% timeseries object.
  %% Fields of the struct include:
  %% Fhandle — Function handle to a user-defined interpolation function.
  %% Name — String that specifies the name of the interpolation method.
  %% 'linear' is the default.
  %% UserData — Any user-defined information entered as a string
  timeseries.DataInfo = parser.Results.DataInfo;

  %% Name
  %% The timeseries object name entered as a string. This name can differ from
  %% the name of the timeseries variable in the workspace.
  timeseries.Name = parser.Results.Name;

  %% Time
  %% Array of time values. The lenght must coincide with the length of the first
  %% dimension of the data.
  timeseries.Time = parser.Results.Time;
  if isempty (timeseries.Time)
    timeseries.Time = 0:1:(timeseries.Length-1);
  end

  %% Events
  %% Not used.
  timeseries.Events = [];

  %% IsTimeFirst
  %% Not used
  timeseries.IsTimeFirst = [];

  %% Quality
  %% Not used
  timeseries.Quality = [];

  %% QualityInfo
  %% Not used
  timeseries.QualityInfo = [];

  %% TimeInfo
  %% Not used.
  timeseries.TimeInfo = [];

  %% TreatNaNasMissing
  %% Not implemented. Logical value that specifies how to treat NA values in Data.
  timeseries.TreatNaNasMissing = [];

  %% UserData
  %% Not used.
  timeseries.UserData = [];

  timeseries = class (timeseries, 'timeseries');

endfunction

%!test
