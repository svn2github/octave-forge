###############################################################################
#
# Inline::Octave - 
#
# $Id$

package Inline::Octave;


$VERSION = '0.15';
require Inline;
@ISA = qw(Inline);
use Carp;
use IPC::Open2;
use vars qw( $octave_object );

# set values which should change to this,
# if it doesn't change, we have an error.
my $retcode_string= "[-101101.101101,-918273.6455,-178.9245867]";
my $retcode_value=   [-101101.101101,-918273.6455,-178.9245867];

sub register {
#  print "REGISTERING\n";
   return {
           language    => 'Octave',
           aliases     => ['octave'],
           type        => 'interpreted',
           suffix      => 'm',
          };
}


sub build {
   my $o = shift;
   $o->_build (@_ );
}

sub _build {
#  print "BUILDING\n";
   my $o = shift;
   my $code = $o->{API}{code};

   # we don't really need to validate the code here
   # since that gets done in load anyway
   #
   # Also, stopping the interpreter will make any
   # functions defined in a previous section disappear
   if (0) {
      $o->start_interpreter();
      print $o->interpret($code);
      my @def_funcs= $o->get_defined_functions();
      $o->stop_interpreter();
   }

   croak "Octave build failed:\n$@" if $@;
   my $path = "$o->{API}{install_lib}/auto/$o->{API}{modpname}";
   my $obj = $o->{API}{location};
   $o->mkpath($path) unless -d $path;
   open PERL_OBJ, "> $obj" or croak "Can't open $obj for output\n$!";
   print PERL_OBJ $code;
   close \*PERL_OBJ;
}



sub load {
#  print "LOADING\n";
   my $o = shift;
   $o->_validate();
   
   my $obj = $o->{API}{location};
   open OCTAVE_OBJ, "< $obj" or croak "Can't open $obj for output\n$!";
   
   my $code;
   my %nargouts;
   while (<OCTAVE_OBJ>) {
      if(/\bfunction\s+(.*?=\s*\w*|\w*)\b/) {
         my $pat =$1;
         my $fnam= $1 if $pat =~ /(\w*)$/;
         #TODO make this better - ie loop
         my $nargout=0;
            $nargout= 1 if $pat =~ /^\w+\s*=/;

         if ($pat =~ /^\[([\s\w,]+)\]\s*=/ ) {
            my @fnpat = split /,/, $1;
            foreach (@fnpat) {
               $nargout++ if /^\s*\w+\s*$/;
            }
         }

         $nargouts{$fnam}=$nargout;
      }
      if (/^\s*##\s*Inline::Octave::(\w+)\s*\(nargout=(\d+)\)\s*=>\s*(\w*)/) {
          $o->bind_octave_function( $3, $1, $2 );
      }
      $code.=$_;
   }
   close OCTAVE_OBJ;
#  use Data::Dumper; print Dumper(\%nargouts);
   
   $o->start_interpreter();

   print $o->interpret($code);
   my @def_funcs= $o->get_defined_functions();
   foreach my $funname (@def_funcs) {
      next if defined $octave_object->{FUNCS}->{$funname};
      $o->bind_octave_function( $funname, $funname, $nargouts{$funname} );
   }

   return;
}


sub validate
{
# print "VALIDATING\n";
  my $o = shift;
  $o->_validate( @_ );
}

sub _validate
{
  my $o = shift;

  my $switches= "-qfH";
  my $octave_interpreter_bin;

  $octave_interpreter_bin= 'octave' # _EDITLINE_MARKER_
     unless $octave_object->{INTERP};

  $octave_interpreter_bin = $ENV{PERL_INLINE_OCTAVE_BIN}
     if $ENV{PERL_INLINE_OCTAVE_BIN};

  $octave_object->{INTERP} = "$octave_interpreter_bin $switches " 
     unless $octave_object->{INTERP};

  while (@_) {
     my ($key, $value) = (shift, shift) ;
     if ($key eq 'OCTAVE_BIN'){
        $octave_object->{INTERP} = "$value $switches ";
     } 
#    print "$key--->$value\n";
  }


  $octave_object->{MARKER} = "-9Ahv87uhBa8l_8Onq,zU9-"
     unless exists $octave_object->{MARKER};
}   

sub info
{
#  print "INFO\n";
   my $o = shift;
}


# here we write code to bind to an octave function and eval this
# into the callers namespace
#
# $o->bind_octave_function( octave_funcname, perl_funcname, nargout )
# 
# we need to specify the nargout, because we can't infer
# it from perl (other than scalar or list context)
#
# now, when perl6 comes out ...
#
sub bind_octave_function
{
   my $o= shift;
   my $oct_funname = shift;
   my $perl_funname = shift;
   my $nargout = shift;
   my $pkg= $o->{API}->{pkg};
   my $code = <<CODE;
package $pkg;
sub $perl_funname {
   # we need to prevent IOM variables from going out of scope
   # in the loop, but rather at the end of the function
   
   #input variables
   my \$inargs=" ";
   my \@vin;
   for (my \$i=0; \$i < \@_; \$i++) {
      \$vin[\$i]= new Inline::Octave::Matrix( \$_[\$i] );
      \$inargs.= \$vin[\$i]->name.",";
   }
   chop(\$inargs); #remove last ,

   #output variables
   my \$outargs=" ";
   my \@vout;
   for (my \$i=0; \$i < $nargout; \$i++) {
      \$vout[\$i]= new Inline::Octave::Matrix( $retcode_string );
      \$outargs.= \$vout[\$i]->name.",";
   }
   chop(\$outargs); #remove last ,
   \$outargs= "[".\$outargs."]=";
   \$outargs= "" if $nargout==0;

   my \$call= "\$outargs $oct_funname(\$inargs);";
#  print "--\$call--\\n";
   my \$retval= Inline::Octave::interpret(0, \$call );
#  print "--\$retval--\\n";

   # Get the correct size for each new variable
   foreach (\@vout) { \$_->store_size(); }

   return \@vout if wantarray();
   return \$vout[0];
}
CODE
#  print "--$code--\n";
   eval $code;
   croak "Problem binding $oct_funname to $perl_funname: $@" if $@;

   $octave_object->{FUNCS}->{$oct_funname}= $perl_funname;
   return;
}   

sub start_interpreter
{
   my $o = shift;

   # check if interpreter already alive
   return if $octave_object->{OCTIN} and $octave_object->{OCTOUT};

   my $Oout; my $Oin;
   my $pid;
   eval {
# This works in perl 5.6
#     open2( $Oout, $Oin , $octave_object->{INTERP} ); 
# But we need to do this in 5.005     
      $pid= open2( \*OOUT, \*OIN , $octave_object->{INTERP} );
      $Oout= \*OOUT; $Oin= \*OIN;
   };
   croak "Can't locate octave interpreter: $@\n" if $@ =~ /Open2/i;

#  $SIG{CHLD}= \&reap_interpreter;
#  $SIG{PIPE}= \&reap_interpreter;

   $octave_object->{octave_pid} = $pid;
   $octave_object->{OCTIN} = $Oin;
   $octave_object->{OCTOUT} = $Oout;

   # some of this is necessary, some are the defaults
   # but it never hurts to be cautious
   my $startup_code= <<STARTUP_CODE;
crash_dumps_octave_core=0;
page_screen_output=0;
silent_functions=1;
do_fortran_indexing=1; 
page_screen_output=0;
page_output_immediately=1;
STARTUP_CODE

   $o->interpret( $startup_code ); # check return value?

   return;
}

sub reap_interpreter
{
#  print "REAP_INTERPRETER\n";
   my $o= $octave_object;
   my $pid= $octave_object->{octave_pid};
   return unless $pid;

   waitpid $pid,0;
   $octave_object->{OCTIN} = "";
   $octave_object->{OCTOUT} = "";
   $octave_object->{octave_pid} = "";
   return;
}   

sub stop_interpreter
{
   my $o = shift;

   my $Oin= $octave_object->{OCTIN};
   my $Oout= $octave_object->{OCTOUT};

   return unless $Oin and $Oout;

   print $Oin "\n\nexit\n";
   #<$Oin>; #clean up input - is this required?
   close $Oin;
   close $Oout;
   $octave_object->{OCTIN} = "";
   $octave_object->{OCTOUT} = "";
   $octave_object->{octave_pid} = "";
   return;
}   

# send a string to octave and get the result
sub interpret
{
   my $o = shift;
   my $cmd= shift;
   my $marker= $octave_object->{MARKER};

   my $Oin= $octave_object->{OCTIN};
   my $Oout= $octave_object->{OCTOUT};

   croak "octave interpreter not alive"  unless $Oin and $Oout;

#  print "INTERP: $cmd\n";

   print $Oin "\n\n$cmd\ndisp('$marker');fflush(stdout);\n";

   my $input;
   my $marker_len= length( $marker )+1;
   while (1) {
      my $line; sysread $Oout, $line, 1024;
      $input.= $line;
      last if substr( $input, -$marker_len, -1) eq $marker;
   }   

   # we need to leave octave blocked doing something,
   # otherwise it can't handle a CTRL-C
   print $Oin "\n\nfread(stdin,1);\n";
   return substr($input,0,-$marker_len);
}   

sub get_defined_functions
{
   my $o = shift;
   my $data= $o->interpret("whos -functions");
   my @funclist;
   while ( $data =~ /user(-defined|) function +- +- +(\w+)/g )
   {
      push @funclist, $2;
   }
   return @funclist;

}       

END {
#  print "ENDING\n";
   Inline::Octave::stop_interpreter() if $octave_object;
}

package Inline::Octave::Matrix;
use Carp;

$varcounter= 10000001;
# called as
# new IOM( [1,2,3] ) -> ColumnVector
# new IOM( [[1,2],[2,3],[3,4]] ) -> Matrix
# new IOM( [1,2,3,4], 2, 2) -> Matrix, rows, cols

sub new
{
   my $class = shift;
   my ($m, $rows, $cols) = @_;
   my $self = {};
   bless ($self, $class);

   my $varname= "vname_".$varcounter++;
   $self->{varname}= $varname;

   my @vals;
   my $do_transpose= '';
   my $code;

   if    (ref $m      eq "Inline::Octave::Matrix") {
      my $prev_varname= $m->{varname};
      $code= "$varname= $prev_varname;";
   }
   elsif (ref $m      eq "ARRAY" and
          ref $m->[0] eq "ARRAY" ) {
      # 2 dimentional array -  ensure all rows are equal size;
      @vals= map {   if ($cols) {
                 croak "specified cols is length ${@$_} not $cols"
                    unless $cols== @$_;
              } else {
                 $cols = @$_;
              };
              @$_ } @$m;
      $rows= @$m unless defined $rows;
      $do_transpose= q(');
      ($rows,$cols)= ($cols,$rows);
   }
   elsif (ref $m eq "ARRAY" ) {
      # 1 dimentional array;
      $rows= @$m unless defined $rows;
      $cols= 1 unless defined $cols;
      @vals= @{$m};
   }
   elsif (ref $m eq "" ) {
      $rows= 1 unless defined $rows;
      $cols= 1 unless defined $cols;
      @vals = ($m);
   } else {
      croak "Can't construct Matrix from Perl var of type:".ref($m);
   }
   croak "Matrix is not size ${cols}x${rows}" unless
                (ref $m eq "Inline::Octave::Matrix")
                || (@vals == $rows*$cols) ;

   # pack data into doubles and use fread to grab it from octave
   # since octave is column major and nested lists in perl are
   # row major, we need to do the transpose.
   unless ($code) {
      $code= "$varname=fread(stdin,[$rows,$cols],'double')$do_transpose;\n".
             pack( "d".($rows*$cols) , @vals );
   }

   Inline::Octave::interpret(0, $code );
   $self->store_size();

   return $self;
}   

sub store_size
{
   my $self = shift;
   my $varname= $self->name;
   my $code = "disp([size($varname), is_complex($varname)] )";
   my $size=  Inline::Octave::interpret(0, $code );
   croak "Problem constructing Matrix" unless $size =~ /^ +(\d+) +(\d+) +([01])/;
   $self->{rows}= $1;
   $self->{cols}= $2;
   $self->{complex}= $3;
}             

sub as_list
{
   my $self = shift;
   my $varname= $self->name;
   croak "Can't handle complex" if $self->{complex};
   my $code = "fwrite(stdout, $varname,'double');";
   my $retval= Inline::Octave::interpret(0, $code );
   my $size= $self->{cols} * $self->{rows};
   my @list= unpack "d$size", $retval;
   return @list;
}

sub as_matrix
{
   my $self = shift;
   my $varname= $self->name;
   croak "Can't handle complex" if $self->{complex};
   my $code = "fwrite(stdout, $varname','double');"; # use transpose
   my $retval= Inline::Octave::interpret(0, $code );
   my $size= $self->{cols} * $self->{rows};
   my @list= unpack "d$size", $retval;
   my @m;
   my $cols= $self->{cols};
   my $rows= $self->{rows};
   for (0..$rows-1) {
      push @m, [ (@list)[$_*$cols .. ($_+1)*$cols-1] ];
   }
   return \@m;
}

sub as_scalar
{
   my $self = shift;
   my $varname= $self->name;
   croak "Can't handle complex" if $self->{complex};
   croak "requested as_scalar for non scalar value:".
           $self->{cols}."x".$self->{rows}
           unless $self->{cols} == 1 && $self->{rows} == 1;
   my $code = "fwrite(stdout, $varname,'double');";
   my $retval= Inline::Octave::interpret(0, $code );
   my @list= unpack "d1", $retval;
   return $list[0];
}   

sub DESTROY
{
#  print "DESTROYing $varname\n";
   my $self = shift;
   my $varname= $self->name;
   my $code = "clear $varname;";
   Inline::Octave::interpret(0, $code );
}   

sub disp
{
   my $self = shift;
   my $varname= $self->name;
   my $code = "disp( $varname );";
   return Inline::Octave::interpret(0, $code );
}   

sub name
{
   my $self = shift;
   return $self->{varname};
}   


#
# Define arithmetic on IOMs 
#
use overload 
    '+' => sub { oct_matrix_arithmetic( @_, '+',  ) },
    '-' => sub { oct_matrix_arithmetic( @_, '-',  ) },
    '*' => sub { oct_matrix_arithmetic( @_, '.*', ) },
    '/' => sub { oct_matrix_arithmetic( @_, './', ) },
    'x' => sub { oct_matrix_arithmetic( @_, '*',  ) };

sub oct_matrix_arithmetic
{
   my $a= new Inline::Octave::Matrix( shift );
   my $b= new Inline::Octave::Matrix( shift );
   ($b,$a)= ($a,$b) if shift;
   my $op= shift;

   my $v= new Inline::Octave::Matrix( $retcode_value );

   my $code= $v->name."=". $a->name ." $op ". $b->name .';';
   run_math_code( $code, $v);
   return $v;
}   

sub transpose
{
   my $a= new Inline::Octave::Matrix( shift );
   my $v= new Inline::Octave::Matrix( $retcode_value );
   my $code= $v->name."=". $a->name.".';";
   run_math_code( $code, $v);
   return $v;
}  

#
# create methods for the various math functions
#
{
   my %methods= (
      abs           => 1, acos          => 1, acosh         => 1,
      all           => 1, angle         => 1, any           => 1,
      asin          => 1, asinh         => 1, atan          => 1,
      atan2         => 1, atanh         => 1, ceil          => 1,
      conj          => 1, cos           => 1, cosh          => 1,
      cumprod       => 1, cumsum        => 1, diag          => 1,
      erf           => 1, erfc          => 1, exp           => 1,
      eye           => 1, finite        => 1, fix           => 1,
      floor         => 1, gamma         => 1, gammaln       => 1,
      imag          => 1, is_bool       => 1, is_complex    => 1,
      is_global     => 1, is_list       => 1, is_matrix     => 1,
      is_stream     => 1, is_struct     => 1, isalnum       => 1,
      isalpha       => 1, isascii       => 1, iscell        => 1,
      iscntrl       => 1, isdigit       => 1, isempty       => 1,
      isfinite      => 1, isieee        => 1, isinf         => 1,
      islogical     => 1, isnan         => 1, isnumeric     => 1,
      isreal        => 1, length        => 1, lgamma        => 1,
      linspace      => 2, log           => 1, log10         => 1,
      ones          => 1, prod          => 1, real          => 1,
      round         => 1, sign          => 1, sin           => 1,
      sinh          => 1, size          => 2, sqrt          => 1,
      sum           => 1, sumsq         => 1, tan           => 1,
      tanh          => 1, zeros         => 1,
   );

   for my $meth ( keys %methods ) {
      no strict 'refs';
      my $nargout= $methods{$meth};
      *$meth = sub {
         my $code= "[";

         my @v;
         foreach (1..$nargout) {
            my $v= new Inline::Octave::Matrix( $retcode_value );
            $code.= $v->name.",";
            push @v,$v;
         }
         chop ($code); #remove last ','
         $code.= "]= $meth (";

         my @a;
         foreach (@_) {
            my $a= new Inline::Octave::Matrix( $_ );
            $code.= $a->name.",";
            push @a, $a;
         }
         chop ($code); #remove last ','
         $code.= ");";

         run_math_code( $code, @v);
         return @v if wantarray();
         return $v[0];
      }
   }
}

# run_math_code ( $code, $val1, $val2 ... )
# dies on error, no return
sub run_math_code
{
   my $code= shift;
   my @v   = @_;
   my $vname= $v[0]->name;

   $runcode= "$code  disp (size($vname)==[3,1] && ".
             " all($vname==$retcode_string') );\n";
   my $retval= Inline::Octave::interpret(0, $runcode );

   if ($retval == 0) {
      foreach my $v (@v) {
         $v->store_size();
      }
   } else {
      croak "Error performing operation $code";
   }
}      

1;


__END__

TODO LIST:

   1. Add import for functions
   2. control matrix size inputs
   3. add destructor for Octave::Matrix
       - done
   4. control waiting in the interpret loop
       - seems ok, except sysread reads small buffers
   5. support for complex variables
   6. octave gets wierd when you CTRL-C out of a 
       running program
       - seems ok
   7. Use parse-recdecent to parse octave code
   8. Come up with an OO way to avoid
       Inline::Octave::interpret(0, $code );

$Log$
Revision 1.11  2001/11/21 03:20:54  aadler
fixed make bug, added method support for IOMs

Revision 1.10  2001/11/20 02:38:05  aadler
fix for select octave path in Makefile.PL

Revision 1.8  2001/11/18 03:29:06  aadler
bug in fread fix - add \n

Revision 1.7  2001/11/18 03:22:42  aadler
multisections now ok, cleaned up singleton object,
octave no longer freaks out on ctrl-c

Revision 1.6  2001/11/17 02:15:21  aadler
changed docs, new options for Makefile.PL

Revision 1.5  2001/11/11 03:36:31  aadler
mod to work with octave-2.0 as well as 2.1

Revision 1.4  2001/11/11 03:00:54  aadler
added makefile and tests
added as_scalar method


=head1 NAME

Inline::Octave - Inline octave code into your perl


=head1 SYNOPSIS

   use Inline Octave => DATA;
   
   $f = jnk1(3);
   print "jnk1=",$f->disp(),"\n";

   $c= new Inline::Octave::Matrix([ [1.5,2,3],[4.5,1,-1] ]);
   
   ($b, $t)= jnk2( $c, [4,4],[5,6] );
   print "t=",$t->as_list(),"\n";
   use Data::Dumper; print Dumper( $b->as_matrix() );
   
   print oct_sum( [1,2,3] )->disp();

   oct_plot( [0..4], [3,2,1,2,3] );
   sleep(2);

   my $d= (2*$c) x $c->transpose;
   print $d->disp;
   
   
   __DATA__
   
   __Octave__
   function x=jnk1(u); x=u+1; endfunction
   
   function [b,t]=jnk2(x,a,b);
      b=x+1+a'*b;
      t=6;
   endfunction
   
   ## Inline::Octave::oct_sum (nargout=1)  => sum
   ## Inline::Octave::oct_plot (nargout=0)  => plot

=head1   WARNING

THIS IS ALPHA SOFTWARE. It is incomplete and possibly unreliable.  It is
also possible that some elements of the interface (API) will change in
future releases. 

=head1 DESCRIPTION

Inline::Octave gives you the power of the octave programming language from
within your Perl programs.

Basically, I create an octave process with controlled stdin and stdout.
Commands send by stdin. Data is send by stdin and read with
fread(stdin, [dimx dimy], "double"), and read similarly.
                   
Inline::Octave::Matrix variables in perl are tied to the octave
variable. When a destructor is called, it sends a "clear varname"
command to octave.
                   
I initially tried to bind the C++ and liboctave to perl, but
it started to get really hard - so I took this route.
I'm planning to get back to that eventually ...

=head1 INSTALLATION

=head2 Requirements

  perl 5.005  or newer
  Inline-0.40 or newer
  octave 2.0  or newer

=head2 Platforms

  I've succeded in getting this to work on win2k (activeperl), 
  and linux (Mandrake 8.0, Redhat 6.2, Debian 2.0). Please
  send me tales of success or failure on other platforms

=head2 Install Proceedure  

You need to install the Inline module from CPAN. This provides
the infrastructure to support all the Inline::* modules.

Then:
   
   perl Makefile.PL
   make 
   make test
   make install

This will search for an octave interpreter and give you
the choice of giving the path to GNU Octave.

If you don't want this interactivity, then specify

   perl Makefile.PL OCTAVE=/path/to/octave
      or
   perl Makefile.PL OCTAVE='/path/to/octave -my -special -switches'

The path to the octave interpreter can be set in the following
ways:

   - set OCTAVE_BIN option in the use line

      use Inline Octave => DATA => OCTAVE_BIN => /path/to/octave

   - set the PERL_INLINE_OCTAVE_BIN environment variable
 
=head1 Why would I use Inline::Octave

If you can't figure out a reason, don't!

I use it to grind through long logfiles (using perl),
and then calculate mathematical results (using octave).

Why not use PDL?

   1) Because there's lots of existing code in Octave/Matlab.
   2) Because there's functionality in Octave that's not in PDL.
   3) Because there's more than one way to do it.

=head1 Using Inline::Octave

The most basic form for using Inline is:
  
   use Inline Octave => "octave source code";
             
The source code can be specified using any of the following syntaxes:

   use Inline Octave => 'DATA';
   ...perl...                                                                    
   __DATA__
   __Octave__
   ...octave...

or,

   use Inline Octave => <<'ENDOCTAVE';
   ...octave...
   ENDOCTAVE
   ...perl...

or,

   use Inline Octave => q{
   ...octave...
   };
   ...perl...

=head2 Defining Functions

Inline::Octave lets you:

1) Talk to octave functions using the syntax

   ## Inline::Octave::oct_plot (nargout=0)  => plot

Here oct_plot in perl is bound to plot in octave.
It is necessary to specify the nargouts required
because we can't get this information from perl.
(although it's promised in perl6)

If you need to use various nargouts for a function,
then bind different functions to it:

   ## Inline::Octave::eig1 (nargout=1)  => eig
   ## Inline::Octave::eig2 (nargout=2)  => eig

2) Write new octave functions,    

      function s=add(a,b);
         s=a+b;
      endfunction

will create a new function add in perl bound
to this new function in octave.

=head2 Calling Functions

A function is called using

   (list of Inline::Octave::Matrix) =
      function_name (list of Inline::Octave::Matrix)

Parameters which are not Inline::Octave::Matrix 
variables will be cast (if possible).

Values returned will need to be converted
into perl values if they need to be used within the
perl code. This can be accomplished using:

1. $oct_var->disp()

Returns a string of the disp output from octave

2. $oct_var->as_list()

Returns a perl list, corresponding to the
ColumnVector for octave "oct_var(:)"

3. $oct_var->as_matrix()

Returns a perl list of list, of the
form

   $var= [ [1,2,3],[4,5,6],[7,8,9] ];


4. $oct_var->as_scalar()

Returns a perl scalar if $oct_var
is a 1x1 matrix, dies with an error otherwise

=head1 Using Inline::Octave::Matrix

Inline::Octave::Matrix is the matrix class that "ties"
(but not using the Perl "tie" mechanism)

Values can be created explicitly, using the syntax:

   $var= new Inline::Octave::Matrix([ [1.5,2,3],[4.5,1,-1] ]);

or values will be automatically created by 
calling octave functions.

=head1 Operations on Inline::Octave::Matrix -es

Many math operations have been overloaded to
work directly on Inline::Octave::Matrix values;

For example, given $var above, we can calculate:

   $v1= ( $var x $var->transpose );
   $v2=  2*$var + 1
   $v3=  $var x [ [1],[2] ];

The relation between Perl and Octave operators is:   

      '+' => '+',
      '-' => '-',
      '*' => '.*',
      '/' => './',
      'x' => '*',

=head1 Methods on Inline::Octave::Matrix -es

Methods can be called on Inline::Octave::Matrix
variables, and the underlying octave function is called.

   my $b= new Inline::Octave::Matrix( 1 );
   $s= 4 * ($b->atan());
   print $s->as_scalar;

Is a labourious way to calculate PI.

The following methods are available, the corresponding
number is the output args available (nargout).

      abs       => 1    acos      => 1    acosh      => 1
      all       => 1    angle     => 1    any        => 1
      asin      => 1    asinh     => 1    atan       => 1
      atan2     => 1    atanh     => 1    ceil       => 1
      conj      => 1    cos       => 1    cosh       => 1
      cumprod   => 1    cumsum    => 1    diag       => 1
      erf       => 1    erfc      => 1    exp        => 1
      eye       => 1    finite    => 1    fix        => 1
      floor     => 1    gamma     => 1    gammaln    => 1
      imag      => 1    is_bool   => 1    is_complex => 1
      is_global => 1    is_list   => 1    is_matrix  => 1
      is_stream => 1    is_struct => 1    isalnum    => 1
      isalpha   => 1    isascii   => 1    iscell     => 1
      iscntrl   => 1    isdigit   => 1    isempty    => 1
      isfinite  => 1    isieee    => 1    isinf      => 1
      islogical => 1    isnan     => 1    isnumeric  => 1
      isreal    => 1    length    => 1    lgamma     => 1
      linspace  => 2    log       => 1    log10      => 1
      ones      => 1    prod      => 1    real       => 1
      round     => 1    sign      => 1    sin        => 1
      sinh      => 1    size      => 2    sqrt       => 1
      sum       => 1    sumsq     => 1    tan        => 1
      tanh      => 1    zeros     => 1

=head1 PERFORMANCE

Performance should be almost as good as octave alone.
The only slowdown is passing large variables across the
pipe between perl and octave - but this should be much
faster than any actual computations.

By using the strengths of both languages, it should be
possible to run faster than in each. (ie using octave
for matrix operations, and running loops and text
stuff in perl)


=head1 AUTHOR

Andy Adler andy@analyti.ca


=head1 COPYRIGHT

© MMI, Andy Adler

All Rights Reserved. This module is free software. It may be used,
redistributed and/or modified under the same terms as Perl itself.



