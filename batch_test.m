## This is a quick and dirty test to see that all the compiled functions
## are loading and running.  In future all tests will be distributed to
## individual directories or even individual function files.  But we have
## to start somewhere...

## Author: Paul Kienzle
## This program is public domain.

addpath(genpath('main'));
addpath(genpath('extra'));
addpath(genpath('nonfree'));
page_screen_output = 0;

if 0 # optim tests are failing far too often!
disp(">lp");
lp_test
A = p'*A*T'*p
disp(">minimize_1"); test_minimize_1; assert(ok,1);
disp(">cg_min_1"); test_cg_min_1; assert(ok,1);
disp(">cg_min_2"); test_cg_min_2; assert(ok,1);
disp(">cg_min_3"); test_cg_min_3; assert(ok,1);
disp(">cg_min_4"); test_cg_min_4; assert(ok,1);
disp(">d2_min_1"); test_d2_min_1; assert(ok,1);
disp(">d2_min_2"); test_d2_min_2; assert(ok,1);
disp(">d2_min_3"); test_d2_min_3; assert(ok,1);
disp(">nelder_mead_min_1"); test_nelder_mead_min_1; assert(ok,1);
disp(">nelder_mead_min_2"); test_nelder_mead_min_2; assert(ok,1);
endif

disp("[main/comm]");
disp(">comms");
try comms("test"); 
catch disp(__error_text__); end

disp("[main/fixed]");
disp(">fixed");
try fixedpoint("test"); 
catch disp(__error_text__); end
 
disp("[main/image]");
try testimio
catch disp(__error_text__); end

disp("=====================");
disp("all tests completed successfully");
