/*

Copyright (C) 2009 VZLU Prague

This file is part of OctaveForge.

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

#include "comm-util.h"

template <class T>
static MPI_Comm do_get (const octave_value&)
{
  error ("MPI handle type not supported.");
  return MPI_COMM_WORLD;
}

// Specializations. Typically, MPI_Comm is 32-bit or 64-bit integer.
template <>
static MPI_Comm do_get<int32_t> (const octave_value& val)
{
  if (val.is_scalar_type () && val.is_int32_type ())
    {
      octave_int32 tmp = val.int32_scalar_value ();
      return tmp.value ();
    }
  else
    error ("MPI: not a valid communicator");
}

template <>
static MPI_Comm do_get<int64_t> (const octave_value& val)
{
  if (val.is_scalar_type () && val.is_int64_type ())
    {
      octave_int64 tmp = val.int64_scalar_value ();
      return tmp.value ();
    }
  else
    error ("MPI: not a valid communicator");
}

MPI_Comm get_mpi_comm (const octave_value& value)
{
  return do_get<MPI_Comm> (value);
}

template <class T>
static octave_value do_set (T)
{
  error ("MPI handle type not supported.");
  return octave_value ();
}

// Specializations. Typically, MPI_Comm is 32-bit or 64-bit integer.
// Provide more if needed.
template <>
static octave_value do_set<int32_t> (int32_t comm)
{
  return octave_int32 (comm);
}

template <>
static octave_value do_set<int64_t> (int64_t comm)
{
  return octave_int64 (comm);
}

octave_value set_mpi_comm (MPI_Comm comm)
{
  return do_set<MPI_Comm> (comm);
}
