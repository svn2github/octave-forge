## Copyright (C) 2000 Ben Sapp.  All rights reserved.
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
##
## Author: Ben Sapp <bsapp@lanl.gov>
## Reference: David G Luenberger's Linear and Nonlinear Programming

## used internally by dfp which is an implementation 
## of the Davidon-Fletcher-Powell quasi-newton method

function v = __quasi_func__(alpha)
  global __quasi_d__;
  global __quasi_x0__;
  global __quasi_f__;
  v = feval(__quasi_f__,__quasi_x0__+alpha*__quasi_d__);
endfunction
