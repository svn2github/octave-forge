% ===================================================================================
% optiPID                          Lukas Reichlin                           July 2009
% ===================================================================================
% Numerical Optimization of an A/H PID Controller
% Required OCTAVE Packages: control, miscellaneous, optim
% Required MATLAB Toolboxes: Control, Optimization
% ===================================================================================

% Tabula Rasa
clear all, close all, clc;

% Global Variables
global P t dt mu_1 mu_2 mu_3

% Plant
numP = [1];
denP = conv ([1, 1, 1], [1, 4, 6, 4, 1]);
P = tf (numP, denP);

% Relative Weighting Factors: PLAY AROUND WITH THESE!
mu_1 = 1;       % Minimize ITAE Criterion
mu_2 = 10;      % Minimize Max Overshoot
mu_3 = 20;      % Minimize Sensitivity Ms

% Simulation Settings: PLANT-DEPENDENT!
t_sim = 30;             % Simulation Time [s]
dt = 0.05;              % Sampling Time [s]
t = 0 : dt : t_sim;     % Time Vector [s]

% A/H PID Controller: Ms = 2.0
[gamma, phi, w_gamma, w_phi] = margin (P);

ku = gamma;
Tu = 2*pi / w_gamma;
kappa = inv (dcgain (P));

disp ('optiPID: Astrom/Hagglund PID controller parameters:');
kp_AH = ku * 0.72 * exp ( -1.60 * kappa  +  1.20 * kappa^2 )
Ti_AH = Tu * 0.59 * exp ( -1.30 * kappa  +  0.38 * kappa^2 )
Td_AH = Tu * 0.15 * exp ( -1.40 * kappa  +  0.56 * kappa^2 )
tau_AH = Td_AH / 10

numC_AH = kp_AH * [Ti_AH * Td_AH,  Ti_AH,  1];
denC_AH = conv ([Ti_AH, 0], [tau_AH^2,  2 * tau_AH,  1]);
C_AH = tf (numC_AH, denC_AH);

% Initial Values
C_par_0 = [kp_AH; Ti_AH; Td_AH];

% Optimization
if (exist ('fminsearch'))
  warning ('optiPID: optimization starts, please be patient ...');
else
  error ('optiPID: please install optim package to proceed');
end

C_par_opt = fminsearch (@optiPIDfun, C_par_0);

% Optimized Controller
disp ('optiPID: optimized PID controller parameters:');
kp_opt = C_par_opt(1)
Ti_opt = C_par_opt(2)
Td_opt = C_par_opt(3)
tau_opt = Td_opt / 10

numC_opt = kp_opt * [Ti_opt * Td_opt,  Ti_opt,  1];
denC_opt = conv ([Ti_opt, 0], [tau_opt^2,  2 * tau_opt,  1]);
C_opt = tf (numC_opt, denC_opt);

% Open Loop
L_AH = P * C_AH;
L_opt = P * C_opt;

% Closed Loop
T_AH = feedback (L_AH, 1);
T_opt = feedback (L_opt, 1);

% A Posteriori Stability Check
disp ('optiPID: closed-loop stability check:');
st_AH = isstable (T_AH)
st_opt = isstable (T_opt)

% Stability Margins
disp ('optiPID: gain margin gamma [-] and phase margin phi [deg]:');
[gamma_AH, phi_AH] = margin (L_AH)
[gamma_opt, phi_opt] = margin (L_opt)

% Plot Step Response
[y_AH, t_AH] = step (T_AH, t);
[y_opt, t_opt] = step (T_opt, t);

figure (1)
plot (t_AH, y_AH, 'b', t_opt, y_opt, 'r')
grid ('on')
title ('Step Response')
xlabel ('Time [s]')
ylabel ('Output [-]')
legend ('A/H', 'Optimized', 'Location', 'SouthEast')

% ===================================================================================
