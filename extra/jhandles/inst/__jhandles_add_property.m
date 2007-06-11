## Copyright (C) 2007 Michael Goffioul
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301  USA

function __jhandles_add_property (h, pname, ptype, varargin)

  parent = __get_object__ (h);
  n = length (varargin);

  switch (ptype)
  case "radio"
    if (n > 0 && ischar (varargin{1}))
      vals = regexp (varargin{1}, "[^|]+", "match");
      defval = get_default_value ("char", "", varargin{2:end});
      if (! strcmp (defval, "") && ! any (strcmp (vals, defval)))
        error ("default value for radio property must be part of possible values");
      endif
      java_new ("org.octave.graphics.RadioProperty", parent, pname, vals, defval);
    else
      error ("radio property values are missing");
    endif
  case "string"
    defval = get_default_value ("char", "", varargin{:});
    java_new ("org.octave.graphics.StringProperty", parent, pname, defval);
  case "double"
    defval = get_default_value ("double", 0, varargin{:});
    java_new ("org.octave.graphics.DoubleProperty", parent, pname, defval);
  case "linestyle"
    defval = get_default_value ("char", "-", varargin{:});
    java_new ("org.octave.graphics.LineStyleProperty", parent, pname, defval);
  case "marker"
    defval = get_default_value ("char", "none", varargin{:});
    java_new ("org.octave.graphics.MarkerProperty", parent, pname, defval);
  case "doublearray"
    defval = get_default_value ("double", [], varargin{:});
    java_new ("org.octave.graphics.DoubleArrayProperty", parent, pname, defval, -1);
  otherwise
    error ("unknown property type `%s'", ptype);
  endswitch

endfunction

function [ val ] = get_default_value (ctype, missing, varargin)

  if (length (varargin) > 0)
    if (isa (varargin{1}, ctype))
      val = varargin{1};
    else
      error ("invalid property default value, expected `%s'", ctype);
    endif
  else
    val = missing;
  endif

endfunction
