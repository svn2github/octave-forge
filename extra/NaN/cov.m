function CC = cov(X,Y,Mode);
% COV covariance matrix
% X and Y can contain missing values encoded with NaN.
% NaN's are skipped, NaN do not result in a NaN output. 
% The output gives NaN only if there are insufficient input data
% The mean is removed from the data. 
%
% C = COV(X [,Mode]);
%      calculates the (auto-)correlation matrix of X
% C = COV(X,Y [,Mode]);
%      calculates the crosscorrelation between X and Y. 
%      C(i,j) is the correlation between the i-th and jth 
%      column of X and Y, respectively. 
%   NOTE: this is different than the behaviour of DATAFUN\COV. 
%      Use COV([X(:),Y(:)]) to get the traditional behaviour of Matlab. 
%
% Mode = 0 [default] scales C by (N-1)
% Mode = 1 scales C by N. 
%
% see also: COVM, SUMSKIPNAN
%
% REFERENCES:
% http://mathworld.wolfram.com/Covariance.html


%	$REevision$
%	$Id$
%	Copyright (C) 2000-2003 by  Alois Schloegl <a.schloegl@ieee.org>	


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


if nargin==1
        Mode = 0;
        Y = [];
elseif nargin==2,
	if all(size(Y)==1) & any(Y==[0,1])
                Mode = Y;
                Y =[];
        else
                Mode = 0;        
                if ~exist('OCTAVE_VERSION'), 	% if Matlab,
                	fprintf(2,'Warning NaN/COV: Behaviour of COV(X,Y) is unlike in datafun/COV. \nSee HELP COV for more information.\n');         
                end;
        end;
elseif nargin==3, 
		        
else
	fprintf(2,'Error COV: invalid number of arguments\n');
end;


if isempty(Y)
	CC = covm(X,['D',int2str(Mode)]);	
else        
        CC = covm(X,Y,['D',int2str(Mode)]);	
end;

