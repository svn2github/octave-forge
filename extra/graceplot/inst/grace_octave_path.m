## Copyright (C) 1998-2002 Joao Cardoso.        -*- octave -*-
## Copyright (C) 2003  Rafael Laboissiere
## Modified to work with Grace: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2 of the License, or (at your
## option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.

## path = grace_octave_path([path])
##
## set or return the current directory path of graceplot scripts

function path = grace_octave_path(path)

  global __pl_grace_octave_path

  if (isempty(__pl_grace_octave_path))
    s = which("grace_octave_path");
    s = s(1:index(s, "/", "last"));
    __pl_grace_octave_path = strcat(s, "alternatives");
  endif

  if (nargin == 0)
    path = __pl_grace_octave_path;
  elseif (nargin == 1 && isstr(path))
    if (path(length (path)) != '/')
      path = [path "//"];
    elseif (path(length (path)-1) != '/')
      path = [path "/"];
    endif
    __pl_grace_octave_path = path;
  else
    help octave_grace_path
  endif

endfunction
