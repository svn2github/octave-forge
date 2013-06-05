pkg load secs1d
clear all
close all

% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
L  = 20e-6;          % [m] 
x1 = L/10;
x2 = x1 + L - 3*L/10;
x3 = x2 + L/10;

Nelements1 = 3000;
Nelements2 = 3000;
Nelements3 = 3000;
Nelements4 = 3000;
Nelements  = Nelements1 + Nelements2 + Nelements3 + Nelements4;

device.x   = [(linspace (0, x1, Nelements1+1)(1:end-1))'
              (linspace (x1, x2, Nelements2+1)(1:end-1))'
              (linspace (x2, x3, Nelements3+1)(1:end-1))'
              (linspace (x3, L, Nelements4+1)(1:end))'];
device.sinodes = [1:length(device.x)];

% doping profile [m^{-3}]
device.Nd  = 1e19 * ones (size (device.x));
device.Nd += 1e23 * exp (-(device.x - L) .^2 / (.3 * (L - x3)) .^ 2 / 2);
device.Na  = 1e22 * exp (-(device.x) .^2 / (.3 * x1) .^ 2 / 2);
device.Na += 1e22 * exp (-(device.x - L) .^2 / (.3 * (L - x2)) .^ 2 / 2);

% avoid zero doping
device.D  = device.Nd - device.Na;  

% time span for simulation
tmin = 0;
tmax = 5;
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

function fn = vbcs_1 (t);
  fn = [0; 0];
  %fn(2) = t;
endfunction

function fp = vbcs_2 (t);
  fp = [0; 0];
  %fp(2) = t;
endfunction

vbcs = {@vbcs_1, @vbcs_2};

% tolerances for convergence checks
algorithm.toll  = 1e-4;
algorithm.maxit = 100;
algorithm.ptoll = 1e-12;
algorithm.pmaxit = 100;
algorithm.maxnpincr = constants.Vth;
algorithm.colscaling = [1 1e23 1e23];
algorithm.rowscaling = [1 1e7 1e7];
algorithm.maxnpincr = constants.Vth / 10;

logplot = @(x) asinh (x/2) / log(10);
close all; plot (device.x, logplot (device.D)); 
set (gca, "yticklabel",
     arrayfun (@(x) sprintf ("%s10^{%g}", ifelse (x >=0, "+", "-"), abs(x)),
               get (gca, "ytick"), "uniformoutput", false));
pause

%% initial guess via stationary simulation
[Vin, nin, pin, res, niter] = ...
    secs1d_nlpoisson_newton_noscale (device, material, 
                                     constants, algorithm, 
                                     V, n, p, Fn, Fp);

close all; semilogy (device.x, nin, 'x-', device.x, pin, 'x-');
hold on
semilogy (device.x, device.Na, device.x, device.Nd);
hold off
pause

%% initial guess via (pseudo)transient simulation
[n, p, V, Fn, Fp, Jn, Jp, t, it, res] = ...
    secs1d_tran_dd_newton_noscale (device, material, constants, algorithm,
                                       Vin, nin, pin, Fn, Fp, tspan, vbcs);

Vin = V(:, end);
nin = n(:, end);
pin = p(:, end);
Fnin = Fn(:, end);
Fpin = Fp(:, end);

function fn = vbcs_1 (t);
  fn = [0; 0];
  fn(2) = -10*2*t/7;
endfunction

function fp = vbcs_2 (t);
  fp = [0; 0];
  fp(2) = -10*2*t/7;
endfunction

vbcs = {@vbcs_1, @vbcs_2};

%% (pseudo)transient simulation with negative applied volatage
# [n, p, V, Fn, Fp, Jn, Jp, t, it, res] = ...
#     secs1d_tran_dd_gummel_map_noscale (device, material, constants, algorithm,
#                                        V(:, end), n(:, end), p(:, end), 
#                                        Fn(:, end), Fp(:, end), tspan, vbcs);

[n, p, V, Fn, Fp, Jnneg, Jpneg, t, it, res] = ...
    secs1d_tran_dd_newton_noscale (device, material, constants, algorithm,
                                   Vin, nin, pin, 
                                   Fnin, Fpin, tspan, vbcs);
vvectorneg  = Fn(end, :);

function fn = vbcs_1 (t);
  fn = [0; 0];
  fn(2) = 80*t;
endfunction

function fp = vbcs_2 (t);
  fp = [0; 0];
  fp(2) = 80*t;
endfunction

vbcs = {@vbcs_1, @vbcs_2};

%% (pseudo)transient simulation with positive applied volatage
# [n, p, V, Fn, Fp, Jn, Jp, t, it, res] = ...
#     secs1d_tran_dd_gummel_map_noscale (device, material, constants, algorithm,
#                                        V(:, end), n(:, end), p(:, end), 
#                                        Fn(:, end), Fp(:, end), tspan, vbcs);

[n, p, V, Fn, Fp, Jnpos, Jppos, t, it, res] = ...
    secs1d_tran_dd_newton_noscale (device, material, constants, algorithm,
                                       Vin, nin, pin, 
                                       Fnin, Fpin, tspan, vbcs);

vvectorpos  = Fn(end, :);
ivectorpos  = (Jnpos(end, :) + Jppos(end, :));
ivectorneg  = (Jnneg(end, :) + Jpneg(end, :));

plot (vvectorpos, ivectorpos, vvectorneg, ivectorneg)
drawnow