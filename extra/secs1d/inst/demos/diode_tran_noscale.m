%pkg load secs1d secs2d
pkg load bim

clear all
close all

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
%device.Na = 1e23 * (device.x <= xm);
%device.Nd = 1e23 * (device.x > xm);
device.Na = 1e24 * exp(-(3*device.x/L).^2);
device.Nd = 1e24 * exp(-(3*(device.x-L)/L).^2);

% avoid zero doping
device.D  = device.Nd - device.Na;  

% time span for simulation
tmin = 0;
tmax = 35;
tspan = [tmin, tmax];

Fn = Fp = zeros (size (device.x));

%% bandgap narrowing correction
device.ni = (material.ni)*exp(secs1d_bandgap_narrowing_model(device.Na,device.Nd)/constants.Vth);
%device.ni = (material.ni)*ones(size(device.Na));%deactivated
plot(device.x,device.ni);


% initial guess for n, p, V, phin, phip

n = p = device.ni;

nregion= device.D > device.ni;
pregion= device.D < -device.ni;

n(nregion) = device.Nd(nregion);
p(pregion) = device.Na(pregion);

p(nregion) = (device.ni(nregion).^2 ./ n(nregion));
n(pregion) = (device.ni(pregion).^2 ./ p(pregion));


%%p = abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs(device.D)) .^2)) .* ...
%%    (device.x <= xm) + device.ni.^2 ./ ...
%%    (abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^2))) .* ...
%%    (device.x > xm);
%%
%%n = abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^ 2)) .* ...
%%    (device.x > xm) + device.ni.^2 ./ ...
%%    (abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^2))) .* ...
%%    (device.x <= xm);

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
algorithm.toll  = 1e-7;
algorithm.maxit = 1000;
algorithm.ptoll = 1e-12;
algorithm.pmaxit = 1000;
algorithm.maxnpincr = constants.Vth;

%% initial guess via stationary simulation
[nin, pin, Vin, Fnin, Fpin, Jn, Jp, it, res] = ...
    secs1d_dd_gummel_map_noscale (device, material,
                                  constants, algorithm,
                                  V, n, p, Fn, Fp);  

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
   
