## -*- texinfo -*-
## @deftypefn {Function File} {} datenum(Y, M, D [, h , m [, s]])
## @deftypefnx {Function File} {} datenum('date' [, P])
## Returns the specified local time as a day number, with Jan 1, 0000
## being day 1. By this reckoning, Jan 1, 1970 is day number 719529.  
## The fractional portion, corresponds to the portion of the specified day.
##
## Years can be negative and/or fractional.
## Months below 1 are considered to be January.
## Days of the month start at 1.
## Days beyond the end of the month go into subsequent months.
## Days before the beginning of the month go to the previous month.
## Days can be fractional.
##
## XXX WARNING XXX this function does not attempt to handle Julian
## calendars so dates before Octave 15, 1582 are wrong by as much
## as eleven days.  Also be aware that only Roman Catholic countries
## adopted the calendar in 1582.  It took until 1924 for it to be 
## adopted everywhere.  See the Wikipedia entry on the Gregorian 
## calendar for more details.
##
## XXX WARNING XXX leap seconds are ignored.  A table of leap seconds
## is available on the Wikipedia entry for leap seconds.
##
## @seealso{date,clock,now,datestr,datevec,calendar,weekday}
## @end deftypefn

## Paul Kienzle
## This program is granted to the public domain.

function n = datenum(Y,M,D,h,m,s)
  persistent monthstart = cumsum([0,31,28,31,30,31,30,31,31,30,31,30]);

  if nargin == 0 || (nargin > 2  && isstr(Y)) || nargin > 6
    usage("n=datenum('date' [, P]) or n=datenum(Y, M, D [, h, m [, s]])");
  endif
  if isstr(Y)
    if nargin < 2, M=[]; endif
    [Y,M,D,h,m,s] = datevec(Y,M);
  else
    if nargin < 6, s = 0; endif
    if nargin < 5, m = s; endif
    if nargin < 4, h = s; endif
  endif

  M(M<1) = 1;
  Y += floor((M-1)/12);
  M = mod(M-1,12)+1;
  n = 365*Y + ceil(Y/4) - ceil(Y/100) + ceil(Y/400) + monthstart(M) + ...
	D + (h+(m+s/60)/60)/24;
  n += mod(Y,4)==0 & (mod(Y,100)~=0 | mod(Y,400)==0) & M>2;
endfunction

%!assert(datevec(datenum(2003,11,28)),[2003,11,28,0,0,0])
