// int MPI_Get_processor_name(char *name, int *resultlen);
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
#include "mpi.h"
#include <octave/oct.h>
DEFUN_DLD(MPI_Get_processor_name, args, nargout,"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} @var{name,resultlen,INFO} = MPI_Get_processor_name()\n\
           Get the name of the processor that is using MPI\n\
\n\
 @example\n\
 @group\n\
    @var{INFO} (int) return code\n\
       0 MPI_SUCCESS    No error\n\
      16 MPI_ERR_OTHER  Attempt was made to call MPI_Init a  second  time\n\
                       MPI_Init may only be called once in a program\n\
                       \n\
SEE ALSO: MPI_Finalize, MPI_Initialized, MPI_Finalized\n\
@end group\n\
@end example\n\
@end deftypefn")
{
    int info; 	
    int nargin = args.length();            
    for (int i=0; i<nargin; i++){
    if(  nargin != 0 ) {
        error("MPI_Get_processor_name: please do not enter arguments");
        return octave_value (MPI_ERR_ARG);    // error returns nothing
    }
    }
    octave_value_list results;	
    std::string cpp_string;
    char argv[MPI_MAX_PROCESSOR_NAME];
    int resultlen=0;

    info = MPI_Get_processor_name(argv, &resultlen);
    cpp_string = argv;	
    results(0) = cpp_string;
    results(1) = resultlen;
    results(2) = info;				
    return results;
}
 