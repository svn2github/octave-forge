use strict;
use Test;
 
BEGIN {
           plan(tests => 3) ;
}
         
use Inline Octave => q{
   function x=jnk1(u); x=u+1; endfunction
   function x=jnk2(u); x=inv(u); endfunction
   function x=jnk3(u); x=toascii(u); endfunction
};   

my $v= jnk1(3)->disp();
chomp ($v);
ok( $v, "4" );


# jnk2 gives warning if u=0
do {
  local $SIG{__WARN__} = sub {
     my $ok = ($_[0] =~ /inverse: matrix singular/);
     ok( $ok, 1);
  };

  $v= jnk2(0)->disp();
};

# jnk3 gives error for u real
eval {
   jnk3(0);
};

my $ok = ($@ =~ /toascii/);
ok( $ok, 1);
