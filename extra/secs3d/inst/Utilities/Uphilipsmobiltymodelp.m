%% Copyright (C) 2004,2007,2008,2009,2010,2011  Carlo de Falco
%%
%% This file is part of:
%%     secs3d - A 3-D Drift--Diffusion Semiconductor Device Simulator 
%%
%%  secs3d is free software; you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation; either version 2 of the License, or
%%  (at your option) any later version.
%%
%%  secs3d is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with secs3d; If not, see <http://www.gnu.org/licenses/>.
%%
%%  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

function mu_b = Uphilipsmobiltymodelp (n, p, N_D, N_A, T)

  %% Meyer parameters
  a_g = 4.41804;
  b_g = 39.9014;
  c_g = 0.52896;
  alpha_g = 0.0001;
  alpha_prime_g = 1.595787;
  beta_g = 0.38297;
  gamma_g = 0.25948;
  
  %% Holes Boron doped Silicon
  mu_max = 470.5;
  mu_min = 44.9;
  theta  = 2.247;
  N_ref  = 2.23e17;
  alpha  = 0.719;
  N_D_ref = 4e20;
  N_A_ref = 7.2e20;
  c_D     = .21;
  c_A     = .5;

  %% Silicon
  m_0 = 1;
  m_n_star = 1;
  m_p_star = 1.258;
  f_CW = 2.459;
  f_BH = 3.828;

  T_300 = 300;                                   

  N_D_star = N_D .* (1 + 1 ./ (c_D + (N_D_ref ./ N_D) .^ 2));
  N_A_star = N_A .* (1 + 1 ./ (c_A + (N_A_ref ./ N_A) .^ 2));

  N_sc = N_D_star + N_A_star + n;

  F = @(P) fF (P, m_n_star, m_p_star);
  G = @(P) fG (P, T, T_300, m_p_star, m_0, a_g, b_g, c_g, alpha_g, alpha_prime_g, beta_g, gamma_g);

  P = (T ./ T_300).^2 ./ (f_CW ./ (3.97e13 .* N_sc .^ (-2/3)) + f_BH ./ ( 1.36e20 .* m_p_star ./ (m_0 .* (n + p))));

  N_sc_eff = N_A_star + G(P) .* N_D_star + n ./ F(P);

  mu_c = ((mu_max .* mu_min) ./ (mu_max - mu_min)) .* (T./T_300).^(1/2);
  mu_N = (mu_max.^2 ./ (mu_max - mu_min)) .* (T./T_300).^(3.*(alpha - 1/2));
  mu_DAeh = mu_N .* (N_sc ./ N_sc_eff) .* (N_ref ./ N_sc) .^ alpha + mu_c .* ((n + p) ./ N_sc_eff);
  
  mu_L = mu_max .* (T ./ T_300) .^ (-theta);
  mu_b = 1 ./ (1./mu_L + 1./mu_DAeh);
         

endfunction

function F = fF (P, m_n_star, m_p_star)
  F = (0.7643 .* P .^ (0.6478) + 2.2999 + 6.5502 .* (m_p_star ./ m_n_star)) ./ ...
      (P .^ (0.6478) + 2.3670 - 0.8552 .* (m_p_star ./ m_n_star));
endfunction

function G = fG (P, T, T_300, m_p_star, m_0, a_g, b_g, c_g, alpha_g, alpha_prime_g, beta_g, gamma_g)
  G = 1 - a_g ./ (b_g + P .* (m_0 .* T ./ (m_p_star .* T_300)) .^ alpha_g) .^ beta_g + ...
      c_g ./ (P .* (m_0 .* T ./ (m_p_star .* T_300)) .^ alpha_prime_g) .^ gamma_g;
endfunction

%!demo
%! N_A = logspace (14, 20, 30);
%! N_D = 1e12;
%! p = N_A;
%! ni = 1.3e10;
%! n = ni .^ 2 ./ p; 
%! T = 300;
%! mu_b = Uphilipsmobiltymodelp (n, p, N_D, N_A, T);
%! semilogx (N_A, mu_b)
%! title ('majority holes')
%! axis tight

%!demo
%! N_A = logspace (18, 22, 30);
%! N_D = 1e12;
%! p = N_A;
%! ni = 1.3e10;
%! n = ni .^ 2 ./ p; 
%! T = 300;
%! mu_b = Uphilipsmobiltymodelp (n, p, N_D, N_A, T);
%! semilogx (N_A, mu_b)
%! title ('majority holes')
%! axis tight

%!demo
%! N_D = logspace (14, 20, 30);
%! N_A = 1e12;
%! n = N_D;
%! ni = 1.3e10;
%! p = ni .^ 2 ./ n; 
%! T = 300;
%! mu_b = Uphilipsmobiltymodelp (n, p, N_D, N_A, T);
%! semilogx (N_D, mu_b)
%! title ('minority holes')
%! axis tight

%!demo
%! N_D = logspace (18, 22, 30);
%! N_A = 1e12;
%! n = N_D;
%! ni = 1.3e10;
%! p = ni .^ 2 ./ n; 
%! T = 300;
%! mu_b = Uphilipsmobiltymodelp (n, p, N_D, N_A, T);
%! semilogx (N_D, mu_b)
%! title ('minority holes')
%! axis tight
