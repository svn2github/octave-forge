## Copyright (C) 2011-2012 L. Markowsky <lmarkov@users.sourceforge.net>
##
## This file is part of the fuzzy-logic-toolkit.
##
## The fuzzy-logic-toolkit is free software; you can redistribute it
## and/or modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 3 of
## the License, or (at your option) any later version.
##
## The fuzzy-logic-toolkit is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the fuzzy-logic-toolkit; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} probor(@var{a}, @var{b})
##
## If @var{a} and @var{b} are scalars, return
## @var{y} = @var{a} + @var{b} - @var{ab}.
## If @var{a} and @var{b} are vectors,
## return a vector @var{y} for which
## @var{y(i)} = @var{a(i)} + @var{b(i)} - @var{a(i)b(i)}.
##
## The arguments are assumed to be either two real scalars or two equal-length
## vectors of real scalars.
##
## Examples:
## @example
## @group
## probor(1, 1)       ==> 1
## probor(1, 0)       ==> 1
## probor(0, 0)       ==> 0
## probor(0.5, 0.5)   ==> 0.75 
## probor(0.5, 1)     ==> 1
## probor([1 1 0 0.5 0.5], [1 0 0 0.5 1]) ==> [1 1 0 0.75 1]
## @end group
## @end example
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy private probor
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      probor.m
## Last-Modified: 20 May 2011

function y = probor (a, b)

  y = a + b - a .* b;

endfunction
