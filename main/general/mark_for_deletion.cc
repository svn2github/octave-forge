// mark_for_deletion - mark a file for deletion
// (C) 2002 Andy Adler
// Licensed under the GNU GPL. 
#include <octave/oct.h>
#include <octave/pt-plot.h>

DEFUN_DLD (mark_for_deletion, args,,
"mark_for_deletion ( filename1, filename2, ... );\n\
put filenames in the list of files to be deleted\n\
when octave terminates.\n\
This is useful for any function which uses temprorary files.")
{
  octave_value retval;
  for ( int i=0; i< args.length(); i++) {
    if( ! args(i).is_string() ) {
      error ("mark_for_deletion: arguments must be string filenames");
      return retval;
    } else {
      mark_for_deletion( args(i).string_value() );
    }
  }
  return retval;

}


