
constants = secs1d_physical_constants_fun ();
material = secs1d_silicon_material_properties_fun (constants);

tbulk= 1.5e-6;
tox = 90e-9;
L = tbulk + tox;
cox = material.esio2/tox;

Nx  = 50;
Nel = Nx - 1;

device.x = linspace (0, L, Nx)';
device.sinodes = find (device.x <= tbulk);
xsi = device.x(device.sinodes);

Nsi = length (device.sinodes);
Nox = Nx - Nsi;

NelSi   = Nsi - 1;
NelSiO2 = Nox - 1;

Na = 1e22;
device.D = - Na * ones (size (xsi));
p = Na * ones (size (xsi));
n = (material.ni^2) ./ p;
Fn = Fp = zeros (size (xsi));
Vg =-10;
Nv = 80;

for ii = 1:Nv

    Vg = Vg + 0.2
    vvect(ii) = Vg; 
    
    V = - material.Phims + Vg * ones (size (device.x));
    V(device.sinodes) = Fn + constants.Vth * log (n / material.ni);
    
    % Solution of Nonlinear Poisson equation
    
    % Algorithm parameters
    algorithm.ptoll  = 1e-5;
    algorithm.pmaxit = 10;
    
    [V, n, p, res, niter] = secs1d_nlpoisson_newton_noscale (device, material, constants, ...
                                                             algorithm, V, n, p, Fn, Fp);

    pause
    qtot(ii) = constants.q * trapz (xsi, p + device.D - n);

    vvectm = (vvect(2:ii)+vvect(1:ii-1))/2;
    C = - diff (qtot) ./ diff (vvect);
    plot(vvectm, C)
    xlabel('Vg [V]')
    ylabel('C [Farad]')
    title('C-V curve')

endfor

