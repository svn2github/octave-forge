## Copyright (C) 2000-2001 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## speed(f, init, max_n, f2, tol, err)
##
##   Determine the execution time of an expression for various n.
##   The n are log-spaced from 1 to max_n.  For each n, an
##   initialization expression is computed to create whatever
##   data are needed for the test.
##
##   f is the expression to evaluate.
##   max_n = 100 is the maximum test length to run.
##   init = "x = randn(n, 1);"
##     Initialization expression for function argument values.  Use 'k' 
##     for the test number and 'n' for the size of the test.  This should
##     compute values for all variables listed in args.  Note that init
##     will be evaluated first for k=0, so things which are constant
##     throughout the test can be computed then.
##   f2 = []
##     is an alternative expression to evaluate, so the speed of the two
##     can be compared
##   tol = eps
##     if tol is inf, then no comparison will be made between the
##     results of express f and expression f2.  Otherwise, expression
##     f should produce a value v and expression f2 should produce
##     a value v2, and these shall be compared using assert(v,v2,tol,err)
##
## r = speed (...)
##   Returns the average speedup ratio instead of displaying and plotting.
##
## Some global variables are also referenced. Choose values suitable to
## your machine and your work style.
##    speed_test_plot = 1
##       if true, plot a nice speed comparison graph
##    speed_test_numtests = 25
##       number of vector lengths to test
##
## Some comments on the graphs.  The line on the speedup ratio graph 
## should be larger than 1 if your function is faster.  The slope on
## the runtime graph shows you the O(f) speed characteristics.  Where it
## is flat, execution time is O(1).  Where it is sloping, execution time
## is O(n^m), with steeper slopes for larger n.  Generally vectorizing
## a function will not change the slope of the run-time graph, but it
## will shift it relative to the original.
##
## Example
##   % If you had an original version of xcorr using for loops and
##   % another version using FFT, you could compare the run speed
##   % for various lags as follows, or for a fixed lag with varying
##   % vector lengths as follows:
##
##   speed("v=xcorr(x,n)", "x=rand(128,1);", 100, ...
##         "v2=xcorr_orig(x,n)", 100*eps,'rel')
##   speed("v=xcorr(x,15)", "x=rand(20+n,1);", 100, ...
##         "v2=xcorr_orig(x,n)", 100*eps,'rel')
##
##   % Assuming one of the two versions is in xcorr_orig, this would
##   % would compare their speed and their output values.  Note that the
##   % FFT version is not exact, so we specify an acceptable tolerance on
##   % the comparison (100*eps), and the errors should be computed
##   % relatively, as abs( (x-y)./y ) rather than absolutely as abs(x-y).
##
## Example
##   speed("strrep(s,x,y)", "s=blanks(n);x=' ';y='b';", 100)
##
## Type example('speed') to see some real examples.  Note for 
## obscure reasons, you can't run examples 1 and 2 directly using 
## demo('speed').  Instead use: 
##    eval(example('speed',1))
##    eval(example('speed',2))

## TODO: consider two dimensional speedup surfaces for functions like kron.
function __ratio_r = speed (__f1, __init, __max_n, __f2, __tol, __err)
  if nargin < 1 || nargin > 6, 
    usage("speed_test(f, init, max_n, f2, tol, err)");
  endif
  if nargin < 2 || isempty(__init), 
    __init = "x = randn(n, 1);";
  endif
  if nargin < 3 || isempty(__max_n), __max_n = 100; endif
  if nargin < 4, __f2 = []; endif
  if nargin < 5 || isempty(__tol), __tol = eps; endif
  if nargin < 6 || isempty(__err), __err = []; endif

  global speed_test_plot = 1;
  global speed_test_numtests = 25;

  __test_n = uniq(round(logspace(0,log10(__max_n),speed_test_numtests)));
  __torig = __tnew = zeros (size(__test_n)) ;

  disp (["testing..........", __f1, "\ninit: ", __init]);

  ## make sure the functions are freshly loaded by evaluating them at
  ## test_n(1); firt have to initialize the args though.
  n=1; k=0;
  eval ([__init, ";"]);
  if !isempty(__f2), eval ([__f2, ";"]); endif
  eval ([__f1, ";"]);

  ## run the tests
  for k=1:length(__test_n)
    if (k > 1)
      n=__test_n(k);
      eval ([__init, ";"]);
    endif
    
    printf ("n%i=%i  ",k, n) ; fflush(1);

    eval (["__t=time();", __f1, "; __v1=ans; __t = time()-__t;"]);
    if (__t < 0.25)
      eval (["__t2=time();", __f1, "; __t2 = time()-__t2;"]);
      eval (["__t3=time();", __f1, "; __t3 = time()-__t3;"]);
      __t = min([__t,__t2,__t3]);
    endif
    __tnew(k) = __t;

    if !isempty(__f2)
      eval (["__t=time();", __f2, "; __v2=ans; __t = time()-__t;"]);
      if (__t < 0.25)
      	eval (["__t2=time();", __f2, "; __t2 = time()-__t2;"]);
      	eval (["__t3=time();", __f2, "; __t3 = time()-__t3;"]);
      endif
      __torig(k) = __t;
      if !isinf(__tol)
      	assert(__v1,__v2,__tol,__err);
      endif
    endif
    
  end
  
  if !isempty(__f2),
				# Don't keep zero times
    idx = find ( __tnew>sqrt(eps) &  __torig>sqrt(eps) ) ;
    ratio = mean (__torig(idx) ./ __tnew(idx));
    if (nargout == 1)
      __ratio_r = ratio;
    else
      printf ("\nmean runtime ratio of %s / %s : %g\n", __f2, __f1, ratio);
    endif
  else
    if (nargout == 1)
      _ratio_r = mean(__tnew);
    else
      printf ("\nmean runtime: %g\n", mean(__tnew));
    endif
  endif

  if (speed_test_plot && nargout == 0 && !isempty(__f2))

    if (gnuplot_has_multiplot) subplot(121); endif
    xlabel("test length");
    title (__f1);
    ylabel("speedup ratio");
    semilogx ( __test_n(idx), __torig(idx)./__tnew(idx) , 
	      ["-*r;", strrep(__f1,";","."), "/", strrep(__f2,";","."), ";"],
	       __test_n(idx), __tnew(idx)./__torig(idx) ,
	      ["-*g;", strrep(__f2,";","."), "/", strrep(__f1,";","."), ";"]);
    if (gnuplot_has_multiplot) 
      subplot (122);
    else
      input ("Press any key for the next graph:", "s");
    endif

    ## convert best execution time to milliseconds.
    __torig = 1000*__torig;
    __tnew = 1000*__tnew;

    ylabel ("best execution time (ms)");
    title (["init: ", __init]);
    loglog ( __test_n (idx), __tnew (idx), ["*-g;", strrep(__f1,";","."), ";" ], 
	    __test_n (idx), __torig (idx), ["*-r;", strrep(__f2,";","."), ";"])
    title (""); xlabel (""); ylabel (""); oneplot();
  elseif (speed_test_plot && nargout == 0)
    __tnew = 1000*__tnew;
    xlabel("test length");
    ylabel ("best execution time (ms)");
    title ([__f1, "  init: ", __init]);
    loglog ( __test_n, __tnew, "*-g;;");
    title (""); xlabel (""); ylabel (""); oneplot();
  endif
  
endfunction

%!demo if 1
%!  function x = build_orig(n)
%!    ## extend the target vector on the fly
%!    for i=0:n-1, x([1:10]+i*10) = 1:10; endfor
%!  endfunction
%!  function x = build(n)
%!    ## preallocate the target vector
%!    x = zeros(1, n*10);
%!    try
%!      if (prefer_column_vectors), x = x.'; endif
%!    catch
%!    end
%!    for i=0:n-1, x([1:10]+i*10) = 1:10; endfor
%!  endfunction
%!
%!  disp("-----------------------");
%!  type build_orig;
%!  disp("-----------------------");
%!  type build;
%!  disp("-----------------------");
%!
%!  disp("Preallocated vector test.\nThis takes a little while...");
%!  speed('build', 'build_orig', 1000, 'v=n;');
%!  clear build build_orig
%!  disp("Note how much faster it is to pre-allocate a vector.");
%!  disp("Notice the peak speedup ratio.");
%!  clear build build_orig
%! endif

%!demo if 1
%!  function x = build_orig(n)
%!    for i=0:n-1, x([1:10]+i*10) = 1:10; endfor
%!  endfunction
%!  function x = build(n)
%!    idx = [1:10]';
%!    x = idx(:,ones(1,n));
%!    x = reshape(x, 1, n*10);
%!    try
%!      if (prefer_column_vectors), x = x.'; endif
%!    catch
%!    end
%!  endfunction
%!
%!  disp("-----------------------");
%!  type build_orig;
%!  disp("-----------------------");
%!  type build;
%!  disp("-----------------------");
%!
%!  disp("Vectorized test. This takes a little while...");
%!  speed('build', 'build_orig', 1000, 'v=n;');
%!  clear build build_orig
%!  disp("-----------------------");
%!  disp("This time, the for loop is done away with entirely.");
%!  disp("Notice how much bigger the speedup is then in example 1.");
%! endif
