#include "mpi.h"
#include <octave/oct.h>

class simple : public octave_base_value
{
public:
  // Constructor
  simple (const std::string _name = "", MPI_Comm _Comm_Value = MPI_COMM_WORLD )
    : octave_base_value (), name (_name), Comm_Value(_Comm_Value)
    {
    }

  void print (std::ostream& os, bool pr_as_read_syntax = false) const
    {
      os << name << std::endl;
    }
   ~simple(void)
    {
      Comm_Value = NULL;
    }
  bool is_defined (void) const { return true; }
  MPI_Comm comunicator_value (bool = false) const { return Comm_Value; }
  const std::string name_value (bool = false) const { return name; }
private:
  const std::string name;
  MPI_Comm Comm_Value;
  DECLARE_OCTAVE_ALLOCATOR
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

DEFINE_OCTAVE_ALLOCATOR (simple);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (simple, "simple", "simple");

static bool simple_type_loaded = false;