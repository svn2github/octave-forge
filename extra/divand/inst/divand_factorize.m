% Factorize some matrices to increase performance.
%
% s = divand_factorize(s)
%
% Create the inverse of the posteriori covariance matrix
% and factorize
%
% Input:
%   s: structure created by divand_background
%
% Output:
%   s.P: factorized P


function s = divand_factorize(s)

R = s.R;
iB = s.iB;
H = s.H;

if s.primal
    if strcmp(s.inversion,'chol')
        iP = iB + H'*(R\H);
        P = CovarIS(iP);

        % Cholesky factor of the inverse of a posteriori
        % error covariance iP
        if s.factorize
            P = factorize(P);
        end
        
        s.P = P;
    else
      tic
        [s.M1,s.M2] = s.compPC(iB,H,R);
      s.pc_time = toc();
    end
else % dual
    %C = H * (iB \ H') + R;
    s.B = CovarIS(iB);
    % pre-conditioning function for conjugate gradient
    s.funPC = [];
    
    if s.factorize
        s.B = factorize(s.B);
        
        % iM = inv(H * B * H' + sparse_diag(diag(R)))
        % iM * (H * B * H' + R) is identify matrix if R is diagonal
        
        M = H * (s.B * H') + sparse_diag(diag(R));
        %M = H * (s.B * H') + sparse_diag(sum(R,1));
        iM = CovarIS(M);
        iM = factorize(iM);
        
        % pre-conditioning function for conjugate gradient
        s.funPC = @(x) iM*x;
        
        if 0
            C = H * (s.B * H') + sparse_diag(diag(R));
            [RC, q, QC] = chol (C);
            s.funPC = @(x) RC' \ (QC*x);
            
        end
    end
end

% LocalWords:  divand

% Copyright (C) 2014 Alexander Barth <a.barth@ulg.ac.be>
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
