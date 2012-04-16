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
# if you have 4 cores or a network of 4 computers with a ssh connection with no password and same openmpi 1.3.3 installation
# type at the terminal mpirun -np 4 octave --eval helloworld


   MPI_Init();
   # the string NEWORLD is just a label could be whatever you want 
   CW = MPI_Comm_Load("NEWORLD");

   

  my_rank = MPI_Comm_rank(CW);
  p = MPI_Comm_size(CW);
  # Could be any number
  TAG=1;


  message="";
  if (my_rank != 0)
      message = sprintf('Greetings from process: %d!',my_rank);
      # rankvect is the vector containing the list of rank  destination process
      rankvect = 0;
      [info] = MPI_Send(message,rankvect,TAG,CW);
  else
      for source = 1:p-1
          disp("We are at rank 0 that is master etc..");
          [message, info] = MPI_Recv(source,TAG,CW);
          printf('%s\n', message);
      endfor
  end   

  MPI_Finalize();

