## eomday(Y,M)
##   Return the last day of the month M for year Y.

## Author: Paul Kienzle
## This program is granted to the public domain

function D = eomday(Y,M)
  persistent eom=[31,28,31,30,31,30,31,31,30,31,30,31];
  D = M; D(:) = eom(M);
  D += M==2 & mod(Y,4)==0 & (mod(Y,100)!=0 | mod(Y,400)==0);

%!assert(eomday([-4:4],2),[29,28,28,28,29,28,28,28,29]);
%!assert(eomday([-901,901],2),[28,28]);
%!assert(eomday([-100,100],2),[28,28]);
%!assert(eomday([-900,900],2),[28,28]);
%!assert(eomday([-400,400],2),[29,29]);
%!assert(eomday([-800,800],2),[29,29]);
%!assert(eomday(2001,1:12),[31,28,31,30,31,30,31,31,30,31,30,31])
%!assert(eomday(1:3,1:3),[31,28,31])
%!assert(eomday(1:2000,2)',datevec(datenum(1:2000,3,0))(:,3))
