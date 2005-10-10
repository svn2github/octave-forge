## Copyright (C) 2000 Paul Kienzle
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {[d,s] =} weekday(date, [P])
## Takes a date (in either datenum format or a string that datenum can
## parse) and returns the number for the day of the week (1 = "Sun", 
## 2 = "Mon", ... , "Sat")
##
## The parameter @code{P} is needed to convert date strings with 2 digit
## years into dates with 4 digit years.  2 digit years are assumed to be
## between @code{P} and @code{P+99}. If @code{P} is not given then the 
## current year - 50 is used, so that dates are centered on the present.
## For birthdates, you would want @code{P} to be current year - 99.  For
## appointments, you would want @code{P} to be current year.
##
## @seealso{date,clock,now,datestr,datenum,datevec,calendar} 
## @end deftypefn

function [d,s] = weekday(date,P)
  if (nargin < 1 || nargin > 2)
    usage("d = weekday(date [, P])");
  endif
  if ischar(date)
    if nargin < 2, P = []; endif
    date = datenum(date, P);
  endif
  d = rem(floor(date)+5,7)+1;
  if nargout == 2,
    persistent day_names = ["Sun";"Mon";"Tue";"Wed";"Thu";"Fri";"Sat"];
    s = day_names(d,:);
  endif
endfunction
