#include "mpi.h"
#include <octave/oct.h>

class simpleop : public octave_base_value
{
public:
  // Constructor
  simpleop (const std::string _name = "", MPI_Op _Op_Value = MPI_OP_NULL )
    : octave_base_value (), name (_name), Op_Value(_Op_Value)
    {


    }
   void set ( MPI_Op _Op_Value) 
     {
	  if(_Op_Value == MPI_BAND)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_BOR)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_BXOR)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_LAND)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_LOR)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_LXOR)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_MAX)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_MIN)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_OP_NULL)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_PROD)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_REPLACE)  {Op_Value=_Op_Value;};
	  if(_Op_Value == MPI_SUM)  {Op_Value=_Op_Value;}
	  else {printf("This is not an MPI Operator!\n");Op_Value=MPI_OP_NULL;};
     }
  void print (std::ostream& os, bool pr_as_read_syntax = false) const
    {
      os << name << std::endl;
    }
   ~simpleop(void)
    {
      Op_Value = MPI_OP_NULL;
    }
  bool is_defined (void) const { return true; }
  MPI_Op operator_value (bool = false) const { return Op_Value; }
  const std::string name_value (bool = false) const { return name; }
private:
  const std::string name;
  MPI_Op Op_Value;
  DECLARE_OCTAVE_ALLOCATOR
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

DEFINE_OCTAVE_ALLOCATOR (simpleop);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (simpleop, "simpleop", "simpleop");

static bool simpleop_type_loaded = false;