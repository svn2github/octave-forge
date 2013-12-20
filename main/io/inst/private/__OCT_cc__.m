## Copyright (C) 2013 Markus Bergholz <markuman@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##  column calculator for OCT interface
##
## A <=> 1 ... XFD <=> 16384
##
## Input argument has to be a positiv integer between 1:18278.
## Result will be a string
##
## Input argument has to be a string (only uppercase letters from "A":"Z") with a length between 1:3.
## Result will be a positiv integer 
##

%% terminologie: 
%% length=3 :(x*26*26+y*26+z)
%% length=2: y*26+z
%% length=1: z

function output = __OCT_cc__ (in)

hstr=["A":"Z"]; % help string

if 1 == isnumeric(in)
  % Input check
  if 18278 < in
    error('__OCT_cc is limited to column number 18278!')
    return
  elseif 1 > in
    error('__OCT_cc supports positiv integer values only!')
    return
  endif
  
  if 1 ==   (27 > in) 
    output=hstr(in);
  elseif (in > 26 && in < 703)
    letter1=fix(in/26);
    if 0 == in-(letter1*26)
      output=[hstr(letter1-1) hstr(26)];
    else
      a=hstr(letter1);
      output=[a hstr(in-(letter1*26))];
    endif
  elseif (in > 702)
    % it's at least (x*26*26+1*26+1)
    letter1=round(in/(26*26+27));
    if in <= letter1*26*26
      letter1=letter1-1;
    elseif 27 < (in-letter1*26*26)/26
      letter1=letter1+1;
    endif
    letter2=fix(fix(in-letter1*26*26)/26);
    if 0 == in-(letter1*26*26)-(letter2*26);
      letter2=letter2-1;
    endif
    letter3=in-(letter1*26*26)-(letter2*26);
    if 0 == letter3
      letter3=26;
    endif
    output=[hstr(letter1) hstr(letter2) hstr(letter3)];
  endif

elseif 1 == ischar(in)
  strlength=length(in);
  
  % input check
  if 3 < strlength
    error('__OCT_cc supports maximum 3 letters!')
    return
  elseif 1 > strlength
    error('__OCT_cc needs at least 1 uppercase letter!')
    return
  endif
  a=isstrprop (in,'upper');
  if 0 ~=numel(a(a==0))
    error('__OCT_cc supports only capital letters vom "A":"Z"')
    return
  endif
  
  if strlength == 1
    output=[(strfind (hstr,in))];
  elseif strlength == 2
    output=[(strfind(hstr,in(1)))*26+(strfind(hstr,in(2)))];
  elseif strlength == 3
    output=[(strfind(hstr,in(1)))*26*26+(strfind(hstr,in(2)))*26+(strfind(hstr,in(3)))];
  else
    error('String to long for __OCT_cc function. That should not happen!')
    return
  endif

else
  error('Wrong usage of __OCT_cc function!')
  return
endif

endfunction
