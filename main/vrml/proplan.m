## Copyright (C) 2002 Etienne Grossmann.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.

##       x = proplan(x,d,v=1)
##
## orthogonally project x to the affine plane d*x == v

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: Setembro 2002

function x = proplan(x,d,v)

if exist("v")!=1, v = 1 ;end

d = d(:) ;
N = prod(size(d)) ;		# Assume x is NxP

v = v/norm(d);
d = d/norm(d);

p = (v*d)*ones(1,size(x,2));

x -= d*d'*(x-p) ;
# x = p + (eye(N)-d*d')*(x-p) ;
