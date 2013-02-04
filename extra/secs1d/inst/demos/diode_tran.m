pkg load secs1d secs2d
clear all
close all


% physical constants and parameters
secs1d_physical_constants;
secs1d_silicon_material_properties;

% geometry
L  = 10e-6;          % [m] 
xm = L/2;

Nelements = 3000;
x         = linspace (0, L, Nelements+1)';
sinodes   = [1:length(x)];

% tolerances for convergence checks
toll  = 1e-4;
maxit = 50;
ptoll = 1e-12;
pmaxit = 1000;

% dielectric constant (silicon)
er = esir * ones (Nelements, 1);

% doping profile [m^{-3}]
Na = 1e23 * (x <= xm);
Nd = 1e23 * (x > xm);

% avoid zero doping
D  = Nd - Na;  

% scaling factors
xbar = L;                       %% [m]
nbar = norm(D, 'inf');          %% [m^{-3}]
Vbar = Vth;                     %% [V]
mubar = max (u0n, u0p);         %% [m^2 V^{-1} s^{-1}]
tbar = xbar^2 / (mubar * Vbar); %% [s]
Rbar = nbar / tbar;             %% [m^{-3} s^{-1}]
Ebar = Vbar / xbar;             %% [V m^{-1}]
Jbar = q * mubar * nbar * Ebar; %% [A m^{-2}]
CAubar = Rbar / nbar^3;         %% [m^6 s^{-1}]
abar = 1/xbar;                  %% [m^{-1}]

% scaling procedure
l2 = e0 * Vbar / (q * nbar * xbar^2);
theta = ni / nbar;

xin = x / xbar;
Din = D / nbar;
Nain = Na / nbar;
Ndin = Nd / nbar;

tnin = tn / tbar;
tpin = tp / tbar;

u0nin = u0n / mubar;
uminnin = uminn / mubar;
vsatnin = vsatn / (mubar * Ebar);

u0pin = u0p / mubar;
uminpin = uminp / mubar;
vsatpin = vsatp / (mubar * Ebar);

Nrefnin = Nrefn / nbar;
Nrefpin = Nrefp / nbar;

Cnin     = Cn / CAubar;
Cpin     = Cp / CAubar;

anin     = an / abar;
apin     = ap / abar;
Ecritnin = Ecritn / Ebar;
Ecritpin = Ecritp / Ebar;

tmin = 0;
tmax = 21;
tspan = [tmin, tmax];

p = abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni./abs(D)) .^2)) .* (x <= xm) + ...
    ni^2 ./ (abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^2))) .* (x > xm);
  
n = abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^ 2)) .* (x > xm) + ...
    ni ^ 2 ./ (abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^2))) .* (x <= xm);

Fp = 0 * (x <= xm);
Fn = Fp;

V = Fn + Vth * log (n / ni);

function fn = vbcs_1 (t, tbar, n, ni, Vth, vbar, nbar);
  fn = [0; 0];
  fn(2) = t*tbar;
  fn(1) = 0;
  v  = fn + Vth * log (n / ni);
  vv = v / vbar;
  nn = n / nbar;
  fn = vv - log (nn);
endfunction

function fp = vbcs_2 (t, tbar, p, ni, Vth, vbar, nbar);
  fp = [0; 0];
  fp(2) = t*tbar;
  fp(1) = 0;
  v  = fp - Vth * log (p / ni);
  vv = v / vbar;
  pp = p / nbar;
  fp = vv + log (pp);
endfunction

vbcs = {(@(t) vbcs_1 (t, tbar, n([1 end]), ni, Vth, Vbar, nbar)), (@(t) vbcs_2 (t, tbar, p([1 end]), ni, Vth, Vbar, nbar))};

%% scaling procedure
pin = p / nbar;
nin = n / nbar;
Vin = V / Vbar;
tin = tspan / tbar;
Fnin = (Vin - log (nin));
Fpin = (Vin + log (pin));

%% initial guess via stationary simulation
[nin, pin, Vin, Fnin, Fpin] = ...
    secs1d_dd_gummel_map (xin, Din, Nain, Ndin, pin, nin, Vin, Fnin, Fpin, ...
                          l2, er, u0nin, uminnin, vsatnin, betan, Nrefnin, ...
                          u0pin, uminpin, vsatpin, betap, Nrefpin, theta, ...
         	          tnin, tpin, Cnin, Cpin, anin, apin, ...
         	          Ecritnin, Ecritpin, toll, maxit, ptoll, pmaxit); 

%% (pseudo)transient simulation
[nout, pout, Vout, Fnout, Fpout, Jnout, Jpout, tout, it, res] = ...
    secs1d_tran_dd_gummel_map (xin, tin, vbcs, Din, Nain, Ndin, pin, nin, Vin, 
                               Fnin, Fpin, l2, er, u0nin, uminnin,
                               vsatnin, betan, Nrefnin, u0pin, 
                               uminpin, vsatpin, betap, Nrefpin,
                               theta, tnin, tpin, Cnin, Cpin, anin, apin, 
		               Ecritnin, Ecritpin, toll, maxit, 
                               ptoll, pmaxit);


%% Descaling procedure
n    = nout*nbar;
p    = pout*nbar;
V    = Vout*Vbar;
t    = tout*tbar;
Fn   = V - Vth*log(n/ni);
Fp   = V + Vth*log(p/ni);
dV   = diff(V, [], 1);
dx   = diff(x);
E    = -dV./dx;
   
%% band structure
Efn  = -Fn;
Efp  = -Fp;
Ec   =  Vth*log(Nc./n)+Efn;
Ev   = -Vth*log(Nv./p)+Efp;
   
## figure (1)
## plot (x, Efn, x, Efp, x, Ec, x, Ev)
## legend ('Efn', 'Efp', 'Ec', 'Ev')
## axis tight
## drawnow

figure (1)
plot (Jnout)
hold on
plot (Jpout, 'r')
drawnow
hold off

vvector  = Fn(end, :);
ivector  = Jbar * (Jnout(end, :) + Jpout(end, :));
ivectorn = Jbar * (Jnout(1, :)   + Jpout(1, :));

figure (2) 
plot (vvector, ivector, vvector, ivectorn)
legend('J_L','J_0')
drawnow
   
