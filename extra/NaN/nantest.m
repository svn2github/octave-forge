% NANTEST checks several mathematical operations and a few 
% statistical functions for their correctness related to NaN's.
% e.g. it checks norminv, normcdf, normpdf, sort, matrix division and multiplication.
%
%
% see also: NANINSTTEST

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

%	$Revision$
%	$Id$
%	Copyright (c) 2000-2003 by  Alois Schloegl <a.schloegl@ieee.org>

FLAG_WARNING = warning;
warning('off');

% check NORMPDF, NORMCDF, NORMINV
x = [-inf,-2,-1,-.5,0,.5,1,2,3,inf,nan]';
if exist('normpdf')==2,
        q(1) = sum(isnan(normpdf(x,2,0)))>sum(isnan(x));
        if q(1),
                fprintf(1,'NORMPDF should be replaced\n');
        end;
end;

if exist('normcdf')==2,
        q(2) = sum(isnan(normcdf(x,2,0)))>sum(isnan(x));
        if q(2),
                fprintf(1,'NORMCDF should be replaced\n');
        end;
end;

if exist('norminv')==2,
        p = [-inf,-.2,0,.2,.5,1,2,inf,nan];
        q(3) = sum(~isnan(norminv(p,2,0)))<4;
        if q(3),
                fprintf(1,'NORMINV should be replaced\n');
        end;
        q(4) = ~isnan(norminv(0,NaN,0)); 
        q(5) = any(norminv(0.5,[1 2 3 ],0)~=[1:3]);
end;

if exist('tpdf')==2,
        q(6) = ~isnan(tpdf(nan,4));
        if q(6),
                fprintf(1,'TPDF should be replaced\n');
        end;
end;

if exist('tcdf')==2,
        try,	
                q(7) = ~isnan(tcdf(nan,4));
        catch,
                q(7) = 1;
        end;
        if q(7),
                fprintf(1,'TCDF should be replaced\n');
        end;
end;

if exist('tinv')==2,
        try,	
                q(8) = ~isnan(tinv(nan,4));
        catch,
                q(8) = 1;
        end;
        if q(8),
                fprintf(1,'TINV should be replaced\n');
        end;
end;


%%%%% sorting of NaN's %%%%
if ~all(isnan(sort([3,4,NaN,3,4,NaN]))==[0,0,0,0,1,1]),  %~exist('OCTAVE_VERSION'),
    	warning('Warning: SORT does not handle NaN.');
end;

%%%%% commutativity of 0*NaN	%%% This test adresses a problem in Octave

x=[-2:2;4:8]';
y=x;y(2,1)=nan;y(4,2)=nan;
B=[1,0,2;0,3,1];
if ~all(all(isnan(y*B)==isnan(B'*y')')),
        fprintf(2,'WARNING: 0*NaN within matrix multiplication is not commutative\n');
end;


%%%%% check nan/nan   %% this test addresses a problem in Matlab 5.3 & 6.1 
p    = 4;
tmp1 = repmat(nan,p)/repmat(nan,p);
tmp2 = repmat(nan,p)\repmat(nan,p);
tmp3 = repmat(0,p)/repmat(0,p);
tmp4 = repmat(0,p)\repmat(0,p);
tmp5 = repmat(0,p)*repmat(inf,p);
tmp6 = repmat(inf,p)*repmat(0,p);
x = randn(100,1)*ones(1,p); y=x'*x; tmp7=y/y;
x = randn(100,1)*ones(1,p); y=x'*x; tmp8=y\y;

if ~all(isnan(tmp1(:))),
        fprintf(2,'WARNING: matrix division NaN/NaN does not result in NaN\n');
end;
if ~all(isnan(tmp2(:))),
        fprintf(2,'WARNING: matrix division NaN\\NaN does not result in NaN\n');
end;
if ~all(isnan(tmp3(:))),
        fprintf(2,'WARNING: matrix division 0/0 does not result in NaN\n');
end;
if ~all(isnan(tmp4(:))),
        fprintf(2,'WARNING: matrix division 0\\0 does not result in NaN\n');
end;
if ~all(isnan(tmp5(:))),
        fprintf(2,'WARNING: matrix multiplication 0*inf does not result in NaN\n');
end;
if ~all(isnan(tmp6(:))),
        fprintf(2,'WARNING: matrix multiplication inf*0 does not result in NaN\n');
end;
if any(any(tmp7==inf));
        fprintf(2,'WARNING: right division of two singulare matrices return INF\n');
end;
if any(any(tmp8==inf));
        fprintf(2,'WARNING: left division of two singulare matrices return INF\n');
end;

tmp  = [tmp1;tmp2;tmp3;tmp4;tmp5;tmp6;tmp7;tmp8];

warning(FLAG_WARNING);



