#!/usr/bin/octave
%%
clear all;
close all;

warning ("off", "Octave:broadcast");

% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
NelementsX = 1;
NelementsY = 1;
NelementsZ = 1;
xdiv = linspace(0,1,NelementsX+1);
ydiv = linspace(0,1,NelementsY+1);
zdiv = linspace(0,1,NelementsZ+1);

L  = 100e-6; % [m]
W  = 1e-6;   % [m]
D  = 1e-6;   % [m]
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
device.Na = zeros (size (device_x));
device.Nd = 1e23 * ones (size (device_x));

% avoid zero doping
device.D  = device.Nd - device.Na;  

% time span for simulation
tmin  = 0;
tmax  = 50;
tspan = [tmin, tmax];

Fn = Fp = zeros (size (device_x));

%% bandgap narrowing correction
device.ni = (material.ni) * exp (secs1d_bandgap_narrowing_model
                                 (device.Na, device.Nd) / constants.Vth); 

%% carrier lifetime
device.tp = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'p');
device.tn = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'n');

% initial guess for n, p, V
pin = ((abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
     (device.D <= 0)) / 2 + 2 * device.ni.^2 ./ ...
    (abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
    (device.D > 0);

nin = ((abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
     (device.D > 0)) / 2 + 2 * device.ni.^2 ./ ...
    (abs(device.D) + sqrt (abs(device.D) .^ 2 + 4 * device.ni .^2)) .* ...
    (device.D <= 0);

Vin = Fn + constants.Vth * log (nin ./ device.ni);

function [Ahere, Bhere, Chere, rhere, xhere, pins] = vbcs (t)
  persistent A1 B1 C1 x1
  persistent Ahere Bhere Chere rhere xhere pins
  %in this case  it's not necessary for A2 B2 C2
  if (isempty (A1))
    load ("resistor_circuit_matrices_full")
    r1 = 0 * x1; r1(1) = 1;
    Ahere = [A1, zeros(size(C1)); zeros(size(C1))', 0];
    Bhere = [B1, zeros(size(C1)); zeros(size(C1))', 1];
    xhere = [x1; 0];
    rhere = [r1, zeros(size(x1)); 0, 0];
    pins = [1, (numel(x1) + 1)];
  endif
  C1(4) = -min(t,1);
  Chere = [C1; 0];
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
algorithm.maxnpincr  = 1.0e-2;

%% compute resistance

[Ex,Ey,Ez] = bim3c_pde_gradient(device.msh, -Vin);
Ex = Ex(:);
Ey = Ey(:);
Ez = Ez(:);
Emag=sqrt(Ex .^ 2 + Ey .^ 2 + Ez .^ 2)(:);

u = secs1d_mobility_model_noscale ...
      (device, material, constants, algorithm, 
       Emag, Vin, nin, pin, Fn, Fp, 'n');
u_nodes = bim3c_tri_to_nodes(device.msh, u);
R_0 = sum (bim3a_rhs (device.msh, 1, 1 ./ (constants.q * nin .* u_nodes))) / ...
      sum (device.msh.area(:)) * L / (W * D) 

%% initial guess via stationary simulation
%%[nin, pin, Vin, Fnin, Fpin, Jn, Jp, it, res] = secs1d_dd_gummel_map_noscale ...
%%    (device, material, constants, algorithm, V, n, p, Fn, Fp);  

%close all; %secs1d_logplot (device.x, device.D, 'x-'); 
%% pause

%% (pseudo)transient simulation
[~, ~, ~, ~, Fin, ~] = vbcs (0);
device.msh = bim3c_mesh_properties (device.msh);
%% save -binary -z datafile_rlc_circuit.octbin.gz  device material constants algorithm tspan Vin nin pin Fin  % A B C x r 
[V, n, p, F, Fn, Fp, Jn, Jp, Itot, tout] = secs3d_coupled_circuit_newton ...
                                           (device, material, constants, algorithm,
                                            Vin, nin, pin, tspan, @vbcs);

%% (pseudo)transient simulation
%[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = secs1d_coupled_circuit_newton ...
%                                          (device, material, constants, algorithm,
%                                           Vin, nin, pin, tspan, @vbcs);

%dV   = diff (V, [], 1);
%dx   = diff (device.x);
%E    = -dV ./ dx;
   
%vvector  = (Fn (1, :) - Fn (end, :));
%ivector  = Itot (2, :);

%R_1 = diff (vvector) ./ diff (ivector);

%plotyy (tout, vvector, tout, ivector)
%drawnow
  
