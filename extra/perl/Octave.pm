###############################################################################
#
# Inline::Octave - 
#
# $Id$

package Inline::Octave;


$VERSION = '0.01';
require Inline;
@ISA = qw(Inline);
use Carp;
use IPC::Open2;
use vars qw( $inline_object );


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
#  print "BUILDING\n";
   my $o = shift;
   my $code = $o->{API}{code};

   {
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
   $inline_object = $o;
   
   my $obj = $o->{API}{location};
   open OCTAVE_OBJ, "< $obj" or croak "Can't open $obj for output\n$!";
   
   my $code;
   my %nargouts;
   while (<OCTAVE_OBJ>) {
      if(/\bfunction\s+(.*?=\s*\w*|\w*)\b/) {
         my $pat =$1;
         my $fnam= $1 if $pat =~ /(\w*)$/;
         my $nargout=0;
            $nargout= 1 if $pat =~ /^\w+\s*=/;
            $nargout= 1 if $pat =~ /^\[\s*\w+\s*\]\s*=/;
            $nargout= 2 if $pat =~ /^\[\s*\w+\s*,\s*\w+\s*]\s*=/;
            $nargout= 3 if $pat =~ /^\[\s*\w+\s*,\s*\w+\s*,\s*\w+\s*]\s*=/;
            $nargout= 4 if $pat =~ /^\[\s*\w+\s*,\s*\w+\s*,\s*\w+\s*,\s*\w+\s*]\s*=/;
         $nargouts{$fnam}=$nargout;
      }
      if (/^\s*##\s*Inline::Octave::(\w+)\s*\(nargout=(\d+)\)\s*=>\s*(\w*)/) {
          $o->bind_octave_function( $3, $1, $2 );
      }
      $code.=$_;
   }
   close OCTAVE_OBJ;
#  use Data::Dumper; print Dumper(\%nargouts);
   
   {
       $o->start_interpreter();
       print $o->interpret($code);
       my @def_funcs= $o->get_defined_functions();
       foreach my $funname (@def_funcs) {
          $o->bind_octave_function( $funname, $funname, $nargouts{$funname} );
       }
       @EXPORT= @def_funcs;
   }
   croak "Unable to load Octave module $obj:\n$@" if $@;
}


sub validate
{
# print "VALIDATING\n";
  my $o = shift;
  $o->_validate();
}

sub _validate
{
  my $o = shift;
  $o->{ILSM}->{INTERP} = "octave -qf "
     unless exists $o->{ILSM}->{INTERP};
  $o->{ILSM}->{MARKER} = "-9Ahv87uhBa8l_8Onq,zU9-"
     unless exists $o->{ILSM}->{MARKER};
}   

sub info
{
  print "INFO\n";
  my $o = shift;
  # Place holder
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
   my \$inargs;
   my \@vin;
   for (my \$i=0; \$i < \@_; \$i++) {
      \$vin[\$i]= new Inline::Octave::Matrix( \$_[\$i] );
      \$inargs.= \$vin[\$i]->name.",";
   }
   chop(\$inargs); #remove last ,

   #output variables
   my \$outargs;
   my \@vout;
   for (my \$i=0; \$i < \$nargout; \$i++) {
      \$vout[\$i]= new Inline::Octave::Matrix( -101101.101101 ); #code
      \$outargs.= \$vout[\$i]->name.",";
   }
   chop(\$outargs); #remove last ,
   \$outargs= "[".\$outargs."]=";
   \$outargs= "" if \$nargout==0;

   my \$call= "\$outargs $oct_funname(\$inargs);";
#  print "--\$call--\\n";
   my \$retval= \$Inline::Octave::inline_object->interpret( \$call );
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
}   

sub start_interpreter
{
   my $o = shift;

   my $Oout; my $Oin;
   eval {
      open2( $Oout, $Oin , $o->{ILSM}->{INTERP} );
   };
   croak "Can't locate octave interpreter: $@\n" if $@ =~ /Open2/i;

   $o->{ILSM}->{OCTIN} = $Oin;
   $o->{ILSM}->{OCTOUT} = $Oout;
}       

sub stop_interpreter
{
   my $o = shift;

   my $Oin= $o->{ILSM}->{OCTIN};
   my $Oout= $o->{ILSM}->{OCTOUT};

   return unless $Oin and $Oout;

   print $Oin "exit\n";
   <$Oin>; #clean up input
   close $Oin, $Oout;
   $o->{ILSM}->{OCTIN} = "";
   $o->{ILSM}->{OCTOUT} = "";
}   

# send a string to octave and get the result
sub interpret
{
   my $o = shift;
   my $cmd= shift;
   my $marker= $o->{ILSM}->{MARKER};

   my $Oin= $o->{ILSM}->{OCTIN};
   my $Oout= $o->{ILSM}->{OCTOUT};

   croak "octave interpreter not alive"  unless $Oin and $Oout;

   print $Oin "$cmd\ndisp('$marker');fflush(stdout);\n";

   my $input;
   my $marker_len= length( $marker )+1;
   while (1) {
      my $line; sysread $Oout, $line, 1024;
      $input.= $line;
      last if substr( $input, -$marker_len, -1) eq $marker;
   }   
   return substr($input,0,-$marker_len);
}   

sub get_defined_functions
{
   my $o = shift;
   my $data= $o->interpret("whos -functions");
   my @funclist;
   while ( $data =~ /user-defined function +- +- +(\w+)/g )
   {
      push @funclist, $1;
   }
   return @funclist;

}       

END {
   $inline_object->stop_interpreter() if $inline_object;
}

package Inline::Octave::Matrix;
use Carp;

$varcounter= 100001;
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
   croak "Matrix is not size ${cols}x${rows}" unless @vals== $rows*$cols;

   # pack data into doubles and use fread to grab it from octave
   # since octave is column major and nested lists in perl are
   # row major, we need to do the transpose.
   unless ($code) {
      $code= "$varname=fread(stdin,[$rows,$cols],'double')$do_transpose;\n".
             pack( "d".($rows*$cols) , @vals );
   }

   $Inline::Octave::inline_object->interpret( $code );
   $self->store_size();

   return $self;
}   

sub store_size
{
   my $self = shift;
   my $varname= $self->name;
   my $code = "disp([size($varname), is_complex($varname)] )";
   my $size=  $Inline::Octave::inline_object->interpret( $code );
   croak "Problem constructing Matrix" unless $size =~ /^ *(\d+) *(\d+) *[01]/;
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
   my $retval= $Inline::Octave::inline_object->interpret( $code );
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
   my $retval= $Inline::Octave::inline_object->interpret( $code );
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

sub DESTROY
{
#  print "DESTROYing $varname\n";
   my $self = shift;
   my $varname= $self->name;
   my $code = "clear $varname;";
   $Inline::Octave::inline_object->interpret( $code );
}   

sub disp
{
   my $self = shift;
   my $varname= $self->name;
   my $code = "disp( $varname );";
   return $Inline::Octave::inline_object->interpret( $code );
}   

sub name
{
   my $self = shift;
   return $self->{varname};
}   

1;


__END__

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
   
   
   __DATA__
   
   __Octave__
   function x=jnk1(u); x=u+1; endfunction
   
   function [b,t]=jnk2(x,a,b);
      b=x+1+a'*b;
      t=6;
   endfunction
   
   ## Inline::Octave::oct_sum (nargout=1)  => sum
   ## Inline::Octave::oct_plot (nargout=0)  => plot


=head1 DESCRIPTION

Inline::Octave gives you the power of the octave programming language from
within your Perl programs.

You need to install the Inline module from CPAN. This provides
the infrastructure to support all the Inline::* modules.
 
Then install Octave.pm in an Inline directory in any path in your @INC.
 
The easiest is to create a ./Inline directory in your
working directory, and put Octave.pm in that.
after that the example code should run.

Note, there is currently no proper Makefile.PL install facility
for Inline::Octave - this reflects it's maturity.
                   
It should work with stock octave - but I'd like to get feedback on this.
Basically, I create an octave process with controlled stdin and stdout.
Commands send by stdin. Data is send by stdin and read with
fread(stdin, [dimx dimy], "double"), and read similarly.
                   
Inline::Octave::Matrix variables in perl are tied to the octave
variable. When a destructor is called, it sends a "clear varname"
command to octave.
                   
I initially tried to bind the C++ and liboctave to perl, but
it started to get really hard - so I took this route.

=head1 Why would I use Inline::Octave

If you can't figure out a reason, don't!

I use it to grind through long logfiles (using perl),
and then calculate mathematical results (using octave).


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



=head1 Using Inline::Octave::Matrix

Inline::Octave::Matrix is the matrix class that "ties"
(but not using the Perl "tie" mechanism)

Values can be created explicitly, using the syntax:

   $var= new Inline::Octave::Matrix([ [1.5,2,3],[4.5,1,-1] ]);

or values will be automatically created by 
calling octave functions.


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



=head1 TODO List

   1. Add import for functions
   2. control matrix size inputs
   3. add destructor for Octave::Matrix
       - done
   4. control waiting in the interpret loop
       - seems ok, except sysread reads small buffers
   5. support for complex variables


