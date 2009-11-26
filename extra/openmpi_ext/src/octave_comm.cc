#include <octave/oct.h>
#include <mpi.h>
class octave_comm: public octave_base_value
{
public:
  // Constructor
  octave_comm (MPI_Comm comm)
    : octave_base_value ()
    {
		objptr=MPI_COMM_WORLD;
		name=new string("MPI_COMM_WORLD");
    }
  octave_comm (MPI_Comm comm, _type)
    : octave_base_value ()
    {
		objptr=MPI_Comm_set_name(comm, const_cast<char*>(_type.c_str()));
		name = new string(_type)
    }

  void print (std::ostream& os, bool pr_as_read_syntax = false) const
    {
      os << name << std::endl;
    }
  bool is_defined (void) const { return true; }
  const std::string name;
  MPI_Comm objptr;
  
private:
  const std::string _type;
  DECLARE_OCTAVE_ALLOCATOR
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

DEFINE_OCTAVE_ALLOCATOR (octave_comm);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_comm, "octave_comm", "octave_comm");

static bool octave_comm_type_loaded = false;
static bool mpiname_load = false; 


DEFUN_DLD(octave_comm, args, ,"")
{
  if (!octave_comm_type_loaded)
    {
      octave_comm::register_type ();
      octave_comm_type_loaded = true;
      mlock ();
    }

  octave_value retval;
  if (args.length () != 1 || !args (0).is_string ())
    {
      error ("simple: first argument must be a string");
      return retval;
    }
   
  std::string myname = args (0).string_value ();
  int nitem = myname.length();
  OCTAVE_LOCAL_BUFFER(char,i8,nitem+1);
  strcpy(i8, myname.c_str());
//   MPI_Comm Inner_Comm;
//   MPI_Comm_set_name(Inner_Comm, const_cast<char*>(myname.c_str()));
  octave_value oct = new octave_comm(myname);
  const octave_base_value& rep = oct.get_rep();
  const octave_comm& b = ((const octave_comm &)rep);

  return retval;
}