%# Copyright (C) 2006, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - Package for solving ordinary differential equations with Octave
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
%# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

%# -*- texinfo -*-
%# @deftypefn  {Function} ode78 (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%# @deftypefnx {Function} {@var{sol} =} ode78 (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%# @deftypefnx {Function} {@var{[t, y, [xe, ye, ie]]} =} ode78 (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%#
%# If called with no return argument, plots the solutions over time in a figure window while solving the set of equations that are defined in a function and specified by the function handle @var{@@fun}. The second input argument @var{slot} must be the time slot, @var{init} must be the states initial values, @var{opt} can optionally be the options structure that is created with the command @command{odeset} and @var{[P1, P2, @dots{}]} can optionally be all arguments that have to be passed to the function @var{fun}. If an invalid input argument is detected then the function terminates with an error.
%#
%# If called with one return argument, returns the solution structure @var{sol} after solving the set of ordinary differential equations. The solution structure @var{sol} has the fields @var{x} for the steps chosen by the solver, @var{y} for the solver solutions, @var{solver} for the solver name and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} of the event function if an event property is set in the option argument @var{opt}. See the description for the input arguments before. If an invalid input argument is detected then the function terminates with an error.
%#
%# If called with more than one return argument, returns the time stamps @var{t}, the solution values @var{y} and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} of the event function if an event property is set in the option argument @var{opt}. See the description for the input arguments before. If an invalid input argument is detected then the function terminates with an error.
%#
%# Run
%# @example
%# demo ode78
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# ChangeLog:
%#   20010519 the function file "ode78.m" was written by Marc Compere
%#     under the GPL for the use with Octave. This function has been
%#     taken as a base for the following implementation.
%#   20060810, Thomas Treichl
%#     This function was adapted to the new syntax that is used by
%#     OdePkg for Octave. An equivalent function in MatLab does not
%#     exist.

function [varargout] = ode78 (vfun, vslot, vinit, varargin)

  if (nargin == 0) %# Check number and types of all input arguments
    help ('ode78');
    error ('OdePkg:ode78:InvalidInputArgument', ...
      'Number of input arguments must be greater than zero');

  elseif (nargin < 3)
    print_usage;

  elseif (~isa (vfun, 'function_handle'))
    error ('OdePkg:ode78:InvalidInputArgument', ...
      'First input argument must be a valid function handle');

  elseif (~isvector (vslot) || length (vslot) < 2)
    error ('OdePkg:ode78:InvalidInputArgument', ...
      'Second input argument must be a valid vector');

  elseif (~isvector (vinit) || ~isnumeric (vinit))
    error ('OdePkg:ode78:InvalidInputArgument', ...
      'Third input argument must be a valid vector');

  elseif (nargin >= 4)

    if (~isstruct (varargin{1}))
      %# varargin{1:len} are parameters for vfun
      vodeoptions = odeset;
      vfunarguments = varargin;

    elseif (length (varargin) > 1)
      %# varargin{1} is an OdePkg options structure vopt
      vodeoptions = odepkg_structure_check (varargin{1}, 'ode78');
      vfunarguments = {varargin{2:length(varargin)}};

    else %# if (isstruct (varargin{1}))
      vodeoptions = odepkg_structure_check (varargin{1}, 'ode78');
      vfunarguments = {};

    end

  else %# if (nargin == 3)
    vodeoptions = odeset; 
    vfunarguments = {};
  end

  %# Preprocessing, have a look which options have been set in
  %# vodeoptions. Check if a invalid option has been set and print
  %# warnings.
  if (size (vslot, 1) > size (vslot, 2)), vslot = vslot'; end %# create row vector
  if (size (vinit, 1) > size (vinit, 2)), vinit = vinit'; end %# create row vector
  if (size (vslot, 2) > 2), vstepsizegiven = true;            %# Step size checking
  else vstepsizegiven = false; end  
  %# A row vector could always easily be created with vinit = (vinit(:))';
  %# Get the default options that can be set with 'odeset' temporarily
  vodetemp = odeset;

  %# Implementation of the option RelTol has been finished. This option
  %# can be set by the user to another value than default value.
  if (isempty (vodeoptions.RelTol) && ~vstepsizegiven)
    vodeoptions.RelTol = 1e-6;
    warning ('OdePkg:ode78:EmptyOption', ...
      'Option "RelTol" not set, new value %f is used', vodeoptions.RelTol);
  elseif (~isempty (vodeoptions.RelTol) && vstepsizegiven)
    warning ('OdePkg:ode78:UnhandledOption', ...
      'Option "RelTol" will be ignored if fixed time stamps are given');
  %# This implementation has been added to odepkg_structure_check.m
  %# elseif (~isscalar (vodeoptions.RelTol) && ~vstepsizegiven)
  %# error ('OdePkg:ode78:InvalidOption', ...
  %#   'Option "RelTol" must be set to a scalar value for this solver');
  end

  %# Implementation of the option AbsTol has been finished. This option
  %# can be set by the user to another value than default value.
  if (isempty (vodeoptions.AbsTol) && ~vstepsizegiven)
    vodeoptions.AbsTol = 1e-6;
    warning ('OdePkg:ode78:EmptyOption', ...
      'Option "AbsTol" not set, new value %f is used', vodeoptions.AbsTol);
  elseif (~isempty (vodeoptions.AbsTol) && vstepsizegiven)
    warning ('OdePkg:ode78:UnhandledOption', ...
      'Option "AbsTol" will be ignored if fixed time stamps are given');
  else %# create column vector
    vodeoptions.AbsTol = vodeoptions.AbsTol(:);
  end

  %# Implementation of the option NormControl has been finished. This
  %# option can be set by the user to another value than default value.
  if (strcmp (vodeoptions.NormControl, 'on')), vnormcontrol = true;
  else vnormcontrol = false;
  end

  %# Implementation of the option NonNegative has been finished. This
  %# option can be set by the user to another value than default value.
  if (~isempty (vodeoptions.NonNegative))
    if (isempty (vodeoptions.Mass)), vhavenonnegative = true;
    else
      vhavenonnegative = false;
      warning ('OdePkg:ode78:UnusedOption', ...
        'Option "NonNegative" will be ignored if mass matrix is set');
    end
  else vhavenonnegative = false;
  end

  %# Implementation of the option OutputFcn has been finished. This
  %# option can be set by the user to another value than default value.
  if (isempty (vodeoptions.OutputFcn) && nargout == 0)
    vodeoptions.OutputFcn = @odeplot;
    vhaveoutputfunction = true;
  elseif (isempty (vodeoptions.OutputFcn)), vhaveoutputfunction = false;
  else vhaveoutputfunction = true;
  end

  %# Implementation of the option OutputSel has been finished. This
  %# option can be set by the user to another value than default value.
  if (~isempty (vodeoptions.OutputSel)), vhaveoutputselection = true;
  else vhaveoutputselection = false; end

  %# Implementation of the option Refine has been finished. This option
  %# can be set by the user to another value than default value.
  if (isequal (vodeoptions.Refine, vodetemp.Refine)), vhaverefine = true;
  else vhaverefine = false; end

  %# Implementation of the option Stats has been finished. This option
  %# can be set by the user to another value than default value.

  %# Implementation of the option InitialStep has been finished. This
  %# option can be set by the user to another value than default value.
  if (isempty (vodeoptions.InitialStep))
    vodeoptions.InitialStep = abs (vslot(1,1) - vslot(1,2)) / 10;
    vodeoptions.InitialStep = vodeoptions.InitialStep / 10^vodeoptions.Refine;
    warning ('OdePkg:ode78:EmptyOption', ...
      'Option "InitialStep" not set, new value %f is used', vodeoptions.InitialStep);
  end

  %# Implementation of the option MaxStep has been finished. This option
  %# can be set by the user to another value than default value.
  if (isempty (vodeoptions.MaxStep))
    vodeoptions.MaxStep = abs (vslot(1,1) - vslot(1,length (vslot))) / 10;
    %# vodeoptions.MaxStep = vodeoptions.MaxStep / 10^vodeoptions.Refine;
    warning ('OdePkg:ode78:EmptyOption', ...
      'Option "MaxStep" not set, new value %f is used', vodeoptions.MaxStep);
  end

  %# Implementation of the option Events has been finished. This option
  %# can be set by the user to another value than default value.
  if (~isempty (vodeoptions.Events)), vhaveeventfunction = true;
  else vhaveeventfunction = false; end

  %# The options 'Jacobian', 'JPattern' and 'Vectorized' will be ignored
  %# by this solver because this solver uses an explicit Runge-Kutta
  %# method and therefore no Jacobian calculation is necessary
  if (~isequal (vodeoptions.Jacobian, vodetemp.Jacobian))
    warning ('OdePkg:ode78:UnusedOption', ...
      'Option "Jacobian" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.JPattern, vodetemp.JPattern))
    warning ('OdePkg:ode78:UnusedOption', ...
      'Option "JPattern" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.Vectorized, vodetemp.Vectorized))
    warning ('OdePkg:ode78:UnusedOption', ...
      'Option "Vectorized" will be ignored by this solver');
  end

  %# Implementation of the option Mass has been finished. This option
  %# can be set by the user to another value than default value.
  if (~isempty (vodeoptions.Mass) && ismatrix (vodeoptions.Mass))
    vhavemasshandle = false; vmass = vodeoptions.Mass; %# constant mass
  elseif (isa (vodeoptions.Mass, 'function_handle'))
    vhavemasshandle = true; %# mass defined by a function handle
  else %# no mass matrix - creating a diag-matrix of ones for mass
    vhavemasshandle = false; vmass = diag (ones (length (vinit), 1), 0);
  end

  %# Implementation of the option MStateDependence has been finished.
  %# This option can be set by the user to another value than default
  %# value. 
  if (strcmp (vodeoptions.MStateDependence, 'none'))
    vmassdependence = false;
  else vmassdependence = true;
  end

  %# Other options that are not used by this solver. Print a warning
  %# message to tell the user that the option(s) is/are ignored.
  if (~isequal (vodeoptions.MvPattern, vodetemp.MvPattern))
    warning ('OdePkg:ode78:UnusedOption', ...
      'Option "MvPattern" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.MassSingular, vodetemp.MassSingular))
    warning ('OdePkg:ode78:UnusedOption', ...
      'Option "MassSingular" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.InitialSlope, vodetemp.InitialSlope))
    warning ('OdePkg:ode78:UnusedOption', ...
      'Option "InitialSlope" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.MaxOrder, vodetemp.MaxOrder))
    warning ('OdePkg:ode78:UnusedOption', ...
      'Option "MaxOrder" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.BDF, vodetemp.BDF))
    warning ('OdePkg:ode78:UnusedOption', ...
      'Option "BDF" will be ignored by this solver');
  end

  %# Starting the initialisation of the core solver ode78 
  vtimestamp  = vslot(1,1);           %# timestamp = start time
  vtimelength = length (vslot);       %# length needed if fixed steps
  vtimestop   = vslot(1,vtimelength); %# stop time = last value

  if (~vstepsizegiven)
    vstepsize = vodeoptions.InitialStep;
    vminstepsize = (vtimestop - vtimestamp) / (1/eps);
  else %# If step size is given then use the fixed time steps
    vstepsize = abs (vslot(1,1) - vslot(1,2));
    vminstepsize = eps; %# vslot(1,2) - vslot(1,1) - eps;
  end

  vretvaltime = vtimestamp; %# first timestamp output
  if (vhaveoutputselection) %# first solution output
    vretvalresult = vinit(vodeoptions.OutputSel);
  else vretvalresult = vinit;
  end

  %# Initialize OutputFcn
  if (vhaveoutputfunction)
    feval (vodeoptions.OutputFcn, vslot', ...
      vretvalresult', 'init', vfunarguments{:});
  end

  %# Initialize EventFcn
  if (vhaveeventfunction)
    odepkg_event_handle (vodeoptions.Events, vtimestamp, ...
      vretvalresult', 'init', vfunarguments{:});
  end

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

  %# The solver main loop - stop if endpoint has been reached
  vcntloop = 2; vcntcycles = 1; vu = vinit; vk = vu' * zeros(1,13);
  vcntiter = 0; vunhandledtermination = true;
  while ((vtimestamp < vtimestop && vstepsize >= vminstepsize))

    %# Hit the endpoint of the time slot exactely
    if ((vtimestamp + vstepsize) > vtimestop)
      vstepsize = vtimestop - vtimestamp; end

    %# Estimate the thirteen results when using this solver
    for j = 1:13
      if (vhavemasshandle)   %# Handle only the dynamic mass matrix,
        if (vmassdependence) %# constant mass matrices have already
          vmass = feval ...  %# been set before (if any)
            (vodeoptions.Mass, vtimestamp + vc(j,1) * vstepsize, ...
             vu' + vstepsize * vk(:,1:j-1) * va(j,1:j-1)', ...
             vfunarguments{:});
        else                 %# if (vmassdependence == false)
          vmass = feval ...  %# then we only have the time argument
            (vodeoptions.Mass, vtimestamp + vc(j,1) * vstepsize, ...
             vfunarguments{:});
        end
      end
      vk(:,j) = vmass \ feval ...
        (vfun, vtimestamp + vc(j,1) * vstepsize, ...
         vu' + vstepsize * vk(:,1:j-1) * va(j,1:j-1)', ...
         vfunarguments{:});
    end

    %# Compute the 7th and the 8th order estimation
    y7 = vu' + vstepsize * (vk * vb7);
    y8 = vu' + vstepsize * (vk * vb8);
    if (vhavenonnegative)
      vu(vodeoptions.NonNegative) = abs (vu(vodeoptions.NonNegative));
      y7(vodeoptions.NonNegative) = abs (y7(vodeoptions.NonNegative));
      y8(vodeoptions.NonNegative) = abs (y8(vodeoptions.NonNegative));
    end
    vSaveVUForRefine = vu;

    %# Calculate the absolute local truncation error and the acceptable error
    if (~vstepsizegiven)
      if (~vnormcontrol)
        vdelta = y8 - y7;
        vtau = max (vodeoptions.RelTol * vu', vodeoptions.AbsTol);
      else
        vdelta = norm (y8 - y7, Inf);
        vtau = max (vodeoptions.RelTol * max (norm (vu', Inf), 1.0), ...
                    vodeoptions.AbsTol);
      end
    else %# if (vstepsizegiven == true)
      vdelta = 1; vtau = 2;
    end

    %# If the error is acceptable then update the vretval variables
    if (all (vdelta <= vtau))
      vtimestamp = vtimestamp + vstepsize;
      vu = y8'; %# MC2001: the higher order estimation as "local extrapolation"
      vretvaltime(vcntloop,:) = vtimestamp;
      if (vhaveoutputselection)
        vretvalresult(vcntloop,:) = vu(vodeoptions.OutputSel);
      else vretvalresult(vcntloop,:) = vu;
      end
      vcntloop = vcntloop + 1; vcntiter = 0;

      %# Call plot only if a valid result has been found, therefore this
      %# code fragment has moved here. Stop integration if plot function
      %# returns false
      if (vhaveoutputfunction)
        if (vhaverefine)                  %# Do interpolation
          for vcnt = 0:vodeoptions.Refine %# Approximation between told and t
            vapproxtime = (vcnt + 1) * vstepsize / (vodeoptions.Refine + 2);
            vapproxvals = vSaveVUForRefine' + vapproxtime * (vk * vb8);
            if (vhaveoutputselection)
              vapproxvals = vapproxvals(vodeoptions.OutputSel);
            end
            feval (vodeoptions.OutputFcn, (vtimestamp - vstepsize) + vapproxtime, ...
              vapproxvals, [], vfunarguments{:});
          end
        end
        vpltret = feval (vodeoptions.OutputFcn, vtimestamp, ...
          vretvalresult(vcntloop-1,:)', [], vfunarguments{:});
        if (~vpltret), vunhandledtermination = false; break; end
      end

      %# Call event only if a valid result has been found, therefore this
      %# code fragment has moved here. Stop integration if veventbreak is
      %# true
      if (vhaveeventfunction)
        vevent = ...
          odepkg_event_handle (vodeoptions.Events, vtimestamp, ...
            vu(:), [], vfunarguments{:});
        %# 20070222, bugfix, Calling event function does not depend on
        %# OutputSel vretvalresult(vcntloop-1,:)', [], vfunarguments{:});
        if (~vevent{1})
          vretvaltime(vcntloop-1,:) = vevent{3}(end,:);
          vretvalresult(vcntloop-1,:) = vevent{4}(end,:);
          vunhandledtermination = false; break;
        end
      end
    end %# If the error is acceptable ...

    %# Update the step size for the next integration step
    if (~vstepsizegiven)
      %# vdelta may be 0 or even negative - could be an iteration problem
      vdelta = max (vdelta, eps); 
      vstepsize = min (vodeoptions.MaxStep, ...
        min (0.8 * vstepsize * (vtau ./ vdelta) .^ vpow));
    elseif (vstepsizegiven)
      if (vcntloop < vtimelength)
        vstepsize = vslot(1,vcntloop-1) - vslot(1,vcntloop-2);
      end
    end

    %# Update counters that count the number of iteration cycles
    vcntcycles = vcntcycles + 1; %# Needed for postprocessing
    vcntiter = vcntiter + 1;     %# Needed to find iteration problems

    %# Stop solving because the last 1000 steps no successful valid
    %# value has been found
    if (vcntiter >= 5000)
      error (['Solving has not been successful. The iterative', ...
        ' integration loop exited at time t = %f before endpoint at', ...
        ' tend = %f was reached. This happened because the iterative', ...
        ' integration loop does not find a valid solution at this time', ...
        ' stamp. Try to reduce the value of "InitialStep" and/or', ...
        ' "MaxStep" with the command "odeset".\n'], vtimestamp, vtimestop);
    end

  end %# The main loop

  %# Check if integration of the ode has been successful
  if (vtimestamp < vtimestop)
    if (vunhandledtermination == true)
      error (['Solving has not been successful. The iterative', ...
        ' integration loop exited at time t = %f', ...
        ' before endpoint at tend = %f was reached. This may', ...
        ' happen if the stepsize grows smaller than defined in', ...
        ' vminstepsize. Try to reduce the value of "InitialStep" and/or', ...
        ' "MaxStep" with the command "odeset".\n'], vtimestamp, vtimestop);
    else
      warning (['Solver has been stopped by a call of "break" in', ...
        ' the main iteration loop at time t = %f before endpoint at', ...
        ' tend = %f was reached. This may happen because the @odeplot', ...
        ' function returned zero or the @event function returned one.'], ...
        vtimestamp, vtimestop);
    end
  end

  %# Postprocessing, do whatever when terminating integration algorithm
  if (vhaveoutputfunction) %# Cleanup plotter
    feval (vodeoptions.OutputFcn, vtimestamp, ...
      vretvalresult(vcntloop-1,:)', 'done', vfunarguments{:});
  end
  if (vhaveeventfunction)  %# Cleanup event function handling
    odepkg_event_handle (vodeoptions.Events, vtimestamp, ...
      vretvalresult(vcntloop-1,:), 'done', vfunarguments{:});
  end

  %# Print additional information if option Stats is set
  if (strcmp (vodeoptions.Stats, 'on'))
    vhavestats = true;
    vsuccess   = vcntloop-2;                    %# vcntloop from 2..end
    vfailed    = (vcntcycles-1)-(vcntloop-2)+1; %# vcntcycl from 1..end
    vfuncalls  = 13*(vcntcycles-1);             %# number of ode evaluations
    vludecomp  = 0;                             %# number of LU decompositions
    vpartderv  = 0;                             %# number of partial derivatives
    vlinsols   = 0;                             %# no. of solutions of linear systems
    vmsg = sprintf ('Number of successful steps: %d', vsuccess); disp (vmsg);
    vmsg = sprintf ('Number of failed attempts:  %d', vfailed); disp (vmsg);
    vmsg = sprintf ('Number of function calls:   %d', vfuncalls); disp (vmsg);
  else vhavestats = false;
  end

  if (nargout == 1)                 %# Sort output variables, depends on nargout
    varargout{1}.x = vretvaltime;   %# Time stamps are saved in field x
    varargout{1}.y = vretvalresult; %# Results are saved in field y
    varargout{1}.solver = 'ode78';  %# Solver name is saved in field solver
    if (vhaveeventfunction) 
      varargout{1}.ie = vevent{2};  %# Index info which event occured
      varargout{1}.xe = vevent{3};  %# Time info when an event occured
      varargout{1}.ye = vevent{4};  %# Results when an event occured
    end
    if (vhavestats)
      varargout{1}.stats.success = vsuccess;
      varargout{1}.stats.failed  = vfailed;    
      varargout{1}.stats.fevals  = vfuncalls;  
      varargout{1}.stats.partial = vpartderv; 
      varargout{1}.stats.ludecom = vludecomp;
      varargout{1}.stats.linsol  = vlinsols; 
    end
  elseif (nargout == 2)
    varargout{1} = vretvaltime;     %# Time stamps are first output argument
    varargout{2} = vretvalresult;   %# Results are second output argument
  elseif (nargout == 5)
    varargout{1} = vretvaltime;     %# Same as (nargout == 2)
    varargout{2} = vretvalresult;   %# Same as (nargout == 2)
    varargout{3} = [];              %# LabMat doesn't accept lines like
    varargout{4} = [];              %# varargout{3} = varargout{4} = [];
    varargout{5} = [];
    if (vhaveeventfunction) 
      varargout{3} = vevent{3};     %# Time info when an event occured
      varargout{4} = vevent{4};     %# Results when an event occured
      varargout{5} = vevent{2};     %# Index info which event occured
    end
  %# else nothing will be returned, varargout{1} undefined
  end

%# The following tests have been added to check the function's input arguments and output arguments
%!test vx = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0]);
%!test [vx, vy] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0]);
%!test [vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0]);
%!test vx = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 26), [0 0]);
%!test [vx, vy] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 26), [0 0]);
%!test [vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 26), [0 0]);
%!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%!     vx = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%!     [vx, vy] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%!     [vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%!     vx = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A, 5, 2, 0.02, 0.1);
%!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%!     [vx, vy] = ode78 (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A, 5, 2, 0.02, 0.1);
%!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
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
