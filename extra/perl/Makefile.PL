use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

#
#   Find the octave interpreter
#

$octave= "octave";
$octave_validated= 0;
while (not $octave_validated) {
   $octave_validated= 1 if `$octave -v` =~ /Octave, version 2/;

   if ($octave_validated) {
      print "Found octave interpreter:[$octave]\n";
      print "Enter new path or <RETURN> to accept: ";
   } else {
      print "Unable to find octave interpreter at:[$octave]\n";
      print "Please enter new path: " ;

   }
   
   chomp( $inp= <STDIN> );
   if ($inp) {
      $octave_validated= 0;
      $octave= $inp;
   }
}

#
# Rewrite Octave.pm 
#
   print "\nFixing Octave.pm for octave path...\n" ;
   open(OCTAVE, "<Octave.pm") or die "Can't open Octave.pm for reading" ;
   my @lines = <OCTAVE> ;
   close(OCTAVE) ;

   open(OCTAVE, ">Octave.pm") or die "Can't open Octave.pm for writing" ;
   foreach my $line (@lines) {
      $line =~ s/(\$o->{ILSM}->{INTERP} = \")octave +-qf/$1$octave -qf/;
      print OCTAVE $line ;
   }
   close(OCTAVE) ;


WriteMakefile(
    'NAME'         => 'Inline::Octave',
    'VERSION_FROM' => 'Octave.pm',
    'PREREQ_PM'    => { Inline => 0.4 },
    'clean'        => {FILES => '_Inline_test/'},  
);
