% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
Nelements = 100;
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
tmax  = 1;
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

function [g, j, r] = vbcs (t, dt);
  g =  [1; 1];
  j =  [t  0];
  r =  [0  0];
endfunction

% tolerances for convergence checks
algorithm.toll       = 1e-6;
algorithm.ltol       = 1e-10;
algorithm.maxit      = 100;
algorithm.lmaxit     = 100;
algorithm.ptoll      = 1e-12;
algorithm.pmaxit     = 1000;
algorithm.colscaling = [10 1e21 1e21 1];
algorithm.rowscaling = [1e7 1e-7 1e-7 1];
algorithm.maxnpincr  = 1e-3;

%% compute resistance
u = secs1d_mobility_model_noscale ...
      (device, material, constants, algorithm, 
       -diff (V) ./ diff (device.x),
       V, n, p, Fn, Fp, 'n');

R_0 = sum (bim1a_rhs (device.x, 1 ./ (constants.q * u), 1 ./ n)) / device.W

%% initial guess via stationary simulation
[nin, pin, Vin, Fnin, Fpin, Jn, Jp, it, res] = secs1d_dd_gummel_map_noscale ...
    (device, material, constants, algorithm, V, n, p, Fn, Fp);  

close all; secs1d_logplot (device.x, device.D, 'x-'); pause

%% (pseudo)transient simulation
[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = secs1d_newton_res (device, material, constants, algorithm,
                                                           Vin, nin, pin, tspan, @vbcs);

dV   = diff (V, [], 1);
dx   = diff (device.x);
E    = -dV ./ dx;
   
vvector  = (Fn (1, :) - Fn (end, :));
ivector  = Itot (2, :);

R_1 = diff (vvector) ./ diff (ivector)

plotyy (tout, vvector, tout, ivector)
drawnow
   
