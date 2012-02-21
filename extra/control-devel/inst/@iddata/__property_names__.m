## Copyright (C) 2012   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{props}, @var{vals}] =} __property_names__ (@var{sys})
## Return the list of properties as well as the assignable values for an LTI object sys.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: February 2012
## Version: 0.1

function [props, vals] = __property_names__ (dat)

  ## cell vector of iddata-specific properties
  props = {"y";
           "outname";
           "outunit";
           "u";
           "inname";
           "inunit";
           "tsam";
           "timeunit";
           "exname";
           "name";
           "notes";
           "userdata"};

  ## cell vector of lti-specific assignable values
  vals = {"p-by-1 cell vector of matrices";
          "p-by-1 cell vector of strings";
          "p-by-1 cell vector of strings";
          "m-by-1 cell vector of matrices";
          "m-by-1 cell vector of strings";
          "m-by-1 cell vector of strings";
          "scalar (sample time in seconds)";
          "string";
          "e-by-1 cell vector of strings";
          "string";
          "string or cell of strings";
          "any data type"};

endfunction