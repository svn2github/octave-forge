#include "simple.h"

DEFUN_DLD(MPI_Comm_Load, args, ,"-*- texinfo -*-\n\
@deftypefn {Built-in Function} {} @var{exprout} = MPI_Comm_Load (@var{exprin})\n\
Return @var{exprout} the MPI_Communicator object whose description is  @var{exprin}, as a string.\n\
The default value will be MPI_COMM_WORLD. \n\
If @var{exprin} is omitted, return anyway an MPI_COMM_WORLD comunicator object \n\
with no decription.\n\
For\n\
example,\n\
\n\
@example\n\
@group\n\
MPI_Init();\n\
X = MPI_Comm_Load(\"description\"); \n\
whos X\n\
MPI_Finalize();\n\
@end group\n\
@end example\n\
@end deftypefn")
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