## Copyright (C) 2000 Paul Kienzle
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

## test('name')
##   Perform tests interactively, stopping at the first error.
##   Tests are from the first file matching 'name', 'name.m' 
##   in your loadpath.
##
## test('name', ['quiet'|'normal'|'verbose'])
##   Perform tests interactively, stopping at the first error.
##   'quiet': Don't report all the tests as they happen, just the errors.
##   'normal': Report all tests as they happen, but don't do tests
##       which require user interaction.
##   'verbose': Do tests which require user interaction.
##
## test('name', ['quiet'|'normal'|'verbose'], fid)
##   Batch processing.  Write errors to already open file fid (hopefully
##   then when octave crashes this file will tell you what was happening
##   when it did).  You can use stdout if you want to see the results as
##   they happen.
##
## success = test(...)
##   return true if all the tests succeeded.
##
## [n, max] = test(...)
##   return number of success and number of tests
##
## [code, idx] = test('name', 'grabdemo')
##   Extract the contents of the demo blocks, but do not execute them.
##   code is the concatenation of all the code blocks and
##   idx is a vector of positions of the ends of the demo blocks.
##
## This function process the named script file looking for lines which
## start with "%! ".  The prefix is stripped off and the rest of the
## line is processed through the octave interpreter.  If the code
## generates an error, then the test is said to fail.
## 
## Since eval() will stop at the first error it encounters, you must
## divide your tests up into blocks, with anything in a separate
## block evaluated separately.  Blocks are introduced by the keyword
## 'test' immediately following the '%!'.  For example,
##    %!test error("this test fails!");
##    %!test "this test doesn't fail since it doesn't generate an error";
## When a test fails, you will see something like:
##      ***** test error('this test fails!')
##    !!!!! test failed
##    this test fails!
##
## Generally, to test if something works, you want to assert that it
## produces a correct value.  A real test might look something like
##    %!test
##    %! A = [1, 2, 3; 4, 5, 6]; B = [1; 2];
##    %! expect = [ A ; 2*A ];
##    %! get = kron (B, A);
##    %! if (any(size(expect) != size(get)))
##    %!    error ("wrong size: expected %d,%d but got %d,%d",
##    %!           size(expect), size(get));
##    %! elseif (any(any(expect!=get)))
##    %!    error ("didn't get what was expected.");
##    %! endif
## To make the process easier, use the assert function.  For example,
## with assert the previous test is reduced to:
##    %!test
##    %! A = [1, 2, 3; 4, 5, 6]; B = [1; 2];
##    %! assert (kron (B, A), [ A; 2*A ]);
## Assert can accept a tolerance so that you can compare results
## absolutely or relatively. For example, the following all succeed:
##    %!test assert (1+eps, 1, 2*eps)          # absolute error
##    %!test assert (100+100*eps, 100, -2*eps) # relative error
## You can also do the comparison yourself, but still have assert
## generate the error:
##    %!test assert (isempty([]))
##    %!test assert ([ 1,2; 3,4 ] > 0)
## Because assert is so frequently used alone in a test block, there
## is a shorthand form:
##    %!assert (...)
## which is equivalent to:
##    %!test assert (...)
##
## Each block is evaluated in its own function environment, which means
## that variables defined in one block are not automatically shared
## with other blocks.  If you do want to share variables, then you
## must declare them as shared before you use them.  For example, the
## following declares the variable A, gives it an initial value (default
## is empty), then uses it in several subsequent tests.
##    %!shared A
##    %! A = [1, 2, 3; 4, 5, 6];
##    %!assert (kron ([1; 2], A), [ A; 2*A ]);
##    %!assert (kron ([1, 2], A), [ A, 2*A ]);
##    %!assert (kron ([1,2; 3,4], A), [ A,2*A; 3*A,4*A ]);
## You can share several variables at the same time:
##    %!shared A, B
## Note that all previous variables and values are lost when a new 
## shared block is declared.
##
## In addition to testing if something works, you also want to test that
## it fails cleanly.  Error blocks help with this.  They are like test
## blocks, but they only succeed if the code generates an error.  You
## will see the error generated if verbose is set. For example,
##    %!error error('this test passes!');
## produces
##      ***** error error('this test passes!');
##      #####
##    this test passes!
## If the code doesn't generate an error, the test fails. For example,
##    %!error "this is an error because it succeeds.";
## produces
##      ***** error "this is an error because it succeeds.";
##    !!!!! test failed: no error
##
## It is important to automate the tests as much as possible, however
## some tests require user interaction.  These can be isolated into
## demo blocks, which if you are in batch mode, are only run when 
## called with 'demo' or 'verbose'.  The code is displayed before
## it is executed. For example,
##    %!demo
##    %! t=[0:0.01:2*pi]; x=sin(t);
##    %! plot(t,x);
##    %! ## you should now see a sine wave in your figure window
## produces
##    > t=[0:0.01:2*pi]; x=sin(t);
##    > plot(t,x);
##    > ## you should now see a sine wave in your figure window
##    Press <enter> to continue: 
## Note that demo blocks cannot use any shared variables.  This is so
## that they can be executed by themselves, ignoring all other tests.
##
## If you want to temporarily disable a test block, put '#' in place
## of the block type.  This creates a comment block which is echoed
## in the log file, but is not executed.  For example:
##    %!#demo
##    %! t=[0:0.01:2*pi]; x=sin(t);
##    %! plot(t,x);
##    %! ## you should now see a sine wave in your figure window
##
## Block type summary:
##    %!test   - test block; fails if error is generated within it
##    %!error  - error block; fails if error is not generated within it
##    %!demo   - demo block; only executes in interactive mode
##    %!#      - comment: ignore everything within the block
##    %!shared x,y,z - declares variables for use in multiple tests
##    %!assert (x, y, tol) - shorthand for %!test assert (x, y, tol)
##
## You can also create test scripts for builtins and your own C++
## functions. Just put a file of the function name on your path without
## any extension and it will be picked up by the test procedure.  You
## can even embed tests directly in your C++ code:
##    #if 0
##    %! disp('this is a test')
##    #endif
## or
##    /*
##    %! disp('this is a test')
##    */
## but then the code will have to be on the load path and the user 
## will have to remember to type test('name.cc').  Conversely, you
## can separate the tests from normal octave script files by putting
## them in plain files with no extension rather than in script files.
## Don't forget to tell emacs that the plain text file you are using
## is actually octave code, using something like:
##    ## -*-octave-*-
##
## See Also: error, assert, demo, example

## TODO: * Consider using keyword fail rather then error?  This allows us
## TODO: to make a functional form of error blocks, which means we
## TODO: can include them in test sections which means that we can use
## TODO: octave flow control for both kinds of tests.
## TODO: * Show pretty shared variable definitions if failure, which
## TODO: will help determine why things are failing when you abstract
## TODO: details of the test into shared variables; alternatively, use
## TODO: some sort of line number, but that sounds complicated to
## TODO: recover and won't help if we have multiple tests in the same
## TODO: block.

## PKG_ADD: mark_as_command test

function [__ret1, __ret2] = test (__name, __flag, __fid)
  if (nargin < 2 || isempty(__flag))
    __flag = 'normal';
  endif
  if (nargin < 3) 
    __fid = []; 
  endif
  if (nargin < 1 || nargin > 3 || !isstr(__name) || !isstr(__flag))
    usage("success = test('name', ['quiet'|'normal'|'verbose'], fid)");
  endif
  __batch = (!isempty(__fid));

  if (strcmp(__flag, "normal"))
    __grabdemo = 0;
    __rundemo = 0;
    __hide_error = 0;
    __verbose = __batch;
  elseif (strcmp(__flag, "quiet"))
    __grabdemo = 0;
    __rundemo = 0;
    __hide_error = 1;
    __verbose = 0;
  elseif (strcmp(__flag, "verbose"))
    __grabdemo = 0;
    __rundemo = 1;
    __hide_error = 0;
    __verbose = 1;
  elseif (strcmp(__flag, "grabdemo"))
    __grabdemo = 1;
    __rundemo = 0;
    __hide_error = 0;
    __verbose = 0;
    __demo_code = "";
    __demo_idx = 1;
  else
    error(["test unknown flag '", __flag, "'"]);
  endif

  ## information from test will be introduced by "key" 
  __signal_fail =  "!!!!! ";
  __signal_empty = "????? ";
  __signal_error = "  ##### ";
  __signal_block = "  ***** ";
  __signal_file =  ">>>>> ";

  ## decide if error messages should be collected
  if (__batch)
    fputs (__fid, [__signal_file, "processing ", __name, "\n" ]);
  else
    __fid = stdout;
  endif

  ## locate the file to test
  __file = file_in_loadpath (__name);
  if (isempty (__file)) 
    __file = file_in_loadpath ([__name, ".m"]);
  endif
  if (isempty (__file))
    __file = file_in_loadpath ([__name, ".cc"]);
  endif
  if (isempty (__file))
    if (__grabdemo)
      __ret1 = "";
      __ret2 = [];
    else
      fputs(__fid, [__signal_empty, __name, " does not exist in path\n" ]);
      if (nargout > 0) __ret1 = 0; endif
    endif
    return;
  endif

  ## grab the test code from the file
  __body = system([ "sed -n 's/^%!//p' '", __file, "'"]);
  if (isempty (__body))
    if (__grabdemo)
      __ret1 = "";
      __ret2 = [];
    else
      fputs(__fid, [ __signal_empty, __file, " has no tests available\n" ]);
      if (nargout > 0) __ret1 = 0; endif
    endif
    return;
  else
    ## assume it starts and ends with test blocks
    if (__body (length(__body)) == "\n")
      __body = [ "\ntest\n", __body, "test" ]; 
    else
      __body = [ "\ntest\n", __body, "\ntest" ]; 
    endif
  endif

  ## chop it up into blocks for evaluation
  __lineidx = find(__body == "\n");
  __blockidx = __lineidx(find(!isspace(__body(__lineidx+1))))+1;

  ## ready to start tests ... if in batch mode, tell us what is happening
  if (__verbose)
    disp ([ __signal_file, __file ]);
  endif

  ## assume all tests will pass
  __all_success = 1;

  ## process each block separately, initially with no shared variables
  __tests = __successes = 0;
  __shared = " ";
  __shared_r = " ";
  for __i=1:length(__blockidx)-1

    ## extract the block
    __block = __body(__blockidx(__i):__blockidx(__i+1)-2);

    ## let the user/logfile know what is happening
    if (__verbose)
      fputs (__fid, [__signal_block, __block, "\n"]);
    endif

    ## split __block into __type and __code
    __idx = find(!isletter(__block));
    if (isempty(__idx))
      __type = __block;
      __code = "";
    else
      __type = __block(1:__idx(1)-1);
      __code = __block(__idx(1):length(__block));
    endif

    ## assume the block will succeed;
    __success = 1;
    __msg = [];
    
    ## DEMO
    ## If in __grabdemo mode, then don't process any other block type.
    ## So that the other block types don't have to worry about
    ## this __grabdemo mode, the demo block processor grabs all block
    ## types and skips those which aren't demo blocks.
    __isdemo = strcmp (__type, "demo");
    if (__grabdemo || __isdemo)

      if (__grabdemo && __isdemo)
	if (isempty(__demo_code))
	  __demo_code = __code;
	  __demo_idx = [ 1, length(__demo_code)+1 ];
	else
	  __demo_code = strcat(__demo_code, __code);
	  __demo_idx = [ __demo_idx, length(__demo_code)+1 ];
	endif

      elseif (__rundemo && __isdemo)
      	try
	  ## process the code in an environment without variables
      	  eval(["function __test__()\n", __code, "\nendfunction"]);
	  __test__;
	  input("Press <enter> to continue: ","s");
      	catch
	  __success = 0;
	  __msg = [ __signal_fail, "demo failed\n", __error_text__];
      	end_try_catch
      	clear __test__;

      endif
      __code = ""; # code already processed
      
    ## SHARED
    elseif strcmp (__type, "shared")
      ## separate initialization code from variables
      __idx = find(__code == "\n");
      if (isempty(__idx))
	__vars = __code;
	__code = "";
      else
      	__vars = __code (1:__idx(1)-1);
      	__code = __code (__idx(1):length(__code));
      endif
      
      ## strip comments off the variables
      __idx = find(__vars=="%" | __vars == "#");
      if (!isempty(__idx))
	__vars = __vars(1:__idx(1)-1);
      endif
      
      ## assign default values to variables
      try
	__vars = deblank(__vars);
	if (!isempty(__vars))
	  eval([strrep(__vars,",","=[];"), "=[];"]);
	  __shared = __vars;
	  __shared_r = ["[ ", __vars, "] = "];
      	else
	  __shared = " ";
	  __shared_r = " ";
      	endif
      catch
	__code = "";  # couldn't declare, so don't initialize
	__success = 0;
	__msg = [ __signal_fail, "shared variable initialization failed\n"];
      end_try_catch
      
      ## initialization code will be evaluated below
    
    ## ASSERT
    elseif strcmp (__type, "assert")
      __code = __block; # put the assert keyword back on the code
      ## assert code will be evaluated below 
      
    ## ERROR
    elseif strcmp (__type, "error")
      try
      	eval(["function ", __shared_r, "__test__(", __shared, ")\n", ...
	      __code, "\nendfunction"]);
      catch
      	__success = 0;
      	__msg = [ __signal_fail, "test failed: syntax error\n", __error_text__];
      end_try_catch
      
      if (__success)
      	__success = 0;
      	__msg = [ __signal_fail, "test failed: no error\n" ];
      	try
	  eval([ __shared_r, "__test__(", __shared, ");"]);
      	catch
	  __success = 1;
	  if (__hide_error)
	    __msg = "";
	  else
	    __msg = [ __signal_error, "\n", __error_text__ ];
	    __idx = index(__msg, "error:");
	    if (__idx > 1) __msg = __msg(1:__idx-1); endif
	  endif
      	end_try_catch
      	clear __test__;
      endif
      __code = ""; # code already processed
      
    ## TEST
    elseif strcmp(__type, "test")
      ## code will be evaluated below
      
    ## comment block
    elseif strcmp (__block(1:1), "#")
      __code = ""; # skip the code

    else
    ## unknown block
      __success = 0;
      __msg = [ __signal_fail, "unknown test type!\n"];
      __code = ""; # skip the code
    endif

    ## evaluate code for test, shared, and assert.
    if (!isempty(__code))
      try
      	eval(["function ", __shared_r, "__test__(", __shared, ")\n", ...
	      __code, "\nendfunction"]);
	eval([__shared_r, "__test__(", __shared, ");"]);
      catch
	__success = 0;
	__msg = [ __signal_fail, "test failed\n", __error_text__];
	if isempty(__error_text__), 
	  error("empty error text, probably Ctrl-C --- aborting"); 
	endif
      end_try_catch
      clear __test__;
    endif
    
    ## All done.  Remember if we were successful and print any messages
    if (!isempty(__msg))
      ## make sure the user knows what caused the error
      if (!__verbose)
      	fputs (__fid, [__signal_block, __block, "\n"]);
      endif
      fputs (__fid, __msg);
      ## show the variable context
      if !strcmp(__type, "error") && !all(__shared==" ")
	fputs(__fid, "shared variables ");
	eval (["fdisp(__fid,tar(",__shared,"));"]); 
      endif
    endif
    if (__success == 0)
      __all_success = 0;
      	## stop after one error if not in batch mode
      if (!__batch)
    	if (nargout > 0) __ret1 = 0; endif
      	return;
      endif
    endif
    __tests++;
    __successes+=__success;
  endfor

  if (nargout == 0)
    printf("PASSES %d out of %d tests\n",__successes,__tests);
  elseif (__grabdemo)
    __ret1 = __demo_code;
    __ret2 = __demo_idx;
  elseif nargout == 1
    __ret1 = __all_success; 
  else
    __ret1 = __successes;
    __ret2 = __tests;
  endif
endfunction

### example from toeplitz
%!error toeplitz ([])
%!error toeplitz ([1,2],[])
%!error toeplitz ([1,2;3,4])
%!error toeplitz ([1,2],[1,2;3,4])
%!error toeplitz ([1,2;3,4],[1,2])
%!error toeplitz
%!error toeplitz (1, 2, 3)
%!test  assert (toeplitz ([1,2,3], [1,4]), [1,4; 2,1; 3,2]);
%!demo  toeplitz ([1,2,3,4],[1,5,6])

### example from kron
%!error kron
%!error kron(1,2,3)
%!test assert (isempty (kron ([], rand(3, 4))))
%!test assert (isempty (kron (rand (3, 4), [])))
%!test assert (isempty (kron ([], [])))
%!shared A, B
%!test
%! A = [1, 2, 3; 4, 5, 6]; 
%! B = [1, -1; 2, -2];
%!assert (size (kron (zeros (3, 0), A)), [ 3*rows (A), 0 ])
%!assert (size (kron (zeros (0, 3), A)), [ 0, 3*columns (A) ])
%!assert (size (kron (A, zeros (3, 0))), [ 3*rows (A), 0 ])
%!assert (size (kron (A, zeros (0, 3))), [ 0, 3*columns (A) ])
%!assert (kron (pi, e), pi*e)
%!assert (kron (pi, A), pi*A) 
%!assert (kron (A, e), e*A)
%!assert (kron ([1, 2, 3], A), [ A, 2*A, 3*A ])
%!assert (kron ([1; 2; 3], A), [ A; 2*A; 3*A ])
%!assert (kron ([1, 2; 3, 4], A), [ A, 2*A; 3*A, 4*A ])
%!test
%! res = [1,-1,2,-2,3,-3; 2,-2,4,-4,6,-6; 4,-4,5,-5,6,-6; 8,-8,10,-10,12,-12];
%! assert (kron (A, B), res)

### an extended demo from specgram
%!#demo 
%! ## Speech spectrogram
%! [x, Fs] = auload(file_in_loadpath("sample.wav")); # audio file
%! step = fix(5*Fs/1000);     # one spectral slice every 5 ms
%! window = fix(40*Fs/1000);  # 40 ms data window
%! fftn = 2^nextpow2(window); # next highest power of 2
%! [S, f, t] = specgram(x, fftn, Fs, window, window-step);
%! S = abs(S(2:fftn*4000/Fs,:)); # magnitude in range 0<f<=4000 Hz.
%! S = S/max(max(S));         # normalize magnitude so that max is 0 dB.
%! S = max(S, 10^(-40/10));   # clip below -40 dB.
%! S = min(S, 10^(-3/10));    # clip above -3 dB.
%! imagesc(flipud(20*log10(S)), 1);
%! % you should now see a spectrogram in the image window


### now test test itself

%!## usage and error testing
%!error  test                    # no args, generates usage()
%!error  test(1,2,3,4)           # too many args, generates usage()
%!error  test("test", 'bogus');  # incorrect args, generates error()
%!error  garbage                 # usage on nonexistent function should be

%!## test of shared variables
%!shared a                # create a shared variable
%!test   a=3;             # assign to a shared variable
%!test   assert(a,3)      # variable should equal 3    
%!shared b,c              # replace shared variables
%!test assert (!exist("a"));   # a no longer exists
%!test assert (isempty(b));    # variables start off empty
%!shared a,b,c            # recreate a shared variable
%!test assert (isempty(a));    # value is empty even if it had a previous value
%!test a=1; b=2; c=3;   # give values to all variables
%!test assert ([a,b,c],[1,2,3]); # test all of them together
%!test c=6;             # update a value
%!test assert([a, b, c],[1, 2, 6]); # show that the update sticks
%!shared                    # clear all shared variables
%!test assert(!exist("a"))  # show that they are cleared
%!shared a,b,c              # support for initializer shorthand
%! a=1; b=2; c=4;

%!## test of assert block
%!assert (isempty([]))      # support for test assert shorthand

%!## demo blocks
%!demo                   # multiline demo block
%! t=[0:0.01:2*pi]; x=sin(t);
%! plot(t,x);
%! % you should now see a sine wave in your figure window
%!demo a=3               # single line demo blocks work too

%!## this is a comment block. it can contain anything.
%!##
%! it is the "#" as the block type that makes it a comment
%! and it  stays as a comment even through continuation lines
%! which means that it works well with commenting out whole tests

%!## failure tests.  All the following should fail
%!test   error("---------Failure tests.  Use test('test','verbose',1)");
%!test   assert([a,b,c],[1,3,6]);   # variables have wrong values
%!bogus                     # unknown block type
%!error  toeplitz([1,2,3]); # correct usage
%!test   syntax errors)     # syntax errors fail properly
%!shared garbage in         # variables must be comma separated
%!error  syntax++error      # error test fails on syntax errors
%!error  "succeeds.";       # error test fails if code succeeds
%!demo   with syntax error  # syntax errors in demo fail properly
%!shared a,b,c              
%!demo                      # shared variables not available in demo
%! assert(exist("a"))
%!error  
%! test('/etc/passwd');
%! test("nonexistent file");
%! ## These don't signal an error, so the test for an error fails. Note 
%! ## that the call doesn't reference the current fid (it is unavailable),
%! ## so of course the informational message is not printed in the log.
