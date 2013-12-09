%%
clear all;
close all;

warning ("off", "Octave:broadcast");

% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
NelementsX = 300;
NelementsY = 2;
NelementsZ = 2;
xdiv = linspace(0,1,NelementsX+1);
ydiv = linspace(0,1,NelementsY+1);
zdiv = linspace(0,1,NelementsZ+1);

L  = 50e-6;   % [m]
W  = 150e-6;  % [m]
D  = 50e-6;   % [m]
device.msh = bim3c_mesh_properties (
                msh3m_structured_mesh (
                  L*xdiv, W*ydiv, D*zdiv, 
                  1, 1:6
                  ));
% first pin on left edge, second on right edge
device.contacts = [1, 2];
device_x = ((device.msh).p(1, :)).';
%device.x = ((device.msh).p(1, :)).';
%device.y = ((device.msh).p(2, :)).';
%device.z = ((device.msh).p(3, :)).';

device.sinodes = [1:numel(device_x)];

% doping profile [m^{-3}]
device.Na = 1e23 * exp (-.5 * ((D - device_x)/ 2.0e-6) .^ 2);
device.Nd = 1e25 * exp (-.5 * ((0 - device_x)/ 2.4e-6) .^ 2) + 1e19;

% avoid zero doping
device.D  = device.Nd - device.Na;

% time span for simulation
tmin  = 0;
tmax  = 1e-4;
tspan = [tmin, tmax];

Fn = Fp = zeros (size (device_x));

%% bandgap narrowing correction
device.ni = (material.ni) * exp (secs1d_bandgap_narrowing_model
                                 (device.Na, device.Nd) / constants.Vth); 

%% carrier lifetime
device.tp = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'p');
device.tn = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'n');

% initial guess for n, p, V
p = ((abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
     (device.D <= 0)) / 2 + 2 * device.ni.^2 ./ ...
    (abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
    (device.D > 0);

n = ((abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
     (device.D > 0)) / 2 + 2 * device.ni.^2 ./ ...
    (abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
    (device.D <= 0);

V = Fn + constants.Vth * log (n ./ device.ni);

function [A, B, C, r, x, pins] = vbcs (t)
  A = zeros (2);
  %% %% Voltage controlled
  B = eye(2);
  C = [sin(2*pi*t/1e-4); 0];
  r = [0, 0; 0, 0];
  %% Current controlled
  %% B = diag ([0, 1]);
  %% C = [100000 * t; 0];
  %% r = [1, 0; 0, 0];
  %%
  x = [0; 0];
  pins = [1, 2];
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
algorithm.toll       = 1e-06;
algorithm.ltol       = 1e-10;
algorithm.maxit      = 100;
algorithm.lmaxit     = 100;
algorithm.ptoll      = 1e-12;
algorithm.pmaxit     = 1000;
algorithm.colscaling = [10 1e21 1e21 .1];
algorithm.rowscaling = [1  1e-7 1e-7 .1];
algorithm.maxnpincr  = 1e2;

%% initial guess via stationary simulation
[Vin, nin, pin, Fin, Fn, Fp, Jn, Jp, Itot, tout] = ...
                secs3d_coupled_circuit_newton ...
                  (device, material, constants, algorithm,
                  V, n, p, tspan, @vbcs0);

save -binary -z datafile_rlc_circuit_T0.octbin.gz  device material constants algorithm tspan Vin nin pin  % A B C x r 
%close all; %secs1d_logplot (device.x, device.D, 'x-'); 
%pause

%% (pseudo)transient simulation


[V, n, p, F, Fn, Fp, Jn, Jp, Itot, tout] = ...
    secs3d_coupled_circuit_newton ...
        (device, material, constants, algorithm,
         Vin, nin, pin, tspan, @vbcs);

