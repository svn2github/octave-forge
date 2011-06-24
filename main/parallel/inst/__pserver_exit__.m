## Copyright (C) 2010 Olaf Till <olaf.till@uni-jena.de>
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

function __pserver_exit__ (hn)

  ## Will be initialized and then registered as an exit function of
  ## Octave, so pserver does not have to wrap Octaves clean_up_and_exit
  ## and Octaves sigterm handler.

  persistent hostname;

  if (nargin == 1)
    hostname = hn;
  else
    fprintf (stderr, "exiting, %s\n", hostname);
  endif

endfunction