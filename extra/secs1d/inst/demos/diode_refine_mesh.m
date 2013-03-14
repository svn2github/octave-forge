% physical constants and parameters
constants = secs1d_physical_constants_fun ();
material  = secs1d_silicon_material_properties_fun (constants);

% geometry
Nelements = 100;
L  = 50e-6;          % [m] 
xm = L/2;
device.W = 150e-6 * 50e-6;

device.x  = linspace (0, L, Nelements+1)';
device.sinodes = [1:length(device.x)];

converged = false;
iters = 1;
maxiters = 10;
while (! converged)

  %% doping profile [m^{-3}]
  device.Na = 1e23 * exp (- (device.x / 2e-6) .^ 2);
  device.Nd = 1e25 * exp (- ((device.x-L) / 2.4e-6) .^ 2) + 1e19;

  %% avoid zero doping
  device.D  = device.Nd - device.Na;  

  Fn = Fp = zeros (size (device.x));

  %% carrier lifetime
  device.tp = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'p');
  device.tn = secs1d_carrier_lifetime_noscale (device.Na, device.Nd, 'n');

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

  secs1d_logplot (device.x, device.D);
  drawnow

  %% initial guess via stationary simulation
  [Vin, nin, pin, res, niter] = ...
      secs1d_nlpoisson_newton_noscale (device, material, 
                                       constants, algorithm, 
                                       V, n, p, Fn, Fp);
  
  els_to_refine = find ((abs (diff (log10 (nin))) > .02) 
                        | (abs (diff (log10 (pin))) > .02) 
                        | (abs (diff (log10 (abs (device.D)))) > .05));

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

save diode_mesh x L xm