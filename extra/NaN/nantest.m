% NANTEST checks whether functions from NaN-toolbox are called
% or the default functions which come with Octve. 
% The functions of the NaN-toolbax can handle NaN's. 
% 

%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


%	Version 1.15
%	12 Mar 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl
%	a.schloegl@ieee.org


flag_implicit_skip_nan(1);
flag_implicit_unbiased_estim(1);
r=zeros(17,1);


x = [NaN,0,1,nan];

r(1) =sumskipnan(x(1));
r(2) =mean(x);
r(3) =std(x);
r(4) =var(x);
r(5) =skewness(x);
r(6) =kurtosis(x);
r(7) =sem(x);
r(8) =median(x);
r(9) =mad(x);
tmp  =zscore(x); r(10)=tmp(2);
r(11)=coefficient_of_variation(x);
r(12)=geomean(x);
r(13)=harmmean(x);
r(14)=meansq(x);
r(15)=moment(x,6);
r(16)=rms(x);
r(17)=sem(x);

tmp=[0,.5,sqrt(.5),.5,0,-2.5,.5,.5,1,-sqrt(.5),sqrt(2),0,0,.5,1,sqrt(.5),.5]';
if all(abs(r-tmp)<eps)
        fprintf(1,'NANTEST successful\n');
else
        fprintf(1,'NANTEST %i not successful\n', find(abs(r-tmp)>eps | isnan(r)));
end;

        