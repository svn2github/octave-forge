pkg load secs1d
clear all
close all

                                % physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

                                % geometry

loaded_mesh    = load ("nplus_n_nnplus_mesh");
device.x       = loaded_mesh.x;
L              = loaded_mesh.L;          % [m] 
device.D       = loaded_mesh.D;          % [m^-3] 
device.Na      = loaded_mesh.Na;         % [m^-3] 
device.Nd      = loaded_mesh.Nd;         % [m^-3] 
device.W       = 1e-12;                  % [m^2]
tspan          = [0 60];

device.sinodes = [1:length(device.x)];

Fn = Fp = zeros (size (device.x));

%% bandgap narrowing correction
device.ni = (material.ni) * exp (secs1d_bandgap_narrowing_model
                                 (device.Na, device.Nd) / constants.Vth); 

%% carrier lifetime
device.tp = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'p');
device.tn = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'n');

%% initial guess for n, p, V, phin, phip
p = ((abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
     (device.D <= 0)) / 2 + 2 * device.ni.^2 ./ ...
                            (abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
                            (device.D > 0);

n = ((abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
     (device.D > 0)) / 2 + 2 * device.ni.^2 ./ ...
                           (abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
                           (device.D <= 0);

V = Fn + constants.Vth * log (n ./ device.ni);


% tolerances for convergence checks
algorithm.toll       = 1e-6;
algorithm.ltol       = 1e-10;
algorithm.maxit      = 100;
algorithm.lmaxit     = 100;
algorithm.ptoll      = 1e-12;
algorithm.pmaxit     = 1000;
algorithm.colscaling = [10 1e21 1e21 1];
algorithm.rowscaling = [1  1e-7 1e-7 1];
algorithm.maxnpincr  = 1e-3;

secs1d_logplot (device.x, device.D);
drawnow

%% initial guess via stationary simulation
[nin, pin, Vin, Fnin, Fpin, Jn, Jp, it, res] = secs1d_dd_gummel_map_noscale ...
    (device, material, constants, algorithm, V, n, p, Fn, Fp);  


function [g, j, r] = vbcs (t, dt);
  g =  [1; 1];
  j = -[t  0];
  r =  [0  0];
endfunction

%% (pseudo)transient simulation
[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = ...
secs1d_newton_res (device, material, constants, algorithm,
                   Vin(:,end), nin(:,end), pin(:,end), 
                   tspan, @vbcs);

dV   = diff (V, [], 1);
dx   = diff (device.x);
E    = -dV ./ dx;

%% band structure
Efn  = -Fn(:, end);
Efp  = -Fp(:, end);
Ec   =  constants.Vth * log (material.Nc ./ n(:, end)) + Efn;
Ev   = -constants.Vth * log (material.Nv ./ p(:, end)) + Efp;

figure (1)
plot (device.x, Efn, device.x, Efp, device.x, Ec, device.x, Ev)
legend ('Efn', 'Efp', 'Ec', 'Ev')
axis tight
drawnow

vvector  = Fn(end, :);
ivector  = (Jn(end, :) + Jp(end, :));
ivectorn = (Jn(1, :)   + Jp(1, :));

figure (2) 
plot (vvector, ivector, vvector, ivectorn)
legend('J_L','J_0')
drawnow
