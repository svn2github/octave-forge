function O=trimean(Y,DIM)
% TRIMEAN evaluates basic statistics of a data series (column)
% TR=TRIMEAN(y)
% 
% The trimean is 
%   TR=(Q1+2*M+Q3)/4
%  
% REFERENCES:
% [1] http://mathworld.wolfram.com/Trimean.html

%    	Version 1.27  Date: 12 Sep 2002
%	Copyright (C) 1996-2002 by Alois Schloegl <a.schloegl@ieee.org>	


% check dimension
sz=size(Y);
if length(sz)>2,
        fprintf('Error TRIMEAN: data must have no more than 2 dimensions\n');	
	return;        
end;

% find the dimension
if nargin==1,
        DIM=min(find(size(Y)>1));
        if isempty(DIM), DIM=1; end;
end;

N = sumskipnan(~isnan(Y),DIM);

sz = size(Y);
sz(DIM) = 1;
O = repmat(nan,sz);

if DIM==2, Y=Y'; end;
Y = [Y; repmat(nan,1,size(Y,2))];
Y = sort(Y);
    
%%% assumes that NaN is at the end of the sorted list
for k=1:size(Y,2),
        Q0250 = flix(Y(:,k),N(k)/4   + 0.75);
        Q0500 = flix(Y(:,k),N(k)/2   + 0.50);
        Q0750 = flix(Y(:,k),N(k)*3/4 + 0.25);
        
        O(k)  = [Q0250 + 2*Q0500 + Q0750]/4;
end;

