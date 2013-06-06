pkg load secs1d
clear all
close all

% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
L  = 600e-9;          % [m] 
xm = L/2;

Nelements      = 10;
device.x       = linspace (0, L, Nelements+1)';
device.sinodes = [1:length(device.x)];

converged = false;
iters = 1;
maxiters = 100;
while (! converged)

  %% doping profile [m^{-3}]
  device.Nd = 1e22 + 4.9e23 * (device.x < 100e-9) + 4.9e23 * (device.x > 500e-9);
  device.Na = 2;

  %% avoid zero doping
  device.D  = device.Nd - device.Na;  


  Fn = Fp = zeros (size (device.x));

  %% bandgap narrowing correction
  device.ni = (material.ni) * exp (secs1d_bandgap_narrowing_model
                                   (device.Na, device.Nd) / constants.Vth); 

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


  %% tolerances for convergence checks
  algorithm.toll  = 1e-6;
  algorithm.maxit = 100;
  algorithm.ptoll = 1e-12;
  algorithm.pmaxit = 1000;
  algorithm.maxnpincr = constants.Vth;

  figure(1)
  secs1d_logplot (device.x, device.D);
  drawnow

  assert (~ any (diff (device.x < 0)))

  %% initial guess via stationary simulation
  [Vin, nin, pin, res, niter] = ...
      secs1d_nlpoisson_newton_noscale (device, material, 
                                       constants, algorithm, 
                                       V, n, p, Fn, Fp);
  figure(2)
  secs1d_logplot (device.x, nin);
  drawnow

  figure(3)
  secs1d_logplot (device.x, pin);
  drawnow


  assert (~ any (isnan (Vin)))
  assert (~ any (isnan (nin)))
  assert (~ any (isnan (pin)))

  els_to_refine = find ((abs (diff (log10 (nin))) > .4) 
                        | (abs (diff (log10 (pin))) > .4));

  if isempty (els_to_refine)
    converged = true;
  endif

  if (converged || (++iters > maxiters))
    break
  endif

  x = device.x;
  newx = (x(els_to_refine) + x(els_to_refine+1)) / 2;
  device.x = sort (vertcat (x, newx));
  device.sinodes = [1:length(device.x)];
  D = device.D;
  Na = device.Na;
  Nd = device.Nd;
endwhile

save nplus_n_nnplus_mesh x L D Na Nd
