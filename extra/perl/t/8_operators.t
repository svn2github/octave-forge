use strict;
use Test;
BEGIN {
           plan(tests => 5) ;
}

         

use Inline Octave => q{
   function t=alleq(a,b); t= all(all(a==b)); endfunction
};   


my $a= new Inline::Octave::Matrix([ [1,2,3],[4,5,6] ]);
my $b= new Inline::Octave::Matrix([ [1,1,1],[2,2,2] ]);

ok ( alleq( $a + $b
          , [ [2,3,4],[6,7,8] ])->as_scalar );
ok ( alleq( $a - $b
          , [ [0,1,2],[2,3,4] ])->as_scalar );
ok ( alleq( $a * $b
          , [ [1,2,3],[8,10,12] ])->as_scalar );
ok ( alleq( $a / $b
          , [ [1,2,3],[2,2.5,3] ])->as_scalar );
ok ( alleq( $a x $b->transpose
          , [ [6,12],[15,30] ])->as_scalar );
