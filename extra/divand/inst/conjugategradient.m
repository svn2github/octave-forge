% Solve a linear system with the preconditioned conjugated-gradient method.
%
% [x] = conjugategradient(fun,b,tol,maxit,pc,pc2,x0);
% [x,Q,T] = conjugategradient(fun,b,tol,maxit,pc,pc2,x0);
%
% solves for x
% A x = b
% using the preconditioned conjugated-gradient method.
% It provides also an approximation of A:
% A \sim Q*T*Q'
%
% J(x) = 1/2 (x' b - x' A x)
% ∇ J = b - A x
% A x = b - ∇ J
% b = ∇ J(0)
%
% the columns of Q are the Lanczos vectors

% Alexander Barth 2010,2012-2013

function [x,Q,T,diag] = conjugategradient(fun,b,varargin)

n = length(b);

% default parameters
maxit = min(n,20);
minit = 0;
tol = 1e-6;
pc = [];
x0 = [];
renorm = 0;

prop = varargin;

for i=1:2:length(prop)
    if strcmp(prop{i},'minit')
        minit = prop{i+1};
    elseif strcmp(prop{i},'maxit')
        maxit = prop{i+1};
    elseif strcmp(prop{i},'tol')
        tol = prop{i+1};
    elseif strcmp(prop{i},'x0')
        x0 = prop{i+1};
    elseif strcmp(prop{i},'pc')
        pc = prop{i+1};
    elseif strcmp(prop{i},'renorm')
        renorm = prop{i+1};
    else
        
    end
end


if isempty(x0)
    % random initial vector
    x0 = randn(n,1);
end


if isempty(pc)
    % no pre-conditioning
    pc = @(x) x;
elseif isnumeric(pc)
    invM = pc;
    pc = @(x)( invM *x);
end


tol2 = tol^2;

delta = [];
gamma = [];
q = NaN*zeros(n,1);

%M = inv(invM);
%E = chol(M);


% initial guess
x = x0;

% gradient at initial guess
r = b - fun(x);

% quick exit
if r'*r < tol2
    return
end

% apply preconditioner
z = pc(r);

% first search direction == gradient
p = z;

% compute: r' * inv(M) * z (we will need this product at several
% occasions)

zr_old = r'*z;

% r_old: residual at previous iteration
r_old = r;

for k=1:maxit
    if k <= n && nargout > 1
        % keep at most n vectors
        Q(:,k) = r/sqrt(zr_old);
    end
    
    % compute A*p
    Ap = fun(p);
    %maxdiff(A*p,Ap)
    
    % how far do we need to go in direction p?
    % alpha is determined by linesearch
    
    % alpha z'*r / (p' * A * p)
    alpha(k) = zr_old / ( p' * Ap);
    
    % get new estimate of x
    x = x + alpha(k)*p;
    
    % recompute gradient at new x. Could be done by
    % r = b-fun(x);
    % but this does require an new call to fun
    r = r - alpha(k)*Ap;
    
    if renorm
        r = r - Q(:,1:k) * Q(:,1:k)' * r ;
    end
    %maxdiff(r,b-fun(x))
    
    % apply pre-conditionner
    z = pc(r);
    
    
    zr_new = r'*z;
        
    if r'*r < tol2 && k >= minit
        break
    end
    
    %Fletcher-Reeves
    beta(k+1) = zr_new / zr_old;
    %Polak-Ribiere
    %beta(k+1) = r'*(r-r_old) / zr_old;
    %Hestenes-Stiefel
    %beta(k+1) = r'*(r-r_old) / (p'*(r-r_old));
    %beta(k+1) = r'*(r-r_old) / (r_old'*r_old);
    
    
    % norm(p)
    p = z + beta(k+1)*p;
    zr_old = zr_new;
    r_old = r;
end


%disp('alpha and beta')
%figure,plot(beta(2:end))
%rg(alpha)
%rg(beta(2:end))

if nargout > 1
    kmax = size(Q,2);
    
    delta(1) = 1/alpha(1);
    
    %delta(1) - Q(:,1)'*invM*A*invM*Q(:,1)
    
    
    for k=1:kmax-1
        delta(k+1) = 1/alpha(k+1) + beta(k+1)/alpha(k);
        gamma(k) = -sqrt(beta(k+1))/alpha(k);
    end
    
    T = sparse([1:kmax   1:kmax-1 2:kmax  ],...
        [1:kmax   2:kmax   1:kmax-1],...
        [delta    gamma    gamma]);
    
    diag.iter = k;
    diag.relres = sqrt(r'*r); 
end

% Copyright (C) 2004 Alexander Barth <a.barth@ulg.ac.be>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, see <http://www.gnu.org/licenses/>.
