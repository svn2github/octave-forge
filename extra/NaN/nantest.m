% NANTEST checks a few statistical functions for their correctness
% e.g. it checks norminv, normcdf, normpdf.
%
% NANTEST checks whether the functions from NaN-toolbox have been
% correctly installed . 

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


r = zeros(23,2);

x = [5,NaN,0,1,nan];

% run test, k=1: with NaNs, k=2: all NaN's are removed
% the result of both should be the same. 


for k=1:2,
        if k==2, x(isnan(x))=[]; end; 
        r(1,k) =sumskipnan(x(1));
        r(2,k) =mean(x);
        r(3,k) =std(x);
        r(4,k) =var(x);
        r(5,k) =skewness(x);
        r(6,k) =kurtosis(x);
        if exist('sem')==2,
                r(7,k) =sem(x);
        end;
        r(8,k) =median(x);
        r(9,k) =mad(x);
    		tmp = zscore(x); 
	r(10,k)=tmp(1);
        if exist('coefficient_of_variation')==2,
                r(11,k)=coefficient_of_variation(x);
        end;
        r(12,k)=geomean(x);
        r(13,k)=harmmean(x);
        if exist('meansq')==2,
        	r(14,k)=meansq(x);
        end;
        r(15,k)=moment(x,6);
        if exist('rms')==2,
                r(16,k)=rms(x);
        end;
        % r(17,k) is currently empty. 
        	tmp=corrcoef(x',(1:length(x))');
        r(18,k)=any(isnan(tmp(:)));
        if exist('rankcorr')==2,
        		tmp=rankcorr(x',(1:length(x))');
                r(19,k)=any(isnan(tmp(:)));
        end;
        if exist('spearman')==2,
        		tmp=spearman(x',(1:length(x))');
	        r(20,k)=any(isnan(tmp(:)));
        end;
        if exist('rankcorr')==2,
                r(21,k)=any(isnan(ranks(x')))+k;
        end;
        if exist('center')==2,
        	        tmp=center(x);
	        r(22,k)=tmp(1);
        end;
        if exist('center')==2,
        	r(23,k)=trimean(x);
        end;
end;

% check if result is correct
tmp = abs(r(:,1)-r(:,2))<eps;


q=zeros(1,5);


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


% output
if all(tmp) & all(~q),
        fprintf(1,'NANTEST successful - your NaN-tools are correctly installed\n');
else
        fprintf(1,'NANTEST %i not successful \n', find(~tmp));
	fprintf(1,'Some functions must still be replaced\n');
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
        fprintf(2,'Warning: 0*NaN is not commutative\n');
end;


%%%%% check nan/nan   %% this test addresses a problem in Matlab 5.3 & 6.1 
p   = 2;
tmp1 = repmat(nan,p)/repmat(nan,p);
tmp2 = repmat(nan,p)\repmat(nan,p);
tmp3 = repmat(0,p)/repmat(0,p);
tmp4 = repmat(0,p)\repmat(0,p);
tmp5 = repmat(0,p)*repmat(inf,p);
tmp6 = repmat(inf,p)*repmat(0,p);

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

tmp  = [tmp1;tmp2;tmp3;tmp4;tmp5;tmp6];

