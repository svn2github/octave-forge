function y=trimean(x,DIM)
% TRIMEAN evaluates basic statistics of a data series
%    m = TRIMEAN(y).
%
% The trimean is  m = (Q1+2*MED+Q3)/4
%    with quartile Q1 and Q3 and median MED   
%
% N-dimensional data is supported
% 
% REFERENCES:
% [1] http://mathworld.wolfram.com/Trimean.html

%	$Revision$
%	$Id$
%	Copyright (C) 1996-2003 by Alois Schloegl <a.schloegl@ieee.org>	


% check dimension
sz=size(x);

% find the dimension
if nargin==1,
        DIM=min(find(sz>1));
        if isempty(DIM), DIM=1; end;
end;

if DIM>length(sz),
        sz = [sz,ones(1,DIM-length(sz))];
end;

D1 = prod(sz(1:DIM-1));
%D2 = sz(DIM);
D3 = prod(sz(DIM+1:length(sz)));
D0 = [sz(1:DIM-1),1,sz(DIM+1:length(sz))];
y  = repmat(nan,D0);
for k = 0:D1-1,
for l = 0:D3-1,
        xi = k + l * D1*sz(DIM) + 1 ;
        xo = k + l * D1 + 1;
        t = sort(x(xi+(0:sz(DIM)-1)*D1));
        n = sum(~isnan(t));
        
        q = flix(t,[n/4 + 0.75; n/2+0.5; n*3/4 + 0.25]);
        y(xo) = (q(1) + 2*q(2) + q(3))/4;
end;
end;

