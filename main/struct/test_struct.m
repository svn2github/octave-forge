##       errors = test_struct
##
## Test whether struct functions behave, and returns the number of errors.
##   
## Sets the global variables test_struct_errors (number of errors)
##                     and   test_struct_cnt    (number of tests) 
##
## If a workspace variable 'verbose' is set to -1 the output is verbose. 
## If it is set to 1, output is minimal (error and test counts).
## Otherwise, each error is reported with a short message and the error and ...
## test counts are displayed at the end of the script (if it is reached).
##

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>

1 ;
global test_struct_errors  ;
global test_struct_cnt  ;
test_struct_verbose = test_struct_errors = test_struct_cnt = 0 ;

if ! exist ("verbose"), verbose = 0; end
if exist ("verbose") && ! isglobal ("verbose")
  tmp = verbose;
  global verbose = tmp;
end

function mytest( val, tag )	# My test function ###################

global test_struct_cnt ;
global test_struct_errors  ;
global verbose ;

% if ! exist("test_struct_verbose"), test_struct_verbose = 0 ; end

if val ,
  if verbose
    printf("OK %i\n",test_struct_cnt) ; 
  end
else
  if verbose 
    printf("NOT OK %-4i : %s\n",test_struct_cnt,tag) ;
  end
  test_struct_errors++ ;
end
test_struct_cnt++ ;
endfunction			# EOF my test function ###############




s.hello = 1 ;
s.world = 2 ;
mytest( isstruct(s)                   , "isstruct" ) ;
mytest( s.hello == getfields(s,"hello"), "getfields 1" ) ;
mytest( s.world == getfields(s,"world"), "getfields 2" ) ; 

t = struct ("hello",1,"world",2) ;
mytest( t.hello == s.hello            , "struct 1" ) ;
mytest( t.world == s.world            , "struct 2" ) ;

s.foo = "bar" ;
s.bye = "ciao" ;
t = setfields (t,"foo","bar","bye","ciao") ;
mytest( t.foo == s.foo                , "setfields 1" ) ;
mytest( t.bye == s.bye                , "setfields 2" ) ;

% s = struct() ;
t = rmfield (t,"foo","bye","hello") ;
mytest( ! struct_contains(t,"foo")    , "rmfield 1" ) ;
mytest( ! struct_contains(t,"bye")    , "rmfield 2" ) ;
mytest( ! struct_contains(t,"hello")  , "rmfield 3" ) ;
mytest( t.world ==  s.world           , "rmfield 4" ) ;


				# Test tar, getfield
x = 2 ; y = 3 ; z = "foo" ;
s = tar (x,y,z);

mytest( x == s.x                          , "tar 1" );
mytest( y == s.y                          , "tar 2" );
mytest( z == s.z                          , "tar 3" );

a = "x" ; b = "y" ; 
[xx,yy,zz] = getfields (s,a,b,"z") ;

mytest( x == xx                           , "getfields 1" );
mytest( y == yy                           , "getfields 2" );
mytest( z == zz                           , "getfields 3" );

[x3,z3,z4] = getfields (s,"x","z","z") ;
mytest( x == x3                           , "getfields 4" );
mytest( z == z3                           , "getfields 5" );
mytest( z == z4                           , "getfields 6" );

try				# Should not return inexistent fields
  [nothing] = getfields (s,"foo");
  found_nothing = 0;
catch
  found_nothing = 1;
end
mytest( found_nothing                     , "getfields 4" );


ok = test_struct_errors == 0;
if verbose
  if ok
    printf ("All %d tests ok\n", test_struct_cnt);
  else
    printf("There were %d errors in of %d tests\n",...
	   test_struct_errors,test_struct_cnt) ;
  end
end
