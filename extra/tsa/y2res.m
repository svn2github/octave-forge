function [R,MU,SD2,EM3,EM4,Max,Min,I,th1prm]=y2res(Y)
% Evaluates basic statistics of a data series
% [N,MU,SD2,EM3,EM4,Max,Min,I]=y2res(y)
% 
% OUTPUT:
% N     sum (number of samples)
% MU    mean
% SD2   variance
% EM3   skewness
% EM4   kurtosis
% Max   Maximum
% Min   Minimum 
% I     entropy
%
% [N,MU,SD2,EM3,EM4,Max,Min,I]=y2res(y)
%
% REFERENCES:
% [1] http://www.itl.nist.gov/
% [2] http://mathworld.wolfram.com/

%	Version 2.99
%	Copyright (C) 1996-2002 by Alois Schloegl <a.schloegl@ieee.org>	


[R.SUM, R.N, R.SSQ, R.S4P] = sumskipnan(Y,1);
%R.S3P = sumskipnan(Y.^3,1);
%R.S4P = sumskipnan(Y.^4,1);
%R.S5P = sumskipnan(Y.^5,1);

R.MEAN	= R.SUM./R.N;
R.MSQ   = R.SSQ./R.N;
R.RMS	= sqrt(R.MSQ);
R.SSQ0  = R.SSQ-R.SUM.*R.MEAN;		% sum square of mean removed

if flag_implicit_unbiased_estim,
    n1 	= max(R.N-1,0);			% in case of n=0 and n=1, the (biased) variance, STD and STE are INF
else
    n1	= R.N;
end;

R.VAR  	= R.SSQ0./n1;	     		% variance (unbiased) 
R.STD  	= sqrt(R.VAR);		     	% standard deviation
R.SEM  	= sqrt(R.SSQ0./(R.N.*n1)); 	% standard error of the mean
R.Coefficient_of_variation = R.STD./R.MEAN;

R.CM2	= R.SSQ0./n1;

R.Max = max(Y,[],1);
R.Min = min(Y,[],1);

Y       = Y - repmat(R.MEAN,size(Y)./size(R.MEAN));
R.CM3 	= sumskipnan(Y.^3,1)./n1;
R.CM4 	= sumskipnan(Y.^4,1)./n1;
%R.CM5 	= sumskipnan(Y.^5,1)./n1;

R.skewness = R.CM3./(R.STD.^3);
R.kurtosis = R.CM4./(R.VAR.^2)-3;

return;

[nr,nc]=size(Y);
if nr==1 
        Y=Y';
        nr=nc; nc=1;
end;

N=ones(1,nc);
MU=ones(1,nc);
SD2=ones(1,nc);
EM2=ones(1,nc);
EM4=ones(1,nc);
Max=ones(1,nc);
Min=ones(1,nc);
I=ones(1,nc);
th1prm=ones(2,nc); %Threshold of 0.1% (1 promille) false detection

%R1prm is ratio to make 0.1% error in case of a normal distribution *P([-z z])=0.1% =3.291/ )/z(p=50%)
%tmp=sqrt(2)*erfinv([0.001,0.5]-1);
%R1prm=tmp(1)/tmp(2);
q1=0.3;
R1prm = erfinv(0.000001-1)/erfinv(-2*q1);
%q2=1-q1;
%R1prm=erfinv(0.001-1)/erfinv(0.5-1);

q1=0.25;
R1prm = erfinv(0.001-1)/erfinv(-2*q1);

%R1prm=exp(diff(-log(-sqrt(2)*erfinv([0.001,0.5]-1))));
%R1prm=exp(diff(-log(-sqrt(2)*erfinv([0.001,0.5]-1))));

MODE=nan*ones(1,nc);

for k=1:nc,
        tmp = sort(Y(:,k));
	dsY = diff(tmp);
	delta(k) = min(dsY(dsY>0)); %minimal Bin-width

        Q0500(k) = flix(tmp,N(k)/2   + 0.5);
        Q0250(k) = flix(tmp,N(k)/4   + 0.5);
        Q0750(k) = flix(tmp,N(k)*3/4 + 0.5);
end;

if nargout<2,
    RES.delta =delta;
    RES.N   = N;
    RES.MU  = MU;
    RES.SD2 = SD2;
    RES.SD  = sqrt(SD2);
    		%normalized 2nd moment (coefficient of variation1)
    RES.Coefficient_of_variation=RES.SD./RES.MU;
    %RES.em2=RES.SD./RES.MU;
	 	%normalized 3rd moment (coefficient of skewness)
    %RES.n3m = EM3./(RES.SD2.*RES.SD);
    RES.EM3 = EM3;
    RES.EM4 = EM4;
    		%normalized 4th moment (coefficient of kurtosis)
    %RES.n4m = EM4./(SD2.*SD2);
    RES.em4 = EM4./(SD2.*SD2)-3;
    RES.Max = Max;
    RES.Min = Min;
    RES.ENTROPY = I;
    RES.NormEntropy = log2(sqrt(2*pi*exp(1)))+log2(RES.SD);
    RES.MEDIAN      = Q0500;
    RES.Quantiles   = [Q0250' Q0500' Q0750'];
    RES.MODE = MODE;
    RES.Skewness.Pearson_Mode   = (MU-MODE)./RES.SD;
    RES.Skewness.Pearson_coeff1 = (3*MU-MODE)./RES.SD;
    RES.Skewness.Pearson_coeff2 = (3*MU-RES.MEDIAN)./RES.SD;
    RES.Skewness.Fisher = (EM3)./(RES.SD.^3);
    RES.Skewness.Bowley = (Q0750+Q0250 - 2*Q0500)./(Q0750-Q0250); % quartile skewness coefficient
    		%normalized 2nd moment (coefficient of variation1)
    RES.Coefficient_of_variation = RES.SD./RES.MU;
else
    RES=N;
end;

