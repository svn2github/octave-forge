function [R,CC]=xval(D,classlabel,MODE,arg4)
% XVAL is used for crossvalidation 
%
%  [R,CC] = xval(D,classlabel)
%  .. = xval(D,classlabel,CLASSIFIER)
%  .. = xval(D,classlabel,CLASSIFIER,type)
%  .. = xval(D,[classlabel,W],CLASSIFIER)
%  .. = xval(D,[classlabel,W,NG],CLASSIFIER)
%
% Input:
%    D:	data features (one feature per column, one sample per row)
%    classlabel  classlabel (same number of rows)
%    CLASSIFIER can be any classifier supported by train_sc (default='LDA')
%	{'MDA','MD2','LD2','LD3','LD4','LD5','LD6','NBC','aNBC','WienerHopf','REG','LDA/GSVD','MDA/GSVD', 'LDA/sparse','MDA/sparse','RDA','GDBC','SVM','RBF'}
%    W:	weights for each sample (row) in D. 
%	default: [] (i.e. all weights are 1)
%	number of elements in W must match the number of rows of D 
%    NG: used to define the type of cross-valdiation
% 	Leave-One-Out-Method (LOOM): NG = [1:length(classlabel)]' (default)
% 	Leave-K-Out-Method: NG = ceil([1:length(classlabel)]'/K)
%	K-fold XV:  NG = ceil([1:length(classlabel)]'*K/length(classlabel))
%	group-wise XV (if samples are not indepentent) can be also defined here
%	samples from the same group (dependent samples) get the same identifier
%	samples from different groups get different classifiers
%    TYPE:  defines the type of cross-validation procedure if NG is not specified 
%	'LOOM'  leave-one-out-method
%       k	k-fold crossvalidation
%
% OUTPUT: 
%    R contains the resulting performance metric
%    CC contains the classifier  
%
%    plota(R) shows the confusion matrix of the results
%
% see also: TRAIN_SC, TEST_SC, CLASSIFY, PLOTA
%
% References: 
% [1] R. Duda, P. Hart, and D. Stork, Pattern Classification, second ed. 
%       John Wiley & Sons, 2001. 
% [2] A. Schlögl, J. Kronegg, J.E. Huggins, S. G. Mason;
%       Evaluation criteria in BCI research.
%       (Eds.) G. Dornhege, J.R. Millan, T. Hinterberger, D.J. McFarland, K.-R.Müller;
%       Towards Brain-Computer Interfacing, MIT Press, 2007, p.327-342

%	$Id: xval.m 2124 2009-06-10 20:34:02Z schloegl $
%	Copyright (C) 2008,2009 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://hci.tu-graz.ac.at/~schloegl/matlab/NaN/

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

if (nargin<3) || isempty(MODE), 
	MODE = 'LDA'; 
end;
if ischar(MODE) 
        tmp = MODE; 
        clear MODE; 
        MODE.TYPE = tmp;
elseif ~isfield(MODE,'TYPE')
        MODE.TYPE=''; 
end;        

sz = size(D);
if sz(1)~=size(classlabel,1),
        error('length of data and classlabel does not fit');
end;

NG = [];	
W = [];
% use only valid samples
ix0 = find(~any(isnan(classlabel),2));

if size(classlabel,2)>1,
	%% group-wise classvalidation
	W = classlabel(:,2);
	if all(W==1) W = []; end; 
	if size(classlabel,2)>2,
		[Label,tmp1,NG] = unique(classlabel(:,3));
	end;
end; 

if isempty(NG)
if (nargin<4) || strcmpi(arg4,'LOOM')
	%% LOOM 
	NG = [1:sz(1)]';

elseif isnumeric(arg4)
	if isscalar(arg4)  
	% K-fold XV
		NG = ceil([1:length(classlabel)]'*arg4/length(classlabel));
	elseif length(arg4)==2,
		NG = ceil([1:length(classlabel)]'*arg4(1)/length(classlabel));
	end; 	
	
end; 
end; 

sz = size(D);
if sz(1)~=length(classlabel),
        error('length of data and classlabel does not fit');
end;
if ~isfield(MODE,'hyperparameter')
        MODE.hyperparameter = [];
end

cl = repmat(NaN,size(classlabel,1),1);
for k = 1:max(NG),
 	ix = ix0(NG(ix0)~=k);
	if isempty(W)	
		CC = train_sc(D(ix,:),classlabel(ix,1),MODE);
	else
		CC = train_sc(D(ix,:),classlabel(ix,1),MODE,W(ix));
	end; 	
 	ix = ix0(NG(ix0)==k);
	r  = test_sc(CC,D(ix,:));
	cl(ix,1) = r.classlabel;
end; 

R = kappa(classlabel(:,1),cl,'notIgnoreNAN',W);
%R1 = kappa(classlabel(:,1),cl,[],W)
%R2 = kappa(R.H)

R.ERR = 1-R.ACC; 
if isnumeric(R.Label)
	R.Label = cellstr(int2str(R.Label)); 
end; 		
R.datatype='confusion';
R.data = R.H; 

if nargout>1,
	% final classifier 
	if isempty(W), 
		CC = train_sc(D,classlabel(:,1),MODE);
	else	
		CC = train_sc(D,classlabel(:,1),MODE,W);
	end; 	
	CC.Labels = 1:max(classlabel);
	%CC.Labels = unique(classlabel);
end; 
