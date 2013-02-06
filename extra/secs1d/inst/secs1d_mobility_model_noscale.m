%% Copyright (C) 2013 Carlo de Falco, Davide Cagnoni, Fabio Mauri
%%
%% This file is part of 
%% SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
%%
%% SECS1D is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% SECS1D is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with SECS1D; If not, see <http://www.gnu.org/licenses/>.

%% u = secs1d_mobility_model_noscale (x, n, p, Na, Nd, E, carrier)
%% FIXME: add documentation!!

function u = secs1d_mobility_model_noscale (x, n, p, Na, Nd, E, carrier)

  t = 300*ones(size(n));          %[K]
  t_300 = 300;                    %[K]
  t_elem =  .5*t(2:end) + .5*t(1:end-1);
  
  Neff = Na + Nd;                 %[m^-3]
  Neff = (Neff(1:end-1) + Neff(2:end)) / 2;
  
  if (carrier =='n')
    %% FIXME: move parameters to material properties file
    %% Electrons reference values 
    vsat      = 1.07e5;         %[m/s]
    beta      = 1.109 ;         %[-]
    b_exp     = 0.66  ;         %[-]
    alpha     = 0.0   ;         %[-]
    vsat_exp  = 0.87  ;         %[-]
    
    beta_m = beta * (t_elem/t_300).^b_exp;
    vsat_m = vsat * (t_elem/t_300).^(-vsat_exp);
    
    mu_ph_nodes = mobility_model_philips_n (n,p,Na,Nd,t); %[m^2/Vs]
    
  elseif (carrier =='p')
    %% %% Hole reference values 
    vsat      = 8.37e4;         %[m/s]
    beta      = 1.213 ;         %[-]
    b_exp     = 0.17  ;         %[-]
    alpha     = 0.0   ;         %[-]
    vsat_exp  = 0.52  ;         %[-]
    
    beta_m = beta * (t_elem/t_300).^b_exp;
    vsat_m = vsat * (t_elem/t_300).^(-vsat_exp);
    
    mu_ph_nodes = mobility_model_philips_p (n,p,Na,Nd,t); %[m^2/Vs]
  else
    error ("Mobility models only defined for electons (carrier=\'n\') or holes (carrier=\'p\')")
  endif

  
  muph  = .5*mu_ph_nodes(2:end) + .5*mu_ph_nodes(1:end-1);
  
  u     = (muph*(alpha +1)) ./ ...
      (alpha + (1 + (((alpha + 1) * muph .* abs(E)) ./ vsat_m) .^ beta_m) .^ 
       (1./beta_m));

endfunction

function mu = mobility_model_philips_n (n, p, n_a, n_d, t)

%%%% MODEL PARAMETERS %% FIXME: move to material properties file
%% Klaasseen parameters
  a_g           =  0.89233;     %[-]
  b_g           =  0.41372;     %[-]  
  c_g           =  0.005978;    %[-]
  alpha_g       =  0.28227;     %[-]
  alpha_prime_g =  0.72169;     %[-]
  beta_g        =  0.19778;     %[-]
  gamma_g       =  1.80618;     %[-]

  %%  %% Meyer parameters
  %%  %% currently discarded
  %%  a_g = 4.41804;
  %%  b_g = 39.9014;
  %%  c_g = 0.52896;
  %%  alpha_g = 0.0001;
  %%  alpha_prime_g = 1.595787;
  %%  beta_g = 0.38297;
  %%  gamma_g = 0.25948;
  
  %% Silicon parameters
  %m_0      =   1.000;           %[kg] mass unit
  m_n_star =   1.000;           %[-] effective mass in m_0 units
  m_p_star =   1.258;           %[-] effective mass in m_0 units
  f_cw     =   2.459;           %[-] 
  f_bh     =   3.828;           %[-]
  t_300    = 300.000;           %[K]
  
  %% Electrons phosphorous doped silicon
  mu_max  = 0.14140;            %[m^2/Vs]
  mu_min  = 0.00685;            %[m^2/Vs]
  theta   = 2.285;              %[-]
  n_ref   = 9.2e22;             %[m^-3]
  alpha   = 0.711;              %[-]
  n_d_ref = 4.0e26;             %[m^-3]
  n_a_ref = 7.2e26;             %[m^-3]
  c_d     = 0.21;               %[-]
  c_a     = 0.5;                %[-]
  pp_min  = 0.324612837783984;  %[-]


  n_d_star = n_d .* (1.0 + 1.0 ./(c_d + (n_d_ref ./ n_d).^2));
  n_a_star = n_a .* (1.0 + 1.0 ./(c_a + (n_a_ref ./ n_a).^2));

  n_sc = n_d_star + n_a_star + p;

  k_1 = 3.97e17;                 %[m^-2]
  k_2 = 1.36e26;                 %[m^-3]
  pp = (t / t_300).^2  ./ ...
       (f_cw ./ (k_1 * n_sc.^(-2.0/3.0)) + 
	(n+p) * (f_bh/(k_2*m_n_star)));

  f = (0.7643 * pp.^(0.6478) + 2.2999 + 6.5502 * (m_n_star / m_p_star)) ./ ...
      (pp.^(0.6478) + 2.3670 - 0.8552 * (m_n_star / m_p_star));

  pbool = (pp < pp_min);
  ppp   = (pbool * pp_min) + (1 - pbool) .* pp;
    
  g   = 1.0 - ... 
      a_g ./ ((b_g+ppp.*(t/(m_n_star*t_300)).^alpha_g).^beta_g) + ...
      c_g ./ ((ppp./(t/(m_n_star*t_300)).^alpha_prime_g).^gamma_g);

  n_sc_eff = n_d_star + g .* n_a_star + p ./ f;

  mu_c = ((mu_max * mu_min) / (mu_max - mu_min)) .* sqrt (t_300 ./ t);
  mu_n = (mu_max^2 / (mu_max - mu_min)) .* (t / t_300) .^ (3.0 *(alpha - 0.5));
  mu_daeh = mu_n .* (n_sc ./ n_sc_eff) .* (n_ref ./ n_sc) .^ ...
      alpha  + mu_c .* ((n + p) ./ n_sc_eff);

  mu_l = mu_max .* (t / t_300) .^ (-theta);
  mu = 1.0 ./ (1.0 ./ mu_l + 1.0 ./ mu_daeh);

endfunction


function mu = mobility_model_philips_p (n, p, n_a, n_d, t)

%%%% MODEL PARAMETERS %% FIXME: move to material properties file
  %% Klaasseen parameters
  a_g           =  0.89233;     %[-]
  b_g           =  0.41372;     %[-]  
  c_g           =  0.005978;    %[-]
  alpha_g       =  0.28227;     %[-]
  alpha_prime_g =  0.72169;     %[-]
  beta_g        =  0.19778;     %[-]
  gamma_g       =  1.80618;     %[-]
  
  %%  %% Meyer parameters
  %%  %% currently discarded
  %%  a_g = 4.41804;
  %%  b_g = 39.9014;
  %%  c_g = 0.52896;
  %%  alpha_g = 0.0001;
  %%  alpha_prime_g = 1.595787;
  %%  beta_g = 0.38297;
  %%  gamma_g = 0.25948;
  
  
  %% Silicon parameters
  %m_0      =   1.000;           %[kg] mass unit
  m_n_star =   1.000;           %[-] effective mass in m_0 units
  m_p_star =   1.258;           %[-] effective mass in m_0 units
  f_cw     =   2.459;           %[-] 
  f_bh     =   3.828;           %[-]
  t_300    = 300.000;           %[K]
  
  %% Holes phosphorous doped silicon
  mu_max  = 0.04705;            %[m^2/Vs]
  mu_min  = 0.00449;            %[m^2/Vs]
  theta   = 2.247;              %[-]
  n_ref   = 2.23e23;            %[m^-3]
  alpha   = 0.719;              %[-]
  n_d_ref = 4.0e26;             %[m^-3]
  n_a_ref = 7.2e26;             %[m^-3]
  c_d     = 0.21;               %[-]
  c_a     = 0.5;                %[-]
  pp_min  = 0.28914605;         %[-]


  n_d_star = n_d .* (1.0 + 1.0 ./ (c_d + (n_d_ref ./ n_d).^ 2));
  n_a_star = n_a .* (1.0 + 1.0 ./ (c_a + (n_a_ref ./ n_a).^ 2));

  n_sc = n_d_star + n_a_star + n;

  k_1 = 3.97e17;                 %[m^-2]
  k_2 = 1.36e26;                 %[m^-3]

  pp = (t / t_300).^2  ./ (f_cw ./ (k_1 * n_sc .^ (-2.0/3.0)) +
			   (n + p) * (f_bh / (k_2 * m_p_star)));

  f = (0.7643 * pp .^ (0.6478) + 2.2999 + 6.5502 * (m_p_star / m_n_star)) ./ ...
      (pp .^ (0.6478) + 2.3670 - 0.8552 * (m_p_star / m_n_star));

  pbool = (pp < pp_min);
  ppp   = (pbool * pp_min) + (1 - pbool) .* pp;
    
  g   = 1.0 - ...
      a_g ./ ((b_g+ppp.*(t/(m_p_star*t_300)).^alpha_g).^beta_g) + ...
      c_g ./ ((ppp./(t/(m_p_star*t_300)).^alpha_prime_g).^gamma_g);

  n_sc_eff = n_a_star + g .* n_d_star + n ./ f ;

  mu_c = ((mu_max * mu_min) / (mu_max - mu_min)) .* sqrt (t_300 ./ t);
  mu_p = (mu_max ^ 2 / (mu_max - mu_min)) .*(t / t_300) .^ (3.0 * (alpha - 0.5));
  mu_daeh = mu_p .* (n_sc ./ n_sc_eff) .* (n_ref ./ n_sc) .^ ...
      alpha  + mu_c .* ((n + p) ./ n_sc_eff);

  mu_l = mu_max .* (t / t_300) .^ (-theta);
  mu = 1.0 ./ (1.0 ./ mu_l + 1.0 ./ mu_daeh);

endfunction
