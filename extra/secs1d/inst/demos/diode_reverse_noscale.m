% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material = secs1d_silicon_material_properties_fun (constants);

% geometry
L  = 10e-6;          % [m] 
xm = L/2;

Nelements = 1000;
device.x       = linspace (0, L, Nelements+1)';
device.sinodes = [1:length(device.x)];

% doping profile [m^{-3}]
device.Na = 1e23 * (device.x <= xm);
device.Nd = 1e23 * (device.x > xm);

% avoid zero doping
device.D  = device.Nd - device.Na;  

%% bandgap narrowing correction
device.ni = (material.ni) * exp (secs1d_bandgap_narrowing_model
                                 (device.Na, device.Nd) / constants.Vth); 
%% carrier lifetime
device.tp = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'p');
device.tn = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'n');

% initial guess for n, p, V, phin, phip
V_p =  1;
V_n =  0;

Fp = V_p * (device.x <= xm);
Fn = Fp;

p = device.ni;
p = abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs(device.D)) .^2)) .* ...
    (device.D < 0) + device.ni .^2 ./ ...
    (abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^2))) .* ...
    (device.D > 0);

n = abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^ 2)) .* ...
    (device.D > 0) + device.ni .^ 2 ./ ...
    (abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^2))) .* ...
    (device.D < 0);

V = Fn + constants.Vth * log (n ./ device.ni);

% tolerances for convergence checks
algorithm.toll  = 1e-10;
algorithm.maxit = 100;
algorithm.ptoll = 1e-12;
algorithm.pmaxit = 1000;
algorithm.colscaling = [10 1e23 1e23];
algorithm.rowscaling = [1e6 1e23 1e23];
algorithm.maxnpincr = constants.Vth / 10;

% solve the problem using the full DD model
[n, p, V, Fn, Fp, Jn, Jp, it, res] = ...
      secs1d_dd_gummel_map_noscale (device, material,
                                    constants, algorithm,
                                    V, n, p, Fn, Fp);  

algorithm.maxit = 1000;
[n_newt, p_newt, V_newt, Fn_newt, Fp_newt, Jn, Jp, it, res] = secs1d_dd_newton_noscale ...  
    (device, material, constants, algorithm, V, n, p, Fn, Fp);

% band structure
Efn  = -Fn;
Efp  = -Fp;
Ec   = constants.Vth * log (material.Nc./n) + Efn;
Ev   = -constants.Vth * log (material.Nv./p) + Efp;

close all
plot (device.x, Efn, 
      device.x, Efp, 
      device.x, Ec, 
      device.x, Ev)
legend ('Efn', 'Efp', 'Ec', 'Ev')
axis tight
