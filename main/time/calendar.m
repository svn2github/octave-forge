## calendar - print the current calendar month
## calendar(d) - print the calendar month containing day
## calendar(y,m) - print the calendar for year y, month m
## c = calendar(...) - return the calendar as a 6x7 matrix with
##   zeros in the invalid dates.

## Author: Paul Kienzle
## This program is granted to the public domain

function ret_c = calendar(y,m)

  today = now;
  if nargin < 2
    if nargin == 0, y = today; endif
    v = datevec(y);
    y = v(:,1); m = v(:,2);
  endif
   
  c = zeros(7,6);
  dayone = datenum(y,m,1);
  days = eomday(y,m);
  c(weekday(dayone) + [0:days-1]) = 1:days;

  if nargout > 0
    ret_c = c';
  else
    ## Layout the calendar days, 4 columns per day, 7 days per row.
    str = sprintf(" %2d  %2d  %2d  %2d  %2d  %2d  %2d\n",c);

    ## Find today in the calendar and put an asterisk before it
    offset = 4*(floor(today)-dayone+weekday(dayone)-1) + 1;
    if (offset >= 1 && offset <= 4*42)
      if str(offset+1) == ' ', offset++; endif
      str(offset) = '*';
    endif

    ## Display the calendar.
    printf("          %s\n",datestr(dayone,28));
    printf("  S   M  Tu   W  Th   F   S\n%s", str);
  endif

%!test
%! c = calendar(2000,2);
%! assert(c'(2:31),[0:29]);
