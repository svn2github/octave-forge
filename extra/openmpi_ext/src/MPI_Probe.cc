// Copyright (C) 2004-2007 Javier Fernández Baldomero, Mancia Anguita López
// This code has been adjusted for octave3.2.3 and more in 
// 2009 by  Riccardo Corradini <riccardocorradini@yahoo.it>

// under the terms of the GNU General Public License.
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



#define   NAME  MPI_Probe
/*
 * ----------------------------------------------------
 * Blocking test for a message
 * [info stat] = MPI_Probe (src, tag, comm)
 * ----------------------------------------------------
 */
#include "simple.h"
	
#include <octave/ov-struct.h>



Octave_map put_MPI_Stat (const MPI_Status &stat){
/*---------------------------------------------*/
    Octave_map map;
    octave_value tmp = stat.MPI_SOURCE;
    map.assign("src", tmp);
    tmp = stat.MPI_TAG;
    map.assign("tag", tmp );
    tmp = stat.MPI_ERROR;
    map.assign("err", tmp );
    tmp = stat._count;
    map.assign("cnt", tmp);
    tmp = stat._cancelled;
    map.assign("can", tmp);

    return map;
}


DEFUN_DLD(NAME, args, nargout,
"MPI_Probe              Blocking test for a message\n\
\n\
  [stat info] = MPI_Probe (src, tag, comm)\n\
\n\
  src  (int) expected source rank, or MPI_ANY_SOURCE\n\
  tag  (int) expected tag value or MPI_ANY_TAG\n\
  comm (int) communicator (handle)\n\
\n\
  stat(struc)status object\n\
       src (int)       source rank for the accepted message\n\
       tag (int)       message tag for the accepted message\n\
       err(int)        error \n\
       cnt (int)       count\n\
       can (int)       cancel\n\
\n\
  info (int)return code\n\
      0 MPI_SUCCESS    No error\n\
      5 MPI_ERR_COMM   Invalid communicator (null?)\n\
      4 MPI_ERR_TAG    Invalid tag argument (MPI_ANY_TAG, 0..MPI_TAG_UB attr)\n\
      6 MPI_ERR_RANK   Invalid src/dst rank (MPI_ANY_SOURCE, 0..Comm_size-1)\n\
\n\
  SEE ALSO: MPI_Iprobe, MPI_Recv, MPI_Irecv\n\
            cancel\n\
\n\
")

{
   octave_value_list results;
   int nargin = args.length ();
   if (nargin != 3)
     {
       error ("expecting  3 input arguments");
       return results;
     }






  if (!simple_type_loaded)
    {
      simple::register_type ();
      simple_type_loaded = true;
      mlock ();
    }

	if( args(2).type_id()!=simple::static_type_id()){
		
		error("Please enter octave comunicator object!");
		return octave_value(-1);
	}

	const octave_base_value& rep = args(2).get_rep();
        const simple& B = ((const simple &)rep);
        MPI_Comm comm = ((const simple&) B).comunicator_value ();
    int src = args(0).int_value();    
  if (error_state)
    {
      error ("expecting first argument to be an integer");
      return results;
    }

    int tag = args(1).int_value();    
  if (error_state)
    {
      error ("expecting second argument to be an integer");
      return results;
    }
    MPI_Status stat = {0,0,0,0};
    int info = MPI_Probe(src,tag,comm,&stat);
    
    results(0) = put_MPI_Stat(stat);
    results(1) = info;
    return results;
	/* [ stat info ] = MPI_Probe (src, tag, comm) */
}




