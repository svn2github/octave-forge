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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function __bw_secure_save__ (fn, data, dn)

  ## function bw_internal_secure_save (fn, data, dn)
  ##
  ## Saves variable "data" under the name "dn" (default name: "data") in
  ## binary format to a temporary file (sprintf ("%s.temporary", fn))
  ## and renames that file to "fn".

  if (nargin < 3)
    dn = "data";
  endif

  eval (sprintf ("%s = data;", dn));

  save ("-binary", tfn = sprintf ("%s.temporary", fn), dn);
  unlink (fn);
  [err, msg] = rename (tfn, fn);
  if (err != 0)
    error ("__bw_secure_save__: error %i in renaming, msg: %s", \
	   err, msg);
  endif

endfunction