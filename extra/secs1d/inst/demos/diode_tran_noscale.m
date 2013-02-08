% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
L  = 10e-6;          % [m] 
xm = L/2;

Nelements = 1000;
device.x       = linspace (0, L, Nelements+1)';
device.sinodes = [1:length(device.x)];

% doping profile [m^{-3}]
device.Na = 1e24 * exp(-(3*device.x/L).^2);
device.Nd = 1e24 * exp(-(3*(device.x-L)/L).^2);

% avoid zero doping
device.D  = device.Nd - device.Na;  

% time span for simulation
tmin = 0;
tmax = 29.9;
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
  fn(2) = t;
endfunction

function fp = vbcs_2 (t);
  fp = [0; 0];
  fp(2) = t;
endfunction

vbcs = {@vbcs_1, @vbcs_2};

% tolerances for convergence checks
algorithm.toll  = 1e-10;
algorithm.maxit = 1000;
algorithm.ptoll = 1e-12;
algorithm.pmaxit = 1000;
algorithm.maxnpincr = constants.Vth;

%% initial guess via stationary simulation
[nin, pin, Vin, Fnin, Fpin, Jn, Jp, it, res] = ...
    secs1d_dd_gummel_map_noscale (device, material,
                                  constants, algorithm,
                                  V, n, p, Fn, Fp);  

close all; semilogy (device.x, nin, 'x-', device.x, pin, 'x-'); pause

%% (pseudo)transient simulation
[n, p, V, Fn, Fp, Jn, Jp, t, it, res] = ...
    secs1d_tran_dd_gummel_map_noscale (device, material, constants, algorithm,
                               Vin, nin, pin, Fnin, Fpin, tspan, vbcs);

dV   = diff (V, [], 1);
dx   = diff (device.x);
E    = -dV ./ dx;
   
%% band structure
Efn  = -Fn;
Efp  = -Fp;
Ec   =  constants.Vth * log (material.Nc ./ n) + Efn;
Ev   = -constants.Vth * log (material.Nv ./ p) + Efp;
   
%## figure (1)
%## plot (x, Efn, x, Efp, x, Ec, x, Ev)
%## legend ('Efn', 'Efp', 'Ec', 'Ev')
%## axis tight
%## drawnow

vvector  = Fn(end, :);
ivector  = (Jn(end, :) + Jp(end, :));
ivectorn = (Jn(1, :)   + Jp(1, :));

figure (1) 
plot (vvector, ivector, vvector, ivectorn)
legend('J_L','J_0')
drawnow
   
