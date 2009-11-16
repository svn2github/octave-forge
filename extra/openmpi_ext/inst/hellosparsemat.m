if not(MPI_Initialized)
   info = MPI_Init();
end

  [info my_rank] = MPI_Comm_rank();
  [info p ] = MPI_Comm_size();
# tag[0] ----> type of octave_value
# tag[1] ----> array of three elements 1) num of rows 2) number of columns 3) number of non zero elements
# tag[2] ---->  vector of rowindex
# tag[3] ---->  vector of columnindex
# tag[4] ---->  vector of  non zero elements
# These tags will be generated after mytag by the MPI_Send and MPI_Recv (see source code)

  mytag = 48;




# This is just to fill the sparse matrix
  M=5;
  N=5;
  D=0.9;
    message = sprand (M, N, D);
#  load message
 

 
  if (my_rank != 0)
      dest = 0;
#       rankvect is the vector containing the list of rank  destination process
     rankvect(1,1) = 0;
     [info] = MPI_Send(message,rankvect,mytag);
     disp("This is flag for sending the message --")
     info
  else
        for source = 1:p-1
          messager='';
          disp("We are at rank 0 that is master etc..");
          [info messager] = MPI_Recv(source,mytag);
          disp("Rank 0 is the master receiving ... :");
          if (messager/message)
                disp('OK!');
          endif
      messager
          endfor
  end   
