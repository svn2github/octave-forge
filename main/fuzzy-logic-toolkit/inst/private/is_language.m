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
## @deftypefn {Function File} {@var{y} =} is_language (@var{x})
##
## Return 1 if @var{x} is one of the strings 'english', 'francais', and
## 'deutsch', and return 0 otherwise. The comparison is case-insensitive.
##
## is_language is a private function that localizes the test for built-in output
## languages.
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy private parameter-test
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      is_language.m
## Last-Modified: 20 May 2011

function y = is_language (x)

  y = ischar (x) && isvector (x) && ...
      ismember (tolower (x), {'english', 'francais', 'deutsch'});

endfunction
