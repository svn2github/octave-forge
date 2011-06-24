## Copyright (C) 2009 Olaf Till <olaf.till@uni-jena.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

function [ret, name] = __bw_load_variable__ (fn)

  ## function [ret, name] = bw_internal_load_variable (fn)
  ##
  ## Performs "load" on "fn" and returns the single loaded variable and
  ## its name.

  tp = load (fn);
  if (length (fields = fieldnames (tp)) > 1)
    error ("load_variable: more than one variable in file");
  endif
  ret = tp.(name = fields{1});

endfunction