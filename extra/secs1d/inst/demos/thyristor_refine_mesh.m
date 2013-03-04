pkg load secs1d
clear all
close all

% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
L  = 400e-6;          % [m] 
xm = L/2;

Nelements      = 1000;
device.x       = linspace (0, L, Nelements+1)';
device.sinodes = [1:length(device.x)];

converged = false;
iters = 1;
maxiters = 100;
while (! converged)

  %% doping profile [m^{-3}]
  device.Nd = 1e26 * exp(-((device.x)/3.5e-6).^2) + 5e19;
  device.Na = 5e23 * exp(-((device.x)/8e-6).^2) + 1e25 * exp(-((device.x - L)/5e-6).^2);

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
  algorithm.pmaxit = 100;
  algorithm.maxnpincr = constants.Vth;

  logplot = @(x) asinh (x/2) / log(10);
  close all; plot (device.x, logplot (device.D)); 
  set (gca, "yticklabel",
       arrayfun (@(x) sprintf ("%s10^{%g}", ifelse (x >=0, "+", "-"), abs(x)),
                 get (gca, "ytick"), "uniformoutput", false));
  drawnow

  %% initial guess via stationary simulation
  [Vin, nin, pin, res, niter] = ...
      secs1d_nlpoisson_newton_noscale (device, material, 
                                       constants, algorithm, 
                                       V, n, p, Fn, Fp);
  
  els_to_refine = find ((abs (diff (log10 (nin))) > .1) | (abs (diff (log10 (pin))) > .1) | (abs (diff (log10 (abs (device.D)))) > .1));
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
endwhile