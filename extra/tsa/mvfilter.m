function [x,z]=mvfilter(B,A,x,z,Mode)
% multivariate (vector) filter function
% Y = MVFILTER(B,A,X)
% [Y,Z] = MVFILTER(B,A,X,Z)
%
%  Y = MVFILTER(B,A,X) filters the data in matrix X with the
%    filter described by cell arrays A and B to create the filtered
%    data Y.  The filter is a "Direct Form II Transposed"
%    implementation of the standard difference equation:
% 
%    a0*Y(n) = b0*X(n) + b1*X(n-1) + ... + bq*X(n-q)
%                          - a1*Y(n-1) - ... - ap*Y(:,n-p)
%
%  A=[a0,a1,a2,...,ap] and B=[b0,b1,b2,...,bq] must be matrices of
%  size  Mx((p+1)*M) and Mx((q+1)*M), respectively. 
%
%  X must be of size N*M
%  a0,a1,...,ap, b0,b1,...,bq are matrices of size MxM
%  a0 is usually the identity matrix I or must be invertible 
%
% see also: MVAR 

%	Version 2.90
%	last revision 06.04.2002
%	Copyright (c) 1996-2002 by Alois Schloegl
%	e-mail: a.schloegl@ieee.org	
%
% .changelog TSA-toolbox

% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Library General Public
% License as published by the Free Software Foundation; either
% Version 2 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Library General Public License for more details.
%
% You should have received a copy of the GNU Library General Public
% License along with this library; if not, write to the
% Free Software Foundation, Inc., 59 Temple Place - Suite 330,
% Boston, MA  02111-1307, USA.


[ra, ca] = size(A);
[rb, cb] = size(B);
[M,  N]  = size(x);

if (M~=ra) | (M~=rb)
        fprintf('Warning MFILTER: dimensions do not fit\n');
end;        

%if ~isfinite(cond(A{1}))
%        fprintf('Warning VFILTER: A0 must be invertible\n');
%end;        
%warning off; 

p  = ca/M-1;
q  = cb/M-1;
oo = max(p,q);

if nargin<4,
        z = zeros(M,oo);
elseif isempty(z)
        z = zeros(M,oo);
else
        if  any(size(z)~=[oo,M])
                fprintf('Error VFILTER: size of z does not fit\n');
                [size(z),oo,M]
                return;
	end;	
end;

%%%%% normalization to A{1}=I;
if p<=q, 
        for k=1:p,
                %A{k}=A{k}/A{1};
                A(:,k*M+(1:M)) = A(:,k*M+(1:M)) / A(:,1:M);
        end;
else
        for k=0:q,
                %B{k}=B{k}/A{1};
                B(:,k*M+(1:M)) = B(:,k*M+(1:M)) / A(:,1:M);
        end;
end; 
A(:,1:M) = eye(M);

for k=1:N,
        acc = B(:,1:M) * (x(:,k) + z(:,1));  % / A{1};
	z   = [z(:,2:oo), zeros(M,1)];
        for l = 1:q,
        	z(:,l) = z(:,l) + B(:,l*M+(1:M)) * x(:,k);
        end;
        for l = 1:p,
        	z(:,l) = z(:,l) - A(:,l*M+(1:M)) * acc;
        end;
        x(:,k) = acc;
end;

