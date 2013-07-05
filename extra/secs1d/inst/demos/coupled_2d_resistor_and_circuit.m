%%
clear all;
close all;

% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
NelementsX = 3;
NelementsY = 3;
xdiv = linspace(0,1,NelementsX+1);
ydiv = linspace(0,1,NelementsY+1);

L  = 100e-6; % [m]
W  = 1e-6;   % [m]
xm = L/2;
device.thickness = 1e-6;% [m]
device.msh = bim2c_mesh_properties (
                msh2m_structured_mesh (
                  L*xdiv, W*ydiv, 
                  1, 1:4
                  ));
% first pin on left edge, second on right edge
device.contacts = [0, 2, 0, 1];
device.x = ((device.msh).p(1, :)).';

device.sinodes = [1:numel(device.x)];

% doping profile [m^{-3}]
device.Na = zeros (size (device.x));
device.Nd = 1e23 * ones (size (device.x));

% avoid zero doping
device.D  = device.Nd - device.Na;  

% time span for simulation
tmin  = 0;
tmax  = 50;
tspan = [tmin, tmax];

Fn = Fp = zeros (size (device.x));

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
    pins = [1, numel(x1) + 1];
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
algorithm.maxnpincr  = 1.0e-5;

%% compute resistance

[E.x,E.y] = bim2c_pde_gradient(device.msh, -Vin);
E.x = E.x(:);
E.y = E.y(:);
E.mag=sqrt((E.x) .^ 2 + (E.y) .^ 2)(:);

u = secs1d_mobility_model_noscale ...
      (device, material, constants, algorithm, 
       E.mag, Vin, nin, pin, Fn, Fp, 'n');
u_nodes = bim2c_tri_to_nodes(device.msh, u);
R_0 = sum(bim2a_rhs (device.msh, 1, 1 ./ (nin .* u_nodes))) ...
      / (constants.q * device.thickness * W ^ 2)

%% initial guess via stationary simulation
%%[nin, pin, Vin, Fnin, Fpin, Jn, Jp, it, res] = secs1d_dd_gummel_map_noscale ...
%%    (device, material, constants, algorithm, V, n, p, Fn, Fp);  

%close all; %secs1d_logplot (device.x, device.D, 'x-'); 
pause

%% (pseudo)transient simulation
[V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = secs2d_coupled_circuit_newton_reordered ...
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
  
