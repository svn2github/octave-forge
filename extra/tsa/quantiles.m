function Q=quantiles(Y,q)
% QUANTILES demonstrates how to calculate quantiles 
%
% see also: FLIX
%
%
% q-quantile Q of data series Y 
% (1) explicite form
%	tmp=sort(Y);
%	N=sum(~isnan(Y));
%	Q = flix(tmp,N*q + 0.5);
%
% (2) in 1 line
%	Q = flix(sort(Y),sum(~isnan(Y))*q + 0.5);
%
% (3) q-quantile Q of histogram H with bins t
%	tmp=HISTOG>0;
%	HISTOG=full(HISTOG(tmp));
%	t = t(tmp);
%	N = sum(HISTOG);
%	tmp = cumsum(HISTOG)-N*q;
%
%	if ~any(~tmp), 
%		Q(k) = t(find(diff(sign(tmp)))+1);
%	else
%		Q(k) = mean(t(find(~tmp)+(0:1)));
%	end;	

% .CHANGELOG
% 27.09.2001  calc of Quantiles 

%	Version 2.83
%	last revision 07.02.2002
%	Copyright (c) 1996-2002 by Alois Schloegl
%	e-mail: a.schloegl@ieee.org	

help quantiles
