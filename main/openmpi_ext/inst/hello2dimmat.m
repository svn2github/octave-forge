## Copyright (C) 2009 Riccardo Corradini <riccardocorradini@yahoo.it>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

# Please add the oct files openmpi_ext folder 
# For instance 
  addpath("../src");
  MPI_SUCCESS =0;
  MPI_Init();

  # the string NEWORLD is just a label could be whatever you want    
  CW = MPI_Comm_Load("NEWORLD");
  my_rank = MPI_Comm_rank(CW);
  p = MPI_Comm_size(CW);
  mytag = 48;


 
  if (my_rank != 0)
#        Generate a random matrix
       message=rand(90,90);
#        load message
#       rankvect is the vector containing the list of rank  destination process
     rankvect = 0;
     [info] = MPI_Send(message,rankvect,mytag,CW);
  else
        for source = 1:p-1
          disp("We are at rank 0 that is master etc..");
          [messager, info] = MPI_Recv(source,mytag,CW);
          
#	You could also save each result and make comparisons if you don't trust MPI
          disp("Rank 0 is the master receiving ... :");
            if (info == MPI_SUCCESS)
              disp('OK!');
          endif
          endfor
  end   


   MPI_Finalize();
