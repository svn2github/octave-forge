use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

#
#   Find the octave interpreter
#

my $octave= "octave";
my $octave_validated= 0;

# check if interpreter was specified on cmd line
foreach (@ARGV) {
   if (/^OCTAVE=(.+)/) {
      $octave= $1;
      $octave_validated= 1;
      $_= "";
   }
}   

while (not $octave_validated) {
   $octave_validated= 1 if `$octave -v` =~ /Octave, version 2/;

   if ($octave_validated) {
      print "Found GNU Octave interpreter:[$octave]\n";
      print "Enter new path or <RETURN> to accept: ";
   } else {
      print "Unable to find GNU Octave interpreter at:[$octave]\n";
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
      $line =~ 
         s{($octave_interpreter_bin\s*=\s*)'.+?'(\s*#\s*_EDITLINE_MARKER_)}
          {$1\'$octave\'$2};
      print OCTAVE $line ;
   }
   close(OCTAVE) ;


WriteMakefile(
    'NAME'         => 'Inline::Octave',
    'VERSION_FROM' => 'Octave.pm',
    'PREREQ_PM'    => { Inline => 0.4 },
    'clean'        => {FILES => '_Inline/'},  
);
