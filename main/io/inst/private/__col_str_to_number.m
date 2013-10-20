## Copyright (C) 2013 Markus Bergholz
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
##  @deftypefn  {Function File} {@var{nr} =} __col_str_to_number (@var{a})
##
## Transform alphabetic to numeric
##
## @end deftypefn

## Created: 2013-10-04

function nr = __col_str_to_number(a)
b=int64(a);
c=columns(b);

if c > 1
    for every=1:c
        cnr(every)=(b(every)-64);
    endfor
    if numel(cnr)==2
       cnr(1)=cnr(1)*26;
       nr=sum(cnr);
    elseif numel(cnr)==3
       cnr(1)=(cnr(1)*702)-26;
       cnr(2)=cnr(2)*26;
       nr=sum(cnr);
    endif

else
    nr=b-64;
endif
endfunction