## Copyright (C) 2002 David Bateman
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} awgn (@var{x},@var{snr})
## @deftypefnx {Function File} {@var{y} =} awgn (@var{x},@var{snr},@var{pwr})
## @deftypefnx {Function File} {@var{y} =} awgn (@var{x},@var{snr}, @var{pwr},@var{seed})
## @deftypefnx {Function File} {@var{y} =} awgn (@var{...}, '@var{type}')
##
## Add white Gaussian noise to a voltage signal.
##
## The input @var{x} is assumed to be a real or complex voltage  signal. The
## returned value @var{y} will be the same form and size as @var{x} but with 
## Gaussian noise added. Unless the power is specified in @var{pwr}, the 
## signal power is assumed to be 0dB, and the noise of @var{snr} dB will be
## added with respect to this. If @var{pwr} is a numeric value then the signal
## @var{x} is assumed to be @var{pwr} dB, otherwise if @var{pwr} is 'measured',
## then the power in the signal will be measured and the noise added 
## relative to this measured power.
##
## If @var{seed} is specified, then the random number generator seed is 
## initialized with this value
##
## By default the @var{snr} and @var{pwr} are assumed to be in dB. Depending
## on the value of @var{type}, the units of @var{snr} and @var{pwr} can be
## either 'dB' or 'linear'. Valid values of @var{type} are therefore 'dB' and 
## 'linear'. Linear power is in Watts.
##
## @seealso{randn,wgn}
## @end deftypefn

## 2003-01-28
##   initial release

function y = awgn (x, snr, arg1, arg2, arg3)

  if ((nargin < 2) || (nargin > 5))
    error ("usage: awgn(x, snr, p, seed, type");
  endif

  [m,n] = size(x);
  if (isreal(x))
    out = 'real';
  else
    out = 'complex'
  endif

  p = 0;
  seed = [];
  type = 'dB';
  args = zeros(3,1);
  meas = 0;
  
  if (nargin > 2)
    if (isstr(arg1))
      args(1) = 1;
    else
      p = arg1;
    endif
  endif
  if (nargin > 3)
    if (isstr(arg2))
      args(2) = 1;
    else
      seed = arg2;
    endif
  endif
  if (nargin > 4)
    if (isstr(arg3))
      args(3) = 1;
    endif
  endif
  
  if (isempty(p))
    p = 0;
  endif

  if (!isempty(seed))
    if (!isscalar(seed) || !isreal(seed) || (seed < 0) || 
      ((seed-floor(seed)) != 0))
      error ("awgn: random seed must be integer");
    endif
  endif

  for i=1:length(args)
    if (args(i) == 1)
      eval(['arg = arg',num2str(i),';']);
      if (strcmp(arg,'measured'))
        meas = 1;  
      elseif (strcmp(arg,'dB'))
        type = 'dB';  
      elseif (strcmp(arg,'linear'))
        type = 'linear';  
      else
        error ("awgn: invalid argument");
      endif
    endif
  end
    
  if (!isscalar(p) || !isreal(p))
    error("awgn: invalid power");
  endif
  if (strcmp(type,'linear') && (p < 0))
    error("awgn: invalid power");
  endif

  if (!isscalar(snr) || !isreal(snr))
    error("awgn: invalid snr");
  endif
  if (strcmp(type,'linear') && (snr < 0))
    error("awgn: invalid snr");
  endif

  if(!isempty(seed))
    randn('state',seed);
  endif

  if (meas == 1)
    p = sum( abs( x(:)) .^ 2) / length(x(:));
    if (strcmp(type,'dB'))
      p = 10 * log10(p);
    endif
  endif

  if (strcmp(type,'linear'))
    np = p / snr;
  else
    np = p - snr;
  endif
    
  y = x + wgn (m, n, np, 1, seed, type, out);
  
endfunction
