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
  dayone_column = weekday(dayone);
  days = eomday(y,m);
  c(dayone_column + [0:days-1]) = 1:days;

  today_column = weekday(today);
  today_row = floor( ((today-dayone) + dayone_column - 1) / 7 ) + 1;
  
  if nargout > 0
    ret_c = c';
  else
    printf("          %s\n",datestr(dayone,28));
    printf("  S   M  Tu   W  Th   F   S\n");
    for i=1:6
      str = sprintf(" %2d  %2d  %2d  %2d  %2d  %2d  %2d",c(:,i));
      if i == today_row, 
        offset = 4*(today_column-1)+1;
	if str(offset+1) == ' ', offset++; endif
        str(offset) = '*';
      endif
      printf("%s\n",str);
    endfor
  endif

%!test
%! c = calendar(2000,2);
%! assert(c'(2:31),0:29);
