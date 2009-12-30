#include "simpleop.h"

DEFUN_DLD(MPI_Op_Load, args, ,"")
{
  if (!simpleop_type_loaded)
    {
      simpleop::register_type ();
      simpleop_type_loaded = true;
      mlock ();
    }

  octave_value retval;
  if (args.length () != 1 || !args (0).is_string ())
    {
      error ("simpleop: first argument must be a string");
      return retval;
    }
   
  const std::string name = args (0).string_value ();
  MPI_Op OP;
  retval = new simpleop (name,OP);
 
  return retval;
}