## Copyright (C) 2008 Luca Favatella <slackydeb@gmail.com>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program  is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.2

function retval = __ga_calcola_img_fitnessfcn__ (fitnessfcn, population)
  img_fitnessfcn = zeros (rows (population), 1);

  %% inside this for the individual is fixed
  for i = 1:rows (population)
    img_fitnessfcn (i) = fitnessfcn (population (i, :));
  endfor

  retval = img_fitnessfcn;
endfunction