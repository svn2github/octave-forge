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
## @deftypefn {Function File} {V} datevec(date)
## @deftypefnx {Function File} {[Y,M,D,h,m,s] =} datevec(date)
## Breaks the number of days since Jan 1, 0000 into a year-month-day
## hour-minute-second format. By this reckoning, Jan 1, 1970 is day
## number 719529.  The fractional portion of @code{date} corresponds to the
## portion of the given day. If a single return value is requested,
## then the components of the date are columns of the matrix @code{V}.
##
## Note: 32-bit architectures only handle times between Dec 14, 1901 
## and Jan 19, 2038, with special handling for 0000-01-01.  datenum
## returns -1 in case of a range error.
##
## The parameter @code{P} is needed to convert date strings with 2 digit
## years into dates with 4 digit years.  2 digit years are assumed to be
## between @code{P} and @code{P+99}. If @code{P} is not given then the 
## current year - 50 is used, so that dates are centered on the present.
## For birthdates, you would want @code{P} to be current year - 99.  For
## appointments, you would want @code{P} to be current year.
##
## Dates must be represented as mm/dd/yy or dd-mmm-yyyy.  Times must
## be hh:mm:ss or hh:mm:ss PM, with seconds optional.  These correspond 
## to datestr format codes 0, 1, 2, 3, 13, 14, 15, 16.
##
## @seealso{date,clock,now,datestr,datenum,calendar,weekday} 
## @end deftypefn

function [Y,M,D,h,m,s] = datevec(date,P)

  if nargin == 0 || nargin > 2
    usage("V=datevec(n) or [Y,M,D,h,m,s]=datevec(n)");
  endif
  if nargin < 2, P = []; endif

  if isstr(date)
    if isempty(P)
      tm = localtime(time);
      P = tm.year+1900-50;
    endif

    global __month_names = ["Jan";"Feb";"Mar";"Apr";"May";"Jun";...
			    "Jul";"Aug";"Sep";"Oct";"Nov";"Dec"];
    global __time_names = ["AM";"PM"];

    Y = h = m = s = zeros(rows(date),1);
    M = D = ones(size(Y));
    error("datevec: doesn't handle strings yet");
  endif

  ## From Peter Baum (http://vsg.cape.com/~pbaum/date/date0.htm)
  ## Move day 0 from midnight -0001-12-31 to midnight 0001-3-1
  z = floor(date) - 60; 
  ## Calculate number of centuries; K1=0.25 is to avoid rounding problems.
  a = floor((z-0.25)/36524.25);
  ## Days within century;  K2=0.25 is to avoid rounding problems.
  b = z - 0.25 + a - floor(a/4);
  ## Calculate the year (year starts on March 1).
  Y = floor(b/365.25);
  ## Calculate day in year.
  c = fix(b-floor(365.25*Y)) + 1;
  ## Calculate month in year.
  M = fix((5*c + 456)/153);
  D = c - fix((153*M-457)/5);
  ## Move to Jan 1 as start of year.
  Y(M>12)++;
  M(M>12)-=12;

  ## Convert hour-minute-seconds
  s = date-floor(date);
  h = floor(s/3600);
  s = s - 3600*h;
  m = floor(s/60);
  s = s - 60*m;
  if nargout <= 1
    Y = [ Y(:), M(:), D(:), h(:), m(:), s(:) ];
  endif
endfunction
