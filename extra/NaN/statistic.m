function [varargout]=statistic(i,DIM,fun)
% STATISTIC estimates various statistics at once.
% 
% R = STATISTIC(x,DIM)
%   calculates all statistic (see list of fun) in dimension DIM
%   R is a struct with all statistics 
%
% y = STATISTIC(x,fun)
%   estimate of fun on dimension DIM
%   y gives the statistic of fun	
%
% DIM	dimension
%	1: STATS of columns
%	2: STATS of rows
% 	N: STATS of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% fun	'mean'	mean
%	'std'	standard deviation
%	'var'	variance
%	'sem'	standard error of the mean
%	'rms'	root mean square
%	'meansq' mean of squares
%	'sum'	sum
%	'sumsq'	sum of squares
%	'CM#'	central moment of order #
%	'skewness' skewness 
%	'kurtosis' excess coefficient (Fisher kurtosis)
%	'mad'	mean absolute deviation
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument 
% - compatible to Matlab and Octave
% - global FLAG_implicit_unbiased_estimation
% - global FLAG_implicit_skip_nan
%
% see also: SUMSKIPNAN
%
% REFERENCE(S):
% [1] http://www.itl.nist.gov/
% [2] http://mathworld.wolfram.com/

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


if nargin==1,
        DIM=[];
	fun=[];        
elseif nargin==2,
        if ~isnumeric(DIM),
	        fun=DIM;
                DIM=[];
        else
                fun=[];
        end
end

% obtain which DIMENSION should be used
if isempty(DIM), 
        DIM = min(find(size(i)>1));
        if isempty(DIM), DIM=1; end;
end;

%R.N   	= sumskipnan(~isnan(i),DIM); 	% number of elements
[R.SUM,R.N] = sumskipnan(i,DIM);	% sum
R.SSQ  	= sumskipnan(i.*i,DIM);		% sum squared
%R.S3P  = sumskipnan(i.^3,DIM);		% sum of 3rd power
%R.S4P  = sumskipnan(i.^4,DIM);		% sum of 4th power
%R.S5P  = sumskipnan(i.^5,DIM);		% sum of 5th power

R.MEAN 	= R.SUM./R.N;			% mean 
R.MSQ  	= R.SSQ./R.N;;			% mean square
R.RMS  	= sqrt(R.MSQ);			% root mean square
R.SSQ0	= R.SSQ-R.SUM.*R.MEAN;		% sum square of mean removed

if flag_implicit_unbiased_estim;
    n1 	= max(R.N-1,0);			% in case of n=0 and n=1, the (biased) variance, STD and SEM are INF
else
    n1	= R.N;
end;

R.VAR  	= R.SSQ0./n1;	     		% variance (unbiased) 
R.STD  	= sqrt(R.VAR);		     	% standard deviation
R.SEM  	= sqrt(R.SSQ0./(R.N.*n1)); 	% standard error of the mean
R.COEFFICIENT_OF_VARIATION = R.STD./R.MEAN;

R.CM2	= R.SSQ0./n1;
i       = i - repmat(R.MEAN,size(i)./size(R.MEAN));
R.CM3 	= sumskipnan(i.^3,DIM)./n1;
R.CM4 	= sumskipnan(i.^4,DIM)./n1;
%R.CM5 	= sumskipnan(i.^5,DIM)./n1;

R.SKEWNESS = R.CM3./(R.STD.^3);
R.KURTOSIS = R.CM4./(R.VAR.^2)-3;
[R.mad,N] = sumskipnan(abs(i),DIM);	% mean absolute deviation
R.mad = R.mad./n1;

if ~isempty(fun),
        if exist('OCTAVE_VERSION')>4
                if strncmp(fun,'CM',2) 
                        oo = str2num(fun(3:length(fun)));
                        varargout  = sumskipnan(i.^oo,DIM)./n1;
                else	            
                        varargout  = getfield(R,upper(fun));
                end;
        else
                if ~iscell(fun), fun={fun}; end;
                for k=1:length(fun),
                        if strncmp(fun{k},'CM',2) 
                                oo = str2num(fun{k}(3:length(fun{k})));
                                varargout(k)  = {sumskipnan(i.^oo,DIM)./n1};
                        else	            
                                varargout(k)  = {getfield(R,upper(fun{k}))};
                        end;
                end;
        end;
end;
