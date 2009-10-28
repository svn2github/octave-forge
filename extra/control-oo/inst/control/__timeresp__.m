## Copyright (C) 2009   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function [y, t, x_arr] = __timeresp__ (sys, resptype, plotflag, tfinal, dt, x0)

  if (! isa (sys, "ss"))
    sys = ss (sys);  # sys must be proper
  endif

  if (! isempty (tfinal) && ! isscalar (tfinal))  # time vector t passed
    dt = tfinal(2) - tfinal(1);  # assume that t is regularly spaced
    tfinal = tfinal(end);
  endif

  [A, B, C, D, tsam] = ssdata (sys);

  digital = ! isct (sys);  # static gains are treated as analog systems

  if (digital)
    if (! isempty (dt))
      warning ("timeresp: argument dt has no effect on sampling time of digital system");
    endif

    dt = tsam;
  endif

  [tfinal, dt] = __simhorizon__ (A, digital, tfinal, dt);

  if (! digital)  # don't transform static gains
    sys = c2d (sys, dt);
  endif

  [F, G] = ssdata (sys);  # matrices C and D don't change

  n = rows (F);  # number of states
  m = columns (G);  # number of inputs
  p = rows (C);  # number of outputs

  ## time vector
  t = (0 : dt : tfinal)';
  l_t = length (t);

  switch (resptype)
    case "initial"
      str = "Response to Initial Conditions";
      yfinal = zeros (p, 1);

      ## preallocate memory
      y = zeros (l_t, p);
      x_arr = zeros (l_t, n);

      ## initial conditions
      x = x0(:);  # make sure that x is a row vector

      if (n != length (x0))
        error ("initial: x0 must be a vector with %d elements", n);
      endif

      ## simulation
      for k = 1 : l_t
        y(k, :) = C * x;
        x_arr(k, :) = x;
        x = F * x;
      endfor

    case "step"
      str = "Step Response";
      yfinal = dcgain (sys);

      ## preallocate memory
      y = zeros (l_t, p, m);
      x_arr = zeros (l_t, n, m);

      for j = 1 : m  # for every input channel
        ## initial conditions
        x = zeros (n, 1);
        u = zeros (m, 1);
        u(j) = 1;

        ## simulation
        for k = 1 : l_t
          y(k, :, j) = C * x + D * u;
          x_arr(k, :, j) = x;
          x = F * x + G * u;
        endfor
      endfor

    case "impulse"
      str = "Impulse Response";
      yfinal = zeros (p, m);

      ## preallocate memory
      y = zeros (l_t, p, m);
      x_arr = zeros (l_t, n, m);

      for j = 1 : m  # for every input channel
        ## initial conditions
        u = zeros (m, 1);
        u(j) = 1;

        if (digital)
          x = G * u / dt;
          y(1, :, j) = D * u / dt;
          x_arr(1, :, j) = x;
        else
          if (D'*D > 0)
            warning ("impulse: system is not strictly proper");
          endif

          x = B * u;  # B, not G!
          y(1, :, j) = C * x;
          x_arr(1, :, j) = x;
          x = F * x;
        endif

        ## simulation
        for k = 2 : l_t
          y (k, :, j) = C * x;
          x_arr(k, :, j) = x;
          x = F * x;
        endfor
      endfor

      if (digital)
        y *= dt;
      endif

    otherwise
      error ("timeresp: invalid response type");

  endswitch

  
  if (plotflag)
    outname = get (sys, "outname");

    if (isempty (outname) || isequal ("", outname{:}))
      outname = strseq ("y_", 1 : length (outname));
    else
      outname = __markemptynames__ (outname);
    endif

    if (strcmp (resptype, "initial"))
      cols = 1;
    else
      cols = m;
    endif

    if (digital)  # discrete system
      for k = 1 : p
        for j = 1 : cols

          subplot (p, cols, (k-1)*cols+j);
          stairs (t, [y(:, k, j), yfinal(k, j) * ones(l_t, 1)]);
          grid ("on");

          if (k == 1)
            title (str);
          endif

          if (j == 1)
            ylabel (sprintf ("Amplitude %s", outname{k}));
          endif

        endfor
      endfor

      xlabel ("Time [s]");

    else  # continuous system
      for k = 1 : p
        for j = 1 : cols

          subplot (p, cols, (k-1)*cols+j);
          plot (t, [y(:, k, j), yfinal(k, j) * ones(l_t, 1)]);
          grid ("on");

          if (k == 1)
            title (str);
          endif

          if (j == 1)
            ylabel (sprintf ("Amplitude %s", outname{k}));
          endif

        endfor
      endfor

      xlabel ("Time [s]");

    endif 
  endif

endfunction


function [tfinal, dt] = __simhorizon__ (A, digital, tfinal, Ts)

  ## code based on __stepimp__.m of Kai P. Mueller and A. Scottedward Hodel

  TOL = 1.0e-10;  # values below TOL are assumed to be zero
  N_MIN = 50;     # min number of points
  N_MAX = 2000;   # max number of points
  N_DEF = 1000;   # default number of points
  T_DEF = 10;     # default simulation time

  n = rows (A);
  eigw = eig (A);

  if (digital)
    ## perform bilinear transformation on poles in z
    for k = 1 : n
      pol = eigw(k);
      if (abs (pol + 1) < TOL)
        eigw(k) = 0;
      else
        eigw(k) = 2 / Ts * (pol - 1) / (pol + 1);
      endif
    endfor
  endif

  ## remove poles near zero from eigenvalue array eigw
  nk = n;
  for k = 1 : n
    if (abs (real (eigw(k))) < TOL)
      eigw(k) = 0;
      nk -= 1;
    endif
  endfor

  if (nk == 0)
    if (isempty (tfinal))
      tfinal = T_DEF;
    endif

    if (! digital)
      dt = tfinal / N_DEF;
    endif
  else
    eigw = eigw(find (eigw));
    eigw_max = max (abs (eigw));

    if (! digital)
      dt = 0.2 * pi / eigw_max;
    endif

    if (isempty (tfinal))
      eigw_min = min (abs (real (eigw)));
      tfinal = 5.0 / eigw_min;

      ## round up
      yy = 10^(ceil (log10 (tfinal)) - 1);
      tfinal = yy * ceil (tfinal / yy);
    endif

    if (! digital)
      N = tfinal / dt;

      if (N < N_MIN)
        dt = tfinal / N_MIN;
      endif

      if (N > N_MAX)
        dt = tfinal / N_MAX;
      endif
    endif
  endif

  if (! isempty (Ts))  # catch case analog system with dt specified
    dt = Ts;
  endif

endfunction
