%% Copyright (C) 1992-1994 Richard Shrager
%% Copyright (C) 1992-1994 Arthur Jutan
%% Copyright (C) 1992-1994 Ray Muzic
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.

function [f,p,cvg,iter,corp,covp,covr,stdresid,Z,r2]= ...
      leasqr(x,y,pin,F,stol,niter,wt,dp,dFdp,options)

  %%function [f,p,cvg,iter,corp,covp,covr,stdresid,Z,r2]=
  %%                   leasqr(x,y,pin,F,{stol,niter,wt,dp,dFdp,options})
  %%
  %% Levenberg-Marquardt nonlinear regression of f(x,p) to y(x).
  %%
  %% Version 3.beta
  %% Optional parameters are in braces {}.
  %% x = vector or matrix of independent variables, 1 entry or row per
  %%   observation.
  %% y = vector of observed values, same length as x or as number of
  %%   rows of x.
  %% wt = vector (dim=length(y)) of statistical weights.  These should
  %%   be set to be proportional to (sqrt of var(y))^-1; (That is, the
  %%   covariance matrix of the data is assumed to be proportional to
  %%   diagonal with diagonal equal to (wt.^2)^-1.  The constant of
  %%   proportionality will be estimated.); default = ones(length(y),1).
  %% pin = vec of initial parameters to be adjusted by leasqr.
  %% dp = fractional increment of p for numerical partial derivatives;
  %%   default = .001*ones(size(pin))
  %%   dp(j) > 0 means central differences on j-th parameter p(j).
  %%   dp(j) < 0 means one-sided differences on j-th parameter p(j).
  %%   dp(j) = 0 holds p(j) fixed i.e. leasqr wont change initial guess: pin(j)
  %% F = name of function in quotes or function handle; the function
  %%   shall be of the form y=f(x,p), with y, x, p of the form y, x, pin
  %%   as described above; the returned y must be a column vector.
  %% dFdp = name of partial derivative function in quotes; default is 'dfdp', a
  %%   slow but general partial derivatives function; the function shall be
  %%   of the form prt=dfdp(x,f,p,dp,F[,bounds]). For backwards
  %%   compatibility, the function will only be called with an extra
  %%   'bounds' argument if the 'bounds' option is explicitely specified
  %%   to leasqr (see dfdp.m).
  %% stol = scalar tolerance on fractional improvement in scalar sum of
  %%   squares = sum((wt.*(y-f))^2); default stol = .0001;
  %% niter = scalar maximum number of iterations; default = 20;
  %% options = structure, currently recognized fields are 'fract_prec',
  %%   'max_fract_change', and 'bounds'. For backwards compatibility,
  %%   'options' can also be a matrix whose first and second column
  %%   contains the values of 'fract_prec' and 'max_fract_change',
  %%   respectively.
  %%   Field 'options.fract_prec': column vector (same length as 'pin') of
  %%   desired fractional precisions in parameter estimates. Iterations
  %%   are terminated if change in parameter vector (chg) on two
  %%   consecutive iterations is less than their corresponding elements in
  %%   'options.fract_prec'.  [ie. all(abs(chg*current parm est) <
  %%   options.fract_prec) on two consecutive iterations.], default =
  %%   zeros().
  %%   Field 'options.max_fract_change': column vector (same length as
  %%   'pin) of maximum fractional step changes in parameter vector.
  %%   Fractional change in elements of parameter vector is constrained to
  %%   be at most 'options.max_fract_change' between sucessive iterations.
  %%   [ie. abs(chg(i))=abs(min([chg(i)
  %%   options.max_fract_change(i)*current param estimate])).], default =
  %%   Inf*ones().
  %%   Field 'options.bounds': two-column-matrix, one row for each
  %%   parameter in 'pin'. Each row contains a minimal and maximal value
  %%   for each parameter. Default: [-Inf, Inf] in each row. If this
  %%   field is used with an existing user-side function for 'dFdp'
  %%   (see above) the functions interface might have to be changed.
  %%   _Warning_: If bounds are set, returned guesses of corp, covp, and
  %%   Z are generally invalid, even if final parameters are not at the
  %%   bounds.
  %%
  %%          OUTPUT VARIABLES
  %% f = column vector of values computed: f = F(x,p).
  %% p = column vector trial or final parameters. i.e, the solution.
  %% cvg = scalar: = 1 if convergence, = 0 otherwise.
  %% iter = scalar number of iterations used.
  %% corp = correlation matrix for parameters.
  %% covp = covariance matrix of the parameters.
  %% covr = diag(covariance matrix of the residuals).
  %% stdresid = standardized residuals.
  %% Z = matrix that defines confidence region (see comments in the source).
  %% r2 = coefficient of multiple determination, intercept form.
  %%
  %% All Zero guesses not acceptable. Not suitable for non-real residuals.

  %% The following two blocks of comments are chiefly from the original
  %% version for Matlab. For later changes the logs of the Octave Forge
  %% svn repository should also be consulted.

  %% A modified version of Levenberg-Marquardt
  %% Non-Linear Regression program previously submitted by R.Schrager.
  %% This version corrects an error in that version and also provides
  %% an easier to use version with automatic numerical calculation of
  %% the Jacobian Matrix. In addition, this version calculates statistics
  %% such as correlation, etc....
  %%
  %% Version 3 Notes
  %% Errors in the original version submitted by Shrager (now called
  %% version 1) and the improved version of Jutan (now called version 2)
  %% have been corrected.
  %% Additional features, statistical tests, and documentation have also been
  %% included along with an example of usage.  BEWARE: Some the the input and
  %% output arguments were changed from the previous version.
  %%
  %%     Ray Muzic     <rfm2@ds2.uh.cwru.edu>
  %%     Arthur Jutan  <jutan@charon.engga.uwo.ca>

  %% Richard I. Shrager (301)-496-1122
  %% Modified by A.Jutan (519)-679-2111
  %% Modified by Ray Muzic 14-Jul-1992
  %%       1) add maxstep feature for limiting changes in parameter estimates
  %%          at each step.
  %%       2) remove forced columnization of x (x=x(:)) at beginning. x
  %%          could be a matrix with the ith row of containing values of
  %%          the independent variables at the ith observation.
  %%       3) add verbose option
  %%       4) add optional return arguments covp, stdresid, chi2
  %%       5) revise estimates of corp, stdev
  %% Modified by Ray Muzic 11-Oct-1992
  %%	1) revise estimate of Vy.  remove chi2, add Z as return values
  %%       (later remark: the current code contains no variable Vy)
  %% Modified by Ray Muzic 7-Jan-1994
  %%       1) Replace ones(x) with a construct that is compatible with versions
  %%          newer and older than v 4.1.
  %%       2) Added global declaration of verbose (needed for newer than v4.x)
  %%       3) Replace return value var, the variance of the residuals
  %%          with covr, the covariance matrix of the residuals.
  %%       4) Introduce options as 10th input argument.  Include
  %%          convergence criteria and maxstep in it.
  %%       5) Correct calculation of xtx which affects coveraince estimate.
  %%       6) Eliminate stdev (estimate of standard deviation of
  %%          parameter estimates) from the return values.  The covp is a
  %%          much more meaningful expression of precision because it
  %%          specifies a confidence region in contrast to a confidence
  %%          interval.. If needed, however, stdev may be calculated as
  %%          stdev=sqrt(diag(covp)).
  %%       7) Change the order of the return values to a more logical order.
  %%       8) Change to more efficent algorithm of Bard for selecting epsL.
  %%       9) Tighten up memory usage by making use of sparse matrices (if 
  %%          MATLAB version >= 4.0) in computation of covp, corp, stdresid.
  %% Modified by Francesco Potort�
  %%       for use in Octave
  %% Added bounds feature to this file and to dfdp.m, Olaf Till 4-Aug-2009
  %%
  %% References:
  %% Bard, Nonlinear Parameter Estimation, Academic Press, 1974.
  %% Draper and Smith, Applied Regression Analysis, John Wiley and Sons, 1981.

  %% argument processing
  %%

  %%if (sscanf(version,'%f') >= 4),
  vernum= sscanf(version,'%f');
  if (vernum(1) >= 4)
    global verbose
    plotcmd='plot(x(:,1),y,''+'',x(:,1),f); figure(gcf)';
  else
    plotcmd='plot(x(:,1),y,''+'',x(:,1),f); shg';
  end
  if (exist('OCTAVE_VERSION'))
    global verbose
    plotcmd='plot(x(:,1),y,''+;data;'',x(:,1),f,'';fit;'');';
  end

  if(exist('verbose')~=1) %If verbose undefined, print nothing
    verbose=0;       %This will not tell them the results
  end

  if (nargin <= 8) dFdp='dfdp'; end
  if (nargin <= 7) dp=.001*(pin*0+1); end %DT
  if (nargin <= 6) wt=ones(length(y),1); end	% SMB modification
  if (nargin <= 5) niter=20; end
  if (nargin == 4) stol=.0001; end
  %%

  y=y(:); wt=wt(:); pin=pin(:); dp=dp(:); %change all vectors to columns
  if (isvector (x)) x = x(:); end
  %% check data vectors- same length?
  m=length(y); n=length(pin);
  if (size (x, 1) ~= m) 
    error('input(x)/output(y) data must have same length ')
  end

  %% processing of 'options'
  pprec = zeros (n, 1);
  maxstep = Inf * ones (n, 1);
  bounds = cat (2, -Inf * ones (n, 1), Inf * ones (n, 1));
  dfdp_cmd = 'feval(dFdp,x,fbest,pprev,dp,F);'; % will possibly be redefined
  if (nargin > 9)
    if (ismatrix (options)) % backwards compatibility
      tp = options;
      options = struct ('fract_prec', tp(:, 1));
      if (columns (tp) > 1)
	options.max_fract_change = tp(:, 2);
      end
    end
    if (isfield (options, 'fract_prec'))
      pprec = options.fract_prec;
      if (rows (pprec) ~= n || columns (pprec) ~= 1)
	error ('fractional precisions: wrong dimensions');
      end
    end
    if (isfield (options, 'max_fract_change'))
      maxstep = options.max_fract_change;
      if (rows (maxstep) ~= n || columns (maxstep) ~= 1)
	error ('maximum fractional step changes: wrong dimensions');
      end
    end
    if (isfield (options, 'bounds'))
      dfdp_cmd = 'feval(dFdp,x,fbest,pprev,dp,F,bounds);';
      bounds = options.bounds;
      if (rows (bounds) ~= n || columns (bounds) ~= 2)
	error ('bounds: wrong dimensions');
      end
      idx = bounds(:, 1) > bounds(:, 2);
      tp = bounds(idx, 2);
      bounds(idx, 2) = bounds(idx, 1);
      bounds(idx, 1) = tp;
      idx = bounds(:, 1) == bounds(:, 2);
      if (any (idx))
	warning ('lower and upper bounds identical for some parameters, setting the respective elements of dp to zero');
	dp(idx) = 0;
      end
      idx = pin < bounds(:, 1);
      if (any (idx))
	warning ('some initial parameters set to lower bound');
	pin(idx) = bounds(idx, 1);
      end
      idx = pin > bounds(:, 2);
      if (any (idx))
	warning ('some initial parameters set to upper bound');
	pin(idx) = bounds(idx, 2);
      end
    end
  end

  if (all (dp == 0))
    error ('no free parameters');
  end

  %% set up for iterations
  %%
  p = pin;
  f=feval(F,x,p); fbest=f; pbest=p;
  r=wt.*(y-f);
  if (~isreal (r)) error ('weighted residuals are not real'); end
  ss = r.' * r;
  sbest=ss;
  chgprev=Inf*ones(n,1);
  cvg=0;
  epsLlast=1;
  epstab=[.1, 1, 1e2, 1e4, 1e6];

  %% do iterations
  %%
  for iter=1:niter
    nrm = zeros (1, n);
    pprev=pbest;
    prt = eval (dfdp_cmd);
    r=wt.*(y-fbest);
    if (~isreal (r)) error ('weighted residuals are not real'); end
    sprev=sbest;
    sgoal=(1-stol)*sprev;
    msk = dp ~= 0;
    prt(:, msk) = prt(:, msk) .* wt(:, ones (1, sum (msk)));
    nrm(msk) = sumsq (prt(:, msk), 1);
    msk = nrm > 0;
    nrm(msk) = 1 ./ sqrt (nrm(msk));
    prt = prt .* nrm(ones (1, m), :);
    nrm = nrm.';
    [prt,s,v]=svd(prt,0);
    s=diag(s);
    g = prt.' * r;
    for jjj=1:length(epstab),
      epsL = max(epsLlast*epstab(jjj),1e-7);
      se=sqrt((s.*s)+epsL);
      gse=g./se;
      chg=((v*gse).*nrm);
      %% check the change constraints and apply as necessary
      ochg=chg;
      idx = ~isinf(maxstep);
      limit = abs(maxstep(idx).*pprev(idx));
      chg(idx) = min(max(chg(idx),-limit),limit);
      if (verbose && any(ochg ~= chg))
	disp(['Change in parameter(s): ', ...
              sprintf('%d ',find(ochg ~= chg)), 'were constrained']);
      end
      aprec=abs(pprec.*pbest);       %---
      %% ss=scalar sum of squares=sum((wt.*(y-f))^2).
      if (any(abs(chg) > 0.1*aprec))%---  % only worth evaluating function if
	p=chg+pprev;                       % there is some non-miniscule change
	%% apply bounds; preserving the direction of the attempted step
	%% might lead to fixing _all_ parameters at their current value,
	%% so decided not to do that and to simply reset parameters to
	%% bounds
	lidx = p < bounds(:, 1);
	p(lidx) = bounds(lidx, 1);
	uidx = p > bounds(:, 2);
	p(uidx) = bounds(uidx, 2);
	idx = lidx | uidx;
	if (verbose && any (idx))
	  tp = find (idx);
	  fprintf ('bounds apply for parameters number %s %i\n', \
		   sprintf ('%i, ', tp(1:end - 1)), tp(end));
	end
	%%
	f=feval(F,x,p);
	r=wt.*(y-f);
	if (~isreal (r)) error ('weighted residuals are not real'); end
	ss = r.' * r;
	if (ss<sbest)
          pbest=p;
          fbest=f;
          sbest=ss;
	end
	if (ss<=sgoal)
          break;
	end
      end                          %---
    end
    epsLlast = epsL;
    if (verbose)
      eval(plotcmd);
    end
    if (ss<eps)
      break;
    end
    aprec=abs(pprec.*pbest);
    %% [aprec, chg, chgprev]
    if (all(abs(chg) < aprec) && all(abs(chgprev) < aprec))
      cvg=1;
      if (verbose)
	fprintf('Parameter changes converged to specified precision\n');
      end
      break;
    else
      chgprev=chg;
    end
    if (ss>sgoal)
      break;
    end
  end

  %% set return values
  %%
  p=pbest;
  f=fbest;
  ss=sbest;
  cvg=((sbest>sgoal)|(sbest<=eps)|cvg);
  if (cvg ~= 1) disp(' CONVERGENCE NOT ACHIEVED! '); end

  if (~(verbose || nargout > 4)) return; end

  %% CALC VARIANCE COV MATRIX AND CORRELATION MATRIX OF PARAMETERS
  %% re-evaluate the Jacobian at optimal values
  jac = eval (dfdp_cmd);
  msk = dp ~= 0;
  n = sum(msk);           % reduce n to equal number of estimated parameters
  jac = jac(:, msk);	% use only fitted parameters

  %% following section is Ray Muzic's estimate for covariance and correlation
  %% assuming covariance of data is a diagonal matrix proportional to
  %% diag(1/wt.^2).  
  %% cov matrix of data est. from Bard Eq. 7-5-13, and Row 1 Table 5.1 

  tp = wt.^2;
  if (exist('sparse'))  % save memory
    Q = sparse (1:m, 1:m, 1 ./ tp);
    Qinv = sparse (1:m, 1:m, tp);
  else
    Q = diag (ones (m, 1) ./ tp);
    Qinv = diag (tp);
  end
  resid=y-f;                                    %un-weighted residuals
  if (~isreal (r)) error ('residuals are not real'); end
  tp = resid.' * Qinv * resid;
  covr = (tp / m) * Q;    %covariance of residuals

  %% Matlab compatibility and avoiding recomputation make the following
  %% logic clumsy.
  compute = 1;
  if (m <= n)
    compute = 0;
  else
    Qinv = ((m - n) / tp) * Qinv;
    %% simplified Eq. 7-5-13, Bard; cov of parm est, inverse; outer
    %% parantheses contain inverse of guessed covariance matrix of data
    covpinv = jac.' * Qinv * jac;
    if (exist ('rcond') && rcond (covpinv) <= eps)
      compute = 0;
    elseif (rank (covpinv) < n)
      %% above test is not equivalent to 'rcond' and may unnecessarily
      %% reject some matrices
      compute = 0;
    end
  end
  if (compute)
    covp = inv (covpinv);
    d=sqrt(diag(covp));
    corp = covp ./ (d * d.');
  else
    covp = NA * ones (n);
    corp = covp;
  end

  if (exist('sparse'))
    covr=spdiags(covr,0);
  else
    covr=diag(covr);                 % convert returned values to
				% compact storage
  end
  stdresid = resid .* abs (wt) / sqrt (tp / m); % equivalent to resid ./
				% sqrt (covr)

  if (~(verbose || nargout > 8)) return; end

  if (m > n)
    Z = ((m - n) / (n * resid.' * Qinv * resid)) * covpinv;
  else
    Z = NA * ones (n);
  end

%%% alt. est. of cov. mat. of parm.:(Delforge, Circulation, 82:1494-1504, 1990
  %%disp('Alternate estimate of cov. of param. est.')
  %%acovp=resid'*Qinv*resid/(m-n)*inv(jac'*Qinv*jac);

  if (~(verbose || nargout > 9)) return; end

  %%Calculate R^2, intercept form
  %%
  tp = sumsq (y - mean (y));
  if (tp > 0)
    r2 = 1 - sumsq (resid) / tp;
  else
    r2 = NA;
  end

  %% if someone has asked for it, let them have it
  %%
  if (verbose)
    eval(plotcmd);
    disp(' Least Squares Estimates of Parameters')
    disp(p.')
    disp(' Correlation matrix of parameters estimated')
    disp(corp)
    disp(' Covariance matrix of Residuals' )
    disp(covr)
    disp(' Correlation Coefficient R^2')
    disp(r2)
    sprintf(' 95%% conf region: F(0.05)(%.0f,%.0f)>= delta_pvec.''*Z*delta_pvec',n,m-n)
    Z
    %% runs test according to Bard. p 201.
    n1 = sum (resid > 0);
    n2 = sum (resid < 0);
    nrun=sum(abs(diff(resid > 0)))+1;
    if ((n1 > 10) && (n2 > 10)) % sufficent data for test?
      zed=(nrun-(2*n1*n2/(n1+n2)+1)+0.5)/(2*n1*n2*(2*n1*n2-n1-n2)...
        /((n1+n2)^2*(n1+n2-1)));
      if (zed < 0)
        prob = erfc(-zed/sqrt(2))/2*100;
        disp([num2str(prob),'% chance of fewer than ',num2str(nrun),' runs.']);
      else
        prob = erfc(zed/sqrt(2))/2*100;
        disp([num2str(prob),'% chance of greater than ',num2str(nrun),' runs.']);
      end
    end
  end
