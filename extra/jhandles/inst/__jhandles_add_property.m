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

function __jhandles_add_property (h, pname, ptype, opts, varargin)

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
      p = java_new ("org.octave.graphics.RadioProperty", parent, pname, vals, defval);
    else
      error ("radio property values are missing");
    endif
  case "string"
    defval = get_default_value ("char", "", varargin{:});
    p = java_new ("org.octave.graphics.StringProperty", parent, pname, defval);
  case "double"
    defval = get_default_value ("double", 0, varargin{:});
    p = java_new ("org.octave.graphics.DoubleProperty", parent, pname, defval);
  case "linestyle"
    defval = get_default_value ("char", "-", varargin{:});
    p = java_new ("org.octave.graphics.LineStyleProperty", parent, pname, defval);
  case "marker"
    defval = get_default_value ("char", "none", varargin{:});
    p = java_new ("org.octave.graphics.MarkerProperty", parent, pname, defval);
  case "doublearray"
    defval = get_default_value ("double", [], varargin{:});
    p = java_new ("org.octave.graphics.ArrayProperty", parent, pname, defval);
  case "handle"
    defval = get_default_value ("double", [], varargin{:});
    p = java_new ("org.octave.graphics.HandleObjectListProperty", parent, pname, -1);
    for hh = defval(:)'
      p.addElement (__get_object__ (hh));
    endfor
  case "colorradio"
    if (n > 0 && ischar (varargin{1}))
      vals = regexp (varargin{1}, "[^|]+", "match");
      defval = get_default_value ({"char", "double"}, vals{1}, varargin{2:end});
      if (ischar (defval) && ! any (strcmp (vals, defval)) && (length (defval) > 1 || isempty (findstr (defval, "rgbywkmc"))))
        error ("invalid default value for colorradio property");
      endif
      p = java_new ("org.octave.graphics.ColorProperty", parent, pname, [], vals, []);
      p.set (defval, true);
    else
      error ("colorradio property values are missing");
    endif
  otherwise
    error ("unknown property type `%s'", ptype);
  endswitch

  if (! opts.visible)
    p.setVisible (false);
  endif
  if (opts.readonly)
    p.setReadOnly (true);
  endif

endfunction

function [ val ] = get_default_value (ctype, missing, varargin)

  if (length (varargin) > 0)
    if (! iscellstr (ctype))
      ctype = {ctype};
    endif
    if (any (cellfun (@(x) isa (varargin{1}, x), ctype)))
      val = varargin{1};
    else
      tstr = sprintf ("%s or ", ctype{:});
      error ("invalid property default value, expected `%s'", tstr(1:end-4));
    endif
  else
    val = missing;
  endif

endfunction
