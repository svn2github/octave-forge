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
## @deftypefn {Function File} {} datestr(date,code,P)
## Format the given date/time according to the format @code{code}.  The date
## 730736.65149 (2000-09-07 15:38:09.0934) would be formated as follows:
## @multitable @columnfractions 0.1 0.45 0.45
## @item @strong{Code} @tab @strong{Format} @tab @strong{Example}
## @item  0 @tab dd-mmm-yyyy HH:MM:SS @tab 07-Sep-2000 15:38:09
## @item  1 @tab dd-mmm-yyyy          @tab 07-Sep-2000 
## @item  2 @tab mm/dd/yy             @tab 09/07/00 
## @item  3 @tab mmm                  @tab Sep 
## @item  4 @tab m                    @tab S 
## @item  5 @tab mm                   @tab 9
## @item  6 @tab mm/dd                @tab 09/07 
## @item  7 @tab dd                   @tab 7 
## @item  8 @tab ddd                  @tab Thu 
## @item  9 @tab d                    @tab T 
## @item 10 @tab yyyy                 @tab 2000 
## @item 11 @tab yy                   @tab 00
## @item 12 @tab mmmyy                @tab Sep00 
## @item 13 @tab HH:MM:SS             @tab 15:38:09 
## @item 14 @tab HH:MM:SS PM          @tab 03:38:09 PM
## @item 15 @tab HH:MM                @tab 15:38 
## @item 16 @tab HH:MM PM             @tab 03:38 PM 
## @item 17 @tab QQ-YY                @tab Q3-00
## @item 18 @tab QQ                   @tab Q3
## @end multitable
##
## If no code is given or code is -1, then use 0, 1 or 13 as the
## default, depending on whether the date portion or the time portion 
## of the date is empty.
##
## If a vector of dates is given, a vector of date strings is returned.
##
## The parameter @code{P} is needed by @code{datevec} to convert date strings
## with 2 digit years into dates with 4 digit years.  See @code{datevec}
## for more information.
##
## @seealso{date,clock,now,datestr,datenum,calendar,weekday} 
## @end deftypefn

## TODO: with shared "code", can vectorize construction
function retval = datestr(date,code,P)
  if (nargin == 0 || nargin > 3 )
    usage("datestr(date [, code]) or datestr('date' [, code [, P]])");
  endif
  if (nargin < 3) P = []; endif
  if (nargin < 2) code = []; endif
  V = datevec(date, P);

  if (isempty(code))
    if (all(V(1,:)==0) && all(all(V(2:3,:) == 1)))
      code(i) = 13;
    elseif (all(V(4:6,:)==0))
      code(i) = 1; 
    else
      code(i) = 0;
    endif
  endif

  global __month_names = ["Jan";"Feb";"Mar";"Apr";"May";"Jun";...
			  "Jul";"Aug";"Sep";"Oct";"Nov";"Dec"];
  global __time_names = ["AM";"PM"];
  for i=1:rows(V)
    [Y, M, D, h, m, s] = deal(V(i,:));
    Y2 = rem(Y,100);
    switch (code)
      case 0, str = sprintf("%02d-%s-%04d %02d:%02d:%02d",...
			    D,__month_names(M,:),Y,h,m,floor(s));
      case 1, str = sprintf("%02d-%s-%04d",D,__month_names(M,:),Y);
      case 2, str = sprintf("%02d-%02d-%02d",D,M,Y2);
      case 3, str = sprintf("%s",__month_names(M,:));
      case 4, str = sprintf("%s",__month_names(M,1));
      case 5, str = sprintf("%d",M);
      case 6, str = sprintf("%02d/%02d",M,D);
      case 7, str = sprintf("%d",D);
      case 8, 
	[d,str] = weekday(datenum(Y,M,D));
      case 9, 
	[d,str] = weekday(datenum(Y,M,D));
	str = str(1);
      case 10, str = sprintf("%04d", Y);
      case 11, str = sprintf("%02d", Y2);
      case 12, str = sprintf("%s%02d", __month_names(M,:),Y2);
      case 13, str = sprintf("%02d:%02d:%02d", h, m, floor(s));
      case 14, str = sprintf("%02d:%02d:%02d %s", rem(h,12), m, floor(s), \
			     __time_names(floor(h/12)+1,:));
      case 15, str = sprintf("%02d:%02d", h, m);
      case 16, str = sprintf("%02d:%02d %s", rem(h,12), m, \
			     __time_names(floor(h/12)+1,:));
      case 17, str = sprintf("Q%d-%02d", floor((M+2)/3),Y2);
      case 18, str = sprintf("Q%d", floor((M+2)/3));
    endswitch
    if i == 1
      retval = str;
    else 
      retval = [ retval ; str ] ;
    endif
  endfor
endfunction
  