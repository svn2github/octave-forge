function [CC]=train_sc(D,classlabel,MODE,W)
% Train a (statistical) classifier
% 
%  CC = train_sc(D,classlabel)
%  CC = train_sc(D,classlabel,MODE)
%  CC = train_sc(D,classlabel, 'REG', W)
%	weighting D(k,:) with weight W(k)
%
% CC contains the model parameters of a classifier which can be applied 
%   to test data using test_sc. 
%   R = test_sc(CC,D,...) 
%
%  The following classifier types are supported MODE.TYPE
%    'MDA'      mahalanobis distance based classifier [1]
%    'MD2'      mahalanobis distance based classifier [1]
%    'MD3'      mahalanobis distance based classifier [1]
%    'GRB'      Gaussian radial basis function     [1]
%    'QDA'      quadratic discriminant analysis    [1]
%    'LD2'      linear discriminant analysis (see LDBC2) [1]
%		MODE.hyperparameter.gamma: regularization parameter [default 0] 
%    'LD3', 'FDA', 'LDA'
%               linear discriminant analysis (see LDBC3) [1]
%		MODE.hyperparameter.gamma: regularization parameter [default 0] 
%    'LD4'      linear discriminant analysis (see LDBC4) [1]
%		MODE.hyperparameter.gamma: regularization parameter [default 0] 
%    'LD5'      another LDA (motivated by CSP)
%		MODE.hyperparameter.gamma: regularization parameter [default 0] 
%    'RDA'      regularized discriminant analysis [7]
%		MODE.hyperparameter.gamma: regularization parameter 
%		MODE.hyperparameter.lambda =
%		gamma = 0, lambda = 0 : MDA
%		gamma = 0, lambda = 1 : LDA
%		Hint: hyperparameters are used only in test_sc.m, testing different 
%		the hyperparameters do not need repetitive calls to train_sc, 
%		it is sufficient to modify CC.hyperparameters before calling test_sc. 	
%    'GDBC'     general distance based classifier  [1]
%    ''         statistical classifier, requires Mode argument in TEST_SC	
%    '###/GSVD'	GSVD and statistical classifier [2,3], 
%    '###/sparse'  sparse  [5] 
%		'###' must be 'LDA' or any other classifier 
%    'PLS'	(linear) partial least squares regression 
%    'REG'      regression analysis;
%    'WienerHopf'	Wiener-Hopf equation  
%    'NBC'	Naive Bayesian Classifier [6]     
%    'aNBC'	Augmented Naive Bayesian Classifier [6]
%    'NBPW'	Naive Bayesian Parzen Window [9]     
%    'PSVM'	Proximal SVM [8] 
%		MODE.hyperparameter.nu  (default: 1.0)
%    'LPM'      Linear Programming Machine
%                 uses and requires train_LPM of the iLog CPLEX optimizer 
%		MODE.hyperparameter.c_value = 
%    'CSP'	CommonSpatialPattern is very experimental and just a hack
%		uses a smoothing window of 50 samples.
%    'SVM','SVM1r'  support vector machines, one-vs-rest
%                 uses and requires svmtrain.mex from libSVM
%		MODE.hyperparameter.c_value = 
%    'SVM11'    support vector machines, one-vs-one + voting
%                 uses and requires svmtrain.mex from libSVM
%		MODE.hyperparameter.c_value = 
%    'RBF'      Support Vector Machines with RBF Kernel
%               uses and requires svmtrain.mex from libSVM
%		MODE.hyperparameter.c_value = 
%		MODE.hyperparameter.gamma = 
%    'SVM:LIB'    uses and requires svmtrain.mex from libSVM
%    'SVM:bioinfo' uses and requires svmtrain from the bioinfo toolbox        
%    'SVM:OSU'   uses and requires mexSVMTrain from the OSU-SVM toolbox 
%    'SVM:LOO'   uses and requires svcm_train from the LOO-SVM toolbox 
%    'SVM:Gunn'  uses and requires svc-functios from the Gunn-SVM toolbox 
%    'SVM:KM'    uses and requires svmclass-function from the KM-SVM toolbox 
%    'SVM:LINz'  LibLinear [10] (requires train.mex from LibLinear somewhere in the path)
%            z=0 (default) LibLinear with -- L2-regularized logistic regression
%            z=1 LibLinear with -- L2-loss support vector machines (dual)
%            z=2 LibLinear with -- L2-loss support vector machines (primal)
%            z=3 LibLinear with -- L1-loss support vector machines (dual)
%    'SVM:LIN4'  LibLinear with -- multi-class support vector machines by Crammer and Singer

%
%  {'MDA','MD2','LD2','LD3','LD4','LD5','LD6','NBC','aNBC','WienerHopf','REG','LDA/GSVD','MDA/GSVD', 'LDA/sparse','MDA/sparse','RDA','GDBC','SVM','RBF'} 
% 
% CC contains the model parameters of a classifier. Some time ago,     
% CC was a statistical classifier containing the mean 
% and the covariance of the data of each class (encoded in the 
%  so-called "extended covariance matrices". Nowadays, also other 
% classifiers are supported. 
%
% see also: TEST_SC, COVM
%
% References: 
% [1] R. Duda, P. Hart, and D. Stork, Pattern Classification, second ed. 
%       John Wiley & Sons, 2001. 
% [2] Peg Howland and Haesun Park,
%       Generalizing Discriminant Analysis Using the Generalized Singular Value Decomposition
%       IEEE Transactions on Pattern Analysis and Machine Intelligence, 26(8), 2004.
%       dx.doi.org/10.1109/TPAMI.2004.46
% [3] http://www-static.cc.gatech.edu/~kihwan23/face_recog_gsvd.htm
% [4] Jieping Ye, Ravi Janardan, Cheong Hee Park, Haesun Park
%       A new optimization criterion for generalized discriminant analysis on undersampled problems.
%       The Third IEEE International Conference on Data Mining, Melbourne, Florida, USA
%       November 19 - 22, 2003
% [5] J.D. Tebbens and P. Schlesinger (2006), 
%       Improving Implementation of Linear Discriminant Analysis for the Small Sample Size Problem
%	Computational Statistics & Data Analysis, vol 52(1): 423-437, 2007
%       http://www.cs.cas.cz/mweb/download/publi/JdtSchl2006.pdf
% [6] H. Zhang, The optimality of Naive Bayes, 
%	 http://www.cs.unb.ca/profs/hzhang/publications/FLAIRS04ZhangH.pdf
% [7] J.H. Friedman. Regularized discriminant analysis. 
%	Journal of the American Statistical Association, 84:165–175, 1989.
% [8] G. Fung and O.L. Mangasarian, Proximal Support Vector Machine Classifiers, KDD 2001.
%        Eds. F. Provost and R. Srikant, Proc. KDD-2001: Knowledge Discovery and Data Mining, August 26-29, 2001, San Francisco, CA.
% 	p. 77-86.
% [9] Kai Keng Ang, Zhang Yang Chin, Haihong Zhang, Cuntai Guan.
%	Filter Bank Common Spatial Pattern (FBCSP) in Brain-Computer Interface.
%	IEEE International Joint Conference on Neural Networks, 2008. IJCNN 2008. (IEEE World Congress on Computational Intelligence). 
%	1-8 June 2008 Page(s):2390 - 2397
% [10] R.-E. Fan, K.-W. Chang, C.-J. Hsieh, X.-R. Wang, and C.-J. Lin. 
%       LIBLINEAR: A Library for Large Linear Classification, Journal of Machine Learning Research 9(2008), 1871-1874. 
%       Software available at http://www.csie.ntu.edu.tw/~cjlin/liblinear 

 
%	$Id: train_sc.m 2140 2009-07-02 12:03:55Z schloegl $
%	Copyright (C) 2005,2006,2007,2008,2009 by Alois Schloegl <a.schloegl@ieee.org>
%       This function is part of the NaN-toolbox
%       http://hci.tu-graz.ac.at/~schloegl/matlab/NaN/

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
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

if nargin<3, MODE = 'LDA'; end;
if nargin<4, W = []; end;
if ischar(MODE) 
        tmp = MODE; 
        clear MODE; 
        MODE.TYPE = tmp;
elseif ~isfield(MODE,'TYPE')
        MODE.TYPE=''; 
end;

sz = size(D);
if sz(1)~=length(classlabel),
        error('length of data and classlabel does not fit');
end;

%CC.Labels = unique(classlabel);
CC.Labels = 1:max(classlabel);

% remove all NaN's
if 1,
	% several classifier can deal with NaN's, there is no need to remove them.
elseif isempty(W)
	%% TODO: some classifiers can deal with NaN's in D. Test whether this can be relaxed.
	%ix = any(isnan([classlabel]),2);
	ix = any(isnan([D,classlabel]),2);
	D(ix,:)=[];
	classlabel(ix,:)=[];
	W = []; 
else
	%ix = any(isnan([classlabel]),2);
	ix = any(isnan([D,classlabel]),2);
	D(ix,:)=[];
	classlabel(ix,:)=[];
	W(ix,:)=[];
	warning('support for weighting of samples is still experimental');
end; 

sz = size(D);
if sz(1)~=length(classlabel),
        error('length of data and classlabel does not fit');
end;
if ~isfield(MODE,'hyperparameter')
        MODE.hyperparameter = [];
end


if 0, 

elseif ~isempty(strfind(lower(MODE.TYPE),'nbpw'))
	error('NBPW not implemented yet')
	%%%% Naive Bayesian Parzen Window Classifier. 
        for k = 1:length(CC.Labels),
                [d,CC.MEAN(k,:)] = center(D(classlabel==CC.Labels(k),:),1);
                [CC.VAR(k,:),CC.N(k,:)] = sumskipnan(d.^2,1);  
                h2_opt = (4./(3*CC.N(k,:))).^(2/5).*CC.VAR(k,:);
                %%% TODO 
        end;


elseif ~isempty(strfind(lower(MODE.TYPE),'nbc'))
	%%%% Naive Bayesian Classifier. 
	if ~isempty(strfind(lower(MODE.TYPE),'anbc'))
		%%%% Augmented Naive Bayesian classifier. 
		[CC.V,L] = eig(covm(D,'M',W)); 
		D = D*CC.V;
	else 
		CC.V = eye(size(D,2));
	end; 
        for k = 1:length(CC.Labels),
        	ix = classlabel==CC.Labels(k); 
                %% [d,CC.MEAN(k,:)] = center(D(ix,:),1);
		if ~isempty(W)
			[s,n] = sumskipnan(D(ix,:),1,W(ix));  
			CC.MEAN(k,:) = s./n; 
			d = D(ix,:) - CC.MEAN(repmat(k,sum(ix),1),:);
			[CC.VAR(k,:),CC.N(k,:)] = sumskipnan(d.^2,1,W(ix));  
		else
			[s,n] = sumskipnan(D(ix,:),1);
			CC.MEAN(k,:) = s./n; 
			d = D(ix,:) - CC.MEAN(repmat(k,sum(ix),1),:);
			[CC.VAR(k,:),CC.N(k,:)] = sumskipnan(d.^2,1);
		end
        end;
        CC.VAR = CC.VAR./max(CC.N-1,0); 
        CC.datatype = ['classifier:',lower(MODE.TYPE)];


elseif ~isempty(strfind(lower(MODE.TYPE),'lpm'))
	if ~isempty(W) 
		error(sprintf('Error TRAIN_SC: Classifier (%s) does not support weighted samples.',MODE.TYPE));
	end; 	
        % linear programming machine 
        % CPLEX optimizer: ILOG solver, ilog cplex 6.5 reference manual http://www.ilog.com
        MODE.TYPE = 'LPM';
        if ~isfield(MODE.hyperparameter,'c_value')
                MODE.hyperparameter.c_value = 1; 
        end

        M = length(CC.Labels);
        if M==2, M=1; end;   % For a 2-class problem, only 1 Discriminant is needed 
        for k = 1:M,
                %LPM = train_LPM(D,(classlabel==CC.Labels(k)),'C',MODE.hyperparameter.c_value);
                LPM = train_LPM(D',(classlabel'==CC.Labels(k)));
                CC.weights(:,k) = [-LPM.b; LPM.w(:)];
        end;
        CC.hyperparameter.c_value = MODE.hyperparameter.c_value; 
        CC.datatype = ['classifier:',lower(MODE.TYPE)];

        
elseif ~isempty(strfind(lower(MODE.TYPE),'pls')) || ~isempty(strfind(lower(MODE.TYPE),'reg'))
	% 4th version: support for weighted samples - work well with unequally distributed data: 
        % regression analysis, can handle sparse data, too. 

        M = length(CC.Labels); 

	if nargin<4,
		W = [];
	end;
	wD = [ones(size(D,1),1),D]; 

	if isempty(W)
		W = 1; 
	else	
		%% wD = diag(W)*wD
		W = W(:);
		for k=1:size(wD,2)
			wD(:,k) = W.*wD(:,k);
		end; 
	end;

	[q,r] = qr(wD,0);
	CC.weights = repmat(NaN,sz(2)+1,M);
	for k = 1:M,
		ix = 2*(classlabel==CC.Labels(k)) - 1;
		CC.weights(:,k)	= r\(q'*(W.*ix));
	end;
        CC.datatype = ['classifier:statistical:',lower(MODE.TYPE)];


elseif ~isempty(strfind(MODE.TYPE,'WienerHopf'))
        % Q: equivalent to LDA
        % equivalent to Regression, except regression can not deal with NaN's  
        M = length(CC.Labels);
        %if M==2, M==1; end;
        CC.weights = repmat(NaN,size(D,2)+1,M);
        cc = covm(D,'E',W);
        c1 = classlabel(~isnan(classlabel));
        c2 = ones(sum(~isnan(classlabel)),M);
        for k = 1:M,
		c2(:,k) = c1==CC.Labels(k);
        end; 
        CC.weights  = cc\covm([ones(size(c2,1),1),D(~isnan(classlabel),:)],2*real(c2)-1,'M',W);
        CC.datatype = ['classifier:statistical:',lower(MODE.TYPE)];


elseif ~isempty(strfind(lower(MODE.TYPE),'/gsvd'))
	if ~isempty(W) 
		error(sprintf('Error TRAIN_SC: Classifier (%s) does not support weighted samples.',MODE.TYPE));
	end; 	
	% [2] Peg Howland and Haesun Park, 2004. 
        %       Generalizing Discriminant Analysis Using the Generalized Singular Value Decomposition
        %       IEEE Transactions on Pattern Analysis and Machine Intelligence, 26(8), 2004.
        %       dx.doi.org/10.1109/TPAMI.2004.46
        % [3] http://www-static.cc.gatech.edu/~kihwan23/face_recog_gsvd.htm

        Hw = zeros(size(D)+[length(CC.Labels),0]); 
        Hb = [];
	m0 = mean(D); 
        K = length(CC.Labels); 
	for k = 1:K,
		ix = find(classlabel==CC.Labels(k));
		N(k) = length(ix); 
		[Hw(ix,:), mu] = center(D(ix,:));
		%Hb(k,:) = sqrt(N(k))*(mu(k,:)-m0);
		Hw(size(D,1)+k,:) = sqrt(N(k))*(mu-m0);  % Hb(k,:)
	end;
        try
                [P,R,Q] = svd(Hw,'econ');
        catch   % needed because SVD(..,'econ') not supported in Matlab 6.x
                [P,R,Q] = svd(Hw,0);
        end;
        t = rank(R);

        clear Hw Hb mu; 
        %[size(D);size(P);size(Q);size(R)]
        R = R(1:t,1:t);
        %P = P(1:size(D,1),1:t); 
        %Q = Q(1:t,:);
        [U,E,W] = svd(P(1:size(D,1),1:t),0);
        %[size(U);size(E);size(W)]
        clear U E P;  
        %[size(Q);size(R);size(W)]
        
        %G = Q(1:t,:)'*[R\W'];
        G = Q(:,1:t)*[R\W'];   % this works as well and needs only 'econ'-SVD
        %G = G(:,1:t);  % not needed 
        
        % do not use this, gives very bad results for Medline database
        %G = G(:,1:K); this seems to be a typo in [2] and [3].

        CC = train_sc(D*G,classlabel,MODE.TYPE(1:find(MODE.TYPE=='/')-1));
        CC.G = G; 
        if isfield(CC,'weights')
                CC.weights = [CC.weights(1,:); G*CC.weights(2:end,:)];
                CC.datatype = ['classifier:statistical:',lower(MODE.TYPE)];
        else
                CC.datatype = [CC.datatype,'/gsvd'];
        end;


elseif ~isempty(strfind(lower(MODE.TYPE),'sparse'))
	if ~isempty(W) 
		error(sprintf('Error TRAIN_SC: Classifier (%s) does not support weighted samples.',MODE.TYPE));
	end; 	
        % [5] J.D. Tebbens and P.Schlesinger (2006), 
        %       Improving Implementation of Linear Discriminant Analysis for the Small Sample Size Problem
        %       http://www.cs.cas.cz/mweb/download/publi/JdtSchl2006.pdf

        warning('sparse LDA is sensitive to linear transformations')
        M = length(CC.Labels); 
        G  = sparse([],[],[],size(D,1),M,size(D,1));
        for k = 1:M,
                G(classlabel==CC.Labels(k),k) = 1; 
        end;
        tol  = 1e-10;

        G    = train_lda_sparse(D,G,1,tol);
        CC.datatype = 'classifier:slda';
        POS1 = find(MODE.TYPE=='/'); 
        %G = v(:,1:size(G.trafo,2)).*G.trafo; 
        %CC.weights = s * CC.weights(2:end,:) + sparse(1,1:M,CC.weights(1,:),sz(2)+1,M); 
        G  = G.trafo; 
        CC = train_sc(D*G,classlabel,MODE.TYPE(1:POS1(1)-1));
        CC.G = G; 
        if isfield(CC,'weights')
                CC.weights = [CC.weights(1,:); G*CC.weights(2:end,:)];
                CC.datatype = ['classifier:statistical:',lower(MODE.TYPE)];
        else
                CC.datatype = [CC.datatype,'/sparse'];
        end;

        
elseif ~isempty(strfind(lower(MODE.TYPE),'rbf'))
	if ~isempty(W) 
		error(sprintf('Error TRAIN_SC: Classifier (%s) does not support weighted samples.',MODE.TYPE));
	end; 	

        % Martin Hieden's RBF-SVM        
        if exist('svmpredict','file')==3,
                MODE.TYPE = 'SVM:LIB:RBF';
        else
                error('No SVM training algorithm available. Install LibSVM for Matlab.\n');
        end;
        if ~isfield(MODE.hyperparameter,'gamma')
                MODE.hyperparameter.gamma = 1; 
        end
        if ~isfield(MODE.hyperparameter,'c_value')
                MODE.hyperparameter.c_value = 1; 
        end
        CC.options = sprintf('-c %g -t 2 -g %g', MODE.hyperparameter.c_value, MODE.hyperparameter.gamma);  %use RBF kernel, set C, set gamma
        CC.hyperparameter.c_value = MODE.hyperparameter.c_value; 
        CC.hyperparameter.gamma = MODE.hyperparameter.gamma; 

        % pre-whitening
        [D,r,m]=zscore(D,1); 
        CC.prewhite = sparse(2:sz(2)+1,1:sz(2),r,sz(2)+1,sz(2),2*sz(2)); 
        CC.prewhite(1,:) = -m.*r; 

        CC.model = svmtrain(classlabel, D, CC.options);    % Call the training mex File     
        CC.datatype = ['classifier:',lower(MODE.TYPE)];


elseif ~isempty(strfind(lower(MODE.TYPE),'svm11'))
	if ~isempty(W) 
		error(sprintf('Error TRAIN_SC: Classifier (%s) does not support weighted samples.',MODE.TYPE));
	end; 	
        % 1-versus-1 scheme 
        if ~isfield(MODE.hyperparameter,'c_value')
                MODE.hyperparameter.c_value = 1; 
        end
        %CC = train_svm11(D,classlabel,MODE.hyperparameter.c_value);

        CC.options=sprintf('-c %g -t 0',MODE.hyperparameter.c_value);  %use linear kernel, set C
        CC.hyperparameter.c_value = MODE.hyperparameter.c_value; 

        % pre-whitening
        [D,r,m]=zscore(D,1); 
        CC.prewhite = sparse(2:sz(2)+1,1:sz(2),r,sz(2)+1,sz(2),2*sz(2)); 
        CC.prewhite(1,:) = -m.*r; 

        CC.model = svmtrain(classlabel, D, CC.options);    % Call the training mex File
        
        FUN = 'SVM:LIB:1vs1';
        CC.datatype = ['classifier:',lower(FUN)];


elseif ~isempty(strfind(lower(MODE.TYPE),'psvm'))
	if ~isempty(W) 
		error(sprintf('Error TRAIN_SC: Classifier (%s) does not support weighted samples.',MODE.TYPE));
	end; 	
        if isfield(MODE.hyperparameters,'nu')
	        nu = MODE.hyperparameter.nu;
	else 
		nu = 1;          
        end;
        [m,n] = size(D); 
        CC.weights = repmat(NaN,n+1,length(CC.Labels));
        for k = 1:length(CC.Labels),
		d = sparse(1:m,1:m,(classlabel==CC.Labels(k))*2-1);
		H = d * [-ones(m,1),D];
		r = sum(H,1)';
		r = (speye(n+1)/nu + H' * H)\r; %solve (I/nu+H’*H)r=H’*e
		u = nu*(1-(H*r)); 
		CC.weights(:,k) = u'*H;
        end;
        CC.hyperparameter.nu = nu; 
        CC.datatype = ['classifier:',lower(MODE.TYPE)];
        

elseif ~isempty(strfind(lower(MODE.TYPE),'svm:lin4'))
	if ~isempty(W) 
		error(sprintf('Error TRAIN_SC: Classifier (%s) does not support weighted samples.',MODE.TYPE));
	end; 	

        if ~isfield(MODE.hyperparameter,'c_value')
                MODE.hyperparameter.c_value = 1; 
        end
        M = length(CC.Labels);
        if M==2, M=1; end;
        CC.weights = repmat(NaN, sz(2)+1, M);

        % pre-whitening
        [D,r,m]=zscore(D,1); 
        s = sparse(2:sz(2)+1,1:sz(2),r,sz(2)+1,sz(2),2*sz(2)); 
        s(1,:) = -m.*r; 

        CC.options = sprintf('-s 4 -c %f ', MODE.hyperparameter.c_value);      % C-SVC, C=1, linear kernel, degree = 1,
        model = train(cl, sparse(D), CC.options);    % C-SVC, C=1, linear kernel, degree = 1,
        CC.weights = model.w([end,1:end-1],:)';

        CC.weights = s * CC.weights(2:end,:) + sparse(1,1:M,CC.weights(1,:),sz(2)+1,M); % include pre-whitening transformation
        CC.hyperparameter.c_value = MODE.hyperparameter.c_value; 
        CC.datatype = ['classifier:',lower(MODE.TYPE)];


elseif ~isempty(strfind(lower(MODE.TYPE),'svm'))
	if ~isempty(W) 
		error(sprintf('Error TRAIN_SC: Classifier (%s) does not support weighted samples.',MODE.TYPE));
	end; 	

        if ~isfield(MODE.hyperparameter,'c_value')
                MODE.hyperparameter.c_value = 1; 
        end
        if any(MODE.TYPE==':'),
                % nothing to be done
        elseif exist('train','file')==3,
                MODE.TYPE = 'SVM:LIN';        %% liblinear 
        elseif exist('svmtrain','file')==3,
                MODE.TYPE = 'SVM:LIB';
        elseif exist('svmtrain','file')==2,
                MODE.TYPE = 'SVM:bioinfo';
        elseif exist('mexSVMTrain','file')==3,
                MODE.TYPE = 'SVM:OSU';
        elseif exist('svcm_train','file')==2,
                MODE.TYPE = 'SVM:LOO';
        elseif exist('svmclass','file')==2,
                MODE.TYPE = 'SVM:KM';
        elseif exist('svc','file')==2,
                MODE.TYPE = 'SVM:Gunn';
        else
                error('No SVM training algorithm available. Install OSV-SVM, or LOO-SVM, or libSVM for Matlab.\n');
        end;

        %%CC = train_svm(D,classlabel,MODE);
        M = length(CC.Labels);
        if M==2, M=1; end;
        CC.weights = repmat(NaN, sz(2)+1, M);

        % pre-whitening
        [D,r,m]=zscore(D,1); 
        s = sparse(2:sz(2)+1,1:sz(2),r,sz(2)+1,sz(2),2*sz(2)); 
        s(1,:) = -m.*r; 
        
        for k = 1:M,
                cl = sign((classlabel~=CC.Labels(k))-.5);
                if strncmp(MODE.TYPE, 'SVM:LIN',7);
                        if isfield(MODE,'options')
                                CC.options = MODE.options;
                        else
                                t = 0; 
                                if length(MODE.TYPE>7), t=MODE.TYPE(8)-'0'; end; 
                                if (t<0 || t>4) t=0; end; 
                                CC.options = sprintf('-s %i -c %f ',t, MODE.hyperparameter.c_value);      % C-SVC, C=1, linear kernel, degree = 1,
                        end;
                        model = train(cl, sparse(D), CC.options);    % C-SVC, C=1, linear kernel, degree = 1,
                        w = model.w(1:end-1)';
                        Bias = model.w(end);

                elseif strcmp(MODE.TYPE, 'SVM:LIB');
                        if isfield(MODE,'options')
                                CC.options = MODE.options;
                        else
                                CC.options = sprintf('-s 0 -c %f -t 0 -d 1', MODE.hyperparameter.c_value);      % C-SVC, C=1, linear kernel, degree = 1,
                        end;
                        model = svmtrain(cl, D, CC.options);    % C-SVC, C=1, linear kernel, degree = 1,
                        w = -cl(1) * model.SVs' * model.sv_coef;  %Calculate decision hyperplane weight vector
                        % ensure correct sign of weight vector and Bias according to class label
                        Bias  = -model.rho * cl(1);

                elseif strcmp(MODE.TYPE, 'SVM:bioinfo');
                        CC.SVMstruct = svmtrain(D, cl,'AUTOSCALE', 0);    % 
                        Bias = CC.SVMstruct.Bias;
                        w = CC.SVMstruct.Alpha'*CC.SVMstruct.SupportVectors;

                elseif strcmp(MODE.TYPE, 'SVM:OSU');
                        [AlphaY, SVs, Bias, Parameters, nSV, nLabel] = mexSVMTrain(D', cl', [0 1 1 1 MODE.hyperparameter.c_value]);    % Linear Kernel, C=1; degree=1, c-SVM
                        w = -SVs * AlphaY'*cl(1);  %Calculate decision hyperplane weight vector
                        % ensure correct sign of weight vector and Bias according to class label
                        Bias = -Bias * cl(1);

                elseif strcmp(MODE.TYPE, 'SVM:LOO');
                        [a, Bias, g, inds, inde, indw]  = svcm_train(D, cl, MODE.hyperparameter.c_value); % C = 1;
                        w = D(inds,:)' * (a(inds).*cl(inds)) ;

                elseif strcmp(MODE.TYPE, 'SVM:Gunn');
                        [nsv, alpha, Bias,svi]  = svc(D, cl, 1, MODE.hyperparameter.c_value); % linear kernel, C = 1;
                        w = D(svi,:)' * alpha(svi) * cl(1);
                        Bias = mean(D*w);

                elseif strcmp(MODE.TYPE, 'SVM:KM');
                        [xsup,w1,Bias,inds,timeps,alpha] = svmclass(D, cl, MODE.hyperparameter.c_value, 1, 'poly', 1); % C = 1;
                        w = -D(inds,:)' * w1;

                else
                        fprintf(2,'Error TRAIN_SVM: no SVM training algorithm available\n');
                        return;
                end

                CC.weights(1,k) = -Bias;
                CC.weights(2:end,k) = w;
        end;
        CC.weights = s * CC.weights(2:end,:) + sparse(1,1:M,CC.weights(1,:),sz(2)+1,M); % include pre-whitening transformation
        CC.hyperparameter.c_value = MODE.hyperparameter.c_value; 
        CC.datatype = ['classifier:',lower(MODE.TYPE)];


elseif ~isempty(strfind(lower(MODE.TYPE),'csp'))
        CC.datatype = ['classifier:',lower(MODE.TYPE)];
        CC.MD = repmat(NaN,[sz(2)+[1,1],length(CC.Labels)]);
        CC.NN = CC.MD;
        for k = 1:length(CC.Labels),
                %% [CC.MD(k,:,:),CC.NN(k,:,:)] = covm(D(classlabel==CC.Labels(k),:),'E');
        	ix = classlabel==CC.Labels(k);
        	if isempty(W)
	                [CC.MD(:,:,k),CC.NN(:,:,k)] = covm(D(ix,:), 'E');
	        else        
                        [CC.MD(:,:,k),CC.NN(:,:,k)] = covm(D(ix,:), 'E', W(ix));
                end;         
        end;
        ECM = CC.MD./CC.NN;
        NC  = size(ECM);
	W   = csp(ECM,'CSP3');
	%%% ### This is a hack ###
	CC.FiltA = 50; 
	CC.FiltB = ones(CC.FiltA,1); 
	d   = filtfilt(CC.FiltB,CC.FiltA,(D*W).^2);
	CC.csp_w = W; 
	CC.CSP = train_sc(log(d),classlabel);	


else          % Linear and Quadratic statistical classifiers 
        CC.datatype = ['classifier:statistical:',lower(MODE.TYPE)];
        CC.MD = repmat(NaN,[sz(2)+[1,1],length(CC.Labels)]);
        CC.NN = CC.MD;
	for k = 1:length(CC.Labels),
		ix = classlabel==CC.Labels(k);
		if isempty(W)
			[CC.MD(:,:,k),CC.NN(:,:,k)] = covm(D(ix,:), 'E');
		else
			[CC.MD(:,:,k),CC.NN(:,:,k)] = covm(D(ix,:), 'E', W(ix));
		end;
	end;

        ECM = CC.MD./CC.NN;
        NC  = size(ECM);
        if strncmpi(MODE.TYPE,'LD',2) || strncmpi(MODE.TYPE,'FDA',3),

                %if NC(1)==2, NC(1)=1; end;                % linear two class problem needs only one discriminant
                CC.weights = repmat(NaN,NC(2),NC(1));     % memory allocation
                type = MODE.TYPE(3)-'0';

                ECM0 = squeeze(sum(ECM,3));  %decompose ECM
                [M0,sd,COV0] = decovm(ECM0);
	        for k = 1:NC(3);
                        ecm = squeeze(ECM(:,:,k));
                        [M1,sd,COV1] = decovm(ECM0-ecm);
                        N1 = ECM0(1,1)-ecm(1,1); 
                        [M2,sd,COV2] = decovm(ecm);
                        N2 = ecm(1,1); 
                        switch (type)
                                case 2          % LD2
                                        cov = (COV1+COV2)/2;
                                case 4          % LD4
                                        cov = (COV1*N1+COV2*N2)/(N1+N2);
                                case 5          % LD5
                                        cov = COV2;
                                case 6          % LD6
                                        cov = COV1;
                                otherwise       % LD3, LDA, FDA
                                        cov = COV0; 
                        end
	        	if isfield(MODE.hyperparameter,'gamma')
	        		cov = cov + mean(diag(cov))*eye(size(cov))*MODE.hyperparameter.gamma;
        		end	
                        w = cov\(M2-M1)';
                        w0    = -M0*w;
                        CC.weights(:,k) = [w0; w];
                end;
		CC.weights = sparse(CC.weights);
		
                
        elseif strcmpi(MODE.TYPE,'RDA');
		if isfield(MODE,'hyperparameters') && isfield(MODE.hyperparameters,'lambda')  && isfield(MODE.hyperparameters,'gamma')
		        CC.hyperparameters = MODE.hyperparameters;
		else 
			error('RDA: hyperparamters lambda and/or gamma not defined')
		end; 	         
        else
                c  = size(ECM,2);
                ECM0 = sum(ECM,3);
                nn = ECM0(1,1,1);	% number of samples in training set for class k
                XC = squeeze(ECM0(:,:,1))/nn;		% normalize correlation matrix
                M  = XC(1,2:NC(2));		% mean
                S  = XC(2:NC(2),2:NC(2)) - M'*M;% covariance matrix

		try
			[v,d]=eig(S);
			U0 = v(diag(d)==0,:);
			CC.iS2 = U0*U0';  
		end;

                %M  = M/nn; S=S/(nn-1);
                ICOV0 = inv(S);
                CC.iS0 = ICOV0; 
                ICOV1 = zeros(size(S));
                for k = 1:NC(3);
                        %[M,sd,S,xc,N] = decovm(ECM{k});  %decompose ECM
                        %c  = size(ECM,2);
                        nn = ECM(1,1,k);	% number of samples in training set for class k
                        XC = squeeze(ECM(:,:,k))/nn;		% normalize correlation matrix
                        M  = XC(1,2:NC(2));		% mean
                        S  = XC(2:NC(2),2:NC(2)) - M'*M;% covariance matrix
                        %M  = M/nn; S=S/(nn-1);

                        %ICOV(1) = ICOV(1) + (XC(2:NC(2),2:NC(2)) - )/nn

                        CC.M{k}   = M;
                        CC.IR{k}  = [-M;eye(NC(2)-1)]*inv(S)*[-M',eye(NC(2)-1)];  % inverse correlation matrix extended by mean
                        CC.IR0{k} = [-M;eye(NC(2)-1)]*ICOV0*[-M',eye(NC(2)-1)];  % inverse correlation matrix extended by mean
                        d = NC(2)-1;
                        CC.logSF(k)  = log(nn) - d/2*log(2*pi) - det(S)/2;
                        CC.logSF2(k) = -2*log(nn/sum(ECM(:,1,1)));
                        CC.logSF3(k) = d*log(2*pi) + log(det(S));
                        CC.logSF4(k) = log(det(S)) + 2*log(nn);
                        CC.logSF5(k) = log(det(S));
                        CC.logSF6(k) = log(det(S)) - 2*log(nn/sum(ECM(:,1,1)));
                        CC.logSF7(k) = log(det(S)) + d*log(2*pi) - 2*log(nn/sum(ECM(:,1,1)));
                        CC.logSF8(k) = sum(log(svd(S))) + log(nn) - log(sum(ECM(:,1,1)));
                        CC.SF(k) = nn/sqrt((2*pi)^d * det(S));
                        %CC.datatype='LLBC';
                end;
        end;
end;

