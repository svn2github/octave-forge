## Copyright (C) 2003 Teemu Ikonen
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Built-in Function} {} hold @var{args}
## Tell Octave to `hold' the current data on the plot when executing
## subsequent plotting commands.  This allows you to execute a series of
## plot commands and have all the lines end up on the same figure.  The
## default is for each new plot command to clear the plot device first.
## For example, the command
##
## @example
## hold on
## @end example
##
## @noindent
## turns the hold state on.  An argument of @code{off} turns the hold state
## off, and @code{hold} with no arguments toggles the current hold state.
## @end deftypefn

## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Created: 25.7.2003

function hold(varargin)

  __grhold__(varargin{:});

endfunction
