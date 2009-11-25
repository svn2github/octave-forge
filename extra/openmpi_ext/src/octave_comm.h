// Copyright (C) 2009 Riccardo Corradini <riccardocorradini@yahoo.it>
// under the terms of the GNU General Public License.
// Copyright (C) 2009 VZLU Prague
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; If not, see <http://www.gnu.org/licenses/>.

#include <mpi.h>
#include <octave/oct.h>
class octave_comm : public octave_base_value
{
public:

  octave_comm (const std::string _name = "" )
    : octave_base_value (), name (_name)
    {
    }

  void print (std::ostream& os, bool pr_as_read_syntax = false) const
    {
      os << name << std::endl;
    }
  bool is_defined (void) const { return true; }
  
  const std::string name;
  MPI_Comm comm;
private:
  
  DECLARE_OCTAVE_ALLOCATOR
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

DEFINE_OCTAVE_ALLOCATOR (octave_comm);
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_comm, "octave_comm", "octave_comm");

static bool octave_comm_type_loaded = false;