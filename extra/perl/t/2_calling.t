use strict;
use Test;
 
BEGIN {
           plan(tests => 1) ;
}
         
use Inline Octave => q{
   function x=jnk1(u); x=u+1; endfunction
};   

my $v= jnk1(3)->disp();
chomp ($v);
ok( $v, "4" );
