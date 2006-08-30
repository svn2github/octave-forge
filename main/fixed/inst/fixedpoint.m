## Copyright (C) 2003 Motorola Inc and David Bateman
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

## -*- texinfo -*-
## @deftypefn {Function File} {} fixedpoint ('help')
## @deftypefnx {Function File} {} fixedpoint ('info')
## @deftypefnx {Function File} {} fixedpoint ('info', @var{mod})
## @deftypefnx {Function File} {} fixedpoint ('test')
## @deftypefnx {Function File} {} fixedpoint ('test', @var{mod})
##
## Manual and test code for the Octave Fixed Point toolbox. There are
## 5 possible ways to call this function.
##
## @table @code
## @item fixedpoint ('help')
## Display this help message. Called with no arguments, this function also
## displays this help message
## @item fixedpoint ('info')
## Open the Fixed Point toolbox manual
## @item fixedpoint ('info', @var{mod})
## Open the Fixed Point toolbox manual at the section specified by
## @var{mod}
## @item fixedpoint ('test')
## Run all of the test code for the Fixed Point toolbox.
## @var{mod}.
## @end table
##
## Valid values for the varibale @var{mod} are
##
## @table @asis
## @item 'basics'
## The section describing the use of the fixed point toolbox within Octave
## @item 'programming'
## The section descrining how to use the fixed-point type with oct-files
## @item 'example'
## The section describing an in-depth example of the use of the fixed-point
## type
## @item 'reference'
## The refernce section of all of the specific fixed point operators and
## functions
## @end table
##
## Please note that this function file should be used as an example of the 
## use of this toolbox.
## @end deftypefn

## PKG_ADD: mark_as_command fixedpoint

function retval = fixedpoint(typ, tests)

  if (nargin < 1)
    typ = "help";
    tests = "all";
  elseif (nargin < 2)
    tests = "all";
  endif

  infofile = [fileparts(mfilename('fullpath')),'/doc.info'];
  n = 10;
  m = 20;
  is = 7;
  ds = 6;
  vals = [-10,10];

  vers = sscanf(OCTAVE_VERSION, "%i.%i.%i");

  if strcmp(tests,"all") 
    nodename = "Top";
  elseif strcmp(tests,"basics") 
    nodename = "Basics";
  elseif  strcmp(tests,"programming") 
    nodename = "Programming";
  elseif  strcmp(tests,"example") 
    nodename = "Example";
  elseif  strcmp(tests,"reference") 
    nodename = "Function Reference";
  else
    error ("fixedpoint: unrecognized section");
  endif

  if (strcmp(typ,"help"))
    help ("fixedpoint");
  elseif (strcmp(typ,"info"))
    infopaths = ["."];
    if (!isempty(split(path,":")))
      infopaths =[infopaths; split(path,":")];
    endif
    if (!isempty(split(DEFAULT_LOADPATH,":")))
      infopaths =[infopaths; split(DEFAULT_LOADPATH,":")];
    endif
    for i=1:size(infopaths,1)
      infopath = deblank(infopaths(i,:));
      len = length(infopath);
      if (len)
        if (len > 1 && strcmp(infopath([len-1, len]),"//"))
          [status, showfile] = system(["find '", infopath(1:len-1), ...
				       "' -name ", infofile]);
        else
          [status, showfile] = system(["find '", infopath, "' -name ", ...
				       infofile, " -maxdepth 1"]);
        endif
        if (length(showfile))
          break;
        endif
      endif
    end
    if (!exist("showfile") || !length(showfile))
      error("fixedpoint: info file not found");
    endif
    if (showfile(length(showfile)) == "\n")
      showfile = showfile(1:length(showfile)-1);
    endif
    
    if (exist("INFO_PROGAM")) 
      [testret, testout] = system(["'", INFO_PROGRAM, "' --version"]);
      if (testret)
        error("fixedpoint: info command not found");
      else
        system(["'", INFO_PROGRAM, "' --file '", showfile, "' --node '", ...
                nodename, "'"]); 
      endif
    else
      [testret, testout] = system("info --version");
      if (testret)
        error("fixedpoint: info command not found");
      else
        system(["info --file '", showfile, "' --node '", nodename, "'"]); 
      endif
    endif
  elseif (strcmp(typ,"test"))
    pso = page_screen_output;
    unwind_protect
      page_screen_output = 0;
      feps = 1 / 2 ^ ds;

      fprintf("\n<< Fixed Point Load Type >>\n");

      ## Load a fixed point variable to start things off
      x = fixed(is,ds);

      if (!exist("fixed_point_warn_overflow") || !exist("fixed_point_debug") ||
	  !exist("fixed_point_count_operations") ||
	  !exist("fixed_point_version"))
	error("Can not find fixed point type")
      endif

      fprintf("  Found Fixed Point Toolbox (version %s)\n", 
	      fixed_point_version);

      fprintf("\n<< Fixed Point Creation >>\n");
      fprintf("  Scalar Creation:                          ");
      zero = fixed(is,ds);
      if (zero.x != 0.) || (zero.int != is) || (zero.dec != ds)
	error ("FAILED");
      endif
      if (!isscalar(zero) || !ismatrix(zero) || !isfixed(zero) ||
	  !isvector(zero))
	error ("FAILED");
      endif
      if any(zero) || all(zero)
	error ("FAILED");
      endif
      if (size(zero) != [1,1]) || (length(zero) != 1)
	error ("FAILED");
      endif
      zero.int = zero.int+1;
      zero.dec = zero.dec+1;
      if (zero.x != 0.) || (zero.int != is+1) || (zero.dec != ds+1)
	error ("FAILED");
      endif
      empty = fixed(is,ds,[]);
      if (isscalar(empty) || ismatrix(empty) || !isfixed(empty) ||
	  isvector(empty) || !isempty(empty) || isempty(zero))
	error ("FAILED");
      endif
      for i=1:100
	x = (vals(2)-vals(1))*rand(1,1)+vals(1);
	a = fixed(is, ds, x);
	if (abs(a.x - x) > feps) || (a.sign != sign(a.x)) || !isfixed(a)
	  error ("FAILED");
	endif
      endfor
      fprintf("PASSED\n");
      fprintf("  Matrix Creation:                          ");
      zero = fixed(is,ds,zeros(n,n));
      
      if (any(any(zero.x)) || any(any(zero.int != is)) || 
	  any(any(zero.dec != ds)))
	error ("FAILED");
      endif
      if (isscalar(zero) || !ismatrix(zero) || !isfixed(zero) ||
	  isvector(zero))
	error ("FAILED");
      endif
      if any(any(zero)) || all(all(zero))
	error ("FAILED");
      endif
      if (size(zero) != [n,n])
	error ("FAILED");
      endif
      zero.int = zero.int+1;
      zero.dec = zero.dec+1;
      if (any(any(zero.x)) || any(any(zero.int != is+1)) || 
	  any(any(zero.dec != ds+1)))
	error ("FAILED");
      endif
      for i=1:100
	x = (vals(2)-vals(1))*rand(n,n)+vals(1);
	a = fixed(is, ds, x);
	if (any(any(abs(a.x - x) > feps)) || any(any(a.sign != sign(a.x))) 
	    || !isfixed(a))
	  error ("FAILED");
	endif
      endfor
      b = freshape(a,n*n,1);
      if (isscalar(b) || !ismatrix(b) || !isfixed(b) || !isvector(b))
	error ("FAILED");
      endif
      if any(b != a(:))
	error ("FAILED");
      endif
      zero = fixed(is,ds,0);
      vec = fixed(is,ds,[1:n]);
      a = fdiag(vec);
      if (size(a,1) != n || size(a,2) != n)
        error("FAILED");
      endif
      for i=1:n
        for j=1:n
          if ((i == j) && (a(i,j) != vec(i)))
            error("FAILED");
          elseif ((i != j) && (a(i,j) != zero))
            error("FAILED");
          endif
        end
      end
      vec = fdiag(a);
      if (length(vec) != n)
        error("FAILED");
      endif
      for i=1:n
        if (a(i,i) != vec(i))
          error("FAILED");
        endif
      end          
      fprintf("PASSED\n");
      fprintf("  Complex Scalar Creation:                  ");
      onei = fixed(is*(1+1i),ds*(1+1i),1+1i);
      if ((onei.x != 1+1i) || (onei.int != is*(1+1i)) || 
	  (onei.dec != ds*(1+1i)))
	error ("FAILED");
      endif
      if (!isscalar(onei) || !ismatrix(onei) || !isfixed(onei) || 
	  !isvector(onei) || !iscomplex(onei))
	error ("FAILED");
      endif
      if !any(onei) || !all(onei)
	error ("FAILED");
      endif
      if (size(onei) != [1,1]) || (length(onei) != 1)
	error ("FAILED");
      endif
      onei.int = onei.int+1;
      onei.dec = onei.dec+1;
      if ((onei.x != 1+1i) || (onei.int != is*(1+1i)+1) || 
	  (onei.dec != ds*(1+1i)+1))
	error ("FAILED");
      endif
      empty = fixed(is*(1+1i),ds*(1+1i),[]);
      if (isscalar(empty) || ismatrix(empty) || !isfixed(empty) ||
	  isvector(empty) || !isempty(empty) || isempty(onei) ||
	  iscomplex(empty))
	## Not complex, since its type is narrowed!!
	error ("FAILED");
      endif
      
      for i=1:100
	x = (vals(2)-vals(1))*rand(1,1)+vals(1) + ...
	    1i * (vals(2)-vals(1))*rand(1,1)+vals(1);
	a = fixed(is, ds, x);
	if ((abs(real(a.x) - real(x)) > feps) || 
	    (abs(imag(a.x) - imag(x)) > feps) || !isfixed(a)) 
	  error ("FAILED");
	endif
      endfor
      fprintf("PASSED\n");
      fprintf("  Complex Matrix Creation:                  ");
      onei = fixed(is*(1+1i),ds*(1+1i),ones(n,n)*(1+1i));
      
      if (any(any(onei.x != 1+1i)) || any(any(onei.int != is*(1+1i))) || 
	  any(any(onei.dec != ds*(1+1i))))
	error ("FAILED");
      endif
      if (isscalar(onei) || !ismatrix(onei) || !isfixed(onei) ||
	  isvector(onei) || !iscomplex(onei))
	error ("FAILED");
      endif
      if !any(any(onei)) || !all(all(onei))
	error ("FAILED");
      endif
      if (size(onei) != [n,n])
	error ("FAILED");
      endif
      onei.int = onei.int+1;
      onei.dec = onei.dec+1;
      if (any(any(onei.x != 1+1i)) || any(any(onei.int != is*(1+1i)+1)) || 
	  any(any(onei.dec != ds*(1+1i)+1)))
	error ("FAILED");
      endif
      for i=1:100
	x = (vals(2)-vals(1))*rand(n,n)+vals(1) + ...
	    1i * (vals(2)-vals(1))*rand(n,n)+vals(1);
	a = fixed(is, ds, x);
	if (any(any(abs(real(a.x) - real(x)) > feps)) || 
	    any(any(abs(imag(a.x) - imag(x)) > feps)) || !isfixed(a)) 
	  error ("FAILED");
	endif
      endfor
      b = freshape(a,n*n,1);
      if (isscalar(b) || !ismatrix(b) || !isfixed(b) || !isvector(b))
	error ("FAILED");
      endif
      if any(b != a(:))
	error ("FAILED");
      endif
      zero = fixed(is,ds,0);
      vec = fixed(is*(1+1i),ds*(1+1i),[1:n]*(1+1i));
      a = fdiag(vec);
      if (size(a,1) != n || size(a,2) != n)
        error("FAILED");
      endif
      for i=1:n
        for j=1:n
          if ((i == j) && (a(i,j) != vec(i)))
            error("FAILED");
          elseif ((i != j) && (a(i,j) != zero))
            error("FAILED");
          endif
        end
      end
      vec = fdiag(a);
      if (length(vec) != n)
        error("FAILED");
      endif
      for i=1:n
        if (a(i,i) != vec(i))
          error("FAILED");
        endif
      end          
      fprintf("PASSED\n");
      fprintf("  Indexed Access of Scalars:                ");
      a = fixed(is,ds,1);
      a(2) = fixed(is,ds,2);
      if (!isvector(a) || !isfixed(a))
        error("FAILED");
      endif
      a = fixed(is,ds,1);
      a(2) = fixed(is,ds,1i);
      if (!isvector(a) || !isfixed(a) || !iscomplex(a))
        error("FAILED");
      endif
      a = fixed(is,ds,1);
      a(1).dec = a(1).dec + 1;
      if (a.dec != ds+1)
        error("FAILED");
      endif
      a = fixed(is,ds,1i);
      a(2) = fixed(is,ds,2*1i);
      if (!isvector(a) || !isfixed(a) || !iscomplex(a))
        error("FAILED");
      endif
      a = fixed(is,ds,1i);
      a(1).dec = a(1).dec + 1;
      if (a.dec != ds*(1+1i)+1)
        error("FAILED");
      endif
      fprintf("PASSED\n");
      fprintf("  Indexed Access of Matrices:               ");
      x = (vals(2)-vals(1))*rand(n,n)+vals(1);
      a = fixed(is, ds, x);
      if (any(any(abs(a(1,:).x - x(1,:)) > feps)) || !isfixed(a))
	error ("FAILED");
      endif
      a(1,:).dec = a(1,:).dec + 1;
      if (a(1,:).dec != ds+1)
        error("FAILED");
      endif
      if (a(2,:).dec != ds)
        error("FAILED");
      endif
      a(1,1) = fixed(is,ds,1i);
      if (!ismatrix(a) || !isfixed(a) || !iscomplex(a))
        error("FAILED");
      endif
      x = ((vals(2)-vals(1))*rand(n,n)+vals(1) +
	   ((vals(2)-vals(1))*rand(n,n)+vals(1)) * 1i);
      a = fixed(is, ds, x);
      if (any(any(abs(real(a(1,:).x) - real(x(1,:))) > feps)) || 
	  any(any(abs(imag(a(1,:).x) - imag(x(1,:))) > feps)) || 
	  !isfixed(a)) 
	error ("FAILED");
      endif
      a(1,:).dec = a(1,:).dec + 1;
      if (a(1,:).dec != ds*(1+1i)+1)
        error("FAILED");
      endif
      if (a(2,:).dec != ds*(1+1i))
        error("FAILED");
      endif
      fprintf("PASSED\n");

      fprintf("\n<< Fixed Point Operators >>\n");

      fprintf("  Logical Operators:                        ");
      if (_fixedpoint_test_bool_operator("==",is,ds,n) ||
	  _fixedpoint_test_bool_operator("!=",is,ds,n) ||
	  _fixedpoint_test_bool_operator(">",is,ds,n) ||
	  _fixedpoint_test_bool_operator("<",is,ds,n) ||
	  _fixedpoint_test_bool_operator(">=",is,ds,n) ||
	  _fixedpoint_test_bool_operator("<=",is,ds,n))
        error("FAILED");
      else
	fprintf("PASSED\n");
      endif

      fprintf("  Unary Operators:                          ");
      if (_fixedpoint_test_unary_operator("-",is,ds,n,1) ||
	  _fixedpoint_test_unary_operator("+",is,ds,n,1) ||
	  _fixedpoint_test_unary_operator("'",is,ds,n,0) ||
	  _fixedpoint_test_unary_operator(".'",is,ds,n,0))
        error("FAILED");
      else
	fprintf("PASSED\n");
      endif
      # This has special meaning for fixed point. Whats the test !!!! 
      # Is the damn operator even correct !! 
      # b = ! a;

      fprintf("  Arithmetic Operators:                     ");
      if (_fixedpoint_test_operator("-",is,ds,n,1,1,1) ||
	  _fixedpoint_test_operator("+",is,ds,n,1,1,1) ||
	  _fixedpoint_test_operator(".*",is,ds,n,1,1,1) ||
	  _fixedpoint_test_operator("*",is,ds,n,1,1,1) ||
	  _fixedpoint_test_operator("./",is,ds,n,0,1,1) ||

##  Bug in octave 2.1.50 and earlier for el_ldiv in op-cs-s.cc. 
	  ((vers(1) > 2 || (vers(1) >= 2 && vers(2) > 1) ||
	  (vers(1) >= 2 && vers(2) >= 1 && vers(3) > 50)) && 
	   _fixedpoint_test_operator(".\\",is,ds,n,0,1,1)) ||

## Rounding errors in complex pow functions make these fail
##	  _fixedpoint_test_operator(".**",is,ds,n,0,1,1) ||
##	  _fixedpoint_test_operator(".^",is,ds,n,0,1,1)

## Can't do "matrix-by-matrix", as well as above problem
##	  _fixedpoint_test_operator("**",is,ds,n,0,1,0) ||
##	  _fixedpoint_test_operator("^",is,ds,n,0,1,0)  ||

## Can't divide by a matrix as don't have inversion
	  _fixedpoint_test_operator("/",is,ds,n,0,1,0) ||
	  _fixedpoint_test_operator("\\",is,ds,n,0,0,1))
        error("FAILED");
      else
	fprintf("PASSED\n");
      endif

      fprintf("\n<< Fixed Point Functions >>\n");
      fprintf("  Rounding Functions:                       ");
	
      if (_fixedpoint_test_function("ceil",is,ds,n,0) ||
	  _fixedpoint_test_function("floor",is,ds,n,0) ||
	  _fixedpoint_test_function("round",is,ds,n,0))
        error("FAILED");
      else
	fprintf("PASSED\n");
      endif

      fprintf("  Matrix Sum and Product Functions:         ");
      if (_fixedpoint_test_function("sum",is,ds,n,0) ||
	  _fixedpoint_test_function("cumsum",is,ds,n,0))
        error("FAILED");
      endif

      ## These can easily under- or  over-flow. Trick the code by
      ## foring ds=0, which simplifies the internal calculations,
      ## effectively limiting the values used to 1 and 0. If you 
      ## can think of a better way, tell me...
      tmpds = ds;
      ds = 0;
      if (_fixedpoint_test_function("sumsq",is,ds,n,feps) ||
	  _fixedpoint_test_function("prod",is,ds,n,feps) ||
	  _fixedpoint_test_function("cumprod",is,ds,n,feps))
        error("FAILED");
      else
	fprintf("PASSED\n");
      endif
      ds = tmpds;

      fprintf("  Miscellaneous Functions:                  ");
      if (_fixedpoint_test_function("real",is,ds,n,0) ||
	  _fixedpoint_test_function("imag",is,ds,n,0) ||
	  _fixedpoint_test_function("conj",is,ds,n,0) ||
	  _fixedpoint_test_function("arg",is,ds,n,feps) ||
	  _fixedpoint_test_function("angle",is,ds,n,feps) ||
	  _fixedpoint_test_function("abs",is,ds,n,sqrt(2)*feps) ||
	  _fixedpoint_test_function("sqrt",is,ds,n,sqrt(2)*feps))
        error("FAILED");
      else
	fprintf("PASSED\n");
      endif

      ## These will underflow/overflow, use larger feps that should be
      ## ok upto ds = 6. Again if you can think of a better way to check!!
      fprintf("  Exponential Functions:                    ");
      if (_fixedpoint_test_function("log",is,ds,n,2*feps,0) ||
	  _fixedpoint_test_function("log10",is,ds,n,20*feps,0) ||
	  _fixedpoint_test_function("exp",is,ds,n,4*feps))
        error("FAILED");
      else
	fprintf("PASSED\n");
      endif

      ## These will underflow/overflow, use larger feps that should be
      ## ok upto ds = 6. Again if you can think of a better way to check!!
      fprintf("  Trigonometric Functions:                  ");
      if (_fixedpoint_test_function("sin",is,ds,n,4*feps) ||
	  _fixedpoint_test_function("sinh",is,ds,n,4*feps) ||
	  _fixedpoint_test_function("cos",is,ds,n,4*feps) ||
	  _fixedpoint_test_function("cosh",is,ds,n,4*feps) ||
	  _fixedpoint_test_function("tan",is,ds,n,4*feps) ||
	  _fixedpoint_test_function("tanh",is,ds,n,4*feps))
        error("FAILED");
      endif

      ## Special case for fatan2
      fzero = fixed(is,ds,0);
      fzeros = fixed(is,ds,zeros(n,1));
      fone = fixed(is,ds,1);
      fones = fixed(is,ds,ones(n,1));
      fpi2 = fixed(is,ds,pi/2);
      fpi4 = fixed(is,ds,pi/4);
      if (fatan2(fzero,fzero) != fzero || 
	  fatan2(fzero,fone) != fzero ||
	  fatan2(fone,fzero) != fpi2 ||
	  fatan2(fone,fone) != fpi4 ||
	  any(fatan2(fzeros,fzeros) != fzero) || 
	  any(fatan2(fzeros,fones) != fzero) ||
	  any(fatan2(fones,fzeros) != fpi2) ||
	  any(fatan2(fones,fones) != fpi4))
        error("FAILED");
      else
	fprintf("PASSED\n");
      endif

      fprintf("\n");
    unwind_protect_cleanup
      page_screen_output = pso;
    end_unwind_protect
  else
    usage("fixedpoint: Unknown argument");
  endif
endfunction

function ret = _fixedpoint_test_operator(op,is,ds,n,includezero,matrixleft,
					 matrixright)
  # Properly test all 16 possible combinations of an operator

  ret = 0;

  tzero = 0;
  tone = 1;
  tzeros = zeros(n,n);
  tones = ones(n,n);
  tczero = 1i;
  tczeros = 1i*ones(n,n);
  tcone = 1 + 1i;
  tcones = (1 + 1i)*ones(n,n);

  fzero = fixed(is,ds,tzero);
  fone = fixed(is,ds,tone);
  fzeros = fixed(is,ds,tzeros);
  fones = fixed(is,ds,tones);
  fczero = fixed(is,ds,tczero);
  fczeros = fixed(is,ds,tczeros);
  fcone = fixed(is,ds,tcone);
  fcones = fixed(is,ds,tcones);

  # scalar by scalar
  if (includezero)
    t1 = eval(["tzero" op "tzero;"]);
    f1 = eval(["fzero" op "fzero;"]);
    if (t1 != f1.x)
      ret = 1;
      return;
    endif
    t1 = eval(["tzero" op "tone;"]);
    f1 = eval(["fzero" op "fone;"]);
    if (t1 != f1.x)
      ret = 1;
      return;
    endif
    t1 = eval(["tone" op "tzero;"]);
    f1 = eval(["fone" op "fzero;"]);
    if (t1 != f1.x)
      ret = 1;
      return;
    endif
    endif
  t1 = eval(["tone" op "tone;"]);
  f1 = eval(["fone" op "fone;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  
  # scalar by matrix
  if (matrixright)
    if (includezero)
      t1 = eval(["tzero" op "tzeros;"]);
      f1 = eval(["fzero" op "fzeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tzero" op "tones;"]);
      f1 = eval(["fzero" op "fones;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tone" op "tzeros;"]);
      f1 = eval(["fone" op "fzeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tone" op "tones;"]);
    f1 = eval(["fone" op "fones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # matrix by scalar
  if (matrixleft)
    if (includezero)
      t1 = eval(["tzeros" op "tzero;"]);
      f1 = eval(["fzeros" op "fzero;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tzeros" op "tone;"]);
      f1 = eval(["fzeros" op "fone;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tones" op "tzero;"]);
      f1 = eval(["fones" op "fzero;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tones" op "tone;"]);
    f1 = eval(["fones" op "fone;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # matrix by matrix
  if (matrixleft && matrixright)
    if (includezero)
      t1 = eval(["tzeros" op "tzeros;"]);
      f1 = eval(["fzeros" op "fzeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tzeros" op "tones;"]);
      f1 = eval(["fzeros" op "fones;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tones" op "tzeros;"]);
      f1 = eval(["fones" op "fzeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tones" op "tones;"]);
    f1 = eval(["fones" op "fones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # scalar by complex scalar
  if (includezero)
    t1 = eval(["tzero" op "tczero;"]);
    f1 = eval(["fzero" op "fczero;"]);
    if (t1 != f1.x)
      ret = 1;
      return;
    endif
    t1 = eval(["tzero" op "tcone;"]);
    f1 = eval(["fzero" op "fcone;"]);
    if (t1 != f1.x)
      ret = 1;
      return;
    endif
  endif
  t1 = eval(["tone" op "tczero;"]);
  f1 = eval(["fone" op "fczero;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tcone;"]);
  f1 = eval(["fone" op "fcone;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif

  # scalar by complex matrix
  if (matrixright)
    if (includezero)
      t1 = eval(["tzero" op "tczeros;"]);
      f1 = eval(["fzero" op "fczeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tzero" op "tcones;"]);
      f1 = eval(["fzero" op "fcones;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tone" op "tczeros;"]);
    f1 = eval(["fone" op "fczeros;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tone" op "tcones;"]);
    f1 = eval(["fone" op "fcones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # matrix by complex scalar
  if (matrixleft)
    if (includezero)
      t1 = eval(["tzeros" op "tczero;"]);
      f1 = eval(["fzeros" op "fczero;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tzeros" op "tcone;"]);
      f1 = eval(["fzeros" op "fcone;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tones" op "tczero;"]);
    f1 = eval(["fones" op "fczero;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tones" op "tcone;"]);
    f1 = eval(["fones" op "fcone;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # matrix by complex matrix
  if (matrixleft && matrixright)
    if (includezero)
      t1 = eval(["tzeros" op "tczeros;"]);
      f1 = eval(["fzeros" op "fczeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tzeros" op "tcones;"]);
      f1 = eval(["fzeros" op "fcones;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tones" op "tczeros;"]);
    f1 = eval(["fones" op "fczeros;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tones" op "tcones;"]);
    f1 = eval(["fones" op "fcones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # complex scalar by scalar
  if (includezero)
    t1 = eval(["tczero" op "tzero;"]);
    f1 = eval(["fczero" op "fzero;"]);
    if (t1 != f1.x)
      ret = 1;
      return;
    endif
    t1 = eval(["tcone" op "tzero;"]);
    f1 = eval(["fcone" op "fzero;"]);
    if (t1 != f1.x)
      ret = 1;
      return;
    endif
  endif
  t1 = eval(["tczero" op "tone;"]);
  f1 = eval(["fczero" op "fone;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tone;"]);
  f1 = eval(["fcone" op "fone;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif

  # complex scalar by matrix
  if (matrixright)
    if (includezero)
      t1 = eval(["tczero" op "tzeros;"]);
      f1 = eval(["fczero" op "fzeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tcone" op "tzeros;"]);
      f1 = eval(["fcone" op "fzeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tczero" op "tones;"]);
    f1 = eval(["fczero" op "fones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcone" op "tones;"]);
    f1 = eval(["fcone" op "fones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # complex matrix by scalar
  if (matrixleft)
    if (includezero)
      t1 = eval(["tczeros" op "tzero;"]);
      f1 = eval(["fczeros" op "fzero;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tcones" op "tzero;"]);
      f1 = eval(["fcones" op "fzero;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tczeros" op "tone;"]);
    f1 = eval(["fczeros" op "fone;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcones" op "tone;"]);
    f1 = eval(["fcones" op "fone;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # complex matrix by matrix
  if (matrixleft && matrixright)
    if (includezero)
      t1 = eval(["tczeros" op "tzeros;"]);
      f1 = eval(["fczeros" op "fzeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
      t1 = eval(["tcones" op "tzeros;"]);
      f1 = eval(["fcones" op "fzeros;"]);
      if any(any(t1 != f1.x))
	ret = 1;
	return;
      endif
    endif
    t1 = eval(["tczeros" op "tones;"]);
    f1 = eval(["fczeros" op "fones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcones" op "tones;"]);
    f1 = eval(["fcones" op "fones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # complex scalar by complex scalar
  t1 = eval(["tczero" op "tczero;"]);
  f1 = eval(["fczero" op "fczero;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  t1 = eval(["tczero" op "tcone;"]);
  f1 = eval(["fczero" op "fcone;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tczero;"]);
  f1 = eval(["fcone" op "fczero;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tcone;"]);
  f1 = eval(["fcone" op "fcone;"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif

  # complex scalar by complex matrix
  if (matrixright)
    t1 = eval(["tczero" op "tczeros;"]);
    f1 = eval(["fczero" op "fczeros;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tczero" op "tcones;"]);
    f1 = eval(["fczero" op "fcones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcone" op "tczeros;"]);
    f1 = eval(["fcone" op "fczeros;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcone" op "tcones;"]);
    f1 = eval(["fcone" op "fcones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # complex matrix by complex scalar
  if (matrixleft)
    t1 = eval(["tczeros" op "tczero;"]);
    f1 = eval(["fczeros" op "fczero;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tczeros" op "tcone;"]);
    f1 = eval(["fczeros" op "fcone;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcones" op "tczero;"]);
    f1 = eval(["fcones" op "fczero;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcones" op "tcone;"]);
    f1 = eval(["fcones" op "fcone;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

  # complex matrix by complex matrix
  if (matrixleft && matrixright)
    t1 = eval(["tczeros" op "tczeros;"]);
    f1 = eval(["fczeros" op "fczeros;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tczeros" op "tcones;"]);
    f1 = eval(["fczeros" op "fcones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcones" op "tczeros;"]);
    f1 = eval(["fcones" op "fczeros;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
    t1 = eval(["tcones" op "tcones;"]);
    f1 = eval(["fcones" op "fcones;"]);
    if any(any(t1 != f1.x))
      ret = 1;
      return;
    endif
  endif

endfunction

function ret = _fixedpoint_test_bool_operator(op,is,ds,n)
  # Properly test all 16 possible combinations of an operator

  ret = 0;

  tzero = 0;
  tone = 1;
  tzeros = zeros(n,n);
  tones = ones(n,n);
  tczero = 1i;
  tczeros = 1i*ones(n,n);
  tcone = 1 + 1i;
  tcones = (1 + 1i)*ones(n,n);

  fzero = fixed(is,ds,tzero);
  fone = fixed(is,ds,tone);
  fzeros = fixed(is,ds,tzeros);
  fones = fixed(is,ds,tones);
  fczero = fixed(is,ds,tczero);
  fczeros = fixed(is,ds,tczeros);
  fcone = fixed(is,ds,tcone);
  fcones = fixed(is,ds,tcones);

  # scalar by scalar
  t1 = eval(["tzero" op "tzero;"]);
  f1 = eval(["fzero" op "fzero;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tzero" op "tone;"]);
  f1 = eval(["fzero" op "fone;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tzero;"]);
  f1 = eval(["fone" op "fzero;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tone;"]);
  f1 = eval(["fone" op "fone;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  
  # scalar by matrix
  t1 = eval(["tzero" op "tzeros;"]);
  f1 = eval(["fzero" op "fzeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tzero" op "tones;"]);
  f1 = eval(["fzero" op "fones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tzeros;"]);
  f1 = eval(["fone" op "fzeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tones;"]);
  f1 = eval(["fone" op "fones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # matrix by scalar
  t1 = eval(["tzeros" op "tzero;"]);
  f1 = eval(["fzeros" op "fzero;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tzeros" op "tone;"]);
  f1 = eval(["fzeros" op "fone;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tones" op "tzero;"]);
  f1 = eval(["fones" op "fzero;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tones" op "tone;"]);
  f1 = eval(["fones" op "fone;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # matrix by matrix
  t1 = eval(["tzeros" op "tzeros;"]);
  f1 = eval(["fzeros" op "fzeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tzeros" op "tones;"]);
  f1 = eval(["fzeros" op "fones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tones" op "tzeros;"]);
  f1 = eval(["fones" op "fzeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tones" op "tones;"]);
  f1 = eval(["fones" op "fones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif


  # scalar by complex scalar
  t1 = eval(["tzero" op "tczero;"]);
  f1 = eval(["fzero" op "fczero;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tzero" op "tcone;"]);
  f1 = eval(["fzero" op "fcone;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tczero;"]);
  f1 = eval(["fone" op "fczero;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tcone;"]);
  f1 = eval(["fone" op "fcone;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif

  # scalar by complex matrix
  t1 = eval(["tzero" op "tczeros;"]);
  f1 = eval(["fzero" op "fczeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tzero" op "tcones;"]);
  f1 = eval(["fzero" op "fcones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tczeros;"]);
  f1 = eval(["fone" op "fczeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tone" op "tcones;"]);
  f1 = eval(["fone" op "fcones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # matrix by complex scalar
  t1 = eval(["tzeros" op "tczero;"]);
  f1 = eval(["fzeros" op "fczero;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tzeros" op "tcone;"]);
  f1 = eval(["fzeros" op "fcone;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tones" op "tczero;"]);
  f1 = eval(["fones" op "fczero;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tones" op "tcone;"]);
  f1 = eval(["fones" op "fcone;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # matrix by complex matrix
  t1 = eval(["tzeros" op "tczeros;"]);
  f1 = eval(["fzeros" op "fczeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tzeros" op "tcones;"]);
  f1 = eval(["fzeros" op "fcones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tones" op "tczeros;"]);
  f1 = eval(["fones" op "fczeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tones" op "tcones;"]);
  f1 = eval(["fones" op "fcones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # complex scalar by scalar
  t1 = eval(["tczero" op "tzero;"]);
  f1 = eval(["fczero" op "fzero;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tczero" op "tone;"]);
  f1 = eval(["fczero" op "fone;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tzero;"]);
  f1 = eval(["fcone" op "fzero;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tone;"]);
  f1 = eval(["fcone" op "fone;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif

  # complex scalar by matrix
  t1 = eval(["tczero" op "tzeros;"]);
  f1 = eval(["fczero" op "fzeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tczero" op "tones;"]);
  f1 = eval(["fczero" op "fones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tzeros;"]);
  f1 = eval(["fcone" op "fzeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tones;"]);
  f1 = eval(["fcone" op "fones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # complex matrix by scalar
  t1 = eval(["tczeros" op "tzero;"]);
  f1 = eval(["fczeros" op "fzero;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tczeros" op "tone;"]);
  f1 = eval(["fczeros" op "fone;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcones" op "tzero;"]);
  f1 = eval(["fcones" op "fzero;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcones" op "tone;"]);
  f1 = eval(["fcones" op "fone;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # complex matrix by matrix
  t1 = eval(["tczeros" op "tzeros;"]);
  f1 = eval(["fczeros" op "fzeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tczeros" op "tones;"]);
  f1 = eval(["fczeros" op "fones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcones" op "tzeros;"]);
  f1 = eval(["fcones" op "fzeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcones" op "tones;"]);
  f1 = eval(["fcones" op "fones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # complex scalar by complex scalar
  t1 = eval(["tczero" op "tczero;"]);
  f1 = eval(["fczero" op "fczero;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tczero" op "tcone;"]);
  f1 = eval(["fczero" op "fcone;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tczero;"]);
  f1 = eval(["fcone" op "fczero;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tcone;"]);
  f1 = eval(["fcone" op "fcone;"]);
  if (t1 != f1)
    ret = 1;
    return;
  endif

  # complex scalar by complex matrix
  t1 = eval(["tczero" op "tczeros;"]);
  f1 = eval(["fczero" op "fczeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tczero" op "tcones;"]);
  f1 = eval(["fczero" op "fcones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tczeros;"]);
  f1 = eval(["fcone" op "fczeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcone" op "tcones;"]);
  f1 = eval(["fcone" op "fcones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # complex matrix by complex scalar
  t1 = eval(["tczeros" op "tczero;"]);
  f1 = eval(["fczeros" op "fczero;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tczeros" op "tcone;"]);
  f1 = eval(["fczeros" op "fcone;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcones" op "tczero;"]);
  f1 = eval(["fcones" op "fczero;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcones" op "tcone;"]);
  f1 = eval(["fcones" op "fcone;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

  # complex matrix by complex matrix
  t1 = eval(["tczeros" op "tczeros;"]);
  f1 = eval(["fczeros" op "fczeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tczeros" op "tcones;"]);
  f1 = eval(["fczeros" op "fcones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcones" op "tczeros;"]);
  f1 = eval(["fcones" op "fczeros;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif
  t1 = eval(["tcones" op "tcones;"]);
  f1 = eval(["fcones" op "fcones;"]);
  if any(any(t1 != f1))
    ret = 1;
    return;
  endif

endfunction

function ret = _fixedpoint_test_unary_operator(op,is,ds,n,front)
  # Properly test all 4 possible combinations of an operator

  ret = 0;

  tzero = 0;
  tone = 1;
  tzeros = zeros(n,n);
  tones = ones(n,n);
  tczero = 1i;
  tczeros = 1i*ones(n,n);
  tcone = 1 + 1i;
  tcones = (1 + 1i)*ones(n,n);

  fzero = fixed(is,ds,tzero);
  fone = fixed(is,ds,tone);
  fzeros = fixed(is,ds,tzeros);
  fones = fixed(is,ds,tones);
  fczero = fixed(is,ds,tczero);
  fczeros = fixed(is,ds,tczeros);
  fcone = fixed(is,ds,tcone);
  fcones = fixed(is,ds,tcones);

  if (front) 
    op1 = op;
    op2 = "";
  else
    op1 = "";
    op2 = op;
  endif    

  # scalar by scalar
  t1 = eval([ op1 "tzero" op2 ";"]);
  f1 = eval([ op1 "fzero" op2 ";"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  t1 = eval([ op1 "tone" op2 ";"]);
  f1 = eval([ op1 "fone" op2 ";"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  
  # matrix
  t1 = eval([ op1 "tzeros" op2 ";"]);
  f1 = eval([ op1 "fzeros" op2 ";"]);
  if any(any(t1 != f1.x))
    ret = 1;
    return;
  endif
  t1 = eval([ op1 "tones" op2 ";"]);
  f1 = eval([ op1 "fones" op2 ";"]);
  if any(any(t1 != f1.x))
    ret = 1;
    return;
  endif

  # complex scalar
  t1 = eval([ op1 "tczero" op2 ";"]);
  f1 = eval([ op1 "fczero" op2 ";"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif
  t1 = eval([ op1 "tcone" op2 ";"]);
  f1 = eval([ op1 "fcone" op2 ";"]);
  if (t1 != f1.x)
    ret = 1;
    return;
  endif

  # complex matrix
  t1 = eval([ op1 "tczeros" op2 ";"]);
  f1 = eval([ op1 "fczeros" op2 ";"]);
  if any(any(t1 != f1.x))
    ret = 1;
    return;
  endif
  t1 = eval([ op1 "tcones" op2 ";"]);
  f1 = eval([ op1 "fcones" op2 ";"]);
  if any(any(t1 != f1.x))
    ret = 1;
    return;
  endif

endfunction

function ret = _fixedpoint_test_function(func,is,ds,n,eps,includezero)
  # Properly test all 4 possible combinations of a function

  if (nargin < 6)
    includezero = 1;
  endif

  ret = 0;
  tzero = 0;
  tone = 1;
  tzeros = zeros(n,n);
  tones = ones(n,n);
  tczero = 1i;
  tczeros = 1i*ones(n,n);
  tcone = 1 + 1i;
  tcones = (1 + 1i)*ones(n,n);
  if (ds == 0)
    tval = tone;
    tvals = tones;
    tcval = tcone;
    tcvals = tcones;
  else
    tval = 0.5;
    if (includezero)
      tvals = ones(n,1) * (round(2^ds * (0:(n-1))/(n-1)) / 2^ds);
    else
      tvals = ones(n,1) * (round(2^ds * (1 + 2^(is-1)*(1:(n-1))/(n-1))) 
			   / 2^ds);
    endif
    tcval = tval * (1+1i);
    tcvals = tvals * (1+1i);
  endif

  fzero = fixed(is,ds,tzero);
  fone = fixed(is,ds,tone);
  fzeros = fixed(is,ds,tzeros);
  fones = fixed(is,ds,tones);
  fczero = fixed(is,ds,tczero);
  fczeros = fixed(is,ds,tczeros);
  fcone = fixed(is,ds,tcone);
  fcones = fixed(is,ds,tcones);
  fval = fixed(is,ds,tval);
  fvals = fixed(is,ds,tvals);
  fcval = fixed(is,ds,tcval);
  fcvals = fixed(is,ds,tcvals);

  ffunc = [ "f" func];

  # scalar by scalar
  if (includezero)
    t1 = eval([ func "(tzero);"]);
    f1 = eval([ ffunc "(fzero);"]);
    if (abs(t1 - f1.x) > eps)
      ret = 1;
      return;
    endif
  endif
  t1 = eval([ func "(tone);"]);
  f1 = eval([ ffunc "(fone);"]);
  if (abs(t1 - f1.x) > eps)
    ret = 1;
    return;
  endif
  t1 = eval([ func "(tval);"]);
  f1 = eval([ ffunc "(fval);"]);
  if (abs(t1 - f1.x) > eps)
    ret = 1;
    return;
  endif
  
  # matrix
  if (includezero)
    t1 = eval([ func "(tzeros);"]);
    f1 = eval([ ffunc "(fzeros);"]);
    if any(any(abs(t1 - f1.x) > eps))
      ret = 1;
      return;
    endif
  endif
  t1 = eval([ func "(tones);"]);
  f1 = eval([ ffunc "(fones);"]);
  if any(any(abs(t1 - f1.x) > eps))
    ret = 1;
    return;
  endif
  t1 = eval([ func "(tvals);"]);
  f1 = eval([ ffunc "(fvals);"]);
  if any(any(abs(t1 - f1.x) > eps))
    ret = 1;
    return;
  endif

  # complex scalar
  if (includezero)
    t1 = eval([ func "(tczero);"]);
    f1 = eval([ ffunc "(fczero);"]);
    if ((abs(real(t1) - freal(f1).x) > eps) || 
	(abs(imag(t1) - fimag(f1).x) > eps))
      ret = 1;
      return;
    endif
  endif
  t1 = eval([ func "(tcone);"]);
  f1 = eval([ ffunc "(fcone);"]);
  if ((abs(real(t1) - freal(f1).x) > eps) || (abs(imag(t1) - fimag(f1).x) > eps))
    ret = 1;
    return;
  endif
  t1 = eval([ func "(tcval);"]);
  f1 = eval([ ffunc "(fcval);"]);
  if ((abs(real(t1) - freal(f1).x) > eps) || (abs(imag(t1) - fimag(f1).x) > eps))
    ret = 1;
    return;
  endif

  # complex matrix
  if (includezero)
    t1 = eval([ func "(tczeros);"]);
    f1 = eval([ ffunc "(fczeros);"]);
    if (any(any(abs(real(t1) - freal(f1).x) > eps)) || 
	any(any(abs(imag(t1) - fimag(f1).x) > eps)))
      ret = 1;
      return;
    endif
  endif
  t1 = eval([ func "(tcones);"]);
  f1 = eval([ ffunc "(fcones);"]);
  if (any(any(abs(real(t1) - freal(f1).x) > eps)) || 
      any(any(abs(imag(t1) - fimag(f1).x) > eps)))
    ret = 1;
    return;
  endif
  t1 = eval([ func "(tcvals);"]);
  f1 = eval([ ffunc "(fcvals);"]);
  if (any(any(abs(real(t1) - freal(f1).x) > eps)) || 
      any(any(abs(imag(t1) - fimag(f1).x) > eps)))
    ret = 1;
    return;
  endif

endfunction

%!test
%! try fixedpoint("test");
%! catch disp(lasterr()); end

## Local Variables: ***
## mode: Octave ***
## End: ***
