% Copyright (C) 2008  Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctaveForge.
% 
% OctaveForge is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 

% function time = benchutil_stopwatch (opt)
% checks or sets the stopwatch timer, or sets which timer is used
% internally
% opt can be one of: 'get' (get timer), 'set' (set timer),
% 'tic' (use tic function), 'cputime' (use cputime function)

function time = benchutil_stopwatch (opt)
  persistent ttype;
  persistent lasttime;

  if (isempty (ttype))
    ttype = 1;
    lasttime = __benchutil_timer (ttype);
  end

  if (strcmp (opt, 'set'))
    lasttime = __benchutil_timer (ttype);
  elseif (strcmp (opt, 'get'))
    time = __benchutil_timer (ttype) - lasttime;
  elseif (strcmp (opt, 'tic'))
    ttype = 1;
  elseif (strcmp (opt, 'cputime'))
    ttype = 2;
  else
    error ("invalid timer spec: %s", opt)
  end

function t = __benchutil_timer (ttype)
  switch (ttype)
  case 1
    t = double (tic ()) * 1e-6;
  case 2
    [tot, usr, sys] = cputime ();
    t = double (usr) * 1e2;
  end
