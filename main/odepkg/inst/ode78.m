%# Copyright (C) 2006, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - Package for solving ordinary differential equations with octave
%#
%# This program is free software; you can redistribute it and/or modify
%# it under the terms of the GNU General Public License as published by
%# the Free Software Foundation; either version 2 of the License, or
%# (at your option) any later version.
%#
%# This program is distributed in the hope that it will be useful,
%# but WITHOUT ANY WARRANTY; without even the implied warranty of
%# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%# GNU General Public License for more details.
%#
%# You should have received a copy of the GNU General Public License
%# along with this program; if not, write to the Free Software
%# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

%# -*- texinfo -*-
%# @deftypefn {Function} ode78 ()
%# Displays the help text of the function and terminates with an error.
%#
%# @deftypefnx {Function} {@var{[vsol]} =} ode78 (@var{@@vfun}, @var{vslot}, @var{vinit}, @var{[vopt]}, @var{[vP1, vP2, @dots{}]})
%# Returns the solution structure @var{vsol} after solving the set of ordinary differential equations defined in a function and specified by the function handle @var{@@vfun}. The first input argument @var{vslot} must be the time slot, @var{vinit} must be the initial values, @var{vopt} can optionally be the options structure that is created with @command{odeset} and @var{[vP1, vP2, @dots{}]} can optionally be all arguments that have to be passed to the function @var{vfun}. If an invalid input argument is detected then the function terminates with an error.
%#
%# @deftypefnx {Function} {@var{[vt, vy, [vte, vye, vie]]} =} ode78 (@var{@@vfun}, @var{vslot}, @var{vinit}, @var{[vopt]}, @var{[vP1, vP2, @dots{}]})
%# Returns the time stamps @var{vt}, the solution values @var{vy} and optionally the extended time stamp information @var{vte}, the extended solution information @var{vye} and the extended index information @var{vie} of the event function if any event property is set in the option argument @var{vopt}. See the description for the input arguments before. If an invalid input argument is detected then the function terminates with an error.
%#
%# Run
%# @example
%# demo ode78
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060809
%# ChangeLog:
%#   20010519 the function file "ode78.m" was written by Marc Compere
%#     under the GPL for the use with octave. This function has been
%#     taken as a basis for the following implementation.
%#   20060810, Thomas Treichl
%#     This function was adapted to the new syntax that is used by
%#     odepkg for octave.

function [varargout] = ode78 (vfun, vslot, vinit, varargin)

  if (nargin == 0) %# Check number and types of all input arguments
    help ('ode78');
    vmsg = sprintf ('Number of input arguments must be greater than zero');
    error (vmsg);
  elseif (nargin < 3)
    vmsg = sprintf ('[vt, vy] = ode78 (vfun, vslot, vinit, varargin)\n');
    usage (vmsg);
  elseif (isa (vfun, 'function_handle') == false)
    vmsg = sprintf ('First input argument must be valid function handle');
    error (vmsg);
  elseif (isvector (vslot) == false || length (vslot) < 2)
    vmsg = sprintf ('Second input argument must be valid vector');
    error (vmsg);
  elseif (isvector (vinit) == false || isnumeric (vinit) == false)
    vmsg = sprintf ('Third input argument must be valid vector');
    error (vmsg);
  elseif (nargin >= 4)
    if (isstruct (varargin{1}) == false)
      vodeoptions = odeset;     %# varargin{1:len} are pars for vfun
      vfunarguments = varargin;
    elseif (length (varargin) > 1) %# varargin{1} is vopt
      vodeoptions = odepkg_structure_check (varargin{1});
      vfunarguments = {varargin{2:length(varargin)}};
    else %# if (isstruct (varargin{1})) == true
      vodeoptions = odepkg_structure_check (varargin{1});
      vfunarguments = {};
    end
  else %# if (nargin == 3)
    vodeoptions = odeset;
    vfunarguments = {};
  end

  %# Preprocessing, have a look which options have been set in vodeoptions
  if (size (vslot, 1) > size (vslot, 2)), vslot = vslot'; end %# create row vector
  if (size (vinit, 1) > size (vinit, 2)), vinit = vinit'; end %# create row vector
  if (size (vslot, 2) > 2), vstepsizegiven = true;            %# Step size checking
  else, vstepsizegiven = false; end
  vodetemp = odeset; %# Get the default options temporarily

  %# Check if any unconsidered options have been set and print warning(s)
  if (isequal (vodeoptions.RelTol, vodetemp.RelTol) == false && ...
      vstepsizegiven == true)
    warning ('Option "RelTol" will be ignored if time stamps = [t0 t1 ...] are given'); end

  if (isequal (vodeoptions.AbsTol, vodetemp.AbsTol) == false && ...
      vstepsizegiven == true)
    warning ('Option "AbsTol" will be ignored if time stamps = [t0 t1 ...] are given'); end

  if (isequal (vodeoptions.NormControl, vodetemp.NormControl) == true)
    %#   vnormcontrol = false; %# Default value is 'off'
    %# else, vnormcontrol = true; end
    vnormcontrol = true; %# I did not have the time to check this feature by now, tt 20060912
    warning ('Not yet implemented option "NormControl" will be ignored'); end

  if (isequal (vodeoptions.NonNegative, vodetemp.NonNegative) == false)
    warning ('Not yet implemented option "NonNegative" will be ignored'); end

  if (isempty (vodeoptions.OutputFcn) == true && nargout == 0)
    vodeoptions.OutputFcn = @odeplot; vhaveoutputfunction = true;
  elseif (isempty (vodeoptions.OutputFcn) == true)
    vhaveoutputfunction = false;
  else, vhaveoutputfunction = true; end

  if (isequal (vodeoptions.OutputSel, vodetemp.OutputSel) == false)
    ('Not yet implemented option "OutputSel" will be ignored'); end

  if (isequal (vodeoptions.Refine, vodetemp.Refine) == false)
    warning ('Not yet implemented option "Refine" will be ignored'); end

  if (isequal (vodeoptions.Stats, vodetemp.Stats) == false)
    warning ('Not yet implemented option "Stats" will be ignored'); end

  if (isequal (vodeoptions.InitialStep, vodetemp.InitialStep) == true)
    vodeoptions.InitialStep = abs (vslot(1,1) - vslot(1,2)) / 10; end
  %# warning ('Option "InitialStep" will be ignored by this solver'); end

  if (isempty (vodeoptions.MaxStep) == true)
    vodeoptions.MaxStep = abs (vslot(1,1) - vslot(1,length (vslot))) / 10; end
  %# warning ('Not yet implemented option "MaxStep" will be ignored'); end

  if (isequal (vodeoptions.Events, vodetemp.Events) == false)
    warning ('Not yet implemented option "Events" will be ignored'); end

  if (isequal (vodeoptions.Jacobian, vodetemp.Jacobian) == false)
    warning ('Not yet implemented option "Jacobian" will be ignored'); end

  if (isequal (vodeoptions.Vectorized, vodetemp.Vectorized) == false)
    warning ('Not yet implemented option "Vectorized" will be ignored'); end

  if (isequal (vodeoptions.Mass, vodetemp.Mass) == false)
    warning ('Not yet implemented option "Mass" will be ignored'); end

  if (isequal (vodeoptions.MStateDependence, vodetemp.MStateDependence) == false)
    warning ('Not yet implemented option "MStateDependence" will be ignored'); end

  if (isequal (vodeoptions.MvPattern, vodetemp.MvPattern) == false)
    warning ('Not yet implemented option "MvPattern" will be ignored'); end

  if (isequal (vodeoptions.MassSingular, vodetemp.MassSingular) == false)
    warning ('Not yet implemented option "MassSingular" will be ignored'); end

  if (isequal (vodeoptions.InitialSlope, vodetemp.InitialSlope) == false)
    warning ('Not yet implemented option "InitialSlope" will be ignored'); end

  if (isequal (vodeoptions.MaxOrder, vodetemp.MaxOrder) == false)
    warning ('Not yet implemented option "MaxOrder" will be ignored'); end

  if (isequal (vodeoptions.BDF, vodetemp.BDF) == false)
    warning ('Not yet implemented option "BDF" will be ignored'); end

  %# Starting initialisation of ode78
  if (vhaveoutputfunction == true),    %# Initialize OutputFcn
    feval (vodeoptions.OutputFcn, vslot, vinit, 'init'); end
  vtimestamp = vslot(1,1);             %# timestamp = start time
  vtimestop = vslot(1,length (vslot)); %# stop time = last value

  if (vstepsizegiven == false)
    vstepsize = vodeoptions.InitialStep;
    vminstepsize = (vtimestop - vtimestamp) / (1/eps);
  else %# If step size is given then use the fixed time steps
    vstepsize = abs (vslot(1,1) - vslot(1,2));
    vminstepsize = eps; %# vslot(1,2) - vslot(1,1) - eps;
  end

  vretvaltime = vtimestamp; %# first timestamp output
  vretvalresult = vinit;    %# first solution output

  vpow = 1/8;                                  %# MC2001: see p.91 in Ascher & Petzold
  va = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;    %# The 7(8) coefficients
        1/18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; %# Coefficients proved, tt 20060827
        1/48, 1/16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
        1/32, 0, 3/32, 0, 0, 0, 0, 0, 0, 0, 0, 0; 
        5/16, 0, -75/64, 75/64, 0, 0, 0, 0, 0, 0, 0, 0; 
        3/80, 0, 0, 3/16, 3/20, 0, 0, 0, 0, 0, 0, 0; 
        29443841/614563906, 0, 0, 77736538/692538347, -28693883/1125000000, ...
            23124283/1800000000, 0, 0, 0, 0, 0, 0;
        16016141/946692911, 0, 0, 61564180/158732637, 22789713/633445777, ...
            545815736/2771057229, -180193667/1043307555, 0, 0, 0, 0, 0;
        39632708/573591083, 0, 0, -433636366/683701615, -421739975/2616292301, ...
            100302831/723423059, 790204164/839813087, 800635310/3783071287, 0, 0, 0, 0;
        246121993/1340847787, 0, 0, -37695042795/15268766246, -309121744/1061227803, ...
            -12992083/490766935, 6005943493/2108947869, 393006217/1396673457, ...
            123872331/1001029789, 0, 0, 0;
        -1028468189/846180014, 0, 0, 8478235783/508512852, 1311729495/1432422823, ...
            -10304129995/1701304382, -48777925059/3047939560, 15336726248/1032824649, ...
            -45442868181/3398467696, 3065993473/597172653, 0, 0;
        185892177/718116043, 0, 0, -3185094517/667107341, -477755414/1098053517, ...
            -703635378/230739211, 5731566787/1027545527, 5232866602/850066563, ...
            -4093664535/808688257, 3962137247/1805957418, 65686358/487910083, 0;
        403863854/491063109, 0, 0, -5068492393/434740067, -411421997/543043805, ...
            652783627/914296604, 11173962825/925320556, -13158990841/6184727034, ...
            3936647629/1978049680, -160528059/685178525, 248638103/1413531060, 0];
  vb7 = [13451932/455176623; 0; 0; 0; 0; -808719846/976000145; ...
            1757004468/5645159321; 656045339/265891186; -3867574721/1518517206; ...
            465885868/322736535; 53011238/667516719; 2/45; 0];
  vb8 = [14005451/335480064; 0; 0; 0; 0; -59238493/1068277825; 181606767/758867731; ...
            561292985/797845732; -1041891430/1371343529; 760417239/1151165299; ...
            118820643/751138087; -528747749/2220607170; 1/4];
  vc = sum (va, 2);

  %# The solver main loop, stop after endpoint has been reached
  vcntloop = 2; vu = vinit; vk = vu' * zeros(1,13);
  while ((vtimestamp < vtimestop && vstepsize >= vminstepsize) == true)

    %# Hit the endpoint of the time slot exactely
    if ((vtimestamp + vstepsize) > vtimestop)
      vstepsize = vtimestop - vtimestamp; end

    %# Estimate the thirteen results when using this solver
    vk(:,1) = feval (vfun, vtimestamp, vu', vfunarguments{:});
    for j = 1:12
      vk(:,j+1) = feval ...
        (vfun, vtimestamp + vc(j+1,1) * vstepsize, ...
         vu' + vstepsize * vk(:,1:j) * va(j+1,1:j)', ...
         vfunarguments{:});
    end

    %# Compute the 7th and the 8th order estimation
    y7 = vu' + vstepsize * (vk * vb7);
    y8 = vu' + vstepsize * (vk * vb8);

    %# Calculate the absolute local truncation error and the acceptable error
    if (vstepsizegiven == false)
      if (vnormcontrol == false)
        vdelta = y8 - y7;
        vtau = max (vodeoptions.RelTol * vu', vodeoptions.AbsTol);
      else
	      vdelta = norm (y8 - y7, Inf);
	      vtau = max (vodeoptions.RelTol * max (norm (vu', Inf), 1.0), vodeoptions.AbsTol);
      end
    elseif (vstepsizegiven == true)
      vdelta = 1; vtau = 2;
    end

    %# If the error is acceptable then update the vretval variables
    if (all (vdelta <= vtau) == true)
      vtimestamp = vtimestamp + vstepsize;
      vu = y8'; %# MC2001: the higher order estimation as "local extrapolation"
      vretvaltime(vcntloop,:) = vtimestamp;
      vretvalresult(vcntloop,:) = vu;
      %# Stop integration if return value is false
      if (vhaveoutputfunction == true)
        if ((feval (vodeoptions.OutputFcn, vtimestamp, vu, [])) == false), break; end
      end
      vcntloop = vcntloop + 1;
    end

    %# Update the step size for the next integration step
    if (vstepsizegiven == false)
      vdelta = max (vdelta, eps); %# vdelta may be 0 or even negativ - could be an iteration problem
      vstepsize = min (vodeoptions.MaxStep, min (0.8 * vstepsize * (vtau ./ vdelta).^vpow));
    elseif (vstepsizegiven == true)% && vtimestamp < vtimestop)
      vstepsize = vslot(1,vcntloop-1) - vslot(1,vcntloop-2);
    end

    %# Reminder for me, this has to be done in the near future
    %# Wenn vstepsizeold == vstepsizenew dann Abbruch wegen Iterationsproblem

  end %# The main loop

  %# Postprocessing, something to do when terminating integration algorithm?
  if (vhaveoutputfunction == true), %# Cleanup plotter
    feval (vodeoptions.OutputFcn, vtimestamp, vu, 'done'); end
  if (nargout == 1)                 %# Sort output variables, depends on nargout
    varargout{1}.x = vretvaltime;   %# Time stamps are saved in field x
    varargout{1}.y = vretvalresult; %# Results are saved in field y
    varargout{1}.solver = 'ode78';  %# Solver name is saved in field solver
  elseif (nargout == 2)
    varargout{1} = vretvaltime;     %# Time stamps are first output argument
    varargout{2} = vretvalresult;   %# Results are second output argument
  elseif (nargout == 5)
    varargout{1} = vretvaltime;     %# Same as (nargout == 2)
    varargout{2} = vretvalresult;   %# Same as (nargout == 2)
    varargout{3} = [];              %# Not yet implemented
    varargout{4} = [];              %# Not yet implemented
    varargout{5} = [];              %# Not yet implemented
  %# else nothing will be returned, varargout{1} undefined
  end

%# The following tests have been added to check the function's input arguments and output arguments
%!test vx = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0]);
%!test [vx, vy] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0]);
%!test [vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0]);
%!test vx = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 26), [0 0]);
%!test [vx, vy] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 26), [0 0]);
%!test [vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 26), [0 0]);
%!test A = odeset ('MaxStep', 1.5/50); 
%!     vx = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%!test A = odeset ('MaxStep', 1.5/50); 
%!     [vx, vy] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%!test A = odeset ('MaxStep', 1.5/50); 
%!     [vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%!test A = odeset ('MaxStep', 1.5/50); 
%!     vx = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A, 5, 2, 0.02, 0.1);
%!test A = odeset ('MaxStep', 1.5/50); 
%!     [vx, vy] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A, 5, 2, 0.02, 0.1);
%!test A = odeset ('MaxStep', 1.5/50); 
%!     [vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A, 5, 2, 0.02, 0.1);

%!demo
%!
%! A = odeset ('RelTol', 1e-9);
%! [vx, vy] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], ...
%!    A, 5, 2, 0.02, 0.1);
%!
%! plot (vx, vy(:,1), '-ob;y, x2;', vx, vy(:,2), '-or;x1;', ...
%!    vx, ones(length(vx),1)*5, '-og;u;');
%!
%! % ---------------------------------------------------------------------
%! % The figure window shows the state variables x1, x2 as well as the 
%! % input signal u and the output signal y(=x2) of a second order lag 
%! % implementation (cf. the control theory). The function ode78 was
%! % called with an option argument A that has been set before with the
%! % command "odeset" and with further parameters "5, 2, 0.02, 0.1" that
%! % are passed to the set of ordinary differential equations.

%# Local Variables: ***
%# mode: octave ***
%# End: ***