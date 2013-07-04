% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
Nelements = 500;
L  = 1e-6;          % [m] 
xm = L/2;
device.W = 1e-6 * 1e-6;
device.x  = linspace (0, L, Nelements+1)';
device.sinodes = [1:length(device.x)];

% doping profile [m^{-3}]
device.Na = 1e23 * exp ( - .5 * device.x.^2 / xm^2);
device.Nd = 1e23 * exp ( - .5 * (device.x - L) .^2 / xm^2);

% avoid zero doping
device.D  = device.Nd - device.Na;  

% time span for simulation
tmin  = 0;
tmax  = 1e-4;
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
  Ahere = zeros(2);
  Bhere = eye(2);
  xhere = [0; 0];
  rhere = [0, 0; 0, 0];
  contacts = [1, 2];
  C1 = sin(2*pi*t/1e-4);
  Chere = [C1; 0];
endfunction

% tolerances for convergence checks
algorithm.toll       = 1e-5;
algorithm.ltol       = 1e-10;
algorithm.maxit      = 100;
algorithm.lmaxit     = 100;
algorithm.ptoll      = 1e-12;
algorithm.pmaxit     = 1000;
algorithm.colscaling = [10 1e21 1e21 .1];
algorithm.rowscaling = [1  1e-7 1e-7 .1];
algorithm.maxnpincr  = 1e-2;

%% initial guess via stationary simulation
[nin, pin, Vin, Fnin, Fpin, Jn, Jp, it, res] = secs1d_dd_gummel_map_noscale ...
    (device, material, constants, algorithm, V, n, p, Fn, Fp);  

close all; secs1d_logplot (device.x, device.D, 'x-'); pause

%%%% (pseudo)transient simulation
%%[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = secs1d_coupled_circuit_newton ...
%%                                           (device, material, constants, algorithm,
%%                                            Vin, nin, pin, tspan, @vbcs);
%%
pause

%% (pseudo)transient simulation
[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = secs1d_coupled_circuit_newton_reordered2 ...
                                          (device, material, constants, algorithm,
                                           Vin, nin, pin, tspan, @vbcs);

% dV   = diff (V, [], 1);
% dx   = diff (device.x);
% E    = -dV ./ dx;
   
vvector  = (Fn(end, :) - Fn(1, :));
ivector  = Itot (2, :);

plotyy (tout, vvector, tout, ivector)
drawnow
   
