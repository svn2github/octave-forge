## Copyright (C) 2001, 2008 Paul Kienzle
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
## Foundation, Inc.

## -*- texinfo -*-
## @deftypefn {Function File} {x} = csvread (@var{filename})
## Read the matrix @var{x} from a file.
##
## This function is equivalent to dlmread (@var{filename}, "," , ...)
##
## @seealso{dlmread, dlmwrite, csvwrite, csv2cell}
## @end deftypefn

function m = csvread(f,varargin)
  m = dlmread(f,',',varargin{:});
