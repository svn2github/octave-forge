#include "simple.h"

DEFUN_DLD(MPI_Comm_Load, args, ,"")
{
  if (!simple_type_loaded)
    {
      simple::register_type ();
      simple_type_loaded = true;
      mlock ();
    }

  octave_value retval;
  if (args.length () != 1 || !args (0).is_string ())
    {
      error ("simple: first argument must be a string");
      return retval;
    }
   
  const std::string name = args (0).string_value ();
  retval = new simple (name,MPI_COMM_WORLD);
 
  return retval;
}