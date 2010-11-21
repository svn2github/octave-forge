function RES = bland_altman(data,group,arg3)
% BLAND_ALTMANN shows the Bland-Altman plot of two columns of measurements
%   and computes several summary results. 
%
%   bland_altman(m1, m2 [,group])
%   bland_altman(data [, group])
%   R = bland_altman(...)
% 
%   m1,m2 are two colums with the same number of elements
%	containing the measurements. m1,m2 can be also combined 
%       in a single two column data matrix. 
%   group [optional] indicates which measurements belong to the same group
%	This is useful to account for repeated measurements.  
%
%
% References:
%    	JM Bland and DG Altman, Measuring agreement in method comparison studies. 
%	Statistical Methods in Medical Research, 1999; 8; 135. 
%	doi:10.1177/09622802990080204

%	$Id$
%	Copyright (C) 2010 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://pub.ist.ac.at/~schloegl/matlab/NaN/

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3
% of the  License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if nargin<2, group = []; end;
if nargin<3, arg3 = []; end;

if (size(data,2)==1)
	data  = [data, group];
	group = arg3;
end; 		


D = data * [1;-1];
M = data * [1;1]/2;


RES.corrcoef = corrcoef(M,D,'spearman');


if isempty(group)
	G = [1:size(data,1)]';
	m = ones(size(data,1),1);
	d = D;
	
elseif ~isempty(group)
	%% TODO: this is not finished  	
	[G,I,J] = unique (group)
	m       = repmat(NaN,length(G),1);
	n       = repmat(NaN,length(G),1);
	d       = repmat(NaN,length(G),1);
	d2      = repmat(NaN,length(G),1);
	data2   = repmat(NaN,length(G),size(data,2));
	SW2     = repmat(NaN,length(G),size(data,2));
	for i   = 1:length(G)
		ix = find(group==G(k));
		n(i)       = length(ix);
		data2(i,:) = mean(data(ix,:));
		SW2(i,:)   = var(data(ix,:));
		d(i)       = mean(D(ix,:));
		m(i)       = mean(M(ix,:));
		d2(i)      = mean(D(ix,:).^2);
	end; 
	RES.repeatability_coefficient = mean(SW2,2);
	D = d; 
	M = m;
%	RES.sigma2_dw = 
end; 

RES.Bias = mean(d,1,[],n);

plot(M,D,'o', [min(M),max(M)]', [0,0]','k--', [min(M),max(M)]', [1,1,1; 0,1.96,-1.96]'*[RES.Bias;std(D)]*[1,1], 'k-');
xlabel('mean')
ylabel('difference')

