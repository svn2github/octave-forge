use strict;
use Test;
BEGIN {
           plan(tests => 73) ;
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

#
# test function calls
#

ok ( alleq( Inline::Octave::Matrix::zeros( 2,3 ),
            [ [0,0,0],[0,0,0] ])->as_scalar );
ok ( alleq( Inline::Octave::Matrix::ones( 2,3 ),
            [ [1,1,1],[1,1,1] ])->as_scalar );
ok ( alleq( Inline::Octave::Matrix::linspace( 1,3,5 )->transpose(),
            [ 1,1.5,2,2.5,3   ])->as_scalar );

#
# test methods
#
my $c= new Inline::Octave::Matrix(  3.1415/4 );


my %methods = (
    'abs' => 0.785375,
    'acos' => 0.667494636365011,
    'all' => 1,
    'angle' => 0,
    'any' => 1,
    'asin' => 0.903301690429886,
    'asinh' => 0.72120727202285,
    'atan' => 0.66575942361951,
    'atanh' => 1.05924571848258,
    'ceil' => 1,
    'conj' => 0.785375,
    'cos' => 0.70712315999226,
    'cosh' => 1.32458896823663,
    'cumprod' => 0.785375,
    'cumsum' => 0.785375,
    'diag' => 0.785375,
    'erf' => 0.733297320648467,
    'erfc' => 0.266702679351533,
    'exp' => 2.19322924750887,
    'eye' => 1,
    'finite' => 1,
    'fix' => 0,
    'floor' => 0,
    'gamma' => 1.18107044739768,
    'gammaln' => 0.166421186069287,
    'imag' => 0,
    'is_bool' => 0,
    'is_complex' => 0,
    'is_list' => 0,
    'is_matrix' => 1,
    'is_stream' => 0,
    'is_struct' => 0,
    'isalnum' => 0,
    'isalpha' => 0,
    'isascii' => 1,
    'iscell' => 0,
    'iscntrl' => 1,
    'isdigit' => 0,
    'isempty' => 0,
    'isfinite' => 1,
    'isieee' => 1,
    'isinf' => 0,
    'islogical' => 0,
    'isnan' => 0,
    'isnumeric' => 1,
    'isreal' => 1,
    'length' => 1,
    'lgamma' => 0.166421186069287,
    'log' => -0.241593968259026,
    'log10' => -0.104922927276004,
    'ones' => 1,
    'prod' => 0.785375,
    'real' => 0.785375,
    'round' => 1,
    'sign' => 1,
    'sin' => 0.707090402001441,
    'sinh' => 0.868640279272249,
    'size' => 1,
    'sqrt' => 0.88621385680884,
    'sum' => 0.785375,
    'sumsq' => 0.616813890625,
    'tan' => 0.999953674278156,
    'tanh' => 0.655781000825211,
    'zeros' => 0,
);

foreach my $meth (sort keys %methods) {
   my $s= $c->$meth;
   my $v1= $s->as_scalar;
   my $v2= $methods{$meth};
   ok ($v1,$v2);
}

#
# replacement methods
#
use Inline Octave => q{
function a=makea()
   a=zeros(4);
   a( [1,3] , :)= [ 1,2,3,4 ; 5,6,7,8 ];
   a( : , [2,4])= [ 2,4; 2,4; 2,4; 2,4 ];
   a( [1,4],[1,4])= [8,7;6,5];
endfunction
};

my $ao= makea();

my $an = Inline::Octave::Matrix::zeros(4);
$an->replace_rows( [1,3], [ [1,2,3,4],[5,6,7,8] ] );
$an->replace_cols( [2,4], [ [2,4],[2,4],[2,4],[2,4] ] );
$an->replace_matrix( [1,4], [1,4], [ [8,7],[6,5] ] );

ok ( alleq( $an, $ao ) ->as_scalar );
