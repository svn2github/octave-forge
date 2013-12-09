% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
Nelements = 3000;
L  = 50e-6;          % [m] 
W  = 150e-6;
D  = 50e-6;

xm = D/2;
device.W = W * L;
device.x  = linspace (0, D, Nelements+1)';
device.sinodes = [1:length(device.x)];

% doping profile [m^{-3}]
%device.Na = 1e23 * exp ( - .5 * device.x.^2 / xm^2);
%device.Nd = 1e23 * exp ( - .5 * (device.x - L) .^2 / xm^2);
device.Na = 1e23 * exp (-.5 * ((D - device.x)/ 2.0e-6) .^ 2);
device.Nd = 1e25 * exp (-.5 * ((0 - device.x)/ 2.4e-6) .^ 2) + 1e19;


% avoid zero doping
device.D  = device.Nd - device.Na;

%% close all
%% figure(99)
%% hold on
%% secs1d_logplot (device.x, device.D, 'x-'); 
%% secs1d_logplot (device.x, device.Na, 'xg-'); 
%% secs1d_logplot (device.x, device.Nd, 'xr-'); 
%% 
%% pause



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

function [A, B, C, r, x, contacts] = vbcs (t)
  A = zeros (2);
  %% %% Voltage controlled
  %% B = eye(2);
  %% C = [sin(2*pi*t/1e-4); 0];
  %% r = [0, 0; 0, 0];
  %% Current controlled
  B = diag ([0, 1]);
  C = [100000 * t; 0];
  r = [1, 0; 0, 0];
  %%
  x = [0; 0];
  contacts = [1, 2];
endfunction

function [A, B, C, r, x, contacts] = vbcs0 (t)
  A = zeros(2);
  B = eye(2);
  C = [0; 0];
  x = [0; 0];
  r = [0, 0; 0, 0];
  contacts = [1, 2];
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
algorithm.maxnpincr  = 1e2;


[Vin, nin, pin, Fn, Fp, Jn, Jp, Itot, tout] = ...
                secs1d_coupled_circuit_newton_reordered ...
                  (device, material, constants, algorithm,
                  V, n, p, tspan, @vbcs0);

%% figure(99)
%% subplot(3,1,1)
%% plot(device.x, Vin, 'g-.', device.x, V, 'r--');
%% grid on
%% legend("Newt", "Est");
%% subplot(3,1,2)
%% semilogy(device.x, nin, 'g-.', device.x, n, 'r--');
%% grid on
%% legend("Newt", "Est");
%% subplot(3,1,3)
%% semilogy(device.x, pin, 'g-.', device.x, p, 'r--');
%% grid on
%% legend("Newt", "Est");

pause

%%
algorithm.maxnpincr  = 1e-0;
[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = ...
                secs1d_coupled_circuit_newton_reordered ...
                  (device, material, constants, algorithm,
                  Vin(:,end), nin(:,end), pin(:,end), tspan, @vbcs);

vvector  = (Fn(end, :) - Fn(1, :));
ivector  = Itot (1, :);

close all
%plotyy (tout, vvector, tout, ivector)
plot (vvector, ivector)
drawnow
   
