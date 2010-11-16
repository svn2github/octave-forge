## Copyright (C) 2010 Olaf Till <olaf.till@uni-jena.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## Internal function, called by nonlin_residmin --- see there --- and
## others. Calling __nonlin_residmin__ indirectly hides the argument
## "hook", usable by wrappers, from users. Currently, hook can contain
## the field "observations", so that dimensions of observations and
## returned values of unchanged model function can be checked against
## each other exactly one time.

## disabled PKG_ADD: __all_opts__ ("__nonlin_residmin__");

function [p, resid, cvg, outp] = \
      __nonlin_residmin__ (f, pin, settings, hook)

  ## The optimset mechanism is broken in Octave 3.2.4.
  optimget = @ __optimget__;

  ## some scalar defaults; some defaults are backend specific, so
  ## lacking elements in respective constructed vectors will be set to
  ## NA here in the frontend
  diffp_default = .001;
  stol_default = .0001;

  if (nargin == 1 && ischar (f) && strcmp (f, "defaults"))
    p = optimset ("param_config", [], \
		  "param_order", [], \
		  "f_inequc_pstruct", false, \
		  "f_equc_pstruct", false, \
		  "f_pstruct", false, \
		  "df_inequc_pstruct", false, \
		  "df_equc_pstruct", false, \
		  "dfdp_pstruct", false, \
		  "bounds", [], \
		  "dfdp", [], \
		  "cpiv", @ cpiv_bard, \
		  "max_fract_change", [], \
		  "fract_prec", [], \
		  "diffp", [], \
		  "diff_onesided", [], \
		  "fixed", [], \
		  "inequc", [], \
		  "equc", [], \
		  "weights", [], \
		  "TolFun", stol_default, \
		  "MaxIter", [], \
		  "Display", "off", \
		  "Algorithm", "lm_svd_feasible", \
		  "plot_cmd", @ (f) 0);
    return;
  endif

  assign = @ assign; # Is this faster in repeated calls?

  if (nargin != 4)
    error ("incorrect number of arguments");
  endif

  if (ischar (f))
    f = str2func (f);
  endif

  if (! (pin_struct = isstruct (pin)))
    if (! isvector (pin) || columns (pin) > 1)
      error ("initial parameters must be either a structure or a column vector");
    endif
  endif

  #### processing of settings and consistency checks

  pconf = optimget (settings, "param_config");
  pord = optimget (settings, "param_order");
  f_inequc_pstruct = optimget (settings, "f_inequc_pstruct", false);
  f_equc_pstruct = optimget (settings, "f_equc_pstruct", false);
  f_pstruct = optimget (settings, "f_pstruct", false);
  dfdp_pstruct = optimget (settings, "dfdp_pstruct", f_pstruct);
  df_inequc_pstruct = optimget (settings, "df_inequc_pstruct", \
				f_inequc_pstruct);
  df_equc_pstruct = optimget (settings, "df_equc_pstruct", \
			      f_equc_pstruct);
  bounds = optimget (settings, "bounds");
  dfdp = optimget (settings, "dfdp");
  if (ischar (dfdp)) dfdp = str2func (dfdp); endif
  max_fract_change = optimget (settings, "max_fract_change");
  fract_prec = optimget (settings, "fract_prec");
  diffp = optimget (settings, "diffp");
  diff_onesided = optimget (settings, "diff_onesided");
  fixed = optimget (settings, "fixed");

  ## collect constraints
  [mc, vc, f_genicstr, df_gencstr, user_df_gencstr] = \
      __collect_constraints__ (optimget (settings, "inequc"));
  [emc, evc, f_genecstr, df_genecstr, user_df_genecstr] = \
      __collect_constraints__ (optimget (settings, "equc"));
  mc_struct = isstruct (mc);
  emc_struct = isstruct (emc);

  ## correct "_pstruct" settings if functions are not supplied
  if (isempty (dfdp)) dfdp_pstruct = false; endif
  if (isempty (f_genicstr)) f_inequc_pstruct = false; endif
  if (isempty (f_genecstr)) f_equc_pstruct = false; endif
  if (! user_df_gencstr) df_inequc_pstruct = false; endif
  if (! user_df_genecstr) df_equc_pstruct = false; endif

  ## some settings require a parameter order
  if (isempty (pord))
    if ((pin_struct || ! isempty (pconf) || f_inequc_pstruct || \
	 f_equc_pstruct || f_pstruct || dfdp_pstruct || \
	 df_inequc_pstruct || df_equc_pstruct || mc_struct || \
	 emc_struct))
      error ("given settings require specification of parameter order");
    endif
  else
    pord = pord(:);
    if (rows (unique (pord)) < rows (pord))
      error ("duplicate parameter names in 'param_order'");
    endif
  endif

  if (! pin_struct)
    np = length (pin);
  else
    np = length (pord);
  endif

  plabels = num2cell ((1:np).');
  if (! isempty (pord))
    plabels = cat (2, plabels, pord);
  endif

  ## some useful vectors
  zerosvec = zeros (np, 1);
  NAvec = NA (np, 1);
  falsevec = false (np, 1);
  sizevec = [np, 1];

  ## collect parameter-related configuration
  if (! isempty (pconf))
    ## use supplied configuration structure

    ## parameter-related configuration is either allowed by a structure
    ## or by vectors
    if (! (isempty (bounds) && isempty (max_fract_change) && \
	 isempty (fract_prec) && isempty (diffp) && \
	 isempty (diff_onesided) && isempty (fixed)))
      error ("if param_config is given, its potential items must not be configured in another way");
    endif

    if (! all (arefields (pconf, pord)))
      error ("param_config does not contain fields for all parameters");
    endif

    pconf = structcat (1, fields2cell (pconf, pord){:});

    bounds = zeros (np, 2);
    bounds(:, 1) = -Inf;
    bounds(:, 2) = Inf;
    if (isfield (pconf, "bounds"))
      bounds(! fieldempty (pconf, "bounds"), :) = cat (1, pconf.bounds);
    endif

    max_fract_change = fract_prec = NAvec;

    if (isfield (pconf, "max_fract_change"))
      max_fract_change(! fieldempty (pconf, "max_fract_change")) = \
	  [pconf.max_fract_change];
    endif

    if (isfield (pconf, "fract_prec"))
      fract_prec(! fieldempty (pconf, "fract_prec")) = \
	  [pconf.fract_prec];
    endif

    diffp = zerosvec;
    diffp(:) = diffp_default;
    if (isfield (pconf, "diffp"))
      diffp(! fieldempty (pconf, "diffp")) = [pconf.diffp];
    endif

    diff_onesided = fixed = falsevec;

    if (isfield (pconf, "diff_onesided"))
      diff_onesided(! fieldempty (pconf, "diff_onesided")) = \
	  logical ([pconf.diff_onesided]);
    endif

    if (isfield (pconf, "fixed"))
      fixed(! fieldempty (pconf, "fixed")) = logical ([pconf.fixed]);
    endif
  else
    ## use supplied configuration vectors

    if (isempty (bounds))
      bounds = zeros (np, 2);
      bounds(:, 1) = -Inf;
      bounds(:, 2) = Inf;
    elseif (any (size (bounds) != [np, 2]))
      error ("bounds: wrong dimensions");
    endif

    if (isempty (max_fract_change))
      max_fract_change = NAvec;
    elseif (any (size (max_fract_change) != sizevec))
      error ("max_fract_change: wrong dimensions");
    endif

    if (isempty (fract_prec))
      fract_prec = NAvec;
    elseif (any (size (fract_prec) != sizevec))
      error ("fract_prec: wrong dimensions");
    endif

    if (isempty (diffp))
      diffp = zerosvec;
      diffp(:) = diffp_default;
    else
      if (any (size (diffp) != sizevec))
	error ("diffp: wrong dimensions");
      endif
      diffp(isna (diffp)) = diffp_default;
    endif

    if (isempty (diff_onesided))
      diff_onesided = falsevec;
    else
      if (any (size (diff_onesided) != sizevec))
	error ("diff_onesided: wrong dimensions")
      endif
      diff_onesided(isna (diff_onesided)) = false;
      diff_onesided = logical (diff_onesided);
    endif

    if (isempty (fixed))
      fixed = falsevec;
    else
      if (any (size (fixed) != sizevec))
	error ("fixed: wrong dimensions");
      endif
      fixed(isna (fixed)) = false;
      fixed = logical (fixed);
    endif
  endif

  ## guaranty all (bounds(:, 1) <= bounds(:, 2))
  tp = bounds((idx = bounds(:, 1) > bounds(:, 2)), 2);
  bounds(idx, 2) = bounds(idx, 1);
  bounds(idx, 1) = tp;

  #### consider whether initial parameters and functions are based on
  #### parameter structures or parameter vectors; wrappers for call to
  #### default function for jacobians

  ## initial parameters
  if (pin_struct)
    if (! all (arefields (pin, pord)))
      error ("some initial parameters lacking");
    endif
    pin = cat (1, fields2cell (pin, pord){:});
  endif

  ## model function
  if (f_pstruct)
    f = @ (p, varargin) \
	f (cell2struct (num2cell (p), pord, 1), varargin{:});
  endif
  f_pin = f (pin);
  if (isfield (hook, "observations"))
    if (any (size (f_pin) != size (obs = hook.observations)))
      error ("dimensions of observations and values of model function must match");
    endif
    f = @ (p) f (p) - obs;
    f_pin -= obs;
  endif

  ## jacobian of model function
  if (isempty (dfdp))
    dfdp = @ (p, hook) __dfdp__ (p, f, hook);
  endif
  if (dfdp_pstruct)
    dfdp = @ (p, hook) \
	cat (2, \
	     fields2cell \
	     (dfdp (cell2struct (num2cell (p), pord, 1), hook), \
	      pord){:});
  endif

  ## function for general inequality constraints
  if (f_inequc_pstruct)
    f_genicstr = @ (p, varargin) \
	f_genicstr \
	(cell2struct (num2cell (p), pord, 1), varargin{:});
  endif

  ## note this stage
  possibly_pstruct_f_genicstr = f_genicstr;

  ## jacobian of general inequality constraints
  if (df_inequc_pstruct)
    df_gencstr = @ (p, func, idx, hook) \
	cat (2, \
	     fields2cell \
	     (df_gencstr (cell2struct (num2cell (p), pord, 1), \
			  func, idx, hook), \
	      pord){:});
  endif

  ## function for general equality constraints
  if (f_equc_pstruct)
    f_genecstr = @ (p, varargin) \
	f_genecstr \
	(cell2struct (num2cell (p), pord, 1), varargin{:});
  endif

  ## note this stage
  possibly_pstruct_f_genecstr = f_genecstr;

  ## jacobian of general equality constraints
  if (df_equc_pstruct)
    df_genecstr = @ (p, func, idx, hook) \
	cat (2, \
	     fields2cell \
	     (df_genecstr (cell2struct (num2cell (p), pord, 1), \
			   func, idx, hook), \
	      pord){:});
  endif

  ## linear inequality constraints
  if (mc_struct)
    idx = arefields (mc, pord);
    if (rows (fieldnames (mc)) > sum (idx))
      error ("unknown fields in structure of linear inequality constraints");
    endif
    smc = mc;
    mc = zeros (np, rows (vc));
    mc(idx, :) = cat (1, fields2cell (smc, pord(idx)){:});
  endif

  ## linear equality constraints
  if (emc_struct)
    idx = arefields (emc, pord);
    if (rows (fieldnames (emc)) > sum (idx))
      error ("unknown fields in structure of linear equality constraints");
    endif
    semc = emc;
    emc = zeros (np, rowd (evc));
    emc(idx, :) = cat (1, fields2cell (semc, pord(idx)){:});
  endif

  ## parameter-related configuration for jacobi functions
  if (dfdp_pstruct || df_inequc_pstruct || df_equc_pstruct)
    s_diffp = cell2struct (num2cell (diffp), pord, 1);
    s_diff_onesided = cell2struct (num2cell (diff_onesided), pord, 1);
    s_orig_bounds = cell2struct (num2cell (bounds, 2), pord, 1);
    s_plabels = cell2struct (cell2cell (plabels, 1), pord, 1);
    s_orig_fixed = cell2struct (num2cell (fixed), pord, 1);
  endif

  #### some further values and checks

  if (any (fixed & (pin < bounds(:, 1) | pin > bounds(:, 2))))
    warning ("some fixed parameters outside bounds");
  endif

  ## dimensions of linear constraints
  if (isempty (mc))
    mc = zeros (np, 0);
    vc = zeros (0, 1);
  endif
  if (isempty (emc))
    emc = zeros (np, 0);
    evc = zeros (0, 1);
  endif
  [rm, cm] = size (mc);
  [rv, cv] = size (vc);
  if (rm != np || cm != rv || cv != 1)
    error ("linear inequality constraints: wrong dimensions");
  endif
  [erm, ecm] = size (emc);
  [erv, ecv] = size (evc);
  if (erm != np || ecm != erv || ecv != 1)
    error ("linear equality constraints: wrong dimensions");
  endif

  ## check weights dimensions
  weights = optimget (settings, "weights", ones (size (f_pin)));
  if (any (size (weights) != size (f_pin)))
    error ("dimension of weights and residuals must match");
  endif

  ## note initial values of linear constraits
  pin_cstr.inequ.lin_except_bounds = mc.' * pin + vc;
  pin_cstr.equ.lin = emc.' * pin + evc;

  ## note number and initial values of general constraints
  if (isempty (f_genicstr))
    pin_cstr.inequ.gen = [];
    n_genicstr = 0;
  else
    n_genicstr = length (pin_cstr.inequ.gen = f_genicstr (pin));
  endif
  if (isempty (f_genecstr))
    pin_cstr.equ.gen = [];
    n_genecstr = 0;
  else
    n_genecstr = length (pin_cstr.equ.gen = f_genecstr (pin));
  endif

  #### collect remaining settings
  hook.TolFun = optimget (settings, "TolFun", stol_default);
  hook.MaxIter = optimget (settings, "MaxIter");
  if (ischar (hook.cpiv = optimget (settings, "cpiv", @ cpiv_bard)))
    hook.cpiv = str2func (hook.cpiv);
  endif
  hook.Display = optimget (settings, "Display", "off");
  hook.plot_cmd = optimget (settings, "plot_cmd", @ (f) 0);
  backend = optimget (settings, "Algorithm", "lm_svd_feasible");
  backend = map_matlab_algorithm_names (backend);
  backend = map_backend (backend);

  #### handle fixing of parameters
  orig_bounds = bounds;
  orig_fixed = fixed;
  if (all (fixed))
    error ("no free parameters");
  endif

  nonfixed = ! fixed;
  if (any (fixed))
    ## backend (returned values and initial parameters)
    backend = @ (f, pin, hook) \
	backend_wrapper (backend, fixed, f, pin, hook);

    ## model function
    f = @ (p, varargin) f (assign (pin, nonfixed, p), varargin{:});

    ## jacobian of model function
    dfdp = @ (p, hook) \
	dfdp (assign (pin, nonfixed, p), hook)(:, nonfixed);
    
    ## function for general inequality constraints
    f_genicstr = @ (p, varargin) \
	f_genicstr (assign (pin, nonfixed, p), varargin{:});
    
    ## jacobian of general inequality constraints
    df_gencstr = @ (p, func, idx, hook) \
	df_gencstr (assign (pin, nonfixed, p), func, idx, hook) \
	(:, nonfixed);

    ## function for general equality constraints
    f_genecstr = @ (p, varargin) \
	f_genecstr (assign (pin, nonfixed, p), varargin{:});

    ## jacobian of general equality constraints
    df_genecstr = @ (p, func, idx, hook) \
	df_genecstr (assign (pin, nonfixed, p), func, idx, hook) \
	(:, nonfixed);

    ## linear inequality constraints
    vc += mc(fixed, :).' * (tp = pin(fixed));
    mc = mc(nonfixed, :);

    ## linear equality constraints
    evc += emc(fixed, :).' * tp;
    emc = emc(nonfixed, :);

    ## _last_ of all, vectors of parameter-related configuration,
    ## including "fixed" itself
    bounds = bounds(nonfixed, :);
    max_fract_change = max_fract_change(nonfixed);
    fract_prec = fract_prec(nonfixed);
    fixed = fixed(nonfixed);
  endif

  #### supplement constants to jacobian functions

  ## jacobian of model function
  if (dfdp_pstruct)
    dfdp = @ (p, hook) \
	dfdp (p, cell2fields \
	      ({s_diffp, s_diff_onesided, s_orig_bounds, s_plabels, \
		cell2fields(num2cell(hook.fixed), pord(nonfixed), \
			    1, s_orig_fixed)}, \
	       {"diffp", "diff_onesided", "bounds", "plabels", \
		"fixed"}, \
	       2, hook));
  else
    dfdp = @ (p, hook) \
	dfdp (p, cell2fields \
	      ({diffp, diff_onesided, orig_bounds, plabels, \
		assign(orig_fixed, nonfixed, hook.fixed)}, \
	       {"diffp", "diff_onesided", "bounds", "plabels", \
		"fixed"}, \
	       2, hook));
  endif

  ## jacobian of general inequality constraints
  if (df_inequc_pstruct)
    df_gencstr = @ (p, func, idx, hook) \
	df_gencstr (p, func, idx, cell2fields \
		    ({s_diffp, s_diff_onesided, s_orig_bounds, s_plabels, \
		      cell2fields(num2cell(hook.fixed), pord(nonfixed), \
				  1, s_orig_fixed)}, \
		     {"diffp", "diff_onesided", "bounds", "plabels", \
		      "fixed"}, \
		     2, hook));
  else
    df_gencstr = @ (p, func, idx, hook) \
	df_gencstr (p, func, idx, cell2fields \
		    ({diffp, diff_onesided, orig_bounds, plabels, \
		      assign(orig_fixed, nonfixed, hook.fixed)}, \
		     {"diffp", "diff_onesided", "bounds", "plabels", \
		      "fixed"}, \
		     2, hook));
  endif

  ## jacobian of general equality constraints
  if (df_equc_pstruct)
    df_genecstr = @ (p, func, idx, hook) \
	df_genecstr (p, func, idx, cell2fields \
		     ({s_diffp, s_diff_onesided, s_orig_bounds, s_plabels, \
		       cell2fields(num2cell(hook.fixed), pord(nonfixed), \
				   1, s_orig_fixed)}, \
		      {"diffp", "diff_onesided", "bounds", "plabels", \
		       "fixed"}, \
		      2, hook));
  else
    df_genecstr = @ (p, func, idx, hook) \
	df_genecstr (p, func, idx, cell2fields \
		     ({diffp, diff_onesided, orig_bounds, plabels, \
		       assign(orig_fixed, nonfixed, hook.fixed)}, \
		      {"diffp", "diff_onesided", "bounds", "plabels", \
		       "fixed"}, \
		      2, hook));
  endif

  #### interfaces to constraints
  
  ## include bounds into linear inequality constraints
  tp = eye (sum (nonfixed));
  lidx = ! isinf (bounds(:, 1));
  uidx = ! isinf (bounds(:, 2));
  mc = cat (2, mc, tp(:, lidx), - tp(:, uidx));
  vc = cat (1, vc, - bounds(lidx, 1), bounds(uidx, 2));

  ## concatenate linear inequality and equality constraints
  mc = cat (2, mc, emc);
  vc = cat (1, vc, evc);
  n_lincstr = rows (vc);

  ## concatenate general inequality and equality constraints
  if (n_genecstr > 0)
    if (n_genicstr > 0)
      nidxi = 1 : n_genicstr;
      nidxe = n_genicstr + 1 : n_genicstr + n_genecstr;
      f_gencstr = @ (p, idx, varargin) \
	  cat (1, \
	       f_genicstr (p, idx(nidxi), varargin{:}), \
	       f_genecstr (p, idx(nidxe), varargin{:}));
      df_gencstr = @ (p, idx, hook) \
	  cat (1, \
	       df_gencstr (p, @ (p, varargin) \
			   possibly_pstruct_f_genicstr \
			   (p, idx(nidxi), varargin{:}), \
			   idx(nidxi), \
			   setfield (hook, "f", \
				     hook.f(nidxi(idx(nidxi))))), \
	       df_genecstr (p, @ (p, varargin) \
			    possibly_pstruct_f_genecstr \
			    (p, idx(nidxe), varargin{:}), \
			    idx(nidxe), \
			    setfield (hook, "f", \
				      hook.f(nidxe(idx(nidxe))))));
    else
      f_gencstr = f_genecstr;
      df_gencstr = @ (p, idx, hook) \
	  df_genecstr (p, \
		       @ (p, varargin) \
		       possibly_pstruct_f_genecstr \
		       (p, idx, varargin{:}), \
		       idx, \
		       setfield (hook, "f", hook.f(idx)));
    endif
  else
    f_gencstr = f_genicstr;
    df_gencstr = @ (p, idx, hook) \
	df_gencstr (p, \
		    @ (p, varargin) \
		    possibly_pstruct_f_genicstr (p, idx, varargin{:}), \
		    idx, \
		    setfield (hook, "f", hook.f(idx)));
  endif    
  n_gencstr = n_genicstr + n_genecstr;

  ## concatenate linear and general constraints, defining the final
  ## function interfaces
  if (n_gencstr > 0)
    nidxl = 1:n_lincstr;
    nidxh = n_lincstr + 1 : n_lincstr + n_gencstr;
    f_cstr = @ (p, idx, varargin) \
	cat (1, \
	     mc(:, idx(nidxl)).' * p + vc(idx(nidxl), 1), \
	     f_gencstr (p, idx(nidxh), varargin{:}));
    df_cstr = @ (p, idx, hook) \
	cat (1, \
	     mc(:, idx(nidxl)).', \
	     df_gencstr (p, idx(nidxh), \
			 setfield (hook, "f", \
				   hook.f(nidxh))));
  else
    f_cstr = @ (p, idx, varargin) mc(:, idx).' * p + vc(idx, 1);
    df_cstr = @ (p, idx, hook) mc(:, idx).';
  endif

  ## define eq_idx (logical index of equality constraints within all
  ## concatenated constraints
  eq_idx = false (n_lincstr + n_gencstr, 1);
  eq_idx(n_lincstr + 1 - rows (evc) : n_lincstr) = true;
  n_cstr = n_lincstr + n_gencstr;
  eq_idx(n_cstr + 1 - n_genecstr : n_cstr) = true;

  #### prepare interface hook

  ## passed constraints
  hook.mc = mc;
  hook.vc = vc;
  hook.f_cstr = f_cstr;
  hook.df_cstr = df_cstr;
  hook.n_gencstr = n_gencstr;
  hook.eq_idx = eq_idx;
  hook.bounds = bounds;

  ## passed values of constraints for initial parameters
  hook.pin_cstr = pin_cstr;

  ## passed function for derivative of model function
  hook.dfdp = dfdp;

  ## passed function for complementary pivoting
  ## hook.cpiv = cpiv; # set before

  ## passed value of residual function for initial parameters
  hook.f_pin = f_pin;

  ## passed options
  hook.max_fract_change = max_fract_change;
  hook.fract_prec = fract_prec;
  ## hook.TolFun = ; # set before
  ## hook.MaxIter = ; # set before
  hook.weights = weights;
  hook.fixed = fixed;

  #### call backend

  [p, resid, cvg, outp] = backend (f, pin, hook);

  if (pin_struct)
    p = cell2struct (num2cell (p), pord, 1);
  endif

endfunction

function backend = map_matlab_algorithm_names (backend)

  switch (backend)
    case "levenberg-marquardt"
      backend = "lm_svd_feasible";
      warning ("algorithm 'levenberg-marquardt' mapped to 'lm_svd_feasible'");
  endswitch

endfunction

function backend = map_backend (backend)

  switch (backend)
    case "lm_svd_feasible"
      backend = "__lm_svd__";
    otherwise
      error ("no backend implemented for algorithm '%s'", backend);
  endswitch

  backend = str2func (backend);

endfunction

function [p, resid, cvg, outp] = backend_wrapper (backend, fixed, f, p, hook)

  [tp, resid, cvg, outp] = backend (f, p(! fixed), hook);

  p(! fixed) = tp;

endfunction

function lval = assign (lval, lidx, rval)

  lval(lidx) = rval;

endfunction

function ret = __optimget__ (s, name, default)

  if (isfield (s, name))
    ret = s.(name);
  elseif (nargin > 2)
    ret = default;
  else
    ret = [];
  endif

endfunction
