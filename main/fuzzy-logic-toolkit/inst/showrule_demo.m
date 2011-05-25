## Copyright (C) 2011 L. Markowsky <lmarkov@users.sourceforge.net>
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
## @deftypefn {Script File} {} showrule_demo
##
## Demonstrate the function @t{showrule} by executing the examples
## given in the comment at the top of showrule.m.
##
## @seealso{showrule}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy tests demos
## Directory:     fuzzy-logic-toolkit/inst
## Filename:      showrule_demo.m
## Version:       0.2
## Last-Modified: 19 May 2011

fis = readfis ('sugeno-tip-calculator.fis');

puts ("\nOutput of: showrule(fis)\n");
showrule (fis)

puts ("\nOutput of: showrule(fis, [2 4], 'symbolic')\n");
showrule (fis, [2 4], 'symbolic')

puts ("\nOutput of: showrule(fis, 1:4, 'indexed')\n");
showrule (fis, 1:4, 'indexed')

puts ("\nOutput of: showrule(fis, 1, 'verbose', 'francais')\n");
showrule (fis, 1, 'verbose', 'francais')

puts ("\n");
