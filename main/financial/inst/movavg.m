## Copyright (C) 2008 Bill Denney
##
## This software is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} movavg (asset, lead, lag)
## @deftypefnx {Function File} {} movavg (asset, lead, lag, alpha)
## @deftypefnx {Function File} {[short, long] =} movavg (asset, lead, lag, alpha)
##
## Plot the @var{lead}ing and @var{lag}ging moving average of an
## @var{asset}. If given, @var{alpha} is the weighting power of the
## delay; 0 (default) is the simple moving average, 0.5 would be the
## square root weighted moving average, 1 would be linear, 2 would be
## squared, ..., and 'e' is the exponential moving average.
##
## The plots are drawn in the following order: asset, lag, lead.
##
## @seealso{bolling, candle, dateaxis, highlow, pointfig}
## @end deftypefn

## Author: Bill Denney <bill@denney.ws>
## Created: 13 Feb 2008

function [varargout] = movavg (asset, lead, lag, alpha)

  if nargin < 3 || nargin > 4
	print_usage ();
  elseif nargin < 4
	alpha = 0;
  endif

  if lead > lag
    error ("lead must be <= lag")
  elseif ischar (alpha)
    if ~ strcmpi (alpha, "e")
      error ("alpha must be 'e' if it is a char");
    endif
  elseif ~ isnumeric (alpha)
    error ("alpha must be numeric or 'e'")
  endif

  ## Compute the weights
  if ischar(alpha)
    lead = exp(1:lead);
    lag = exp(1:lag);
  else
    lead = (1:lead).^alpha;
    lag = (1:lag).^alpha;
  endif
  ## Adjust the weights to equal 1
  lead = lead / sum(lead);
  lag = lag / sum(lag);

  short = asset;
  long = asset;
  for i = 1:length(asset)
    if i < length(lead)
      ## Compute the run-in period
      r = length(lead)-i+1:length(lead);
      short(i) = dot(asset(1:i), lead(r))./sum(lead(r));
    else
      short(i) = dot(asset(i-length(lead)+1:i), lead);
    endif
    if i < length(lag)
      r = length(lag)-i+1:length(lag);
      long(i) = dot(asset(1:i), lag(r))./sum(lag(r));
    else
      long(i) = dot(asset(i-length(lag)+1:i), lag);
    endif
  endfor

  plot((1:length(asset))', [asset(:), long(:), short(:)]);

  if nargout > 0
    varargout{1} = short;
  endif
  if nargout > 1
    varargout{2} = long
  endif

endfunction
