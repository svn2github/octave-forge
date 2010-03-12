#include "simpleop.h"

DEFUN_DLD(MPI_Op_Test, args, ,"")
{
  if (!simpleop_type_loaded)
    {
      simpleop::register_type ();
      simpleop_type_loaded = true;
      mlock ();
    }

  octave_value retval;
	if(args.length() != 1 
	   || args(0).type_id()!=simpleop::static_type_id()){
		
		error("usage: simpleoptest(simpleopobject)");
		return octave_value(-1);
	}
	const octave_base_value& rep = args(0).get_rep();
	const simpleop& b = ((const simpleop &)rep);
        octave_stdout << "simpleoptest has " << b.name_value()  << " output arguments.\n";
       MPI_Op res = b.operator_value();
   
  return retval;
}