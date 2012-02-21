## Copyright (C) 2012   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} set (@var{sys})
## @deftypefnx {Function File} set (@var{sys}, @var{"property"}, @var{value}, @dots{})
## @deftypefnx {Function File} {@var{retsys} =} set (@var{sys}, @var{"property"}, @var{value}, @dots{})
## Set or modify properties of LTI objects.
## If no return argument @var{retsys} is specified, the modified LTI object is stored
## in input argument @var{sys}.  @command{set} can handle multiple properties in one call:
## @code{set (sys, 'prop1', val1, 'prop2', val2, 'prop3', val3)}.
## @code{set (sys)} prints a list of the object's property names.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: February 2012
## Version: 0.1

function retdat = set (dat, varargin)

  if (nargin == 1)       # set (dat), dat = set (dat)

    [props, vals] = __property_names__ (dat);
    nrows = numel (props);

    str = strjust (strvcat (props), "right");
    str = horzcat (repmat ("   ", nrows, 1), str, repmat (":  ", nrows, 1), strvcat (vals));

    disp (str);

    if (nargout != 0)    # function dat = set (dat, varargin)
      retdat = dat;      # would lead to unwanted output when using
    endif                # set (dat)

  else                   # set (dat, "prop1", val1, ...), sys = set (dat, "prop1", val1, ...)

    if (rem (nargin-1, 2))
      error ("iddata: set: properties and values must come in pairs");
    endif

    [n, p, m, e] = size (dat);

    for k = 1 : 2 : (nargin-1)
      prop = lower (varargin{k});
      val = varargin{k+1};

      switch (prop)
        case {"y", "outdata", "outputdata"}
          val = __adjust_iddata__ (val, dat.u);
          __iddata_dim__ (val, dat.u);
          dat.y = val;
        case {"u", "indata", "inputdata"}
          [~, val] = __adjust_iddata__ (dat.y, val);
          __iddata_dim__ (dat.y, val);
          dat.u = val;
        case {"outname", "outputname"}
          dat.outname = __adjust_labels__ (val, p);
        case {"inname", "inputname"}
          dat.inname = __adjust_labels__ (val, m);
        case {"outunit", "outputunit"}
          dat.outunit = __adjust_labels__ (val, p);
        case {"inunit", "inputunit"}
          dat.inunit = __adjust_labels__ (val, m);
        case {"tsam", "ts"}
          dat.tsam;
        case {"timeunit"}
          dat.timeunit
        case {"exname", "experimentname"}
          dat.exname = __adjust_labels__ (val, e);

        case {"tsam", "ts"}
          if (issample (val, -1))
            sys.tsam = val;
            warning ("lti: set: use the editing of property '%s' with caution", prop);
            warning ("          it may lead to corrupted models");
          else
            error ("lti: set: invalid sampling time");
          endif
          ## TODO: use of c2d, d2c and d2d if tsam changes?

        case "name"
          if (ischar (val))
            sys.name = val;
          else
            error ("lti: set: property 'name' requires a string");
          endif

        case "notes"
          if (iscellstr (val))
            sys.notes = val;
          elseif (ischar (val))
            sys.notes = {val};
          else
            error ("lti: set: property 'notes' requires string or cell of strings");
          endif

        case "userdata"
          sys.userdata = val;

        otherwise
          error ("iddata: set: invalid property name '%s'", varargin{k});
      endswitch
    endfor

    if (nargout == 0)    # set (sys, "prop1", val1, ...)
      assignin ("caller", inputname (1), dat);
    else                 # dat = set (dat, "prop1", val1, ...)
      retdat = dat;
    endif

  endif

endfunction