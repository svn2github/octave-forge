%# Copyright (C) 2006-2008, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - A package for solving ordinary differential equations and more
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
%# along with this program; If not, see <http://www.gnu.org/licenses/>.

%# -*- texinfo -*-
%# @deftypefn  {Function File} {[@var{}] =} ode23 (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%# @deftypefnx {Command} {[@var{sol}] =} ode23 (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%# @deftypefnx {Command} {[@var{t}, @var{y}, [@var{xe}, @var{ye}, @var{ie}]] =} ode23 (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%#
%# This function file can be used to solve a set of non--stiff ordinary differential equations (non--stiff ODEs) or non--stiff differential algebraic equations (non--stiff DAEs) with the well known explicit Runge--Kutta method of order (2,3).
%#
%# If this function is called with no return argument then plot the solution over time in a figure window while solving the set of ODEs that are defined in a function and specified by the function handle @var{@@fun}. The second input argument @var{slot} is a double vector that defines the time slot, @var{init} is a double vector that defines the initial values of the states, @var{opt} can optionally be a structure array that keeps the options created with the command @command{odeset} and @var{par1}, @var{par2}, @dots{} can optionally be other input arguments of any type that have to be passed to the function defined by @var{@@fun}.
%#
%# If this function is called with one return argument then return the solution @var{sol} of type structure array after solving the set of ODEs. The solution @var{sol} has the fields @var{x} of type double column vector for the steps chosen by the solver, @var{y} of type double column vector for the solutions at each time step of @var{x}, @var{solver} of type string for the solver name and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector that keep the informations of the event function if an event function handle is set in the option argument @var{opt}.
%#
%# If this function is called with more than one return argument then return the time stamps @var{t}, the solution values @var{y} and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector.
%#
%# For example, solve an anonymous implementation of the Van der Pol equation
%#
%# @example
%# fvdb = @@(vt,vy) [vy(2); (1 - vy(1)^2) * vy(2) - vy(1)];
%#
%# vopt = odeset ("RelTol", 1e-3, "AbsTol", 1e-3, \
%#          "NormControl", "on", "OutputFcn", @@odeplot);
%# ode23 (fvdb, [0 20], [2 0], vopt);
%# @end example
%# @end deftypefn
%#
%# @seealso{odepkg}

%# ChangeLog:
%#   20010703 the function file "ode23.m" was written by Marc Compere
%#     under the GPL for the use with this software. This function has been
%#     taken as a base for the following implementation.
%#   20060810, Thomas Treichl
%#     This function was adapted to the new syntax that is used by the
%#     new OdePkg for Octave and is compatible to Matlab's ode23.

function [varargout] = ode23 (vfun, vslot, vinit, varargin)

  if (nargin == 0) %# Check number and types of all input arguments
    help ('ode23');
    error ('OdePkg:InvalidArgument', ...
      'Number of input arguments must be greater than zero');

  elseif (nargin < 3)
    print_usage;

  elseif ~(isa (vfun, 'function_handle') || isa (vfun, 'inline'))
    error ('OdePkg:InvalidArgument', ...
      'First input argument must be a valid function handle');

  elseif (~isvector (vslot) || length (vslot) < 2)
    error ('OdePkg:InvalidArgument', ...
      'Second input argument must be a valid vector');

  elseif (~isvector (vinit) || ~isnumeric (vinit))
    error ('OdePkg:InvalidArgument', ...
      'Third input argument must be a valid numerical value');

  elseif (nargin >= 4)

    if (~isstruct (varargin{1}))
      %# varargin{1:len} are parameters for vfun
      vodeoptions = odeset;
      vfunarguments = varargin;

    elseif (length (varargin) > 1)
      %# varargin{1} is an OdePkg options structure vopt
      vodeoptions = odepkg_structure_check (varargin{1}, 'ode23');
      vfunarguments = {varargin{2:length(varargin)}};

    else %# if (isstruct (varargin{1}))
      vodeoptions = odepkg_structure_check (varargin{1}, 'ode23');
      vfunarguments = {};

    end

  else %# if (nargin == 3)
    vodeoptions = odeset; 
    vfunarguments = {};
  end

  %# Start preprocessing, have a look which options are set in
  %# vodeoptions, check if an invalid or unused option is set
  vslot = vslot(:).';     %# Create a row vector
  vinit = vinit(:).';     %# Create a row vector
  if (length (vslot) > 2) %# Step size checking
    vstepsizefixed = true;
  else
    vstepsizefixed = false;
  end  

  %# Get the default options that can be set with 'odeset' temporarily
  vodetemp = odeset;

  %# Implementation of the option RelTol has been finished. This option
  %# can be set by the user to another value than default value.
  if (isempty (vodeoptions.RelTol) && ~vstepsizefixed)
    vodeoptions.RelTol = 1e-6;
    warning ('OdePkg:InvalidArgument', ...
      'Option "RelTol" not set, new value %f is used', vodeoptions.RelTol);
  elseif (~isempty (vodeoptions.RelTol) && vstepsizefixed)
    warning ('OdePkg:InvalidArgument', ...
      'Option "RelTol" will be ignored if fixed time stamps are given');
  end

  %# Implementation of the option AbsTol has been finished. This option
  %# can be set by the user to another value than default value.
  if (isempty (vodeoptions.AbsTol) && ~vstepsizefixed)
    vodeoptions.AbsTol = 1e-6;
    warning ('OdePkg:InvalidArgument', ...
      'Option "AbsTol" not set, new value %f is used', vodeoptions.AbsTol);
  elseif (~isempty (vodeoptions.AbsTol) && vstepsizefixed)
    warning ('OdePkg:InvalidArgument', ...
      'Option "AbsTol" will be ignored if fixed time stamps are given');
  else
    vodeoptions.AbsTol = vodeoptions.AbsTol(:); %# Create column vector
  end

  %# Implementation of the option NormControl has been finished. This
  %# option can be set by the user to another value than default value.
  if (strcmp (vodeoptions.NormControl, 'on')) vnormcontrol = true;
  else vnormcontrol = false; end

  %# Implementation of the option NonNegative has been finished. This
  %# option can be set by the user to another value than default value.
  if (~isempty (vodeoptions.NonNegative))
    if (isempty (vodeoptions.Mass)), vhavenonnegative = true;
    else
      vhavenonnegative = false;
      warning ('OdePkg:InvalidArgument', ...
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

  %# Implementation of the option OutputSave has been finished. This
  %# option can be set by the user to another value than default value.
  if (isempty (vodeoptions.OutputSave)), vodeoptions.OutputSave = 1;
  end

  %# Implementation of the option Refine has been finished. This option
  %# can be set by the user to another value than default value.
  if (isequal (vodeoptions.Refine, vodetemp.Refine)), vhaverefine = true;
  else vhaverefine = false; end

  %# Implementation of the option Stats has been finished. This option
  %# can be set by the user to another value than default value.

  %# Implementation of the option InitialStep has been finished. This
  %# option can be set by the user to another value than default value.
  if (isempty (vodeoptions.InitialStep) && ~vstepsizefixed)
    vodeoptions.InitialStep = vslot(1,2) - vslot(1,1) / 10;
    vodeoptions.InitialStep = vodeoptions.InitialStep / 10^vodeoptions.Refine;
    warning ('OdePkg:InvalidArgument', ...
      'Option "InitialStep" not set, new value %f is used', vodeoptions.InitialStep);
  end

  %# Implementation of the option MaxStep has been finished. This option
  %# can be set by the user to another value than default value.
  if (isempty (vodeoptions.MaxStep) && ~vstepsizefixed)
    vodeoptions.MaxStep = vslot(1,2) - vslot(1,1) / 10;
    warning ('OdePkg:InvalidArgument', ...
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
    warning ('OdePkg:InvalidArgument', ...
      'Option "Jacobian" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.JPattern, vodetemp.JPattern))
    warning ('OdePkg:InvalidArgument', ...
      'Option "JPattern" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.Vectorized, vodetemp.Vectorized))
    warning ('OdePkg:InvalidArgument', ...
      'Option "Vectorized" will be ignored by this solver');
  end

  %# Implementation of the option Mass has been finished. This option
  %# can be set by the user to another value than default value.
  if (~isempty (vodeoptions.Mass) && ismatrix (vodeoptions.Mass))
    vhavemasshandle = false; vmass = vodeoptions.Mass; %# constant mass
  elseif (isa (vodeoptions.Mass, 'function_handle'))
    vhavemasshandle = true; %# mass defined by a function handle
  else %# no mass matrix - creating a diag-matrix of ones for mass
    vhavemasshandle = false; %# vmass = diag (ones (length (vinit), 1), 0);
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
    warning ('OdePkg:InvalidArgument', ...
      'Option "MvPattern" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.MassSingular, vodetemp.MassSingular))
    warning ('OdePkg:InvalidArgument', ...
      'Option "MassSingular" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.InitialSlope, vodetemp.InitialSlope))
    warning ('OdePkg:InvalidArgument', ...
      'Option "InitialSlope" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.MaxOrder, vodetemp.MaxOrder))
    warning ('OdePkg:InvalidArgument', ...
      'Option "MaxOrder" will be ignored by this solver');
  end
  if (~isequal (vodeoptions.BDF, vodetemp.BDF))
    warning ('OdePkg:InvalidArgument', ...
      'Option "BDF" will be ignored by this solver');
  end

  %# Starting the initialisation of the core solver ode23 
  vtimestamp  = vslot(1,1);           %# timestamp = start time
  vtimelength = length (vslot);       %# length needed if fixed steps
  vtimestop   = vslot(1,vtimelength); %# stop time = last value
  vdirection  = sign (vtimestop);     %# Flag for direction to solve

  if (~vstepsizefixed)
    vstepsize = vodeoptions.InitialStep;
    vminstepsize = (vtimestop - vtimestamp) / (1/eps);
  else %# If step size is given then use the fixed time steps
    vstepsize = vslot(1,2) - vslot(1,1);
    vminstepsize = sign (vstepsize) * eps;
  end

  vretvaltime = vtimestamp; %# first timestamp output
  if (vhaveoutputselection) %# first solution output
    vretvalresult = vinit(vodeoptions.OutputSel);
  else vretvalresult = vinit;
  end

  %# Initialize the OutputFcn
  if (vhaveoutputfunction)
    feval (vodeoptions.OutputFcn, vslot.', ...
      vretvalresult.', 'init', vfunarguments{:});
  end

  %# Initialize the EventFcn
  if (vhaveeventfunction)
    odepkg_event_handle (vodeoptions.Events, vtimestamp, ...
      vretvalresult.', 'init', vfunarguments{:});
  end

  vpow = 1/3;            %# 20071016, reported by Luis Randez
  va = [  0, 0, 0;       %# The Runge-Kutta-Fehlberg 2(3) coefficients
        1/2, 0, 0;       %# Coefficients proved on 20060827
         -1, 2, 0];      %# See p.91 in Ascher & Petzold
  vb2 = [0; 1; 0];       %# 2nd and 3rd order
  vb3 = [1/6; 2/3; 1/6]; %# b-coefficients
  vc = sum (va, 2);

  %# The solver main loop - stop if the endpoint has been reached
  vcntloop = 2; vcntcycles = 1; vu = vinit; vk = vu.' * zeros(1,3);
  vcntiter = 0; vunhandledtermination = true; vcntsave = 2;
  while ((vdirection * (vtimestamp) < vdirection * (vtimestop)) && ...
         (vdirection * (vstepsize) >= vdirection * (vminstepsize)))

    %# Hit the endpoint of the time slot exactely
    if ((vtimestamp + vstepsize) > vdirection * vtimestop)
%# if (((vtimestamp + vstepsize) > vtimestop) || ...
%#   (abs(vtimestamp + vstepsize - vtimestop) < eps))
      vstepsize = vtimestop - vdirection * vtimestamp;
    end

    %# Estimate the three results when using this solver
    for j = 1:3
      vthetime  = vtimestamp + vc(j,1) * vstepsize;
      vtheinput = vu.' + vstepsize * vk(:,1:j-1) * va(j,1:j-1).';
      if (vhavemasshandle)   %# Handle only the dynamic mass matrix,
        if (vmassdependence) %# constant mass matrices have already
          vmass = feval ...  %# been set before (if any)
            (vodeoptions.Mass, vthetime, vtheinput, vfunarguments{:});
        else                 %# if (vmassdependence == false)
          vmass = feval ...  %# then we only have the time argument
            (vodeoptions.Mass, vthetime, vfunarguments{:});
        end
        vk(:,j) = vmass \ feval ...
          (vfun, vthetime, vtheinput, vfunarguments{:});
      else
        vk(:,j) = feval ...
          (vfun, vthetime, vtheinput, vfunarguments{:});
      end
    end

    %# Compute the 2nd and the 3rd order estimation
    y2 = vu.' + vstepsize * (vk * vb2);
    y3 = vu.' + vstepsize * (vk * vb3);
    if (vhavenonnegative)
      vu(vodeoptions.NonNegative) = abs (vu(vodeoptions.NonNegative));
      y2(vodeoptions.NonNegative) = abs (y2(vodeoptions.NonNegative));
      y3(vodeoptions.NonNegative) = abs (y3(vodeoptions.NonNegative));
    end
    vSaveVUForRefine = vu;

    %# Calculate the absolute local truncation error and the acceptable error
    if (~vstepsizefixed)
      if (~vnormcontrol)
        vdelta = abs (y3 - y2);
        vtau = max (vodeoptions.RelTol * abs (vu.'), vodeoptions.AbsTol);
      else
        vdelta = norm (y3 - y2, Inf);
        vtau = max (vodeoptions.RelTol * max (norm (vu.', Inf), 1.0), ...
                    vodeoptions.AbsTol);
      end
    else %# if (vstepsizefixed == true)
      vdelta = 1; vtau = 2;
    end

    %# If the error is acceptable then update the vretval variables
    if (all (vdelta <= vtau))
      vtimestamp = vtimestamp + vstepsize;
      vu = y3.'; %# MC2001: the higher order estimation as "local extrapolation"
      %# Save the solution every vodeoptions.OutputSave steps             
      if (mod (vcntloop-1,vodeoptions.OutputSave) == 0)             
        if (vhaveoutputselection)
          vretvaltime(vcntsave,:) = vtimestamp;
          vretvalresult(vcntsave,:) = vu(vodeoptions.OutputSel);
        else
          vretvaltime(vcntsave,:) = vtimestamp;
          vretvalresult(vcntsave,:) = vu;
        end
        vcntsave = vcntsave + 1;    
      end     
      vcntloop = vcntloop + 1; vcntiter = 0;

      %# Call plot only if a valid result has been found, therefore this
      %# code fragment has moved here. Stop integration if plot function
      %# returns false
      if (vhaveoutputfunction)
        if (vhaverefine)                  %# Do interpolation
          for vcnt = 0:vodeoptions.Refine %# Approximation between told and t
            vapproxtime = (vcnt + 1) * vstepsize / (vodeoptions.Refine + 2);
            vapproxvals = vSaveVUForRefine.' + vapproxtime * (vk * vb3);
            if (vhaveoutputselection)
              vapproxvals = vapproxvals(vodeoptions.OutputSel);
            end
            feval (vodeoptions.OutputFcn, (vtimestamp - vstepsize) + vapproxtime, ...
              vapproxvals, [], vfunarguments{:});
          end
        end

        vpltret = feval (vodeoptions.OutputFcn, vtimestamp, ...
          vu.', [], vfunarguments{:});
        if (vpltret)
          vunhandledtermination = false;
          break;
        end
      end

      %# Call event only if a valid result has been found, therefore this
      %# code fragment has moved here. Stop integration if veventbreak is
      %# true
      if (vhaveeventfunction)
        vevent = ...
          odepkg_event_handle (vodeoptions.Events, vtimestamp, ...
            vu(:), [], vfunarguments{:});
        if (~isempty (vevent{1}) && vevent{1} == 1)
          vretvaltime(vcntloop-1,:) = vevent{3}(end,:);
          vretvalresult(vcntloop-1,:) = vevent{4}(end,:);
          vunhandledtermination = false; break;
        end
      end
    end %# If the error is acceptable ...

    %# Update the step size for the next integration step
    if (~vstepsizefixed)
      %# 20080425, reported by Marco Caliari
      %# vdelta cannot be negative (because of the absolute value that
      %# has been introduced) but it could be 0, then replace the zeros 
      %# with the maximum value of vdelta
      vdelta(find (vdelta == 0)) = max (vdelta);
      %# It could happen that max (vdelta) == 0 (ie. that the original
      %# vdelta was 0), in that case we double the previous vstepsize
      vdelta(find (vdelta == 0)) = max (vtau) .* (0.4 ^ (1 / vpow));

      if (vdirection == 1)
        vstepsize = min (vodeoptions.MaxStep, ...
           min (0.8 * vstepsize * (vtau ./ vdelta) .^ vpow));
      else
        vstepsize = max (vodeoptions.MaxStep, ...
          max (0.8 * vstepsize * (vtau ./ vdelta) .^ vpow));
      end

    else %# if (vstepsizefixed)
      if (vcntloop <= vtimelength)
        vstepsize = vslot(1,vcntloop-1) - vslot(1,vcntloop-2);
      else %# Get out of the main integration loop
        break;
      end
    end

    %# Update counters that count the number of iteration cycles
    vcntcycles = vcntcycles + 1; %# Needed for cost statistics
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
  if (vdirection * vtimestamp < vdirection * vtimestop)
    if (vunhandledtermination == true)
      error ('OdePkg:InvalidArgument', ...
        ['Solving has not been successful. The iterative', ...
         ' integration loop exited at time t = %f', ...
         ' before endpoint at tend = %f was reached. This may', ...
         ' happen if the stepsize grows smaller than defined in', ...
         ' vminstepsize. Try to reduce the value of "InitialStep" and/or', ...
         ' "MaxStep" with the command "odeset".\n'], vtimestamp, vtimestop);
    else
      warning ('OdePkg:InvalidArgument', ...
        ['Solver has been stopped by a call of "break" in', ...
         ' the main iteration loop at time t = %f before endpoint at', ...
         ' tend = %f was reached. This may happen because the @odeplot', ...
         ' function returned "true" or the @event function returned "true".'], ...
         vtimestamp, vtimestop);
    end
  end

  %# Postprocessing, do whatever when terminating integration algorithm
  if (vhaveoutputfunction) %# Cleanup plotter
    feval (vodeoptions.OutputFcn, vtimestamp, ...
      vu.', 'done', vfunarguments{:});
  end
  if (vhaveeventfunction)  %# Cleanup event function handling
    odepkg_event_handle (vodeoptions.Events, vtimestamp, ...
      vu.', 'done', vfunarguments{:});
  end
  %# Save the last step, if not already saved
  if (mod (vcntloop-2,vodeoptions.OutputSave) ~= 0)
    vretvaltime(vcntsave,:) = vtimestamp;
    vretvalresult(vcntsave,:) = vu;
  end 

  %# Print additional information if option Stats is set
  if (strcmp (vodeoptions.Stats, 'on'))
    vhavestats = true;
    vnsteps    = vcntloop-2;                    %# vcntloop from 2..end
    vnfailed   = (vcntcycles-1)-(vcntloop-2)+1; %# vcntcycl from 1..end
    vnfevals   = 3*(vcntcycles-1);              %# number of ode evaluations
    vndecomps  = 0;                             %# number of LU decompositions
    vnpds      = 0;                             %# number of partial derivatives
    vnlinsols  = 0;                             %# no. of solutions of linear systems
    %# Print cost statistics if no output argument is given
    if (nargout == 0)
      vmsg = fprintf (1, 'Number of successful steps: %d', vnsteps);
      vmsg = fprintf (1, 'Number of failed attempts:  %d', vnfailed);
      vmsg = fprintf (1, 'Number of function calls:   %d', vnfevals);
    end
  else
    vhavestats = false;
  end

  if (nargout == 1)                 %# Sort output variables, depends on nargout
    varargout{1}.x = vretvaltime;   %# Time stamps are saved in field x
    varargout{1}.y = vretvalresult; %# Results are saved in field y
    varargout{1}.solver = 'ode23';  %# Solver name is saved in field solver
    if (vhaveeventfunction) 
      varargout{1}.ie = vevent{2};  %# Index info which event occured
      varargout{1}.xe = vevent{3};  %# Time info when an event occured
      varargout{1}.ye = vevent{4};  %# Results when an event occured
    end
    if (vhavestats)
      varargout{1}.stats = struct;
      varargout{1}.stats.nsteps   = vnsteps;
      varargout{1}.stats.nfailed  = vnfailed;
      varargout{1}.stats.nfevals  = vnfevals;
      varargout{1}.stats.npds     = vnpds;
      varargout{1}.stats.ndecomps = vndecomps;
      varargout{1}.stats.nlinsols = vnlinsols;
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
  end
end

%! # We are using the "Van der Pol" implementation for all tests that
%! # are done for this function. We also define a Jacobian, Events,
%! # pseudo-Mass implementation. For further tests we also define a
%! # reference solution (computed at high accuracy) and an OutputFcn
%!function [ydot] = fpol (vt, vy, varargin) %# The Van der Pol
%!  ydot = [vy(2); (1 - vy(1)^2) * vy(2) - vy(1)];
%!function [vjac] = fjac (vt, vy, varargin) %# its Jacobian
%!  vjac = [0, 1; -1 - 2 * vy(1) * vy(2), 1 - vy(1)^2];
%!function [vjac] = fjcc (vt, vy, varargin) %# sparse type
%!  vjac = sparse ([0, 1; -1 - 2 * vy(1) * vy(2), 1 - vy(1)^2]);
%!function [vval, vtrm, vdir] = feve (vt, vy, varargin)
%!  vval = fpol (vt, vy, varargin); %# We use the derivatives
%!  vtrm = zeros (2,1);             %# that's why component 2
%!  vdir = ones (2,1);              %# seems to not be exact
%!function [vval, vtrm, vdir] = fevn (vt, vy, varargin)
%!  vval = fpol (vt, vy, varargin); %# We use the derivatives
%!  vtrm = ones (2,1);              %# that's why component 2
%!  vdir = ones (2,1);              %# seems to not be exact
%!function [vmas] = fmas (vt, vy)
%!  vmas = [1, 0; 0, 1];            %# Dummy mass matrix for tests
%!function [vmas] = fmsa (vt, vy)
%!  vmas = sparse ([1, 0; 0, 1]);   %# A sparse dummy matrix
%!function [vref] = fref ()         %# The computed reference sol
%!  vref = [0.32331666704577, -1.83297456798624];
%!function [vout] = fout (vt, vy, vflag, varargin)
%!  if (regexp (char (vflag), 'init') == 1)
%!    if (any (size (vt) ~= [2, 1])) error ('"fout" step "init"'); end
%!  elseif (isempty (vflag))
%!    if (any (size (vt) ~= [1, 1])) error ('"fout" step "calc"'); end
%!    vout = false;
%!  elseif (regexp (char (vflag), 'done') == 1)
%!    if (any (size (vt) ~= [1, 1])) error ('"fout" step "done"'); end
%!  else error ('"fout" invalid vflag');
%!  end
%!
%! %# Turn off output of warning messages for all tests, turn them on
%! %# again if the last test is called
%!error %# input argument number one
%!  warning ('off', 'OdePkg:InvalidArgument');
%!  B = ode23 (1, [0 25], [3 15 1]);
%!error %# input argument number two
%!  B = ode23 (@fpol, 1, [3 15 1]);
%!error %# input argument number three
%!  B = ode23 (@flor, [0 25], 1);
%!test %# one output argument
%!  vsol = ode23 (@fpol, [0 2], [2 0]);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!  assert (isfield (vsol, 'solver'));
%!  assert (vsol.solver, 'ode23');
%!test %# two output arguments
%!  [vt, vy] = ode23 (@fpol, [0 2], [2 0]);
%!  assert ([vt(end), vy(end,:)], [2, fref], 1e-3);
%!test %# five output arguments and no Events
%!  [vt, vy, vxe, vye, vie] = ode23 (@fpol, [0 2], [2 0]);
%!  assert ([vt(end), vy(end,:)], [2, fref], 1e-3);
%!  assert ([vie, vxe, vye], []);
%!test %# anonymous function instead of real function
%!  fvdb = @(vt,vy) [vy(2); (1 - vy(1)^2) * vy(2) - vy(1)];
%!  vsol = ode23 (fvdb, [0 2], [2 0]);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# extra input arguments passed trhough
%!  vsol = ode23 (@fpol, [0 2], [2 0], 12, 13, 'KL');
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# empty OdePkg structure *but* extra input arguments
%!  vopt = odeset;
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt, 12, 13, 'KL');
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!error %# strange OdePkg structure
%!  vopt = struct ('foo', 1);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!test %# Solve in backward direction starting at t=0
%! %# vref = [-1.2054034414, 0.9514292694];
%!  vsol = ode23 (@fpol, [0 -2], [2 0]);
%! %# assert ([vsol.x(end), vsol.y(end,:)], [-2, fref], 1e-3);
%!test %# Solve in backward direction starting at t=2
%! %#  vref = [-1.2154183302, 0.9433018000];
%!  vsol = ode23 (@fpol, [2 -2], [0.3233166627 -1.8329746843]);
%! %#  assert ([vsol.x(end), vsol.y(end,:)], [-2, fref], 1e-3);
%!test %# AbsTol option
%!  vopt = odeset ('AbsTol', 1e-5);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# AbsTol and RelTol option
%!  vopt = odeset ('AbsTol', 1e-8, 'RelTol', 1e-8);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# RelTol and NormControl option -- higher accuracy
%!  vopt = odeset ('RelTol', 1e-8, 'NormControl', 'on');
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-6);
%!test %# Keeps initial values while integrating
%!  vopt = odeset ('NonNegative', 2);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, 2, 0], 1e-1);
%!test %# Details of OutputSel and Refine can't be tested
%!  vopt = odeset ('OutputFcn', @fout, 'OutputSel', 1, 'Refine', 5);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!test %# Details of OutputSave can't be tested
%!  vopt = odeset ('OutputSave', 1, 'OutputSel', 1);
%!  vsla = ode23 (@fpol, [0 2], [2 0], vopt);
%!  vopt = odeset ('OutputSave', 2);
%!  vslb = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert (length (vsla.x) > length (vslb.x))
%!test %# Stats must add further elements in vsol
%!  vopt = odeset ('Stats', 'on');
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert (isfield (vsol, 'stats'));
%!  assert (isfield (vsol.stats, 'nsteps'));
%!test %# InitialStep option
%!  vopt = odeset ('InitialStep', 1e-8);
%!  vsol = ode23 (@fpol, [0 0.2], [2 0], vopt);
%!  assert ([vsol.x(2)-vsol.x(1)], [1e-8], 1e-9);
%!test %# MaxStep option
%!  vopt = odeset ('MaxStep', 1e-2);
%!  vsol = ode23 (@fpol, [0 0.2], [2 0], vopt);
%!  assert ([vsol.x(5)-vsol.x(4)], [1e-2], 1e-2);
%!test %# Events option add further elements in vsol
%!  vopt = odeset ('Events', @feve);
%!  vsol = ode23 (@fpol, [0 10], [2 0], vopt);
%!  assert (isfield (vsol, 'ie'));
%!  assert (vsol.ie, [2; 1; 2; 1]);
%!  assert (isfield (vsol, 'xe'));
%!  assert (isfield (vsol, 'ye'));
%!test %# Events option, now stop integration
%!  vopt = odeset ('Events', @fevn, 'NormControl', 'on');
%!  vsol = ode23 (@fpol, [0 10], [2 0], vopt);
%!  assert ([vsol.ie, vsol.xe, vsol.ye], ...
%!    [2.0, 2.496110, -0.830550, -2.677589], 1e-3);
%!test %# Events option, five output arguments
%!  vopt = odeset ('Events', @fevn, 'NormControl', 'on');
%!  [vt, vy, vxe, vye, vie] = ode23 (@fpol, [0 10], [2 0], vopt);
%!  assert ([vie, vxe, vye], ...
%!    [2.0, 2.496110, -0.830550, -2.677589], 1e-3);
%!test %# Jacobian option
%!  vopt = odeset ('Jacobian', @fjac);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# Jacobian option and sparse return value
%!  vopt = odeset ('Jacobian', @fjcc);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!
%! %# test for JPattern option is missing
%! %# test for Vectorized option is missing
%!
%!test %# Mass option as function
%!  vopt = odeset ('Mass', @fmas);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# Mass option as matrix
%!  vopt = odeset ('Mass', eye (2,2));
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# Mass option as sparse matrix
%!  vopt = odeset ('Mass', sparse (eye (2,2)));
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# Mass option as function and sparse matrix
%!  vopt = odeset ('Mass', @fmsa);
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!test %# Mass option as function and MStateDependence
%!  vopt = odeset ('Mass', @fmas, 'MStateDependence', 'strong');
%!  vsol = ode23 (@fpol, [0 2], [2 0], vopt);
%!  assert ([vsol.x(end), vsol.y(end,:)], [2, fref], 1e-3);
%!
%! %# test for MvPattern option is missing
%! %# test for InitialSlope option is missing
%! %# test for MaxOrder option is missing
%! %# test for BDF option is missing
%!
%!  warning ('on', 'OdePkg:InvalidArgument');

%# Local Variables: ***
%# mode: octave ***
%# End: ***

