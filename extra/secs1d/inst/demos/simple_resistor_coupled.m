% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
Nelements = 99;
L  = 100e-6;          % [m] 
xm = L/2;
device.W = 1e-6 * 1e-6;
device.x  = linspace (0, L, Nelements+1)';
device.sinodes = [1:length(device.x)];

% doping profile [m^{-3}]
device.Na = zeros (size (device.x));
device.Nd = 1e23 * ones (size (device.x));

% avoid zero doping
device.D  = device.Nd - device.Na;  

% time span for simulation
tmin  = 0;
tmax  = 20;% 50;
tspan = [tmin, tmax];

Fn = Fp = zeros (size (device.x));

%% bandgap narrowing correction
device.ni = (material.ni) * exp (secs1d_bandgap_narrowing_model
                                 (device.Na, device.Nd) / constants.Vth); 

%% carrier lifetime
device.tp = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'p');
device.tn = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'n');

% initial guess for n, p, V, phin, phip
p = ((abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
     (device.D <= 0)) / 2 + 2 * device.ni.^2 ./ ...
    (abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
    (device.D > 0);

n = ((abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
     (device.D > 0)) / 2 + 2 * device.ni.^2 ./ ...
    (abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
    (device.D <= 0);

V = Fn + constants.Vth * log (n ./ device.ni);

function [Ahere, Bhere, Chere, rhere, xhere, contacts] = vbcs (t)
  persistent A1 B1 C1 x1
  persistent Ahere Bhere Chere rhere xhere contacts
  %in this case  it's not necessary for A2 B2 C2
  if (isempty (A1))
    load ("resistor_circuit_matrices_full")
    r1 = 0 * x1; r1(1) = 1;
    Ahere = [A1, zeros(size(C1)); zeros(size(C1))', 0];
    Bhere = [B1, zeros(size(C1)); zeros(size(C1))', 1];
    xhere = [x1; 0];
    rhere = [r1, zeros(size(x1)); 0, 0];
    contacts = [1, numel(x1) + 1];
  endif
  C1(4) = -min(t,1);
  Chere = [C1; 0];
endfunction

% tolerances for convergence checks
algorithm.toll       = 1e-06;
algorithm.ltol       = 1e-10;
algorithm.maxit      = 100;
algorithm.lmaxit     = 100;
algorithm.ptoll      = 1e-08;
algorithm.pmaxit     = 1000;
algorithm.colscaling = [10 1e21 1e21 1];
algorithm.rowscaling = [1e0 1e-7 1e-7 1];
algorithm.maxnpincr  = 1.0e-2;

%% compute resistance
u = secs1d_mobility_model_noscale ...
      (device, material, constants, algorithm, 
       -diff (V) ./ diff (device.x),
       V, n, p, Fn, Fp, 'n');

R_0 = sum (bim1a_rhs (device.x, 1 ./ (constants.q * u), 1 ./ n)) / device.W

%% initial guess via stationary simulation
[nin, pin, Vin, Fnin, Fpin, Jn, Jp, it, res] = secs1d_dd_gummel_map_noscale ...
    (device, material, constants, algorithm, V, n, p, Fn, Fp);  

%close all; %secs1d_logplot (device.x, device.D, 'x-'); 
pause

%% Vin = (device.x-xm)/(3*max(device.x));
%% pin = device.Na;
%% nin = device.Nd;

%% (pseudo)transient simulation
[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = secs1d_coupled_circuit_newton_reordered2 ...
                                           (device, material, constants, algorithm,
                                            Vin, nin, pin, tspan, @vbcs);

pause

%% (pseudo)transient simulation
[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = secs1d_coupled_circuit_newton ...
                                          (device, material, constants, algorithm,
                                           Vin, nin, pin, tspan, @vbcs);

%dV   = diff (V, [], 1);
%dx   = diff (device.x);
%E    = -dV ./ dx;
   
vvector  = (Fn (1, :) - Fn (end, :));
ivector  = Itot (2, :);

%R_1 = diff (vvector) ./ diff (ivector);

plotyy (tout, vvector, tout, ivector)
drawnow
   
