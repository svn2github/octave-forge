function Y=flix(D,x)
% FLIX floating point index
%
% Y=flix(D,x)
%   FLIX returns Y=D(x) if x is an integer 
%   otherwise D(x) is interpolated from the neighbors D(ceil(x)) and D(floor(x)) 
% 
% Applications: 
% (1)  discrete Dataseries can be upsampled to higher sampling rate   
% (2)  transformation of non-equidistant samples to equidistant samples
% (3)  [Q]=flix(sort(D),q*(length(D)+1)) calculates the q-quantile of data series D   
%
% see also: HIST2RES, Y2RES, PLOTCDF

%	Version 2.75
%	21.Sep.2001
%	Copyright (c) by 2001 Alois Schloegl
%	a.schloegl@ieee.org	


[dr,dc] = size(D);
Y = zeros(size(x));

k1 = ((x>=1) & (x<=dr*dc));
Y(~k1) = NaN;

k = rem(x,1); 		% distance to next sample	 

ix = find(~k & k1); 	% find integer indices
Y(ix) = D(x(ix)); 	% put integer indices

ix = find(~~k & k1); 	% find non-integer indices
Y(ix) = D(floor(x(ix))).*(1-k(ix)) + D(ceil(x(ix))).*k(ix);  
