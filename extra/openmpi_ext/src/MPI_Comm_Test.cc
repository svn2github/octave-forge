#include "simple.h"
DEFUN_DLD(MPI_Comm_Test, args, ,"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} @var{DESCRIPTION} = MPI_Comm_Test (@var{COMM})\n\
Return @var{DESCRIPTION} string description of the MPI_Communicator  @var{COMM}\n\
For\n\
example,\n\
\n\
@example\n\
@group\n\
MPI_Init();\n\
X = MPI_Comm_Load(\"description\"); \n\
whos X\n\
MPI_Comm_Test(X) \n\
@result{} \"description\"\n\
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
	if(args.length() != 1 
	   || args(0).type_id()!=simple::static_type_id()){
		
		error("usage: MPI_Comm_Test(octave_comunicator_object)");
		return octave_value(-1);
	}
	const octave_base_value& rep = args(0).get_rep();
	const simple& b = ((const simple &)rep);
        octave_stdout << "MPI_Comm_Test has " << b.name_value()  << " output arguments.\n";
       MPI_Comm res = b.comunicator_value();
       retval = b.name_value();
  return retval;
}