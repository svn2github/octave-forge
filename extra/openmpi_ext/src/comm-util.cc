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
#define	STRFY(ARGNAM)  #ARGNAM

#define	STRNGFY(ARGNAME)  \
	STRFY  (ARGNAME)	// 2-level, as opposed to 1-level above


template <class T>
static MPI_Comm do_get (const octave_value&)
{
  error ("MPI handle type not supported.");
  return MPI_COMM_WORLD;
}



template <>
static MPI_Comm do_get<MPI_Comm> (const octave_value& val)
{
  if (val.is_string())
    {
      std::string Comm_Name = val.string_value();
      MPI_Comm tmp = MPI_COMM_WORLD;
      return tmp;
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
  return MPI_ERR_UNKNOWN;
}


template <>
static octave_value do_set<MPI_Comm> (MPI_Comm comm)
{
  return comm;
}



MPI_Comm set_mpi_comm (MPI_Comm comm)
{
  return do_set<MPI_Comm> (comm);
}
