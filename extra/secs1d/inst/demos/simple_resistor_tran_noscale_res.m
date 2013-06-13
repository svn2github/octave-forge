% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
Nelements = 10;
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
tmax  = 16;
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

function [g, j, r] = vbcs (t, dt, x1)
  persistent A1 B1 C1
  %in this case  it's not necessary for A2 B2 C2
  if (isempty (A1))
    load ("resistor_circuit_matrices")
  endif
  C1(4) = -min(t,1);
  [g(1) j(1) r(1)] = coupled_circuit_coeff (A1, B1, C1, dt, x1);
  g(2) = 1;   j(2) = 0;   r(2) = 0;
endfunction


function [x1, x2] = update_states (t, dt, F1)
  persistent A1 B1 C1 x1 x2 %A2 B2 C2 x2
  persistent a22 b21 b22
  if (isempty (A1))
    load ("resistor_circuit_matrices")
    x2 = [];
    a22 = A1(2:end,2:end);
    b21 = B1(2:end,1);
    b22 = B1(2:end,2:end);
  else
    C1(4) = -min(t,1);
    e22 = a22/dt+b22;
    P = spdiags(1 ./ max(abs(e22),[],2));
    f2 = C1(2:end);
    w  = P * (((a22 * x1) / dt) - f2 - b21 * F1);
    eprec = P * e22;
    x1 = eprec \ w;
  endif
endfunction

% tolerances for convergence checks
algorithm.toll       = 1e-06;
algorithm.ltol       = 1e-10;
algorithm.maxit      = 100;
algorithm.lmaxit     = 100;
algorithm.ptoll      = 1e-08;
algorithm.pmaxit     = 1000;
algorithm.colscaling = [10 1e21 1e21 1];
algorithm.rowscaling = [1e7 1e-7 1e-7 1];
algorithm.maxnpincr  = 5e-5;

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
[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = secs1d_newton_res ...
                                          (device, material, constants, algorithm,
                                           Vin, nin, pin, tspan, @vbcs, @update_states);

dV   = diff (V, [], 1);
dx   = diff (device.x);
E    = -dV ./ dx;
   
vvector  = (Fn (1, :) - Fn (end, :));
ivector  = Itot (2, :);

R_1 = diff (vvector) ./ diff (ivector)

plotyy (tout, vvector, tout, ivector)
drawnow
   
